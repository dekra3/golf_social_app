/// Supabase credentials, injected at build/run time via --dart-define, e.g.:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
///
/// Keeping these out of source keeps the key out of version control
/// (it's safe to ship in a built app, but still shouldn't sit in a public
/// repo). Uses the publishable key (sb_publishable_...), Supabase's current
/// replacement for the legacy anon key — same low-privilege role, same RLS
/// behavior, just the format going forward as anon keys are phased out.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
}