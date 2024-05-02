class Trans {
  final String code;
  final double dollarAmount;
  final double stockAmount;
  final double priceBought;
  final bool open;
  final double profit;
  final String ID;

  Trans({
    required this.code,
    required this.dollarAmount,
    required this.priceBought,
    required this.stockAmount,
    required this.open,
    required this.profit,
    required this.ID,
  });
}
