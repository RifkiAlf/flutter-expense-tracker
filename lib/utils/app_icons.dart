import 'package:flutter/material.dart';

class AppIcons {
  static const Map<int, IconData> _registeredIcons = {
    0xe532: Icons.restaurant,
    0xe1d7: Icons.directions_car,
    0xe59c: Icons.shopping_cart,
    0xf2eb: Icons.receipt_long,
    0xe5e8: Icons.sports_esports,
    0xe3b1: Icons.local_hospital,
    0xe559: Icons.school,
    0xf0288: Icons.volunteer_activism,
    0xe148: Icons.category,
    0xf0540: Icons.payments,
    0xe138: Icons.card_giftcard,
    0xe5f9: Icons.storefront,
    0xe655: Icons.trending_up,
    0xe041: Icons.account_balance_wallet,
    0xe4a2: Icons.phone_android,
    0xe040: Icons.account_balance,
    0xf34a: Icons.shield,
    0xe29b: Icons.flight_takeoff,
    0xe378: Icons.laptop_mac,
    0xf0125: Icons.savings,
    0xe406: Icons.more_horiz,
    0xe5cf: Icons.swap_horiz,
  };

  static final Map<int, IconData> _runtimeCache = {
    Icons.restaurant.codePoint: Icons.restaurant,
    Icons.directions_car.codePoint: Icons.directions_car,
    Icons.shopping_cart.codePoint: Icons.shopping_cart,
    Icons.receipt_long.codePoint: Icons.receipt_long,
    Icons.sports_esports.codePoint: Icons.sports_esports,
    Icons.local_hospital.codePoint: Icons.local_hospital,
    Icons.school.codePoint: Icons.school,
    Icons.volunteer_activism.codePoint: Icons.volunteer_activism,
    Icons.category.codePoint: Icons.category,
    Icons.payments.codePoint: Icons.payments,
    Icons.card_giftcard.codePoint: Icons.card_giftcard,
    Icons.storefront.codePoint: Icons.storefront,
    Icons.trending_up.codePoint: Icons.trending_up,
    Icons.account_balance_wallet.codePoint: Icons.account_balance_wallet,
    Icons.phone_android.codePoint: Icons.phone_android,
    Icons.account_balance.codePoint: Icons.account_balance,
    Icons.shield.codePoint: Icons.shield,
    Icons.flight_takeoff.codePoint: Icons.flight_takeoff,
    Icons.laptop_mac.codePoint: Icons.laptop_mac,
    Icons.savings.codePoint: Icons.savings,
    Icons.more_horiz.codePoint: Icons.more_horiz,
    Icons.swap_horiz.codePoint: Icons.swap_horiz,
  };

  static IconData getIcon(int codePoint) {
    return _runtimeCache[codePoint] ??
        _registeredIcons[codePoint] ??
        Icons.category;
  }
}
