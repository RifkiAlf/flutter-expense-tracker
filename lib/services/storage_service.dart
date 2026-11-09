import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/goal.dart';

class StorageService {
  static const String _keyTransactions = 'money_transactions_v1';
  static const String _keyCategories = 'money_categories_v1';
  static const String _keyWallets = 'money_wallets_v1';
  static const String _keyBudgets = 'money_budgets_v1';
  static const String _keyGoals = 'money_goals_v1';
  static const String _keyThemeMode = 'money_theme_mode_v1';
  static const String _keyHideBalance = 'money_hide_balance_v1';
  static const String _keyInitialized = 'money_initialized_v1';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isFirstRun => !(_prefs.getBool(_keyInitialized) ?? false);

  Future<void> markInitialized() async {
    await _prefs.setBool(_keyInitialized, true);
  }

  // --- Transactions ---
  List<FinancialTransaction> loadTransactions() {
    final raw = _prefs.getString(_keyTransactions);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => FinancialTransaction.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTransactions(List<FinancialTransaction> transactions) async {
    final encoded = jsonEncode(transactions.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyTransactions, encoded);
  }

  // --- Categories ---
  List<ExpenseCategory> loadCategories() {
    final raw = _prefs.getString(_keyCategories);
    if (raw == null || raw.isEmpty) return ExpenseCategory.defaultCategories;
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => ExpenseCategory.fromJson(e)).toList();
    } catch (_) {
      return ExpenseCategory.defaultCategories;
    }
  }

  Future<void> saveCategories(List<ExpenseCategory> categories) async {
    final encoded = jsonEncode(categories.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyCategories, encoded);
  }

  // --- Wallets ---
  List<Wallet> loadWallets() {
    final raw = _prefs.getString(_keyWallets);
    if (raw == null || raw.isEmpty) return Wallet.defaultWallets;
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => Wallet.fromJson(e)).toList();
    } catch (_) {
      return Wallet.defaultWallets;
    }
  }

  Future<void> saveWallets(List<Wallet> wallets) async {
    final encoded = jsonEncode(wallets.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyWallets, encoded);
  }

  // --- Budgets ---
  List<Budget> loadBudgets() {
    final raw = _prefs.getString(_keyBudgets);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => Budget.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBudgets(List<Budget> budgets) async {
    final encoded = jsonEncode(budgets.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyBudgets, encoded);
  }

  // --- Goals ---
  List<FinancialGoal> loadGoals() {
    final raw = _prefs.getString(_keyGoals);
    if (raw == null || raw.isEmpty) return FinancialGoal.defaultGoals;
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => FinancialGoal.fromJson(e)).toList();
    } catch (_) {
      return FinancialGoal.defaultGoals;
    }
  }

  Future<void> saveGoals(List<FinancialGoal> goals) async {
    final encoded = jsonEncode(goals.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyGoals, encoded);
  }

  // --- Settings ---
  bool loadDarkMode() => _prefs.getBool(_keyThemeMode) ?? false;
  Future<void> saveDarkMode(bool value) async => await _prefs.setBool(_keyThemeMode, value);

  bool loadHideBalance() => _prefs.getBool(_keyHideBalance) ?? false;
  Future<void> saveHideBalance(bool value) async => await _prefs.setBool(_keyHideBalance, value);

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
