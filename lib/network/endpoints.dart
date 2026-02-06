class Endpoints {
  // ================= BASES =================
  static const apiBase = "https://api-staging.mera-ashiana.com/api";
  static const blogBase = "https://api-staging.mera-ashiana.com/admin/blogs";

  // ================= AUTH =================
  static const login = "$apiBase/login";
  static const register = "$apiBase/register";
  static const googleLogin = "$apiBase/google-login";

  // ================= PROFILE =================
  static const profile = "$apiBase/profile";
  static const updateProfile = "$apiBase/profile/update";

  // ================= PROPERTIES =================
  static const properties = "$apiBase/properties";
  static const myFavorites = "$apiBase/my-likes";

  static String likeProperty(int id) => "$apiBase/properties/$id/like";
  static String unlikeProperty(int id) => "$apiBase/properties/$id/unlike";

  // ================= LISTINGS =================
  static const createListing = "$apiBase/listings";
  static const myListings = "$apiBase/my-listings";
  static String deleteListing(int id) => "$apiBase/listings/$id";

  // ================= AGENCY =================
  static const agencyBase = "$apiBase/agency";
  static const myAgency = "$agencyBase/my-agency";
  static const registerAgency = "$agencyBase/register";

  // ================= BLOGS =================
  static const allBlogs = blogBase;
  static String blogById(int id) => "$blogBase/$id";
}
