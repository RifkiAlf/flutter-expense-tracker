import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format angka ke Rupiah standar: Rp 1.500.000
  static String format(double amount, {bool showSymbol = true}) {
    final formatted = _currencyFormat.format(amount.abs());
    final result = showSymbol ? formatted : formatted.replaceAll('Rp ', '');
    return amount < 0 ? '-$result' : result;
  }

  /// Format angka ringkas: Rp 1,5 Jt / Rp 500 rb
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      final inMillions = amount / 1000000;
      return 'Rp ${inMillions.toStringAsFixed(inMillions % 1 == 0 ? 0 : 1)} Jt';
    } else if (amount >= 1000) {
      final inThousands = amount / 1000;
      return 'Rp ${inThousands.toStringAsFixed(inThousands % 1 == 0 ? 0 : 0)} Rb';
    }
    return format(amount);
  }

  /// Parse string input ke double
  static double parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
