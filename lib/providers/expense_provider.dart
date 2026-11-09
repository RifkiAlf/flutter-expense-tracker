import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';

class ExpenseProvider with ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();

  List<FinancialTransaction> _transactions = [];
  List<ExpenseCategory> _categories = [];
  List<Wallet> _wallets = [];
  List<Budget> _budgets = [];
  List<FinancialGoal> _goals = [];
  bool _hideBalance = false;
  bool _isLoading = true;

  ExpenseProvider(this._storage) {
    _init();
  }

  bool get isLoading => _isLoading;
  bool get hideBalance => _hideBalance;
  List<FinancialTransaction> get transactions => List.unmodifiable(_transactions);
  List<ExpenseCategory> get categories => List.unmodifiable(_categories);
  List<Wallet> get wallets => List.unmodifiable(_wallets);
  List<Budget> get budgets => List.unmodifiable(_budgets);
  List<FinancialGoal> get goals => List.unmodifiable(_goals);

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _categories = _storage.loadCategories();
    _wallets = _storage.loadWallets();
    _budgets = _storage.loadBudgets();
    _goals = _storage.loadGoals();
    _transactions = _storage.loadTransactions();
    _hideBalance = _storage.loadHideBalance();

    // Hapus data dummy agar pengguna bisa langsung mencoba CRUD dari nol
    final hasDemoData = _transactions.any((t) => t.id.startsWith('demo_')) ||
        _goals.any((g) => g.id.startsWith('goal_')) ||
        _budgets.any((b) => b.id.startsWith('b'));
    if (hasDemoData) {
      _transactions.removeWhere((t) => t.id.startsWith('demo_'));
      _goals.removeWhere((g) => g.id.startsWith('goal_'));
      _budgets.removeWhere((b) => b.id.startsWith('b'));
      _wallets = Wallet.defaultWallets;
      await _storage.saveTransactions(_transactions);
      await _storage.saveGoals(_goals);
      await _storage.saveBudgets(_budgets);
      await _storage.saveWallets(_wallets);
    }

    if (_storage.isFirstRun) {
      await _storage.markInitialized();
    }

    // Pastikan dompet E-Wallet otomatis tersedia jika belum ada di database lokal
    if (!_wallets.any((w) => w.type == WalletType.ewallet || w.id == 'wallet_ewallet')) {
      _wallets.add(
        Wallet(
          id: 'wallet_ewallet',
          name: 'E-Wallet',
          type: WalletType.ewallet,
          balance: 0.0,
          iconCodePoint: Icons.account_balance_wallet.codePoint,
          colorValue: 0xFF8B5CF6,
        ),
      );
      await _storage.saveWallets(_wallets);
    }

    _sortTransactions();
    _isLoading = false;
    notifyListeners();
  }

  void _sortTransactions() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  // --- Getters & Computed Metrics ---
  double get totalBalance {
    return _wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
  }

  ExpenseCategory? getCategoryById(String id) {
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].id == id) return _categories[i];
    }
    return ExpenseCategory(
      id: id,
      name: 'Kategori Lain',
      iconCodePoint: Icons.category.codePoint,
      colorValue: 0xFF9E9E9E,
      type: CategoryType.expense,
    );
  }

  Wallet? getWalletById(String id) {
    for (int i = 0; i < _wallets.length; i++) {
      if (_wallets[i].id == id) return _wallets[i];
    }
    return null;
  }

  List<FinancialTransaction> getRecentTransactions({int limit = 5}) {
    return _transactions.take(limit).toList();
  }

  double getCurrentMonthExpense({DateTime? referenceDate}) {
    final ref = referenceDate ?? DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == ref.year &&
            t.date.month == ref.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getCurrentMonthIncome({DateTime? referenceDate}) {
    final ref = referenceDate ?? DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.year == ref.year &&
            t.date.month == ref.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getCurrentMonthCashflow({DateTime? referenceDate}) {
    return getCurrentMonthIncome(referenceDate: referenceDate) -
        getCurrentMonthExpense(referenceDate: referenceDate);
  }

  double getSpentForCategory(String categoryId, {int? month, int? year}) {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.categoryId == categoryId &&
            t.date.month == targetMonth &&
            t.date.year == targetYear)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Budget? getBudgetForCategory(String categoryId, {int? month, int? year}) {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    try {
      return _budgets.firstWhere(
        (b) => b.categoryId == categoryId && b.month == targetMonth && b.year == targetYear,
      );
    } catch (_) {
      return null;
    }
  }

  Map<ExpenseCategory, double> getExpensesGroupedByCategory({int? month, int? year}) {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    final Map<ExpenseCategory, double> map = {};
    for (final tx in _transactions) {
      if (tx.type == TransactionType.expense &&
          tx.date.month == targetMonth &&
          tx.date.year == targetYear) {
        final category = getCategoryById(tx.categoryId) ??
            ExpenseCategory(
              id: tx.categoryId,
              name: 'Lainnya',
              iconCodePoint: Icons.more_horiz.codePoint,
              colorValue: 0xFF78909C,
              type: CategoryType.expense,
            );
        map[category] = (map[category] ?? 0.0) + tx.amount;
      }
    }
    return map;
  }

  // --- Transactions Actions ---
  Future<void> addTransaction(FinancialTransaction transaction) async {
    _transactions.add(transaction);
    _applyBalanceChange(transaction);
    _sortTransactions();
    await _storage.saveTransactions(_transactions);
    await _storage.saveWallets(_wallets);
    notifyListeners();
  }

  Future<void> updateTransaction(
    FinancialTransaction oldTransaction,
    FinancialTransaction newTransaction,
  ) async {
    _revertBalanceChange(oldTransaction);
    final index = _transactions.indexWhere((t) => t.id == oldTransaction.id);
    if (index != -1) {
      _transactions[index] = newTransaction;
    }
    _applyBalanceChange(newTransaction);
    _sortTransactions();
    await _storage.saveTransactions(_transactions);
    await _storage.saveWallets(_wallets);
    notifyListeners();
  }

  Future<void> deleteTransaction(FinancialTransaction transaction) async {
    _revertBalanceChange(transaction);
    _transactions.removeWhere((t) => t.id == transaction.id);
    await _storage.saveTransactions(_transactions);
    await _storage.saveWallets(_wallets);
    notifyListeners();
  }

  void _applyBalanceChange(FinancialTransaction tx) {
    final walletIdx = _wallets.indexWhere((w) => w.id == tx.walletId);
    if (walletIdx != -1) {
      final w = _wallets[walletIdx];
      if (tx.type == TransactionType.expense) {
        _wallets[walletIdx] = w.copyWith(balance: w.balance - tx.amount);
      } else if (tx.type == TransactionType.income) {
        _wallets[walletIdx] = w.copyWith(balance: w.balance + tx.amount);
      } else if (tx.type == TransactionType.transfer) {
        _wallets[walletIdx] = w.copyWith(balance: w.balance - tx.amount);
        if (tx.toWalletId != null) {
          final toIdx = _wallets.indexWhere((target) => target.id == tx.toWalletId);
          if (toIdx != -1) {
            final toW = _wallets[toIdx];
            _wallets[toIdx] = toW.copyWith(balance: toW.balance + tx.amount);
          }
        }
      }
    }
  }

  void _revertBalanceChange(FinancialTransaction tx) {
    final walletIdx = _wallets.indexWhere((w) => w.id == tx.walletId);
    if (walletIdx != -1) {
      final w = _wallets[walletIdx];
      if (tx.type == TransactionType.expense) {
        _wallets[walletIdx] = w.copyWith(balance: w.balance + tx.amount);
      } else if (tx.type == TransactionType.income) {
        _wallets[walletIdx] = w.copyWith(balance: w.balance - tx.amount);
      } else if (tx.type == TransactionType.transfer) {
        _wallets[walletIdx] = w.copyWith(balance: w.balance + tx.amount);
        if (tx.toWalletId != null) {
          final toIdx = _wallets.indexWhere((target) => target.id == tx.toWalletId);
          if (toIdx != -1) {
            final toW = _wallets[toIdx];
            _wallets[toIdx] = toW.copyWith(balance: toW.balance - tx.amount);
          }
        }
      }
    }
  }

  // --- Wallet Actions ---
  Future<void> addWallet(Wallet wallet) async {
    _wallets.add(wallet);
    await _storage.saveWallets(_wallets);
    notifyListeners();
  }

  Future<void> updateWallet(Wallet wallet) async {
    final index = _wallets.indexWhere((w) => w.id == wallet.id);
    if (index != -1) {
      _wallets[index] = wallet;
      await _storage.saveWallets(_wallets);
      notifyListeners();
    }
  }

  Future<void> deleteWallet(String walletId) async {
    if (_wallets.length <= 1) return; // Sisakan minimal 1 dompet
    _wallets.removeWhere((w) => w.id == walletId);
    await _storage.saveWallets(_wallets);
    notifyListeners();
  }

  // --- Budget Actions ---
  Future<void> setBudget({
    required String categoryId,
    required double monthlyLimit,
    required int month,
    required int year,
  }) async {
    final existingIndex = _budgets.indexWhere(
      (b) => b.categoryId == categoryId && b.month == month && b.year == year,
    );

    if (existingIndex != -1) {
      _budgets[existingIndex] = _budgets[existingIndex].copyWith(monthlyLimit: monthlyLimit);
    } else {
      _budgets.add(Budget(
        id: _uuid.v4(),
        categoryId: categoryId,
        monthlyLimit: monthlyLimit,
        month: month,
        year: year,
      ));
    }
    await _storage.saveBudgets(_budgets);
    notifyListeners();
  }

  Future<void> deleteBudget(String budgetId) async {
    _budgets.removeWhere((b) => b.id == budgetId);
    await _storage.saveBudgets(_budgets);
    notifyListeners();
  }

  // --- Goal Actions ---
  Future<void> addGoal(FinancialGoal goal) async {
    _goals.add(goal);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> updateGoal(FinancialGoal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      await _storage.saveGoals(_goals);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> contributeToGoal({
    required String goalId,
    required double amount,
    required String walletId,
  }) async {
    final goalIdx = _goals.indexWhere((g) => g.id == goalId);
    if (goalIdx == -1) return;

    final goal = _goals[goalIdx];
    final updatedGoal = goal.copyWith(currentAmount: goal.currentAmount + amount);
    _goals[goalIdx] = updatedGoal;

    // Catat juga transaksi pengeluaran tabungan
    final tx = FinancialTransaction(
      id: _uuid.v4(),
      title: 'Tabungan: ${goal.title}',
      amount: amount,
      type: TransactionType.expense,
      categoryId: 'cat_investment',
      walletId: walletId,
      date: DateTime.now(),
      notes: 'Alokasi dana ke target tabungan',
    );
    await addTransaction(tx);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  // --- Category Actions ---
  Future<void> addCategory(ExpenseCategory category) async {
    _categories.add(category);
    await _storage.saveCategories(_categories);
    notifyListeners();
  }

  // --- Visibility & Privacy ---
  void toggleHideBalance() {
    _hideBalance = !_hideBalance;
    _storage.saveHideBalance(_hideBalance);
    notifyListeners();
  }

  // --- Export JSON ---
  String exportDataAsJson() {
    final data = {
      'exported_at': DateTime.now().toIso8601String(),
      'transactions': _transactions.map((t) => t.toJson()).toList(),
      'wallets': _wallets.map((w) => w.toJson()).toList(),
      'budgets': _budgets.map((b) => b.toJson()).toList(),
      'goals': _goals.map((g) => g.toJson()).toList(),
      'categories': _categories.map((c) => c.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // --- Import JSON ---
  Future<ImportResult> importDataFromJson(String jsonString) async {
    if (jsonString.trim().isEmpty) {
      return const ImportResult(
        success: false,
        message: 'Teks JSON tidak boleh kosong.',
      );
    }

    try {
      final dynamic decoded = jsonDecode(jsonString.trim());
      if (decoded is! Map) {
        return const ImportResult(
          success: false,
          message: 'Format data JSON tidak valid (harus berupa objek/map).',
        );
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

      final hasRelevantKey = data.containsKey('transactions') ||
          data.containsKey('wallets') ||
          data.containsKey('budgets') ||
          data.containsKey('goals') ||
          data.containsKey('categories');

      if (!hasRelevantKey) {
        return const ImportResult(
          success: false,
          message: 'Format JSON tidak cocok. Tidak ditemukan data transaksi, dompet, atau target.',
        );
      }

      int importedTxs = _transactions.length;
      int importedWallets = _wallets.length;
      int importedBudgets = _budgets.length;
      int importedGoals = _goals.length;

      // 1. Categories
      if (data.containsKey('categories') && data['categories'] is List) {
        final rawCats = data['categories'] as List;
        final List<ExpenseCategory> parsedCats = [];
        for (final item in rawCats) {
          if (item is Map) {
            parsedCats.add(ExpenseCategory.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        if (parsedCats.isNotEmpty) {
          _categories = parsedCats;
          await _storage.saveCategories(_categories);
        }
      }

      // 2. Wallets
      if (data.containsKey('wallets') && data['wallets'] is List) {
        final rawWallets = data['wallets'] as List;
        final List<Wallet> parsedWallets = [];
        for (final item in rawWallets) {
          if (item is Map) {
            parsedWallets.add(Wallet.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        if (parsedWallets.isNotEmpty) {
          _wallets = parsedWallets;
          await _storage.saveWallets(_wallets);
          importedWallets = _wallets.length;
        }
      }

      // 3. Budgets
      if (data.containsKey('budgets') && data['budgets'] is List) {
        final rawBudgets = data['budgets'] as List;
        final List<Budget> parsedBudgets = [];
        for (final item in rawBudgets) {
          if (item is Map) {
            parsedBudgets.add(Budget.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        _budgets = parsedBudgets;
        await _storage.saveBudgets(_budgets);
        importedBudgets = _budgets.length;
      }

      // 4. Goals
      if (data.containsKey('goals') && data['goals'] is List) {
        final rawGoals = data['goals'] as List;
        final List<FinancialGoal> parsedGoals = [];
        for (final item in rawGoals) {
          if (item is Map) {
            parsedGoals.add(FinancialGoal.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        _goals = parsedGoals;
        await _storage.saveGoals(_goals);
        importedGoals = _goals.length;
      }

      // 5. Transactions
      if (data.containsKey('transactions') && data['transactions'] is List) {
        final rawTxs = data['transactions'] as List;
        final List<FinancialTransaction> parsedTxs = [];
        for (final item in rawTxs) {
          if (item is Map) {
            parsedTxs.add(FinancialTransaction.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        _transactions = parsedTxs;
        await _storage.saveTransactions(_transactions);
        importedTxs = _transactions.length;
      }

      notifyListeners();

      return ImportResult(
        success: true,
        message: 'Berhasil memulihkan $importedTxs transaksi & $importedWallets dompet.',
        txCount: importedTxs,
        walletCount: importedWallets,
        budgetCount: importedBudgets,
        goalCount: importedGoals,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Gagal memproses data JSON: ${e.toString()}',
      );
    }
  }

  // --- Reset All Data ---
  Future<void> resetAllData() async {
    _transactions.clear();
    _budgets.clear();
    _wallets = Wallet.defaultWallets;
    _categories = ExpenseCategory.defaultCategories;
    _goals = FinancialGoal.defaultGoals;
    await _storage.saveTransactions(_transactions);
    await _storage.saveWallets(_wallets);
    await _storage.saveBudgets(_budgets);
    await _storage.saveCategories(_categories);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  // --- Load Rich Demo Data ---
  Future<void> loadDemoData({bool isFirstRunInit = false}) async {
    _wallets = Wallet.defaultWallets;
    _categories = ExpenseCategory.defaultCategories;
    _goals = FinancialGoal.defaultGoals;

    final now = DateTime.now();

    // Default budgets untuk bulan ini
    _budgets = [
      Budget(
        id: 'b1',
        categoryId: 'cat_food',
        monthlyLimit: 2500000,
        month: now.month,
        year: now.year,
      ),
      Budget(
        id: 'b2',
        categoryId: 'cat_transport',
        monthlyLimit: 1000000,
        month: now.month,
        year: now.year,
      ),
      Budget(
        id: 'b3',
        categoryId: 'cat_groceries',
        monthlyLimit: 1800000,
        month: now.month,
        year: now.year,
      ),
      Budget(
        id: 'b4',
        categoryId: 'cat_bills',
        monthlyLimit: 1200000,
        month: now.month,
        year: now.year,
      ),
    ];

    // Riwayat transaksi beberapa hari terakhir
    _transactions = [
      FinancialTransaction(
        id: 'demo_1',
        title: 'Gaji Pokok Oktober',
        amount: 8500000,
        type: TransactionType.income,
        categoryId: 'cat_salary',
        walletId: 'wallet_bca',
        date: DateTime(now.year, now.month, 1, 9, 30),
        notes: 'Gaji bulanan kantor',
      ),
      FinancialTransaction(
        id: 'demo_2',
        title: 'Tarik Tunai ATM',
        amount: 500000,
        type: TransactionType.transfer,
        categoryId: 'cat_other_exp',
        walletId: 'wallet_bca',
        toWalletId: 'wallet_cash',
        date: DateTime(now.year, now.month, 2, 14, 0),
        notes: 'Persiapan uang cash saku',
      ),
      FinancialTransaction(
        id: 'demo_3',
        title: 'Makan Siang & Kopi',
        amount: 65000,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        walletId: 'wallet_cash',
        date: DateTime(now.year, now.month, now.day, 12, 15),
        notes: 'Nasi padang & es kopi susu',
      ),
      FinancialTransaction(
        id: 'demo_4',
        title: 'Belanja Mingguan Supermarket',
        amount: 420000,
        type: TransactionType.expense,
        categoryId: 'cat_groceries',
        walletId: 'wallet_bca',
        date: DateTime(now.year, now.month, (now.day - 1).clamp(1, 28), 16, 45),
        notes: 'Bahan masakan, susu, sabun',
      ),
      FinancialTransaction(
        id: 'demo_5',
        title: 'Bensin & Tol',
        amount: 250000,
        type: TransactionType.expense,
        categoryId: 'cat_transport',
        walletId: 'wallet_mandiri',
        date: DateTime(now.year, now.month, (now.day - 2).clamp(1, 28), 8, 20),
        notes: 'Isi BBM Pertamax',
      ),
      FinancialTransaction(
        id: 'demo_6',
        title: 'Listrik PLN & WiFi Rumah',
        amount: 650000,
        type: TransactionType.expense,
        categoryId: 'cat_bills',
        walletId: 'wallet_bca',
        date: DateTime(now.year, now.month, (now.day - 3).clamp(1, 28), 10, 0),
        notes: 'Tagihan bulanan rumah tangga',
      ),
      FinancialTransaction(
        id: 'demo_7',
        title: 'Bonus Proyek Sampingan',
        amount: 2000000,
        type: TransactionType.income,
        categoryId: 'cat_business',
        walletId: 'wallet_mandiri',
        date: DateTime(now.year, now.month, (now.day - 4).clamp(1, 28), 19, 30),
        notes: 'Freelance web development',
      ),
      FinancialTransaction(
        id: 'demo_8',
        title: 'Top Up Saldo GoPay',
        amount: 300000,
        type: TransactionType.transfer,
        categoryId: 'cat_other_exp',
        walletId: 'wallet_bca',
        toWalletId: 'wallet_gopay',
        date: DateTime(now.year, now.month, (now.day - 4).clamp(1, 28), 20, 10),
        notes: 'Untuk pesan makan online',
      ),
      FinancialTransaction(
        id: 'demo_9',
        title: 'Pesan Makan Malam Online',
        amount: 85000,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        walletId: 'wallet_gopay',
        date: DateTime(now.year, now.month, (now.day - 5).clamp(1, 28), 20, 0),
        notes: 'Ayam geprek & jus',
      ),
    ];

    _sortTransactions();

    await _storage.saveTransactions(_transactions);
    await _storage.saveWallets(_wallets);
    await _storage.saveBudgets(_budgets);
    await _storage.saveCategories(_categories);
    await _storage.saveGoals(_goals);

    if (!isFirstRunInit) {
      notifyListeners();
    }
  }
}

class ImportResult {
  final bool success;
  final String message;
  final int txCount;
  final int walletCount;
  final int budgetCount;
  final int goalCount;

  const ImportResult({
    required this.success,
    required this.message,
    this.txCount = 0,
    this.walletCount = 0,
    this.budgetCount = 0,
    this.goalCount = 0,
  });
}
