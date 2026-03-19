class Money {
  static String formatRupeesFromCents(int cents) {
    final rupees = (cents / 100).round();
    return '₹$rupees';
  }
}

