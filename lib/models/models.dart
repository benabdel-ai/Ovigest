import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class LotInfo {
  final String label;
  final String emoji;
  final String associe1;
  final double part1;
  final String associe2;
  final double part2;

  const LotInfo({
    required this.label,
    required this.emoji,
    required this.associe1,
    required this.part1,
    required this.associe2,
    required this.part2,
  });
}

const Map<String, LotInfo> lots = {
  'abdel_fidaoui': LotInfo(
    label: 'Abdel + Fidaoui',
    emoji: '🐑',
    associe1: 'Abdel',
    part1: 0.75,
    associe2: 'Fidaoui',
    part2: 0.25,
  ),
  'abdel_nouri': LotInfo(
    label: 'Abdel + Nouri',
    emoji: '🐏',
    associe1: 'Abdel',
    part1: 0.50,
    associe2: 'Nouri',
    part2: 0.50,
  ),
  'abdel_adil': LotInfo(
    label: 'Abdel + Adil',
    emoji: '🤝',
    associe1: 'Abdel',
    part1: 0.50,
    associe2: 'Adil',
    part2: 0.50,
  ),
};

class Mouvement {
  final String id;
  final String type;
  final int qte;
  final DateTime date;
  final String remarque;
  final String lot;

  Mouvement({
    String? id,
    required this.type,
    required this.qte,
    required this.date,
    this.remarque = '',
    this.lot = 'abdel_fidaoui',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'qte': qte,
        'date': date.toIso8601String().split('T').first,
        'remarque': remarque,
        'lot': lot,
      };

  factory Mouvement.fromMap(Map<String, dynamic> map) => Mouvement(
        id: map['id'] as String,
        type: map['type'] as String,
        qte: map['qte'] as int,
        date: DateTime.parse(map['date'] as String),
        remarque: (map['remarque'] ?? '') as String,
        lot: (map['lot'] ?? 'abdel_fidaoui') as String,
      );

  String get label => mvtLabels[type] ?? type;
  String get emoji => mvtEmojis[type] ?? '📋';
  MvtColor get color => mvtColors[type] ?? MvtColor.green;
}

enum MvtColor { green, red, blue, gold }

const mvtLabels = {
  'init_femelles': 'Stock initial · Femelles',
  'init_males': 'Stock initial · Mâles',
  'init_agf': 'Stock initial · Agneaux ♀',
  'init_agm': 'Stock initial · Agneaux ♂',
  'naissance_agf': 'Naissance · Agneau ♀',
  'naissance_agm': 'Naissance · Agneau ♂',
  'achat_femelle': 'Achat · Femelle',
  'achat_male': 'Achat · Mâle',
  'vente_femelle': 'Vente · Femelle',
  'vente_male': 'Vente · Mâle',
  'deces_femelle': 'Décès · Femelle',
  'deces_male': 'Décès · Mâle',
  'passage_agf': 'Passage Agneau ♀ → Femelle',
  'passage_agm': 'Passage Agneau ♂ → Mâle',
};

const mvtEmojis = {
  'init_femelles': '🐑',
  'init_males': '🐏',
  'init_agf': '🍼',
  'init_agm': '🐣',
  'naissance_agf': '🍼',
  'naissance_agm': '🐣',
  'achat_femelle': '🛒',
  'achat_male': '🛒',
  'vente_femelle': '🤝',
  'vente_male': '🤝',
  'deces_femelle': '💀',
  'deces_male': '💀',
  'passage_agf': '🔄',
  'passage_agm': '🔄',
};

const mvtColors = {
  'init_femelles': MvtColor.green,
  'init_males': MvtColor.green,
  'init_agf': MvtColor.green,
  'init_agm': MvtColor.green,
  'naissance_agf': MvtColor.green,
  'naissance_agm': MvtColor.green,
  'achat_femelle': MvtColor.blue,
  'achat_male': MvtColor.blue,
  'vente_femelle': MvtColor.gold,
  'vente_male': MvtColor.gold,
  'deces_femelle': MvtColor.red,
  'deces_male': MvtColor.red,
  'passage_agf': MvtColor.blue,
  'passage_agm': MvtColor.blue,
};

class Depense {
  final String id;
  final double montant;
  final DateTime date;
  final String categorie;
  final String remarque;
  final String lot;

  Depense({
    String? id,
    required this.montant,
    required this.date,
    required this.categorie,
    this.remarque = '',
    this.lot = 'abdel_fidaoui',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'montant': montant,
        'date': date.toIso8601String().split('T').first,
        'categorie': categorie,
        'remarque': remarque,
        'lot': lot,
      };

  factory Depense.fromMap(Map<String, dynamic> map) => Depense(
        id: map['id'] as String,
        montant: (map['montant'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        categorie: (map['categorie'] ?? '') as String,
        remarque: (map['remarque'] ?? '') as String,
        lot: (map['lot'] ?? 'abdel_fidaoui') as String,
      );
}

class Revenu {
  final String id;
  final double montant;
  final DateTime date;
  final String categorie;
  final String remarque;
  final String lot;

  Revenu({
    String? id,
    required this.montant,
    required this.date,
    required this.categorie,
    this.remarque = '',
    this.lot = 'abdel_fidaoui',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'montant': montant,
        'date': date.toIso8601String().split('T').first,
        'categorie': categorie,
        'remarque': remarque,
        'lot': lot,
      };

  factory Revenu.fromMap(Map<String, dynamic> map) => Revenu(
        id: map['id'] as String,
        montant: (map['montant'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        categorie: (map['categorie'] ?? '') as String,
        remarque: (map['remarque'] ?? '') as String,
        lot: (map['lot'] ?? 'abdel_fidaoui') as String,
      );
}

class Stock {
  final int femelles;
  final int males;
  final int agneauxF;
  final int agneauxM;

  const Stock({
    this.femelles = 0,
    this.males = 0,
    this.agneauxF = 0,
    this.agneauxM = 0,
  });

  int get total => femelles + males + agneauxF + agneauxM;

  Stock apply(String type, int qte) {
    var f = femelles;
    var m = males;
    var af = agneauxF;
    var am = agneauxM;

    switch (type) {
      case 'init_femelles':
        f += qte;
        break;
      case 'init_males':
        m += qte;
        break;
      case 'init_agf':
        af += qte;
        break;
      case 'init_agm':
        am += qte;
        break;
      case 'naissance_agf':
        af += qte;
        break;
      case 'naissance_agm':
        am += qte;
        break;
      case 'achat_femelle':
        f += qte;
        break;
      case 'achat_male':
        m += qte;
        break;
      case 'vente_femelle':
      case 'deces_femelle':
        f = (f - qte).clamp(0, 999999);
        break;
      case 'vente_male':
      case 'deces_male':
        m = (m - qte).clamp(0, 999999);
        break;
      case 'passage_agf':
        af = (af - qte).clamp(0, 999999);
        f += qte;
        break;
      case 'passage_agm':
        am = (am - qte).clamp(0, 999999);
        m += qte;
        break;
    }

    return Stock(femelles: f, males: m, agneauxF: af, agneauxM: am);
  }
}

const depCategories = <String>[
  'Alimentation',
  "Main-d'œuvre",
  'Vétérinaire',
  'Transport',
  'Achat bétail',
  'Équipement',
  'Location',
  'Autre',
];

const revCategories = <String>[
  'Vente brebis',
  'Vente bélier',
  'Vente agneau ♂',
  'Vente agneau ♀',
  'Vente lot Aïd',
  'Autre',
];
