import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/form_sheet.dart';
import '../widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy', 'fr_FR').format(now);

    final depMois = provider.depensesMois(now);
    final revMois = provider.revenusMois(now);
    final bilanMois = revMois - depMois;
    final soldeGlobal = provider.bilan;

    final recentItems = <({DateTime date, String type, dynamic item})>[
      ...provider.mouvements.reversed.take(3).map((m) => (date: m.date, type: 'mvt', item: m)),
      ...provider.depenses.take(3).map((d) => (date: d.date, type: 'dep', item: d)),
      ...provider.revenus.take(3).map((r) => (date: r.date, type: 'rev', item: r)),
    ]..sort((a, b) => b.date.compareTo(a.date));
    final recent = recentItems.take(8).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionTitle('🏡 Ma Ferme', sub: monthName),

          // ── Carte solde mensuel (style Daily Expenses 3) ──────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF256F49), Color(0xFF3BAA74)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'SOLDE MENSUEL',
                  style: TextStyle(fontSize: 11, letterSpacing: .8, fontWeight: FontWeight.w800, color: Colors.white54),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            fmtMAD(soldeGlobal.abs()),
                            style: TextStyle(
                              fontSize: 28,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              color: soldeGlobal >= 0 ? Colors.white : const Color(0xFFFF8A80),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            soldeGlobal >= 0 ? 'Solde positif ✓' : 'Solde négatif',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Text('🐑', style: const TextStyle(fontSize: 52, color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    _MonthStat(label: 'Revenus', value: fmtMAD(revMois), positive: true),
                    Container(width: 1, height: 36, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 16)),
                    _MonthStat(label: 'Dépenses', value: fmtMAD(depMois), positive: false),
                    Container(width: 1, height: 36, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 16)),
                    _MonthStat(
                      label: bilanMois >= 0 ? 'Bilan +' : 'Bilan -',
                      value: fmtMAD(bilanMois.abs()),
                      positive: bilanMois >= 0,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Stock global ──────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('🐑 TROUPEAU TOTAL'),
                Builder(builder: (context) {
                  final stock = provider.stock;
                  return Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(child: _StockChip(emoji: '🐑', label: 'Femelles', value: stock.femelles)),
                          const SizedBox(width: 10),
                          Expanded(child: _StockChip(emoji: '🐏', label: 'Mâles', value: stock.males)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(child: _StockChip(emoji: '🍼', label: 'Agneaux ♀', value: stock.agneauxF)),
                          const SizedBox(width: 10),
                          Expanded(child: _StockChip(emoji: '🐣', label: 'Agneaux ♂', value: stock.agneauxM)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'TOTAL : ${stock.total} têtes',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.green2),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // ── Par activité ──────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('🌿 PAR ACTIVITÉ'),
                ...secteurs.entries.map((entry) {
                  final secteurKey = entry.key;
                  final info = entry.value;
                  final dep = provider.totalDepensesBySecteur(secteurKey);
                  final rev = provider.totalRevenusBySecteur(secteurKey);
                  final bilan = rev - dep;
                  if (dep == 0 && rev == 0) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSoft),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(info.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(info.label,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '${bilan >= 0 ? '+' : '-'}${fmtMAD(bilan.abs())}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: bilan >= 0 ? AppColors.green2 : AppColors.red,
                              ),
                            ),
                            Text(
                              'Dep: ${fmtMAD(dep)}',
                              style: const TextStyle(fontSize: 10, color: AppColors.text3, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // ── Par lot ───────────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📊 RÉSUMÉ PAR LOT'),
                ...lots.entries.map((entry) {
                  final lotKey = entry.key;
                  final info = entry.value;
                  final stock = provider.stockByLot(lotKey);
                  final dep = provider.totalDepensesByLot(lotKey);
                  final rev = provider.totalRevenusByLot(lotKey);
                  final bilan = rev - dep;
                  final depMoisLot = provider.depensesMoisByLot(now, lotKey);
                  final revMoisLot = provider.revenusMoisByLot(now, lotKey);
                  return _LotRow(
                    info: info,
                    stock: stock,
                    dep: dep,
                    rev: rev,
                    bilan: bilan,
                    depMois: depMoisLot,
                    revMois: revMoisLot,
                  );
                }),
              ],
            ),
          ),

          // ── Actions rapides ───────────────────────────────────────────────
          const Text(
            'ACTIONS RAPIDES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .6, color: AppColors.text3),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: .96,
            padding: const EdgeInsets.only(bottom: 14),
            children: <Widget>[
              QuickBtn(emoji: '🍼', label: 'Naissance', onTap: () => showMvtForm(context, initialType: 'naissance_agf')),
              QuickBtn(emoji: '💸', label: 'Dépense', onTap: () => showDepForm(context)),
              QuickBtn(emoji: '💰', label: 'Revenu', onTap: () => showRevForm(context)),
              QuickBtn(emoji: '🛒', label: 'Achat', onTap: () => showMvtForm(context, initialType: 'achat_femelle')),
              QuickBtn(emoji: '🤝', label: 'Vente', onTap: () => showMvtForm(context, initialType: 'vente_femelle')),
              QuickBtn(emoji: '💀', label: 'Décès', onTap: () => showMvtForm(context, initialType: 'deces_femelle')),
            ],
          ),

          // ── Évolution 6 mois ──────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📈 ÉVOLUTION TROUPEAU — 6 MOIS'),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= provider.last6MonthsData.length) return const SizedBox.shrink();
                              final month = provider.last6MonthsData[index]['month'] as DateTime;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(DateFormat('MMM', 'fr_FR').format(month),
                                    style: const TextStyle(fontSize: 11, color: AppColors.text3)),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: <LineChartBarData>[
                        LineChartBarData(
                          spots: List<FlSpot>.generate(
                            provider.last6MonthsData.length,
                            (i) => FlSpot(i.toDouble(), (provider.last6MonthsData[i]['total'] as int).toDouble()),
                          ),
                          isCurved: true,
                          barWidth: 4,
                          color: AppColors.green2,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 10 derniers enregistrements ───────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('🕘 DIX DERNIERS ENREGISTREMENTS'),
                if (recent.isEmpty)
                  const EmptyState(emoji: '📭', text: 'Aucune donnée récente')
                else
                  ...recent.map((entry) {
                    if (entry.type == 'mvt') {
                      final m = entry.item as Mouvement;
                      final lotInfo = lots[m.lot];
                      return RecentItem(
                        emoji: m.emoji,
                        title: m.label,
                        subtitle: '${fmtDate(m.date)} · ${lotInfo?.label ?? m.lot}',
                        value: '×${m.qte}',
                        valueColor: mvtFgColor(m.color),
                        bgColor: mvtBgColor(m.color),
                      );
                    }
                    if (entry.type == 'dep') {
                      final d = entry.item as Depense;
                      final lotInfo = lots[d.lot];
                      return RecentItem(
                        emoji: '💸',
                        title: d.categorie,
                        subtitle: '${fmtDate(d.date)} · ${lotInfo?.label ?? d.lot}${d.remarque.isNotEmpty ? ' · ${d.remarque}' : ''}',
                        value: '-${fmtMAD(d.montant)}',
                        valueColor: AppColors.red,
                        bgColor: AppColors.redBg,
                      );
                    }
                    final r = entry.item as Revenu;
                    final lotInfo = lots[r.lot];
                    return RecentItem(
                      emoji: '💰',
                      title: r.categorie,
                      subtitle: '${fmtDate(r.date)} · ${lotInfo?.label ?? r.lot}${r.remarque.isNotEmpty ? ' · ${r.remarque}' : ''}',
                      value: '+${fmtMAD(r.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  const _MonthStat({required this.label, required this.value, required this.positive});
  final String label;
  final String value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: positive ? Colors.white : const Color(0xFFFF8A80),
              )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  const _StockChip({required this.emoji, required this.label, required this.value});
  final String emoji;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.cardSoft, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderSoft)),
      child: Row(
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.green2)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LotRow extends StatelessWidget {
  const _LotRow({
    required this.info,
    required this.stock,
    required this.dep,
    required this.rev,
    required this.bilan,
    required this.depMois,
    required this.revMois,
  });

  final LotInfo info;
  final Stock stock;
  final double dep;
  final double rev;
  final double bilan;
  final double depMois;
  final double revMois;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(info.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(info.label,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                    Text(
                      '${info.associe1} ${(info.part1 * 100).toInt()}% · ${info.associe2} ${(info.part2 * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(10)),
                child: Text('${stock.total} têtes',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.green2)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(child: _MiniStat(label: 'Dépenses total', value: fmtMAD(dep), color: AppColors.red)),
              const SizedBox(width: 6),
              Expanded(child: _MiniStat(label: 'Revenus total', value: fmtMAD(rev), color: AppColors.green2)),
              const SizedBox(width: 6),
              Expanded(
                child: _MiniStat(
                  label: bilan >= 0 ? 'Bilan +' : 'Bilan -',
                  value: fmtMAD(bilan.abs()),
                  color: bilan >= 0 ? AppColors.green2 : AppColors.red,
                ),
              ),
            ],
          ),
          if (depMois > 0 || revMois > 0) ...<Widget>[
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.text3),
                const SizedBox(width: 4),
                Text('Ce mois : ', style: const TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w700)),
                Text('-${fmtMAD(depMois)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.red)),
                const SizedBox(width: 8),
                Text('+${fmtMAD(revMois)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.green2)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.text3, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHEPTEL
// ─────────────────────────────────────────────────────────────────────────────
class CheptelScreen extends StatefulWidget {
  const CheptelScreen({super.key});

  @override
  State<CheptelScreen> createState() => _CheptelScreenState();
}

class _CheptelScreenState extends State<CheptelScreen> {
  String _selectedLot = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final mouvementsFiltered = _selectedLot == 'all'
        ? provider.mouvements
        : provider.mouvements.where((m) => m.lot == _selectedLot).toList();

    final stock = _selectedLot == 'all' ? provider.stock : provider.stockByLot(_selectedLot);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('🐑 Cheptel'),
          // Filtre par lot
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _LotChip(label: 'Tous', value: 'all', selected: _selectedLot == 'all', onTap: () => setState(() => _selectedLot = 'all')),
                ...lots.entries.map((e) => _LotChip(
                      label: '${e.value.emoji} ${e.value.label}',
                      value: e.key,
                      selected: _selectedLot == e.key,
                      onTap: () => setState(() => _selectedLot = e.key),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('ÉTAT ACTUEL'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.22,
                  children: <Widget>[
                    KpiCard(emoji: '🐑', value: '${stock.femelles}', label: 'Femelles'),
                    KpiCard(emoji: '🐏', value: '${stock.males}', label: 'Mâles'),
                    KpiCard(emoji: '🍼', value: '${stock.agneauxF}', label: 'Agneaux ♀'),
                    KpiCard(emoji: '🐣', value: '${stock.agneauxM}', label: 'Agneaux ♂'),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(14)),
                  child: Center(
                    child: Text('TOTAL : ${stock.total} têtes',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.green2)),
                  ),
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('➕ AJOUTER UN MOUVEMENT'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.25,
                  children: <Widget>[
                    MvtBtn(emoji: '🍼', label: 'Naissance ♀', onTap: () => showMvtForm(context, initialType: 'naissance_agf')),
                    MvtBtn(emoji: '🐣', label: 'Naissance ♂', onTap: () => showMvtForm(context, initialType: 'naissance_agm')),
                    MvtBtn(emoji: '🛒', label: 'Achat', onTap: () => showMvtForm(context, initialType: 'achat_femelle')),
                    MvtBtn(emoji: '🤝', label: 'Vente', onTap: () => showMvtForm(context, initialType: 'vente_femelle')),
                    MvtBtn(emoji: '💀', label: 'Décès', onTap: () => showMvtForm(context, initialType: 'deces_femelle')),
                    MvtBtn(emoji: '⚙️', label: 'Stock initial', onTap: () => showMvtForm(context, initialType: 'init_femelles')),
                  ],
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📋 DERNIERS MOUVEMENTS'),
                if (mouvementsFiltered.isEmpty)
                  const EmptyState(emoji: '🐑', text: 'Aucun mouvement enregistré')
                else
                  ...mouvementsFiltered.reversed.take(30).map(
                        (m) => HistoryItem(
                          emoji: m.emoji,
                          title: m.label,
                          subtitle: '${fmtDate(m.date)} · ${lots[m.lot]?.label ?? m.lot}${m.remarque.isNotEmpty ? ' · ${m.remarque}' : ''}',
                          value: '×${m.qte}',
                          valueColor: mvtFgColor(m.color),
                          bgColor: mvtBgColor(m.color),
                          onDelete: () => _confirmDelete(context, () => context.read<AppProvider>().deleteMouvement(m.id)),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LotChip extends StatelessWidget {
  const _LotChip({required this.label, required this.value, required this.selected, required this.onTap});
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.green2 : AppColors.bg2,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? AppColors.green2 : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.text2)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DÉPENSES
// ─────────────────────────────────────────────────────────────────────────────
class DepensesScreen extends StatefulWidget {
  const DepensesScreen({super.key});

  @override
  State<DepensesScreen> createState() => _DepensesScreenState();
}

class _DepensesScreenState extends State<DepensesScreen> {
  String _selectedSecteur = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();

    final filtered = _selectedSecteur == 'all'
        ? provider.depenses
        : provider.depenses.where((d) => d.secteur == _selectedSecteur).toList();

    final total = filtered.fold(0.0, (s, d) => s + d.montant);
    final mois = filtered
        .where((d) => d.date.year == now.year && d.date.month == now.month)
        .fold(0.0, (s, d) => s + d.montant);

    final catMap = <String, double>{};
    for (final d in filtered) {
      catMap[d.categorie] = (catMap[d.categorie] ?? 0) + d.montant;
    }
    final cats = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('💸 Dépenses'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _LotChip(label: 'Tous', value: 'all', selected: _selectedSecteur == 'all', onTap: () => setState(() => _selectedSecteur = 'all')),
                ...secteurs.entries.map((e) => _LotChip(
                      label: '${e.value.emoji} ${e.value.label}',
                      value: e.key,
                      selected: _selectedSecteur == e.key,
                      onTap: () => setState(() => _selectedSecteur = e.key),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FinSumCard(value: fmtMAD(mois), label: 'Ce mois', color: AppColors.red),
              FinSumCard(value: fmtMAD(total), label: 'Total', color: AppColors.red),
            ],
          ),
          const SizedBox(height: 14),
          AddButton(label: 'Ajouter une dépense', onTap: () => showDepForm(context), color: AppColors.red2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📊 PAR CATÉGORIE'),
                if (cats.isEmpty)
                  const EmptyState(emoji: '📊', text: 'Aucune dépense')
                else
                  ...cats.map((entry) => CatRow(cat: entry.key, amount: entry.value, total: total, color: AppColors.red)),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📋 TOUTES LES DÉPENSES'),
                if (filtered.isEmpty)
                  const EmptyState(emoji: '💸', text: 'Aucune dépense enregistrée')
                else
                  ...filtered.map(
                    (d) => HistoryItem(
                      emoji: secteurs[d.secteur]?.emoji ?? '💸',
                      title: d.categorie,
                      subtitle: '${fmtDate(d.date)} · ${secteurs[d.secteur]?.label ?? d.secteur} · ${lots[d.lot]?.label ?? d.lot}${d.remarque.isNotEmpty ? ' · ${d.remarque}' : ''}',
                      value: '-${fmtMAD(d.montant)}',
                      valueColor: AppColors.red,
                      bgColor: AppColors.redBg,
                      onDelete: () => _confirmDelete(context, () => context.read<AppProvider>().deleteDepense(d.id)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVENUS
// ─────────────────────────────────────────────────────────────────────────────
class RevenusScreen extends StatefulWidget {
  const RevenusScreen({super.key});

  @override
  State<RevenusScreen> createState() => _RevenusScreenState();
}

class _RevenusScreenState extends State<RevenusScreen> {
  String _selectedSecteur = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();

    final filtered = _selectedSecteur == 'all'
        ? provider.revenus
        : provider.revenus.where((r) => r.secteur == _selectedSecteur).toList();

    final total = filtered.fold(0.0, (s, r) => s + r.montant);
    final mois = filtered
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .fold(0.0, (s, r) => s + r.montant);

    final catMap = <String, double>{};
    for (final r in filtered) {
      catMap[r.categorie] = (catMap[r.categorie] ?? 0) + r.montant;
    }
    final cats = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('💰 Revenus'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _LotChip(label: 'Tous', value: 'all', selected: _selectedSecteur == 'all', onTap: () => setState(() => _selectedSecteur = 'all')),
                ...secteurs.entries.map((e) => _LotChip(
                      label: '${e.value.emoji} ${e.value.label}',
                      value: e.key,
                      selected: _selectedSecteur == e.key,
                      onTap: () => setState(() => _selectedSecteur = e.key),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FinSumCard(value: fmtMAD(mois), label: 'Ce mois', color: AppColors.green2),
              FinSumCard(value: fmtMAD(total), label: 'Total', color: AppColors.green2),
            ],
          ),
          const SizedBox(height: 14),
          AddButton(label: 'Ajouter un revenu', onTap: () => showRevForm(context)),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📊 PAR CATÉGORIE'),
                if (cats.isEmpty)
                  const EmptyState(emoji: '📊', text: 'Aucun revenu')
                else
                  ...cats.map((entry) => CatRow(cat: entry.key, amount: entry.value, total: total, color: AppColors.green2)),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📋 TOUS LES REVENUS'),
                if (filtered.isEmpty)
                  const EmptyState(emoji: '💰', text: 'Aucun revenu enregistré')
                else
                  ...filtered.map(
                    (r) => HistoryItem(
                      emoji: secteurs[r.secteur]?.emoji ?? '💰',
                      title: r.categorie,
                      subtitle: '${fmtDate(r.date)} · ${secteurs[r.secteur]?.label ?? r.secteur} · ${lots[r.lot]?.label ?? r.lot}${r.remarque.isNotEmpty ? ' · ${r.remarque}' : ''}',
                      value: '+${fmtMAD(r.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                      onDelete: () => _confirmDelete(context, () => context.read<AppProvider>().deleteRevenu(r.id)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HISTORIQUE
// ─────────────────────────────────────────────────────────────────────────────
class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final items = <({DateTime date, String type, dynamic item})>[
      if (_filter == 'all' || _filter == 'mvt')
        ...provider.mouvements.map((m) => (date: m.date, type: 'mvt', item: m)),
      if (_filter == 'all' || _filter == 'dep')
        ...provider.depenses.map((d) => (date: d.date, type: 'dep', item: d)),
      if (_filter == 'all' || _filter == 'rev')
        ...provider.revenus.map((r) => (date: r.date, type: 'rev', item: r)),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('📜 Historique'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _chip('Tout', 'all'),
                    _chip('🐑 Troupeau', 'mvt'),
                    _chip('💸 Dépenses', 'dep'),
                    _chip('💰 Revenus', 'rev'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const EmptyState(emoji: '📭', text: 'Aucune donnée')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final entry = items[index];
                    if (entry.type == 'mvt') {
                      final m = entry.item as Mouvement;
                      return HistoryItem(
                        emoji: m.emoji,
                        title: m.label,
                        subtitle: '${fmtDate(m.date)} · ${lots[m.lot]?.label ?? m.lot}${m.remarque.isNotEmpty ? ' · ${m.remarque}' : ''}',
                        value: '×${m.qte}',
                        valueColor: mvtFgColor(m.color),
                        bgColor: mvtBgColor(m.color),
                      );
                    }
                    if (entry.type == 'dep') {
                      final d = entry.item as Depense;
                      return HistoryItem(
                        emoji: '💸',
                        title: '${lots[d.lot]?.emoji ?? ''} ${d.categorie}',
                        subtitle: '${fmtDate(d.date)}${d.remarque.isNotEmpty ? ' · ${d.remarque}' : ''}',
                        value: '-${fmtMAD(d.montant)}',
                        valueColor: AppColors.red,
                        bgColor: AppColors.redBg,
                      );
                    }
                    final r = entry.item as Revenu;
                    return HistoryItem(
                      emoji: '💰',
                      title: '${lots[r.lot]?.emoji ?? ''} ${r.categorie}',
                      subtitle: '${fmtDate(r.date)}${r.remarque.isNotEmpty ? ' · ${r.remarque}' : ''}',
                      value: '+${fmtMAD(r.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.green2 : AppColors.bg2,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? AppColors.green2 : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.text2)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSOCIÉS
// ─────────────────────────────────────────────────────────────────────────────
class AssociesScreen extends StatelessWidget {
  const AssociesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bilanMap = provider.bilanAssocies();
    final depMap = provider.depensesAssocies();
    final revMap = provider.revenusAssocies();
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy', 'fr_FR').format(now);

    const associes = <String>['Abdel', 'Fidaoui', 'Nouri', 'Adil'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionTitle('👥 Associés', sub: 'Répartition · $monthName'),

          // ── Bilan par associé ─────────────────────────────────────────────
          const Text(
            'BILAN PAR ASSOCIÉ',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .6, color: AppColors.text3),
          ),
          const SizedBox(height: 10),
          ...associes.map((name) {
            final dep = depMap[name] ?? 0;
            final rev = revMap[name] ?? 0;
            final bilan = bilanMap[name] ?? 0;
            return AppCard(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: name == 'Abdel' ? AppColors.green2 : AppColors.bg4,
                        child: Text(name[0],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: name == 'Abdel' ? Colors.white : AppColors.text2,
                            )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text)),
                            Text(
                              _lotsPourAssocie(name),
                              style: const TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: bilan >= 0 ? AppColors.greenBg : AppColors.redBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '${bilan >= 0 ? '+' : '-'}${fmtMAD(bilan.abs())}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: bilan >= 0 ? AppColors.green2 : AppColors.red),
                            ),
                            Text('bilan', style: const TextStyle(fontSize: 10, color: AppColors.text3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(child: _MiniStat(label: 'Dépenses (part)', value: fmtMAD(dep), color: AppColors.red)),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniStat(label: 'Revenus (part)', value: fmtMAD(rev), color: AppColors.green2)),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 6),

          // ── Détail par lot ────────────────────────────────────────────────
          const Text(
            'DÉTAIL PAR LOT',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .6, color: AppColors.text3),
          ),
          const SizedBox(height: 10),
          ...lots.entries.map((entry) {
            final lotKey = entry.key;
            final info = entry.value;
            final dep = provider.totalDepensesByLot(lotKey);
            final rev = provider.totalRevenusByLot(lotKey);
            final bilan = rev - dep;
            final stock = provider.stockByLot(lotKey);

            final depA1 = dep * info.part1;
            final revA1 = rev * info.part1;
            final bilanA1 = bilan * info.part1;
            final depA2 = dep * info.part2;
            final revA2 = rev * info.part2;
            final bilanA2 = bilan * info.part2;

            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(info.emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(info.label,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                            Text('${stock.total} têtes · Dép: ${fmtMAD(dep)} · Rev: ${fmtMAD(rev)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.text3)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: bilan >= 0 ? AppColors.greenBg : AppColors.redBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${bilan >= 0 ? '+' : ''}${fmtMAD(bilan)}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: bilan >= 0 ? AppColors.green2 : AppColors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.borderSoft),
                  const SizedBox(height: 10),
                  // Part associé 1
                  _AssociePartRow(
                    name: info.associe1,
                    part: info.part1,
                    dep: depA1,
                    rev: revA1,
                    bilan: bilanA1,
                  ),
                  const SizedBox(height: 8),
                  // Part associé 2
                  _AssociePartRow(
                    name: info.associe2,
                    part: info.part2,
                    dep: depA2,
                    rev: revA2,
                    bilan: bilanA2,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _lotsPourAssocie(String name) {
    final participations = <String>[];
    for (final entry in lots.entries) {
      final info = entry.value;
      if (info.associe1 == name) {
        participations.add('${(info.part1 * 100).toInt()}% ${info.label}');
      } else if (info.associe2 == name) {
        participations.add('${(info.part2 * 100).toInt()}% ${info.label}');
      }
    }
    return participations.join(' · ');
  }
}

class _AssociePartRow extends StatelessWidget {
  const _AssociePartRow({
    required this.name,
    required this.part,
    required this.dep,
    required this.rev,
    required this.bilan,
  });
  final String name;
  final double part;
  final double dep;
  final double rev;
  final double bilan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.bg4,
          child: Text(name[0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text2)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('$name (${(part * 100).toInt()}%)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
              Text('-${fmtMAD(dep)} · +${fmtMAD(rev)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.text3)),
            ],
          ),
        ),
        Text(
          '${bilan >= 0 ? '+' : ''}${fmtMAD(bilan)}',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: bilan >= 0 ? AppColors.green2 : AppColors.red),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.bg2,
      title: const Text('Confirmer'),
      content: const Text('Supprimer cet enregistrement ?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onConfirm();
          },
          child: const Text('Supprimer', style: TextStyle(color: AppColors.red)),
        ),
      ],
    ),
  );
}
