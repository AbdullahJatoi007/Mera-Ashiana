class Endpoints {
  static const String _base = "https://api-staging.mera-ashiana.com";
  static const String apiBase = "$_base/api";

  // ───────── AUTH (MOBILE — tokens returned in JSON body) ─────────
  static const String sendOtp =
      "$apiBase/auth/mobile/identity/register/send-otp";

  static const String register =
      "$apiBase/auth/mobile/identity/register";

  static const String login =
      "$apiBase/auth/mobile/identity/login";

  static const String googleAuth =
      "$apiBase/auth/mobile/identity/google";

  static const String logout =
      "$apiBase/auth/mobile/session/logout";

  static const String refreshToken =
      "$apiBase/auth/mobile/session/refresh";

  // ───────── PROFILE ─────────
  static const String profile = "$apiBase/auth/profile";
  static const String updateProfile = "$apiBase/auth/profile/update";

  // ───────── LISTINGS ─────────
  static const String listings = "$apiBase/listings";
  static const String myListings = "$apiBase/listings/me";

  static String listing(int id) => "$apiBase/listings/$id";
  static String deleteListing(int id) => "$apiBase/listings/$id";

  static String likeListing(int id) =>
      "$apiBase/listings/$id/like";

  // ───────── AGENCY ─────────
  static const String agency = "$apiBase/agencies";
  static const String myAgency = "$apiBase/agencies/me";

  // ───────── BLOGS ─────────
  static const String blogs = "$apiBase/blogs";
  static String blog(int id) => "$apiBase/blogs/$id";
}