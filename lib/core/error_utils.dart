import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Converts a caught error into a short, user-facing message. Use this
/// instead of interpolating a raw exception into UI text — exceptions
/// from Supabase/http/sockets aren't written for end users to read.
String friendlyErrorMessage(Object error) {
  // Auth/database/storage errors from Supabase already carry a
  // reasonably readable message (e.g. "Invalid login credentials").
  if (error is AuthException) return error.message;
  if (error is PostgrestException) return error.message;
  if (error is StorageException) return error.message;

  if (error is SocketException || error is TimeoutException) {
    return 'No internet connection. Check your network and try again.';
  }

  // Fallback: sniff the error's string form for common network-failure
  // signatures across platforms (mobile SocketException text, web fetch
  // errors, DNS failures) that don't come through as a typed exception —
  // this also covers Flutter web, where dart:io's SocketException isn't
  // the type actually thrown.
  final text = error.toString().toLowerCase();
  const networkSignatures = [
    'failed host lookup',
    'network is unreachable',
    'connection refused',
    'connection closed',
    'connection reset',
    'failed to fetch',
    'xmlhttprequest',
    'err_internet_disconnected',
    'err_name_not_resolved',
    'socketexception',
    'clientexception',
  ];
  if (networkSignatures.any(text.contains)) {
    return 'Could not reach the server. Check your internet connection and try again.';
  }

  return 'Something went wrong. Please try again.';
}