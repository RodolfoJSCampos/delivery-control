import 'package:app/src/features/control/control_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../services/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isExpanded = true;
  int _selectedIndex = 0;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${info.version} © ${DateTime.now().year}';
    });
  }

  static const List<Widget> _destinationPages = <Widget>[
    Center(child: Text('Conteúdo da página Home')),
    ControlScreen(), // Replaced placeholder with ControlScreen
    Center(child: Text('Conteúdo da página Relatório')),
  ];

  @override
  Widget build(BuildContext context) {
    final double collapsedWidth = 80.0;
    final double expandedWidth = 180.0; // Corrected width

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Row(
            children: <Widget>[
              _buildNavigationRail(),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: _destinationPages[_selectedIndex],
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            top: 8.0,
            left: _isExpanded ? (expandedWidth - 8) : (collapsedWidth - 5),
            child: SizedBox(
              width: 32,
              height: 32,
              child: FloatingActionButton(
                elevation: 1.0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: CircleBorder(side: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Icon(
                  _isExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  NavigationRail _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      extended: _isExpanded,
      minExtendedWidth: 180, // Corrected width
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _isExpanded
                ? Text(
                    _appVersion,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : const SizedBox(), // Show nothing when collapsed
          ),
        ),
      ),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping),
          label: Text('Controle'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text('Relatório'),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Image.asset(
        Theme.of(context).brightness == Brightness.dark
            ? 'assets/logo-dark-mode.png'
            : 'assets/logo-light-mode.png',
        height: 40,
      ),
      actions: [
        if (user != null)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                FirebaseAuth.instance.signOut();
              } else if (value == 'theme') {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Text(user!.email ?? 'Usuário'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'account',
                child: Row(
                  children: [
                    const Icon(Icons.account_circle),
                    const SizedBox(width: 8),
                    const Text('Minha Conta'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'theme',
                child: Row(
                  children: [
                    const Icon(Icons.brightness_6),
                    const SizedBox(width: 8),
                    const Text('Alterar Tema'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    const Text('Sair'),
                  ],
                ),
              ),
            ],
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(user!.email ?? ''),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      child: Text(user!.email?.substring(0, 1).toUpperCase() ?? 'U'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}