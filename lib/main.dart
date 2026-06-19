import 'package:flutter/material.dart';

import 'constants.dart';
import 'screens/home_screen.dart';
import 'screens/voyages_screen.dart';
import 'screens/offers_screen.dart';
import 'screens/contact_screen.dart';

void main() => runApp(const EvecToursApp());

class EvecToursApp extends StatelessWidget {
  const EvecToursApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: kGold);
    return MaterialApp(
      title: 'Evec Tours',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: kIvory,
        appBarTheme: const AppBarTheme(
          backgroundColor: kIvory,
          foregroundColor: kInk,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
              color: kInk, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onTab: _go),
      const VoyagesScreen(),
      const OffersScreen(),
      const ContactScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: kSurface,
          indicatorColor: kGold.withValues(alpha: .15),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _go,
          height: 64,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: kGold),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.luggage_outlined),
                selectedIcon: Icon(Icons.luggage, color: kGold),
                label: 'Voyages'),
            NavigationDestination(
                icon: Icon(Icons.local_offer_outlined),
                selectedIcon: Icon(Icons.local_offer, color: kGold),
                label: 'Offers'),
            NavigationDestination(
                icon: Icon(Icons.support_agent_outlined),
                selectedIcon: Icon(Icons.support_agent, color: kGold),
                label: 'Contact'),
          ],
        ),
      ),
    );
  }
}
