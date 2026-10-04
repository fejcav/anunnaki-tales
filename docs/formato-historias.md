# Formato de las historias de Anunnaki Tales

Versión 1 · 2 de octubre de 2026. Cada aventura es un archivo JSON en `assets/data/stories/<adventureId>.json`, escrito una sola vez (con Claude, en el proyecto de claude.ai) y revisado por Federico antes de entrar a la app. La app solo lee estos archivos: no hay servidor ni IA en vivo.

## Estructura

```json
{
  "formatVersion": 1,
  "adventureId": "gilgamesh_enkidu",
  "contentVersion": "0.1",
  "hero": {
    "name": { "es": "Gilgamesh", "en": "Gilgamesh" },
    "description": { "es": "…", "en": "…" }
  },
  "chapters": [
    { "number": 1, "title": { "es": "El rey sin rival", "en": "…" } }
  ],
  "start": "c1_uruk",
  "scenes": [
    {
      "id": "c1_uruk",
      "chapter": 1,
      "mood": "epic",
      "text": { "es": "Párrafo uno.\n\nPárrafo dos.", "en": "…" },
      "fact": { "es": "Dato histórico real.", "en": "…" },
      "choices": [
        {
          "to": "c1_shamhat",
          "risk": "low",
          "text": { "es": "Enviar a Shamhat a la estepa", "en": "…" },
          "description": { "es": "Una oración que explica la opción.", "en": "…" }
        }
      ]
    },
    {
      "id": "fin_polvo",
      "chapter": 8,
      "mood": "tragic",
      "ending": { "type": "myth", "title": { "es": "La casa del polvo", "en": "…" } },
      "text": { "es": "…", "en": "…" },
      "fact": { "es": "…", "en": "…" },
      "choices": []
    }
  ]
}
```

## Campos

| Campo | Qué es |
|-------|--------|
| `formatVersion` | Siempre `1` por ahora. Si el formato cambia, sube y la app avisa. |
| `adventureId` | Igual al `id` / `myth_id` del catálogo (`gilgamesh_enkidu`, `descent_inanna`, …). |
| `contentVersion` | Versión del texto, para saber qué revisó Federico. No la usa la app. |
| `hero` | El protagonista fijo de la aventura (ya no se elige héroe): nombre y descripción corta para la pantalla de presentación. |
| `chapters` | Títulos de los capítulos (opcional). La app puede mostrar "Capítulo N · Título" arriba de la escena. |
| `start` | Id de la primera escena. |
| `scenes[].id` | Único en el archivo; minúsculas, números y `_`. Por convención `c<capítulo>_<nombre>` y los finales `fin_<nombre>`. |
| `scenes[].chapter` | Número de capítulo. Nunca baja al avanzar por una opción. |
| `scenes[].mood` | `epic`, `mysterious`, `dangerous`, `peaceful`, `sacred`, `tragic` o `triumphant` (los mismos de antes). |
| `scenes[].text` | El texto de la escena en segunda persona y presente. Los párrafos se separan con una línea en blanco (`\n\n`). |
| `scenes[].fact` | Opcional. "Dato histórico": 1 o 2 oraciones **verificables**, sin inventar. |
| `scenes[].choices` | De 1 a 3 opciones. Vacío solo en los finales. |
| `choices[].to` | Id de la escena a la que lleva. |
| `choices[].risk` | `low`, `medium` o `high`. Obligatorio cuando hay 2 o 3 opciones; en una escena con una sola opción ("continuar") se omite y el botón va sin etiqueta de riesgo. |
| `choices[].text` | Máximo 8 palabras. |
| `choices[].description` | Una oración. |
| `scenes[].ending` | Solo en los finales: `type` (`myth` = el final del mito original, `alternative` = otro final posible y no trágico, `tragic` = final trágico) y `title`. |

Todos los textos son `{ "es": "…", "en": "…" }`. Si falta el inglés (texto vacío), la app muestra el español: así se puede probar una historia antes de traducirla. Para el release, las dos lenguas tienen que estar completas.

## Reglas que verifica el test (`test/story_validation_test.dart`)

1. `start` existe y todos los `to` apuntan a escenas que existen.
2. Todas las escenas se alcanzan desde `start` y no hay ciclos (siempre se avanza).
3. Cada escena que no es final tiene de 1 a 3 opciones; cada final tiene `ending` y 0 opciones. Todo camino termina en un final.
4. El capítulo nunca baja al pasar por una opción.
5. `mood`, `risk` y `ending.type` tienen valores válidos; con 2 o 3 opciones, todas tienen `risk`.
6. Ningún texto en español está vacío. Texto de escena: entre 40 y 190 palabras. Opción: máximo 8 palabras. Dato histórico: máximo 50 palabras.
7. Español neutro (tú): ninguna forma de voseo (`tenés`, `podés`, `sos`, `querés`…) ni de vosotros (`lucháis`, `tenéis`…).
8. Para el release (modo estricto): ningún texto en inglés vacío.

## Pautas de escritura

- Segunda persona, presente, español neutro (tú). Tono de bardo antiguo pero claro; frases cortas para leer en el celular.
- Escenas "nudo" de 100 a 150 palabras; escenas de consecuencia de 60 a 110; finales de 100 a 160.
- Las ramas se separan y se vuelven a juntar en un nudo por capítulo. Por eso el texto de un nudo no puede dar por hecho algo que solo pasó en una de las ramas que llegan a él.
- Unas 15 a 18 escenas por partida y de 4 a 6 finales por aventura: uno es el final del mito original y los otros son "¿qué hubiera pasado si…?" creíbles dentro del mito.
- El riesgo tiene que ser honesto: las opciones `high` a veces llevan a un final trágico; las `low` nunca.
- Fiel a las fuentes (poemas sumerios y babilónicos). Lo que se inventa para las ramas alternativas no contradice el mundo del mito. Nada explícito: público 13+.
- Los datos históricos se escriben solo si son ciertos; ante la duda, se omiten.
