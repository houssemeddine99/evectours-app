import 'package:flutter/material.dart';

import '../api.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets.dart';
import 'voyage_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onTab});

  /// Switch the bottom-nav tab (1 = Voyages, 2 = Offers, 3 = Contact).
  final void Function(int index) onTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Voyage> _featured = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final v = await Api.voyages();
      if (mounted) setState(() => _featured = v.take(6).toList());
    } catch (_) {
      // Home stays usable even if featured fails to load.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _hero(),
            _quickActions(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text('Featured voyages',
                  style: TextStyle(color: kInk, fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            _featuredList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDFBF7), Color(0xFFF4EEE2)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('✈', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text('YOUR TRUSTED TRAVEL PARTNER',
                style: TextStyle(
                    color: kGoldDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 14),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: kInk, fontSize: 30, fontWeight: FontWeight.w800, height: 1.15),
              children: [
                TextSpan(text: 'Discover '),
                TextSpan(text: 'Unforgettable', style: TextStyle(color: kGold)),
                TextSpan(text: '\nJourneys'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Curated voyages, exclusive offers, and a team that replies fast.',
              style: TextStyle(color: kInk, fontSize: 14.5, height: 1.5)),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13)),
            onPressed: () => widget.onTab(1),
            child: const Text('Explore voyages', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    final items = [
      [Icons.luggage, 'Voyages', 1],
      [Icons.local_offer, 'Offers', 2],
      [Icons.support_agent, 'Contact', 3],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Row(
        children: items.map((it) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => widget.onTab(it[2] as int),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kHairline),
                  ),
                  child: Column(children: [
                    Icon(it[0] as IconData, color: kGold, size: 24),
                    const SizedBox(height: 8),
                    Text(it[1] as String,
                        style: const TextStyle(
                            color: kInk, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _featuredList() {
    if (_loading) {
      return const SizedBox(
        height: 230,
        child: Center(child: CircularProgressIndicator(color: kGold)),
      );
    }
    if (_featured.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No voyages yet — check back soon.', style: TextStyle(color: kMuted)),
      );
    }
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
        itemCount: _featured.length,
        itemBuilder: (_, i) {
          final v = _featured[i];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => VoyageDetailScreen(slug: v.slug, title: v.title),
            )),
            child: Container(
              width: 230,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kHairline),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AspectRatio(aspectRatio: 16 / 10, child: NetImage(v.image)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v.destination,
                        style: const TextStyle(
                            color: kGold, fontSize: 11, fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(v.title,
                        style: const TextStyle(
                            color: kInk, fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(formatPrice(v.price),
                        style: const TextStyle(
                            color: kGoldDark, fontSize: 14, fontWeight: FontWeight.w800)),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
