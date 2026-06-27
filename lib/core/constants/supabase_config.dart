/// Configuration centralisée de Supabase pour ParkSmart
/// 
/// Ces variables sont définies via --dart-define lors de la compilation
/// Exemple: flutter build apk \
///   --dart-define=SUPABASE_URL=https://... \
///   --dart-define=SUPABASE_ANON_KEY=...

class SupabaseConfig {
  // URLs et clés Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://knzoqcvlxmgsxgooizuk.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtuem9xY3ZseG1nc3hnb29penVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTQwNTcsImV4cCI6MjA5NTkzMDA1N30.wttuOVO3mACoWdhtbJ9pklOwn1J0EwzPVWfjMPmfYnY',
  );

  // Validation
  static bool isConfigured() {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('example.supabase.co');
  }

  // Messages d'erreur
  static String getConfigError() {
    if (supabaseUrl.isEmpty) {
      return 'SUPABASE_URL est vide';
    }
    if (supabaseAnonKey.isEmpty) {
      return 'SUPABASE_ANON_KEY est vide';
    }
    if (supabaseUrl.contains('example.supabase.co')) {
      return 'SUPABASE_URL n\'est pas configurée correctement';
    }
    return 'Configuration Supabase inconnue';
  }

  // Informations pour le debugging
  static String getDebugInfo() {
    return 'URL: ${supabaseUrl.replaceRange(20, null, '...')}\n'
        'Key: ${supabaseAnonKey.replaceRange(10, null, '...')}';
  }
}
