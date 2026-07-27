/// Google Sign-In configuration for the mobile app.
///
/// Only the **Web Application** OAuth client ID belongs here — that is what
/// `serverClientId` needs, and it is the `aud` the backend verifies against
/// `GOOGLE_CLIENT_ID`. The **Android** OAuth client (package name + SHA-1)
/// lives in Google Cloud only and is never referenced from code.
///
/// A Google client ID is not a secret. This is the only place to edit it.
class GoogleAuthConfig {
  GoogleAuthConfig._();

  static const String webClientId =
      '1036155739982-12eubri97salh87u90mvju47au7rl0u8.apps.googleusercontent.com';
}
