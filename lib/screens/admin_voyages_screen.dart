import 'package:flutter/material.dart';

import '../api.dart';
import '../auth_store.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets.dart';

class AdminVoyagesScreen extends StatefulWidget {
  const AdminVoyagesScreen({super.key});

  @override
  State<AdminVoyagesScreen> createState() => _AdminVoyagesScreenState();
}

class _AdminVoyagesScreenState extends State<AdminVoyagesScreen> {
  List<Voyage> _voyages = [];
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
      final v = await Api.adminVoyages(token);
      if (mounted) setState(() => _voyages = v);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(Voyage v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete voyage?'),
        content: Text('“${v.title}” will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || v.id == null) return;
    final token = AuthStore.instance.token;
    if (token == null) return;
    setState(() => _busyId = v.id);
    try {
      await Api.adminDeleteVoyage(token, v.id!);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voyage deleted')));
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
      appBar: AppBar(title: const Text('Voyages')),
      body: _loading || _error != null
          ? StateView(loading: _loading, error: _error, onRetry: _load)
          : RefreshIndicator(
              color: kBlue,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                        color: kBlueSoft.withValues(alpha: .4),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      const Icon(Icons.info_outline, color: kBlueDark, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                          child: Text('Create & edit voyages in the web admin for now.',
                              style: TextStyle(color: kBlueDark, fontSize: 12.5))),
                      TextButton(
                        onPressed: () => launchExternal('$kAdminWebBase/voyages'),
                        child: const Text('Open', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                  if (_voyages.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('No voyages yet.', style: TextStyle(color: kMuted))),
                    )
                  else
                    ..._voyages.map(_row),
                ],
              ),
            ),
    );
  }

  Widget _row(Voyage v) {
    final busy = _busyId == v.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [
        SizedBox(width: 84, height: 84, child: NetImage(v.image)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.title,
                  style: poppins(size: 14, weight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(v.destination,
                  style: const TextStyle(color: kMuted, fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text(formatPrice(v.price),
                  style: poppins(size: 13.5, weight: FontWeight.w800, color: kBlueDark)),
            ]),
          ),
        ),
        IconButton(
          onPressed: busy ? null : () => _delete(v),
          icon: busy
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.delete_outline, color: Color(0xFFB91C1C)),
        ),
      ]),
    );
  }
}
