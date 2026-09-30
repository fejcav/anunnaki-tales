import "https://deno.land/x/xhr@0.3.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const SYSTEM_PROMPT = `You are the Narrator of Anunnaki Tales, an interactive storytelling game set in ancient Mesopotamian mythology. You create immersive, branching narratives where the player makes meaningful choices that shape the story.

## Your Role
You are a master storyteller channeling the voice of an ancient Sumerian bard. Your tone is epic yet accessible — think of a wise elder telling tales by firelight. You balance mythological accuracy with engaging gameplay.

## Core Rules

### Narrative Structure
- Each response is ONE story segment (150-250 words max — concise for mobile reading)
- End EVERY segment with exactly 3 choices for the playerh
- Choices must be meaningfully different (not just cosmetic variations)
- At least one choice should be risky/bold, one cautious, and one creative/unexpected

### Output Format (STRICT JSON)
Always respond in this exact JSON format:
{
  "narrative": "The story text the player reads. Use vivid sensory details. Second person ('you').",
  "scene_mood": "one of: epic, mysterious, dangerous, peaceful, sacred, tragic, triumphant",
  "choices": [
    {
      "id": 1,
      "text": "Short choice label (max 8 words)",
      "description": "One sentence expanding what this choice means",
      "risk_level": "low|medium|high"
    },
    {
      "id": 2,
      "text": "...",
      "description": "...",
      "risk_level": "low|medium|high"
    },
    {
      "id": 3,
      "text": "...",
      "description": "...",
      "risk_level": "low|medium|high"
    }
  ]
}

### Language
- Always respond in the SAME language the player uses
- If language parameter is "es", respond entirely in Spanish
- If language parameter is "en", respond entirely in English

### Myths Available
- gilgamesh_enkidu: The Epic of Gilgamesh — friendship, mortality, and the quest for eternal life
- inanna_underworld: Inanna's Descent to the Underworld — death, rebirth, and sacrifice
- enki_creation: Enki and the Creation of Humanity — wisdom, creation, and divine purpose
- marduk_tiamat: Marduk vs Tiamat — cosmic battle, chaos vs order
- etana_eagle: Etana and the Eagle — ambition, trust, and the quest for the plant of birth
- nergal_ereshkigal: Nergal and Ereshkigal — forbidden love between the god of war and the queen of the dead
- adapa_immortality: The Myth of Adapa — wisdom vs immortality, the mortal who refused eternal life
- anzu_tablets: The Myth of Anzu — the stolen Tablets of Destiny, cosmic chaos and heroic quest
- lugalbanda_anzu: Lugalbanda and the Anzu Bird — survival, kindness, and supernatural gifts
- sargon_akkad: Legend of Sargon of Akkad — from abandoned baby to founder of the first empire`;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function getSupabaseClient() {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
}

// Build multi-turn messages from history for better context
function buildMessages(history: any[], newUserMessage: string) {
  const messages: any[] = [];

  // Add history as alternating user/assistant turns (last 6 turns max)
  const recentHistory = history.slice(-6);
  for (const entry of recentHistory) {
    if (entry.userMessage) {
      messages.push({ role: "user", content: entry.userMessage });
    }
    if (entry.assistantResponse) {
      messages.push({ role: "assistant", content: JSON.stringify(entry.assistantResponse) });
    }
  }

  // Add the new user message
  messages.push({ role: "user", content: newUserMessage });
  return messages;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const {
      action,
      session_id,
      myth_id,
      player_name,
      difficulty,
      language,
      choice_id,
      user_id,
      history, // kept for backward compatibility
    } = await req.json();

    if (!action) {
      return new Response(
        JSON.stringify({ error: "Missing required field: action" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!ANTHROPIC_API_KEY) {
      return new Response(
        JSON.stringify({ error: "ANTHROPIC_API_KEY not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = getSupabaseClient();
    let userMessage = "";
    let sessionHistory: any[] = [];
    let currentSessionId = session_id;
    const lang = language || "es";
    const diff = difficulty || "normal";
    // Parse choice_id as integer (FlutterFlow sends it as string)
    const parsedChoiceId = choice_id ? parseInt(choice_id, 10) || 1 : null;

    // ======== START ACTION ========
    if (action === "start") {
      userMessage = `Start a new adventure for player "${player_name || "Viajero"}".
Myth: ${myth_id || "gilgamesh_enkidu"}
Difficulty: ${diff}
Language: ${lang}

