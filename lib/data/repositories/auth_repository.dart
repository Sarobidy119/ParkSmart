import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';

class AuthRepository {
  final SupabaseClientSingleton _supabase = SupabaseClientSingleton();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final client = _supabase.client;
    final normalizedEmail = email.trim().toLowerCase();

    final res = await client.auth.signInWithPassword(
      email: normalizedEmail,
      password: password,
    );

    if (res.user == null) {
      throw AuthException(res);
    }
  }

  Future<void> signUp({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    final client = _supabase.client;
    final normalizedEmail = email.trim().toLowerCase();

    final res = await client.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
      },
    );

    if (res.user == null) {
      throw AuthException(res);
    }

    final userId = res.user!.id;

    await client
        .from('utilisateur')
        .upsert({
          'id': userId,
          'nom': nom,
          'prenom': prenom,
          'email': normalizedEmail,
          'telephone': telephone,
        })
        .select()
        .maybeSingle();
  }

  Future<void> signOut() async {
    final client = _supabase.client;
    await client.auth.signOut();
  }

  User? getCurrentUser() {
    final client = _supabase.client;
    return client.auth.currentUser;
  }
}

class AuthException implements Exception {
  final dynamic source;
  AuthException(this.source);

  @override
  String toString() => source.toString();
}

class AuthMessageException implements Exception {
  final String message;

  const AuthMessageException(this.message);

  @override
  String toString() => message;
}

String formatAuthError(Object error) {
  final source = error is AuthException ? error.source : error;
  final message = source.toString();

  if (message.contains('Failed host lookup') ||
      message.contains('SocketException')) {
    return 'Connexion Supabase impossible. Verifiez que le telephone a Internet, que SUPABASE_URL est exactement https://knzoqcvlxmgsxgooizuk.supabase.co, puis recompilez et reinstallez l APK.';
  }

  if (message.contains('ClientException')) {
    return 'Connexion Supabase impossible. Verifiez Internet sur le telephone et reinstallez le dernier APK compile avec les vraies cles Supabase.';
  }

  if (source is AuthApiException || error is AuthException) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already registered')) {
      return 'Cet email est deja utilise. Connectez-vous ou utilisez un autre email.';
    }
    if (lower.contains('password')) {
      return 'Le mot de passe est invalide ou trop faible.';
    }
    if (lower.contains('invalid email') ||
        lower.contains('email address is invalid') ||
        lower.contains('unable to validate email address')) {
      return 'Adresse email invalide. Utilisez une adresse complete, par exemple nom@gmail.com.';
    }
    if (lower.contains('email not confirmed') ||
        lower.contains('email confirmation')) {
      return 'Email non confirme. Verifiez votre boite mail ou desactivez la confirmation email dans Supabase pour les tests.';
    }
  }

  if (error is PostgrestException) {
    final lower = error.message.toLowerCase();
    
    // Erreur de contrainte unique (email déjà existant)
    if (lower.contains('duplicate') || 
        lower.contains('unique constraint') ||
        lower.contains('violates unique constraint')) {
      if (lower.contains('email')) {
        return 'Cet email est deja utilise. Connectez-vous ou utilisez un autre email.';
      }
      if (lower.contains('telephone')) {
        return 'Ce numero de telephone est deja utilise. Utilisez un autre numero.';
      }
      return 'Cette information est deja enregistree. Veuillez utiliser d autres donnees.';
    }
    
    if (lower.contains('relation') ||
        lower.contains('does not exist')) {
      return 'La table Supabase est manquante. Executez le script SQL fourni dans supabase_schema.sql.';
    }
    if (lower.contains('row-level security') ||
        lower.contains('violates row-level security')) {
      return 'Supabase bloque l action avec RLS. Verifiez les policies SQL de la table utilisateur.';
    }
    return 'Erreur base de donnees Supabase: ${error.message}';
  }

  return message.replaceFirst('Exception: ', '');
}
