enum TransactionType { expense, income, transfer }

class FinancialTransaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String walletId;
  final String? toWalletId; // Digunakan jika tipe transaksi adalah transfer
  final DateTime date;
  final String? notes;

  const FinancialTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.walletId,
    this.toWalletId,
    required this.date,
    this.notes,
  });

  FinancialTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? walletId,
    String? toWalletId,
    DateTime? date,
    String? notes,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      toWalletId: toWalletId ?? this.toWalletId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'type': type.name,
    'categoryId': categoryId,
    'walletId': walletId,
    'toWalletId': toWalletId,
    'date': date.toIso8601String(),
    'notes': notes,
  };

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) => FinancialTransaction(
    id: json['id'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    type: TransactionType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => TransactionType.expense,
    ),
    categoryId: json['categoryId'] as String? ?? 'cat_other_exp',
    walletId: json['walletId'] as String,
    toWalletId: json['toWalletId'] as String?,
    date: DateTime.parse(json['date'] as String),
    notes: json['notes'] as String?,
  );
}
