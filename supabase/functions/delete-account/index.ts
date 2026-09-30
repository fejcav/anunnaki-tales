// Supabase Edge Function: delete-account
// Anunnaki Tales — eliminación de cuenta desde la app (requisito de Apple, guideline 5.1.1(v)).
//
// Qué hace: identifica al usuario por el JWT de su sesión y lo borra de Supabase Auth.
// Todo lo demás se borra en cascada por las foreign keys:
//   auth.users → profiles → game_sessions → turns
//                         → purchases
//                         → user_achievements
//
// Cómo se llama desde FlutterFlow (Custom Action deleteUserAccount):
//   await SupaFlow.client.functions.invoke('delete-account');
//
// "Verify JWT" debe quedar ACTIVADO en la configuración de la función.
// Las suscripciones de Google Play / App Store NO se cancelan desde acá:
// el usuario las cancela en la tienda (la app se lo avisa antes de confirmar).

import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "Missing authorization" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // 1. Identificar al usuario a partir de SU sesión (nunca de un id que mande el cliente).
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser();
  const user = userData?.user;
  if (userError || !user) {
    return json({ error: "Invalid session" }, 401);
  }

  // 2. Borrar el usuario con permisos de servicio. La cascada limpia el resto.
  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { error: deleteError } = await admin.auth.admin.deleteUser(user.id);
  if (deleteError) {
    console.error("delete-account failed", user.id, deleteError.message);
    return json({ error: "Could not delete account" }, 500);
  }

  console.log("delete-account ok", user.id);
  return json({ deleted: true });
});
