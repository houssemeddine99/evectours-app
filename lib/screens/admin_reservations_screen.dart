import 'package:flutter/material.dart';

import '../api.dart';
import '../auth_store.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() => _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
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
    if (token == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Api.adminReservations(token);
      if (mounted) setState(() => _res = res);
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
      confirm ? await Api.adminConfirm(token, id) : await Api.adminCancel(token, id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(confirm ? 'Booking confirmed as paid' : 'Booking cancelled')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservations')),
      body: _loading || _error != null
          ? StateView(loading: _loading, error: _error, onRetry: _load)
          : RefreshIndicator(
              color: kBlue,
              onRefresh: _load,
              child: _res.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 100),
                      Center(child: Text('No reservations yet.', style: TextStyle(color: kMuted))),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _res.length,
                      itemBuilder: (_, i) => _card(_res[i]),
                    ),
            ),
    );
  }

  Widget _card(AdminReservation r) {
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
          Expanded(child: Text(r.voyageTitle ?? 'Voyage', style: poppins(size: 14.5, weight: FontWeight.w700))),
          _badge(r.paymentStatus ?? r.status ?? '—', paid, cancelled),
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
          Text(formatPrice(r.totalPrice), style: poppins(size: 14, weight: FontWeight.w800, color: kBlueDark)),
          if (r.people != null) ...[
            const SizedBox(width: 8),
            Text('· ${r.people} pax', style: const TextStyle(color: kMuted, fontSize: 12.5)),
          ],
          const Spacer(),
          if (r.date != null) Text(r.date!, style: const TextStyle(color: kMuted, fontSize: 12)),
        ]),
        if (!paid && !cancelled) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: kGreen, padding: const EdgeInsets.symmetric(vertical: 10)),
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

  Widget _badge(String text, bool good, bool bad) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: bad
              ? const Color(0x14B91C1C)
              : (good ? const Color(0x1416A34A) : const Color(0x140078D8)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: bad ? const Color(0xFFB91C1C) : (good ? kGreen : kBlueDark),
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );
}
