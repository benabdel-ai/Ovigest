import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/screens.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TroupeauApp());
}

class TroupeauApp extends StatelessWidget {
  const TroupeauApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppProvider>(
      create: (_) => AppProvider()..init(),
      child: MaterialApp(
        title: 'Ma Ferme',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    CheptelScreen(),
    DepensesScreen(),
    RevenusScreen(),
    HistoriqueScreen(),
    AssociesScreen(),
  ];

  static const List<String> _labels = <String>[
    'Accueil',
    'Cheptel',
    'Dépenses',
    'Revenus',
    'Historique',
    'Associés',
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.dashboard_rounded,
    Icons.pets_rounded,
    Icons.trending_down_rounded,
    Icons.trending_up_rounded,
    Icons.history_rounded,
    Icons.people_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.green2, AppColors.green4],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text('🐑', style: TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ma Ferme',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chargement des données...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text2,
                ),
              ),
              const SizedBox(height: 28),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const SizedBox(
                  width: 190,
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    backgroundColor: AppColors.greenBg,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.green2),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 16,
        title: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.green2, AppColors.green4],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('🐑', style: TextStyle(fontSize: 23)),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Ma Ferme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green2,
                  ),
                ),
                Text(
                  'Abdel · Fidaoui · Nouri · Adil',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.bg4,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _dayName(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green3,
                    ),
                  ),
                  Text(
                    _dateStr(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bg2,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 18,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (value) => setState(() => _index = value),
            items: List<BottomNavigationBarItem>.generate(
              _labels.length,
              (index) => BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Icon(_icons[index]),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Icon(_icons[index]),
                ),
                label: _labels[index],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _dayName() {
    const days = <String>['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return days[DateTime.now().weekday % 7];
  }

  String _dateStr() {
    final date = DateTime.now();
    const months = <String>[
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
