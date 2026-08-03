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
      // 1 Crore = 10,000,000 — always show 2 decimals, e.g. "1.00 Crore"
      final double crore = price / 10000000;
      return "PKR ${crore.toStringAsFixed(2)} Crore";
    } else if (price >= 100000) {
      // 1 Lakh = 100,000 — always show 2 decimals, e.g. "1.00 Lac"
      final double lakh = price / 100000;
      return "PKR ${lakh.toStringAsFixed(2)} Lac";
    } else {
      // Fallback for smaller listings — add thousand separators, e.g. "50,000"
      return "PKR ${_addThousandSeparators(price.toStringAsFixed(0))}";
    }
  }

  /// Inserts commas as thousand separators into a plain digit string.
  /// e.g. "50000" -> "50,000", "1234567" -> "1,234,567"
  static String _addThousandSeparators(String digits) {
    final buffer = StringBuffer();
    final reversed = digits.split('').reversed.toList();

    for (int i = 0; i < reversed.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(',');
      buffer.write(reversed[i]);
    }

    return buffer.toString().split('').reversed.join();
  }
}
