import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientSingleton {
  static final SupabaseClientSingleton _instance =
      SupabaseClientSingleton._internal();

  factory SupabaseClientSingleton() => _instance;

  SupabaseClientSingleton._internal();

  SupabaseClient get client => Supabase.instance.client;
}

