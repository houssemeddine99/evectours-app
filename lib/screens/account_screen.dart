import 'package:flutter/material.dart';

import '../api.dart';
import '../auth_store.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets.dart';
import 'admin_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthStore.instance,
      builder: (context, _) {
        final store = AuthStore.instance;
        return Scaffold(
          appBar: AppBar(title: const Text('Account')),
          body: store.isLoggedIn ? _LoggedIn(user: store.user!) : const _LoggedOut(),
        );
      },
    );
  }
}

class _LoggedOut extends StatelessWidget {
  const _LoggedOut();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_circle_outlined, size: 72, color: kGold),
            const SizedBox(height: 16),
            Text('Your account', style: poppins(size: 20, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Sign in to view your bookings and manage your trips.',
                textAlign: TextAlign.center, style: TextStyle(color: kMuted)),
            const SizedBox(height: 22),
            AuthButton(
              label: 'Sign in',
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen())),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: kGoldDark,
                    side: const BorderSide(color: kHairline),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('Create an account',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggedIn extends StatefulWidget {
  const _LoggedIn({required this.user});
  final AppUser user;

  @override
  State<_LoggedIn> createState() => _LoggedInState();
}

class _LoggedInState extends State<_LoggedIn> {
  List<Booking> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final token = AuthStore.instance.token;
    if (token == null) return;
    try {
      final r = await Api.account(token);
      if (mounted) setState(() => _bookings = r.bookings);
    } catch (_) {
      // keep profile usable even if bookings fail
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final initial = (u.username.isNotEmpty ? u.username[0] : '?').toUpperCase();
    return RefreshIndicator(
      color: kGold,
      onRefresh: _loadBookings,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: kGold,
              backgroundImage: (u.imageUrl != null && u.imageUrl!.isNotEmpty)
                  ? NetworkImage(u.imageUrl!)
                  : null,
              child: (u.imageUrl == null || u.imageUrl!.isEmpty)
                  ? Text(initial,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u.username, style: poppins(size: 18, weight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(u.email, style: const TextStyle(color: kMuted, fontSize: 13)),
              ]),
            ),
          ]),
          if (u.isAdmin) ...[
            const SizedBox(height: 22),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AdminScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kTeal, kTealDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(children: [
                  const Icon(Icons.dashboard_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Admin dashboard',
                          style: poppins(size: 15, weight: FontWeight.w800, color: Colors.white)),
                      Text('Stats & manage bookings',
                          style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 12.5)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 26),
          Text('My bookings', style: poppins(size: 16, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator(color: kGold)),
            )
          else if (_bookings.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kHairline)),
              child: const Row(children: [
                Icon(Icons.luggage_outlined, color: kMuted),
                SizedBox(width: 12),
                Expanded(child: Text('No bookings yet.', style: TextStyle(color: kMuted))),
              ]),
            )
          else
            ..._bookings.map(_bookingCard),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB91C1C),
                  side: const BorderSide(color: Color(0x33B91C1C)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => AuthStore.instance.logout(),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(Booking b) {
    final paid = (b.paymentStatus ?? '').toUpperCase() == 'PAID';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kHairline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(b.voyageTitle ?? 'Voyage',
            style: poppins(size: 14.5, weight: FontWeight.w700)),
        if (b.destination != null) ...[
          const SizedBox(height: 2),
          Text(b.destination!, style: const TextStyle(color: kMuted, fontSize: 12.5)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          if (b.totalPrice != null)
            Text(formatPrice(b.totalPrice),
                style: poppins(size: 14, weight: FontWeight.w800, color: kGoldDark)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: paid ? const Color(0x1416A34A) : const Color(0x140D9488),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(b.paymentStatus ?? (b.status ?? '—'),
                style: TextStyle(
                    color: paid ? const Color(0xFF15803D) : kGoldDark,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }
}
