// Límite diario de elecciones gratis (ver "Límite diario" en CLAUDE.md).
// El contador se guarda en el teléfono como `dailyChoicesUsed` + el día de la
// última elección (`lastChoiceDay`, yyyy-MM-dd local). Si ese día no es hoy,
// el contador vale 0: así se reinicia a medianoche sin hacer nada.

const dailyFreeChoices = 3;

// El día local de `now` como yyyy-MM-dd.
String dayKey(DateTime now) {
  final local = now.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

// Cuántas elecciones gratis se usaron hoy.
int choicesUsedToday({
  required int used,
  required String? lastDay,
  required DateTime now,
}) {
  return lastDay == dayKey(now) ? used : 0;
}

// Cuántas elecciones gratis quedan hoy (nunca menos de 0).
int choicesLeftToday({
  required int used,
  required String? lastDay,
  required DateTime now,
}) {
  final left = dailyFreeChoices - choicesUsedToday(used: used, lastDay: lastDay, now: now);
  return left < 0 ? 0 : left;
}

// Si se puede elegir una opción ahora. Premium no tiene límite.
bool canChoose({
  required bool isPremium,
  required int used,
  required String? lastDay,
  required DateTime now,
}) {
  return isPremium || choicesLeftToday(used: used, lastDay: lastDay, now: now) > 0;
}

// El contador después de una elección que la IA respondió bien. Se llama
// solo en ese caso: si la llamada falla, no se descuenta nada.
({int used, String day}) recordChoice({
  required int used,
  required String? lastDay,
  required DateTime now,
}) {
  return (
    used: choicesUsedToday(used: used, lastDay: lastDay, now: now) + 1,
    day: dayKey(now),
  );
}
