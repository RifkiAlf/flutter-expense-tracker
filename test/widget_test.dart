import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money/services/storage_service.dart';
import 'package:money/providers/expense_provider.dart';
import 'package:money/models/category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ExpenseProvider initializes with default categories and wallets', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();
    final provider = ExpenseProvider(storage);

    expect(provider.categories.isNotEmpty, true);
    expect(provider.wallets.isNotEmpty, true);
    expect(provider.categories.any((c) => c.type == CategoryType.expense), true);
    expect(provider.categories.any((c) => c.type == CategoryType.income), true);
  });
}
