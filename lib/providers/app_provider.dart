import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Mouvement> mouvements = <Mouvement>[];
  List<Depense> depenses = <Depense>[];
  List<Revenu> revenus = <Revenu>[];

  bool loading = true;

  Future<void> init() async {
    final empty = await _db.isEmpty();
    if (empty) {
      await _db.insertAll(
        mouvements: seedMouvements(),
        depenses: seedDepenses(),
        revenus: seedRevenus(),
      );
    }
    await load();
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();

    mouvements = await _db.getMouvements();
    depenses = await _db.getDepenses();
    revenus = await _db.getRevenus();

    loading = false;
    notifyListeners();
  }

  // ---- Stock global ----
  Stock get stock {
    var current = const Stock();
    for (final m in mouvements) {
      current = current.apply(m.type, m.qte);
    }
    return current;
  }

  // ---- Stock par lot ----
  Stock stockByLot(String lot) {
    var current = const Stock();
    for (final m in mouvements.where((m) => m.lot == lot)) {
      current = current.apply(m.type, m.qte);
    }
    return current;
  }

  // ---- Finances globales ----
  double get totalDepenses => depenses.fold(0, (sum, item) => sum + item.montant);
  double get totalRevenus => revenus.fold(0, (sum, item) => sum + item.montant);
  double get bilan => totalRevenus - totalDepenses;

  double depensesMois(DateTime month) => depenses
      .where((d) => d.date.year == month.year && d.date.month == month.month)
      .fold(0, (sum, item) => sum + item.montant);

  double revenusMois(DateTime month) => revenus
      .where((r) => r.date.year == month.year && r.date.month == month.month)
      .fold(0, (sum, item) => sum + item.montant);

  // ---- Finances par lot ----
  double totalDepensesByLot(String lot) =>
      depenses.where((d) => d.lot == lot).fold(0.0, (s, d) => s + d.montant);

  double totalRevenusByLot(String lot) =>
      revenus.where((r) => r.lot == lot).fold(0.0, (s, r) => s + r.montant);

  double bilanByLot(String lot) => totalRevenusByLot(lot) - totalDepensesByLot(lot);

  double depensesMoisByLot(DateTime month, String lot) => depenses
      .where((d) => d.lot == lot && d.date.year == month.year && d.date.month == month.month)
      .fold(0.0, (s, d) => s + d.montant);

  double revenusMoisByLot(DateTime month, String lot) => revenus
      .where((r) => r.lot == lot && r.date.year == month.year && r.date.month == month.month)
      .fold(0.0, (s, r) => s + r.montant);

  // ---- Bilan par associé ----
  Map<String, double> bilanAssocies() {
    final result = <String, double>{};
    for (final entry in lots.entries) {
      final lotKey = entry.key;
      final info = entry.value;
      final dep = totalDepensesByLot(lotKey);
      final rev = totalRevenusByLot(lotKey);
      final b = rev - dep;
      result[info.associe1] = (result[info.associe1] ?? 0) + b * info.part1;
      result[info.associe2] = (result[info.associe2] ?? 0) + b * info.part2;
    }
    return result;
  }

  Map<String, double> depensesAssocies() {
    final result = <String, double>{};
    for (final entry in lots.entries) {
      final info = entry.value;
      final dep = totalDepensesByLot(entry.key);
      result[info.associe1] = (result[info.associe1] ?? 0) + dep * info.part1;
      result[info.associe2] = (result[info.associe2] ?? 0) + dep * info.part2;
    }
    return result;
  }

  Map<String, double> revenusAssocies() {
    final result = <String, double>{};
    for (final entry in lots.entries) {
      final info = entry.value;
      final rev = totalRevenusByLot(entry.key);
      result[info.associe1] = (result[info.associe1] ?? 0) + rev * info.part1;
      result[info.associe2] = (result[info.associe2] ?? 0) + rev * info.part2;
    }
    return result;
  }

  // ---- Historique ----
  List<Map<String, dynamic>> get last6MonthsData {
    final now = DateTime.now();
    return List<Map<String, dynamic>>.generate(6, (index) {
      final month = DateTime(now.year, now.month - 5 + index, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      var stockAtMonth = const Stock();
      for (final m in mouvements) {
        if (!m.date.isAfter(endOfMonth)) {
          stockAtMonth = stockAtMonth.apply(m.type, m.qte);
        }
      }
      return <String, dynamic>{
        'month': month,
        'total': stockAtMonth.total,
        'depenses': depensesMois(month),
        'revenus': revenusMois(month),
      };
    });
  }

  // ---- Catégories ----
  Map<String, double> depensesByCategorie() {
    final result = <String, double>{};
    for (final item in depenses) {
      result[item.categorie] = (result[item.categorie] ?? 0) + item.montant;
    }
    final entries = result.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  Map<String, double> revenusByCategorie() {
    final result = <String, double>{};
    for (final item in revenus) {
      result[item.categorie] = (result[item.categorie] ?? 0) + item.montant;
    }
    final entries = result.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  // ---- CRUD ----
  Future<void> addMouvement(Mouvement mouvement) async {
    await _db.insertMouvement(mouvement);
    mouvements = await _db.getMouvements();
    notifyListeners();
  }

  Future<void> deleteMouvement(String id) async {
    await _db.deleteMouvement(id);
    mouvements.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> addDepense(Depense depense) async {
    await _db.insertDepense(depense);
    depenses = await _db.getDepenses();
    notifyListeners();
  }

  Future<void> deleteDepense(String id) async {
    await _db.deleteDepense(id);
    depenses.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> addRevenu(Revenu revenu) async {
    await _db.insertRevenu(revenu);
    revenus = await _db.getRevenus();
    notifyListeners();
  }

  Future<void> deleteRevenu(String id) async {
    await _db.deleteRevenu(id);
    revenus.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _db.clearAll();
    mouvements = <Mouvement>[];
    depenses = <Depense>[];
    revenus = <Revenu>[];
    notifyListeners();
  }
}
