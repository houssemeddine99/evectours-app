import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_store.dart';
import 'constants.dart';
import 'screens/home_screen.dart';
import 'screens/voyages_screen.dart';
import 'screens/offers_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthStore.instance.load();
  runApp(const EvecToursApp());
}

class EvecToursApp extends StatelessWidget {
  const EvecToursApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: kGold);
    return MaterialApp(
      title: 'Evec Tours',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: kBg,
        textTheme: GoogleFonts.interTextTheme(base.textTheme)
            .apply(bodyColor: kInk, displayColor: kInk),
        appBarTheme: AppBarTheme(
          backgroundColor: kBg,
          foregroundColor: kInk,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle:
              GoogleFonts.poppins(color: kInk, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
            textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kLine)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kLine)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kTeal, width: 1.6)),
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
      const AccountScreen(),
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
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: kGold),
                label: 'Account'),
          ],
        ),
      ),
    );
  }
}
