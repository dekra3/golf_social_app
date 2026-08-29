/// Supabase credentials, injected at build/run time via --dart-define, e.g.:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_PUBLISHABLE_KEY=your-anon-key
///
/// Keeping these out of source keeps the anon key out of version control
/// (it's safe to ship in a built app, but still shouldn't sit in a public repo).
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qirnrolcdscqhbrzeknj.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_iaRTVW1eTi0ponX-fb2P1w_fiJzkDqQ',
  );
}
