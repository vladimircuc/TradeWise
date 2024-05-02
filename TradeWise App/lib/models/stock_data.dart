class StockData {
  double open;
  double high;
  double low;
  double close;
  int volume;
  double dividends;
  double stockSplits;

  StockData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.dividends,
    required this.stockSplits,
  });

  factory StockData.fromJson(Map<String, dynamic> json) => StockData(
        open: json['Open'].toDouble(),
        high: json['High'].toDouble(),
        low: json['Low'].toDouble(),
        close: json['Close'].toDouble(),
        volume: json['Volume'].toInt(),
        dividends: json['Dividends'].toDouble(),
        stockSplits: json['Stock Splits'].toDouble(),
      );
}
