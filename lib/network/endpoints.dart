class Endpoints {
  static const String _base = "https://api-staging.mera-ashiana.com";
  static const String apiBase = "$_base/api";

  // AUTH
  static const String login = "$apiBase/login";
  static const String register = "$apiBase/register";
  static const String googleLogin = "$apiBase/google-login";

  // PROFILE
  static const String profile = "$apiBase/profile";
  static const String updateProfile = "$apiBase/profile/update";

  // PROPERTIES
  static const String properties = "$apiBase/properties";
  static const String myFavorites = "$apiBase/my-likes";

  static String likeProperty(int id) => "$apiBase/properties/$id/like";

  static String unlikeProperty(int id) => "$apiBase/properties/$id/unlike";

  // LISTINGS
  static const String createListing = "$apiBase/listings";
  static const String myListings = "$apiBase/my-listings";

  static String deleteListing(int id) => "$apiBase/listings/$id";

  // AGENCY
  static const String agencyBase = "$apiBase/agency";
  static const String myAgency = "$agencyBase/my-agency";
  static const String registerAgency = "$agencyBase/register";

  // BLOGS
  static const String blogBase = "$_base/admin/blogs";
  static const String allBlogs = blogBase;

  static String blogById(int id) => "$blogBase/$id";
}
