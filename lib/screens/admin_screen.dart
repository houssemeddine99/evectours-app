import 'package:flutter/material.dart';

import '../api.dart';
import '../auth_store.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets.dart';
import 'admin_reservations_screen.dart';
import 'admin_voyages_screen.dart';
import 'admin_users_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  AdminStats? _stats;
  List<AdminReservation> _recent = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = AuthStore.instance.token;
    if (token == null) {
      setState(() {
        _loading = false;
        _error = 'Not authenticated.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await Api.adminStats(token);
      final res = await Api.adminReservations(token);
      if (mounted) {
        setState(() {
          _stats = stats;
          _recent = res.take(4).toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin dashboard')),
      body: _loading || _error != null
          ? StateView(loading: _loading, error: _error, onRetry: _load)
          : RefreshIndicator(
              color: kBlue,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  _hero(),
                  const SizedBox(height: 18),
                  _kpiGrid(),
                  const SizedBox(height: 24),
                  _sectionTitle('Manage'),
                  const SizedBox(height: 12),
                  _manageGrid(),
                  const SizedBox(height: 24),
                  _sectionTitle('More — web admin'),
                  const SizedBox(height: 12),
                  _webGrid(),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: _sectionTitle('Recent bookings')),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AdminReservationsScreen())),
                      child: const Text('View all',
                          style: TextStyle(color: kBlueDark, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  if (_recent.isEmpty)
                    _box('No bookings yet.')
                  else
                    ..._recent.map(_recentCard),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: poppins(size: 17, weight: FontWeight.w800));

  Widget _hero() {
    final s = _stats ?? AdminStats();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [kBlue, kBlueDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x330078D8), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Total revenue',
            style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 13)),
        const SizedBox(height: 4),
        Text(formatPrice(s.revenue.toStringAsFixed(0)),
            style: poppins(size: 30, weight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 14),
        Row(children: [
          _heroStat('${s.reservations}', 'Bookings'),
          _heroDivider(),
          _heroStat('${s.pending}', 'Pending'),
          _heroDivider(),
          _heroStat('${s.users}', 'Users'),
        ]),
      ]),
    );
  }

  Widget _heroStat(String v, String l) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(v, style: poppins(size: 18, weight: FontWeight.w800, color: Colors.white)),
          Text(l, style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 12)),
        ]),
      );

  Widget _heroDivider() =>
      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: .25));

  Widget _kpiGrid() {
    final s = _stats ?? AdminStats();
    final cards = [
      [Icons.luggage, 'Voyages', '${s.voyages}', kBlue],
      [Icons.event_available, 'Paid', '${s.paid}', kGreen],
      [Icons.pending_actions, 'Pending', '${s.pending}', kAmber],
      [Icons.groups, 'Users', '${s.users}', kBlueDark],
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: cards.map((c) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kLine),
            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                    color: (c[3] as Color).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(c[0] as IconData, color: c[3] as Color, size: 19),
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(c[2] as String, style: poppins(size: 20, weight: FontWeight.w800)),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(c[1] as String, style: const TextStyle(color: kMuted, fontSize: 12.5)),
                ),
              ]),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _manageGrid() {
    final tiles = [
      _Tile(Icons.event_note, 'Reservations', kBlue, () => _go(const AdminReservationsScreen())),
      _Tile(Icons.luggage, 'Voyages', kGreen, () => _go(const AdminVoyagesScreen())),
      _Tile(Icons.groups, 'Users', kBlueDark, () => _go(const AdminUsersScreen())),
    ];
    return _grid(tiles);
  }

  Widget _webGrid() {
    final tiles = [
      _Tile(Icons.local_offer, 'Offers', kCoral, _web, web: true),
      _Tile(Icons.hiking, 'Activities', kOrange, _web, web: true),
      _Tile(Icons.star, 'Reviews', kAmber, _web, web: true),
      _Tile(Icons.report_problem, 'Reclamations', kCoral, _web, web: true),
      _Tile(Icons.receipt_long, 'Refunds', kBlueDark, _web, web: true),
      _Tile(Icons.insights, 'Analytics', kGreen, _web, web: true),
    ];
    return _grid(tiles);
  }

  Widget _grid(List<_Tile> tiles) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: .92,
      children: tiles.map((t) {
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: t.onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kLine),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(clipBehavior: Clip.none, children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                        color: t.color.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(t.icon, color: t.color, size: 22),
                  ),
                  if (t.web)
                    const Positioned(
                        right: -4, top: -4,
                        child: Icon(Icons.open_in_new, size: 13, color: kMuted)),
                ]),
                const SizedBox(height: 8),
                Text(t.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: kInk)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _go(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  void _web() => launchExternal(kAdminWebBase);

  Widget _recentCard(AdminReservation r) {
    final paid = (r.paymentStatus ?? '').toUpperCase() == 'PAID';
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kLine),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.customer ?? '—', style: poppins(size: 14, weight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(r.voyageTitle ?? '',
                style: const TextStyle(color: kMuted, fontSize: 12.5),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: paid ? const Color(0x1416A34A) : const Color(0x140078D8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(r.paymentStatus ?? r.status ?? '—',
              style: TextStyle(
                  color: paid ? kGreen : kBlueDark, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _box(String msg) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine)),
        child: Text(msg, style: const TextStyle(color: kMuted)),
      );
}

class _Tile {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool web;
  _Tile(this.icon, this.label, this.color, this.onTap, {this.web = false});
}
