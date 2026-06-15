class Endpoints {
  static const String _base = "https://api.mera-ashiana.com";
  static const String apiBase = "$_base/api";

  // ✨ Add this for images/static files
  static String get baseUrl => _base;

  // ───────── AUTH (MOBILE — tokens returned in JSON body) ─────────
  static const String sendOtp =
      "$apiBase/auth/mobile/identity/register/send-otp";

  static const String register = "$apiBase/auth/mobile/identity/register";

  static const String login = "$apiBase/auth/mobile/identity/login";

  static const String googleAuth = "$apiBase/auth/mobile/identity/google";

  static const String logout = "$apiBase/auth/mobile/session/logout";

  static const String refreshToken = "$apiBase/auth/mobile/session/refresh";

  // ───────── FORGOT PASSWORD (lives on the WEB identity router) ─────────
  // ⚠️ These routes are NOT under /mobile/identity. Set _webIdentityBase to
  // wherever the web identity router is mounted. Defaulting to /auth/identity;
  // the commented line is the other likely option. A wrong base → 404.
  static const String _webIdentityBase = "$apiBase/auth/identity";
  // static const String _webIdentityBase = "$apiBase/auth/web/identity";

  static const String forgotPasswordSendOtp =
      "$_webIdentityBase/forgot-password/send-otp"; // body: { email }
  static const String forgotPasswordReset =
      "$_webIdentityBase/forgot-password/reset"; // body: { email, otp, password }

  // ───────── PROFILE ─────────
  static const String profile = "$apiBase/auth/profile";

  // static const String updateProfile = "$apiBase/auth/profile/update";
  static const String updateProfile = "$apiBase/auth/profile";

  // DELETE ACCOUNT (same endpoint, different method)
  static const String deleteAccount = "$apiBase/auth/profile";

  // Under ───────── PROFILE ─────────
  static const String sendEmailOtp = "$apiBase/auth/profile/email/send-otp";
  static const String verifyEmailChange = "$apiBase/auth/profile/email/verify";

  // ───────── LISTINGS ─────────
  static const String listings = "$apiBase/listings";
  static const String myListings = "$apiBase/listings/me";

  static String listing(int id) => "$apiBase/listings/$id";

  static String deleteListing(int id) => "$apiBase/listings/$id";

  static String likeListing(int id) => "$apiBase/listings/$id/like";

  // ───────── AGENCY ─────────
  static const String agency = "$apiBase/agencies";
  static const String myAgency = "$apiBase/agencies/me";

  // ───────── BLOGS ─────────
  static const String blogs = "$apiBase/blogs";

  static String blog(int id) => "$apiBase/blogs/$id";
}