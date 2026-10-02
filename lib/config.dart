// Datos fijos de conexión. Son públicos por diseño: la seguridad de Supabase
// la dan las reglas RLS del servidor, no esta clave.
class AppConfig {
  AppConfig._();

  static const supabaseUrl = 'https://wtkohxujhvaxoablfevz.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0a29oeHVqaHZheG9hYmxmZXZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzOTg0NjQsImV4cCI6MjA4Nzk3NDQ2NH0.Ga3SgxGPxGk5Y5FWbYSRJ_MkKy5P3XO-dW5N-MIl8T0';

  // Clave pública de RevenueCat para Android (proyecto 72d974c7). La de iOS
  // (appl_...) llega en la iteración 13.
  static const revenueCatAndroidKey = 'goog_wuNZVNSPtgKsYMSKIlYjfnXuyQz';

  // Política de privacidad (GitHub Pages, repo fejcav/anunnaki-tales-legal).
  static const privacyPolicyUrl =
      'https://fejcav.github.io/anunnaki-tales-legal/privacy_policy.html';
}
