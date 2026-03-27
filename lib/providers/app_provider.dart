import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Mouvement> mouvements = <Mouvement>[];
  List<Depense> depenses = <Depense>[];
  List<Revenu> revenus = <Revenu>[];

  bool loading = true;

  Future<void> init() async {
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

  Stock get stock {
    var current = const Stock();
    for (final m in mouvements) {
      current = current.apply(m.type, m.qte);
    }
    return current;
  }

  double get totalDepenses => depenses.fold(0, (sum, item) => sum + item.montant);
  double get totalRevenus => revenus.fold(0, (sum, item) => sum + item.montant);
  double get bilan => totalRevenus - totalDepenses;

  double depensesMois(DateTime month) => depenses
      .where((d) => d.date.year == month.year && d.date.month == month.month)
      .fold(0, (sum, item) => sum + item.montant);

  double revenusMois(DateTime month) => revenus
      .where((r) => r.date.year == month.year && r.date.month == month.month)
      .fold(0, (sum, item) => sum + item.montant);

  List<Map<String, dynamic>> get last6MonthsData {
    final now = DateTime.now();

    return List<Map<String, dynamic>>.generate(6, (index) {
      final month = DateTime(now.year, now.month - 5 + index, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      var stockAtMonth = const Stock();
      for (final mouvement in mouvements) {
        if (!mouvement.date.isAfter(endOfMonth)) {
          stockAtMonth = stockAtMonth.apply(mouvement.type, mouvement.qte);
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

  Map<String, double> depensesByCategorie() {
    final result = <String, double>{};
    for (final item in depenses) {
      result[item.categorie] = (result[item.categorie] ?? 0) + item.montant;
    }
    final entries = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  Map<String, double> revenusByCategorie() {
    final result = <String, double>{};
    for (final item in revenus) {
      result[item.categorie] = (result[item.categorie] ?? 0) + item.montant;
    }
    final entries = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  Future<void> clearAll() async {
    await _db.clearAll();
    mouvements = <Mouvement>[];
    depenses = <Depense>[];
    revenus = <Revenu>[];
    notifyListeners();
  }
}
