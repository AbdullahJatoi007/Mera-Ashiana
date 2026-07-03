class CurrencyFormatter {
  /// Formats raw dynamic prices from the API to Pakistani notation (Crore / Lakh)
  /// Matches the exact style of the Mera Ashiana website.
  static String formatPakistaniPrice(dynamic priceInput) {
    if (priceInput == null) return "PKR 0";

    // 1. Convert dynamic API input safely into a clean number
    num price = 0;
    if (priceInput is num) {
      price = priceInput;
    } else if (priceInput is String) {
      price = num.tryParse(priceInput.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    }

    // 2. Format exactly like the website (e.g., PKR 4.15 Crore)
    if (price >= 10000000) {
      // 1 Crore = 10,000,000
      double crore = price / 10000000;
      String formatted = crore.toStringAsFixed(crore == crore.toInt() ? 0 : 2);
      return "PKR $formatted Crore";
    } else if (price >= 100000) {
      // 1 Lakh = 100,000
      double lakh = price / 100000;
      String formatted = lakh.toStringAsFixed(lakh == lakh.toInt() ? 0 : 2);
      return "PKR $formatted Lac";
    } else {
      // Fallback for smaller listings
      return "PKR ${price.toStringAsFixed(0)}";
    }
  }
}
