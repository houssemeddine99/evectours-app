import 'package:flutter/material.dart';

import '../api.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets.dart';
import 'voyage_detail_screen.dart';

class VoyagesScreen extends StatefulWidget {
  const VoyagesScreen({super.key});

  @override
  State<VoyagesScreen> createState() => _VoyagesScreenState();
}

class _VoyagesScreenState extends State<VoyagesScreen> {
  List<Voyage> _all = [];
  String _query = '';
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final v = await Api.voyages();
      if (mounted) setState(() => _all = v);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load voyages.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Voyage> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all
        .where((v) =>
            v.title.toLowerCase().contains(q) ||
            v.destination.toLowerCase().contains(q))
        .toList();
  }

  void _open(Voyage v) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => VoyageDetailScreen(slug: v.slug, title: v.title),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voyages')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search destinations…',
                prefixIcon: const Icon(Icons.search, color: kMuted),
                filled: true,
                fillColor: kSurface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: kHairline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: kGold),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading || _error != null
                ? StateView(loading: _loading, error: _error, onRetry: _load)
                : RefreshIndicator(
                    color: kGold,
                    onRefresh: _load,
                    child: _filtered.isEmpty
                        ? ListView(children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Text('No voyages found',
                                  style: TextStyle(color: kMuted, fontSize: 16)),
                            ),
                          ])
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) =>
                                VoyageCard(voyage: _filtered[i], onTap: () => _open(_filtered[i])),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
