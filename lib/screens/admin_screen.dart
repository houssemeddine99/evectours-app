import 'package:flutter/material.dart';

import '../api.dart';
import '../auth_store.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  AdminStats? _stats;
  List<AdminReservation> _res = [];
  bool _loading = true;
  String? _error;
  int? _busyId;

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
          _res = res;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _action(int id, bool confirm) async {
    final token = AuthStore.instance.token;
    if (token == null) return;
    setState(() => _busyId = id);
    try {
      if (confirm) {
        await Api.adminConfirm(token, id);
      } else {
        await Api.adminCancel(token, id);
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(confirm ? 'Booking confirmed' : 'Booking cancelled')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin dashboard')),
      body: _loading || _error != null
          ? StateView(loading: _loading, error: _error, onRetry: _load)
          : RefreshIndicator(
              color: kTeal,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _statsGrid(),
                  const SizedBox(height: 24),
                  Text('Bookings', style: poppins(size: 18, weight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  if (_res.isEmpty)
                    _emptyBox('No bookings yet.')
                  else
                    ..._res.map(_resCard),
                ],
              ),
            ),
    );
  }

  Widget _statsGrid() {
    final s = _stats ?? AdminStats();
    final cards = [
      [Icons.luggage, 'Voyages', '${s.voyages}', kTeal],
      [Icons.event_note, 'Bookings', '${s.reservations}', kEvecBlue],
      [Icons.verified, 'Paid', '${s.paid}', const Color(0xFF16A34A)],
      [Icons.payments, 'Revenue', formatPrice(s.revenue.toStringAsFixed(0)), kTealDark],
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: cards.map((c) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kLine),
            boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(c[0] as IconData, color: c[3] as Color, size: 22),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c[2] as String, style: poppins(size: 20, weight: FontWeight.w800)),
                Text(c[1] as String, style: const TextStyle(color: kMuted, fontSize: 12.5)),
              ]),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _resCard(AdminReservation r) {
    final paid = (r.paymentStatus ?? '').toUpperCase() == 'PAID';
    final cancelled = (r.status ?? '').toUpperCase() == 'CANCELLED';
    final busy = _busyId == r.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(r.voyageTitle ?? 'Voyage',
                style: poppins(size: 14.5, weight: FontWeight.w700)),
          ),
          _badge(r.paymentStatus ?? r.status ?? '—', paid),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.person_outline, size: 14, color: kMuted),
          const SizedBox(width: 4),
          Expanded(
            child: Text('${r.customer ?? '—'}  ·  ${r.email ?? ''}',
                style: const TextStyle(color: kMuted, fontSize: 12.5),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Text(formatPrice(r.totalPrice),
              style: poppins(size: 14, weight: FontWeight.w800, color: kTealDark)),
          if (r.people != null) ...[
            const SizedBox(width: 8),
            Text('· ${r.people} pax', style: const TextStyle(color: kMuted, fontSize: 12.5)),
          ],
        ]),
        if (!paid && !cancelled) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(vertical: 10)),
                onPressed: busy ? null : () => _action(r.id!, true),
                child: busy
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Confirm paid'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB91C1C),
                  side: const BorderSide(color: Color(0x33B91C1C)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16)),
              onPressed: busy ? null : () => _action(r.id!, false),
              child: const Text('Cancel'),
            ),
          ]),
        ],
      ]),
    );
  }

  Widget _badge(String text, bool good) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: good ? const Color(0x1416A34A) : const Color(0x140D9488),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: good ? const Color(0xFF15803D) : kTealDark,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );

  Widget _emptyBox(String msg) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: kLine)),
        child: Text(msg, style: const TextStyle(color: kMuted)),
      );
}
