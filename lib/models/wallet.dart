import 'package:flutter/material.dart';
import '../utils/app_icons.dart';

enum WalletType { cash, bank, ewallet, savings, other }

class Wallet {
  final String id;
  final String name;
  final WalletType type;
  final double balance;
  final int iconCodePoint;
  final int colorValue;
  final String? accountNumber;

  const Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.iconCodePoint,
    required this.colorValue,
    this.accountNumber,
  });

  IconData get icon => AppIcons.getIcon(iconCodePoint);
  Color get color => Color(colorValue);

  Wallet copyWith({
    String? id,
    String? name,
    WalletType? type,
    double? balance,
    int? iconCodePoint,
    int? colorValue,
    String? accountNumber,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'balance': balance,
    'iconCodePoint': iconCodePoint,
    'colorValue': colorValue,
    'accountNumber': accountNumber,
  };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'] as String,
    name: json['name'] as String,
    type: WalletType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => WalletType.cash,
    ),
    balance: (json['balance'] as num).toDouble(),
    iconCodePoint: json['iconCodePoint'] as int,
    colorValue: json['colorValue'] as int,
    accountNumber: json['accountNumber'] as String?,
  );

  static List<Wallet> get defaultWallets => [
    Wallet(
      id: 'wallet_cash',
      name: 'Uang Tunai (Cash)',
      type: WalletType.cash,
      balance: 0.0,
      iconCodePoint: Icons.payments.codePoint,
      colorValue: 0xFF10B981, // Emerald Green
    ),
    Wallet(
      id: 'wallet_bank',
      name: 'Rekening Bank',
      type: WalletType.bank,
      balance: 0.0,
      iconCodePoint: Icons.account_balance.codePoint,
      colorValue: 0xFF2563EB, // Royal Blue
    ),
    Wallet(
      id: 'wallet_ewallet',
      name: 'E-Wallet',
      type: WalletType.ewallet,
      balance: 0.0,
      iconCodePoint: Icons.account_balance_wallet.codePoint,
      colorValue: 0xFF8B5CF6, // Purple / Indigo
    ),
  ];
}