Begin the story with an atmospheric opening that sets the scene and draws the player in. Introduce the mythological setting and the player's role.`;

    // ======== CONTINUE ACTION ========
    } else if (action === "continue") {
      if (!session_id) {
        return new Response(
          JSON.stringify({ error: "Missing session_id for continue action" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Load session from database
      const { data: session, error: sessionError } = await supabase
        .from("game_sessions")
        .select("*")
        .eq("id", session_id)
        .single();

      if (sessionError || !session) {
        return new Response(
          JSON.stringify({ error: "Session not found", details: sessionError?.message }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      sessionHistory = session.history || [];

      // Find the chosen option text from current_choices
      const cid = parsedChoiceId || 1;
      const chosenOption = (session.current_choices || []).find(
        (c: any) => c.id === cid
      );
      const choiceText = chosenOption ? chosenOption.text : `Option ${cid}`;

      userMessage = `The player chose: "${choiceText}" (option ${cid}).
Language: ${session.language || lang}
Difficulty: ${session.difficulty || diff}

Continue the story based on this choice. Advance the plot meaningfully and present new challenges.`;

    // ======== LOAD ACTION (resume existing session) ========
    } else if (action === "load") {
      if (!session_id) {
        return new Response(
          JSON.stringify({ error: "Missing session_id for load action" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const { data: session, error } = await supabase
        .from("game_sessions")
        .select("*")
        .eq("id", session_id)
        .single();

      if (error || !session) {
        return new Response(
          JSON.stringify({ error: "Session not found" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      return new Response(
        JSON.stringify({
          session_id: session.id,
          narrative: session.current_narrative,
          scene_mood: session.current_mood,
          choices: session.current_choices,
          turn_count: session.turn_count,
          myth_id: session.myth_id,
          status: session.status,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );

    } else {
      return new Response(
        JSON.stringify({ error: `Unknown action: ${action}. Use "start", "continue", or "load".` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ======== CALL CLAUDE API ========
    const messages = sessionHistory.length > 0
      ? buildMessages(sessionHistory, userMessage)
      : [{ role: "user", content: userMessage }];

    const response = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-haiku-4-5-20251001",
        max_tokens: 1024,
        system: SYSTEM_PROMPT,
        messages,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("Anthropic API error:", response.status, errorText);
      return new Response(
        JSON.stringify({
          error: "AI service error",
          details: `Status ${response.status}`,
          narrative: "Error al conectar con el narrador. Por favor intenta de nuevo.",
        }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const aiResponse = await response.json();
    const assistantMessage = aiResponse.content[0].text;

    // ======== PARSE RESPONSE ========
    let parsedNarrative;
    try {
      const jsonMatch = assistantMessage.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        parsedNarrative = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error("No JSON found in response");
      }
    } catch (parseError) {
      console.error("JSON parse error:", parseError);
      parsedNarrative = {
        narrative: assistantMessage,
        scene_mood: "mysterious",
        choices: [
          { id: 1, text: "Continuar", description: "Seguir adelante", risk_level: "low" },
          { id: 2, text: "Explorar", description: "Buscar otra opción", risk_level: "medium" },
          { id: 3, text: "Arriesgar todo", description: "Tomar un camino peligroso", risk_level: "high" },
        ],
      };
    }

    // ======== SAVE TO DATABASE ========
    // Build updated history
    const newHistoryEntry = {
      userMessage,
      assistantResponse: parsedNarrative,
      choice_id: parsedChoiceId || null,
      timestamp: new Date().toISOString(),
    };
    const updatedHistory = [...sessionHistory, newHistoryEntry];

    if (action === "start" && user_id) {
      // Create new session
      const { data: newSession, error: insertError } = await supabase
        .from("game_sessions")
        .insert({
          user_id,
          myth_id: myth_id || "gilgamesh_enkidu",
          difficulty: diff,
          language: lang,
          current_narrative: parsedNarrative.narrative,
          current_choices: parsedNarrative.choices,
          current_mood: parsedNarrative.scene_mood,
          history: updatedHistory,
          turn_count: 1,
          status: "active",
        })
        .select("id")
        .single();

      if (!insertError && newSession) {
        currentSessionId = newSession.id;
      } else {
        console.error("Failed to save session:", insertError);
      }
    } else if (action === "continue" && session_id) {
      // Update existing session
      const { error: updateError } = await supabase
        .from("game_sessions")
        .update({
          current_narrative: parsedNarrative.narrative,
          current_choices: parsedNarrative.choices,
          current_mood: parsedNarrative.scene_mood,
          history: updatedHistory,
          turn_count: updatedHistory.length,
        })
        .eq("id", session_id);

      if (updateError) {
        console.error("Failed to update session:", updateError);
      }
    }

    // ======== RETURN RESPONSE ========
    return new Response(
      JSON.stringify({
        ...parsedNarrative,
        session_id: currentSessionId || null,
        turn_count: updatedHistory.length,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Function error:", error);
    return new Response(
      JSON.stringify({
        error: error.message,
        narrative: "Ha ocurrido un error inesperado. Por favor intenta de nuevo.",
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
