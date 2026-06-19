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
      if (mounted) setState(() => _featured = v.take(8).toList());
    } catch (_) {
      // home stays usable even if featured fails
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
          padding: const EdgeInsets.only(bottom: 26),
          children: [
            _header(),
            _searchBar(),
            const SizedBox(height: 16),
            _categories(),
            const SizedBox(height: 18),
            _promoBanner(),
            const SizedBox(height: 24),
            _sectionHeader('Featured voyages', () => widget.onTab(1)),
            _featuredList(),
            const SizedBox(height: 26),
            _whyUs(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hi there 👋', style: TextStyle(color: kMuted, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Where to next?', style: poppins(size: 26, weight: FontWeight.w800)),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: kTeal.withValues(alpha: .12), shape: BoxShape.circle),
            child: const Icon(Icons.travel_explore, color: kTeal),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: GestureDetector(
        onTap: () => widget.onTab(1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kLine),
            boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))],
          ),
          child: const Row(children: [
            Icon(Icons.search, color: kTeal),
            SizedBox(width: 10),
            Text('Search destinations…', style: TextStyle(color: kMuted, fontSize: 15)),
          ]),
        ),
      ),
    );
  }

  Widget _categories() {
    const cats = [
      ['🕋', 'Umrah'],
      ['🏖️', 'Beach'],
      ['🏙️', 'City'],
      ['⛰️', 'Adventure'],
      ['🚢', 'Cruise'],
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => widget.onTab(1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: kLine)),
            child: Row(children: [
              Text(cats[i][0]),
              const SizedBox(width: 6),
              Text(cats[i][1],
                  style: const TextStyle(fontWeight: FontWeight.w600, color: kInk, fontSize: 13)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _whyUs() {
    const items = [
      [Icons.verified_user, 'Secure payments'],
      [Icons.local_offer, 'Best price guarantee'],
      [Icons.map, 'Expert local guides'],
      [Icons.chat, '24/7 WhatsApp support'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Why Evec Tours', style: poppins(size: 18, weight: FontWeight.w800)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.6,
          children: items.map((it) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kLine)),
              child: Row(children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      color: kTeal.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(it[0] as IconData, color: kTeal, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(it[1] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: kInk, fontSize: 12.5)),
                ),
              ]),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _promoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [kTeal, kTealDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Color(0x330D9488), blurRadius: 18, offset: Offset(0, 10))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan with our experts',
                      style: poppins(size: 17, weight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Tell us your dream trip — we reply fast.',
                      style: TextStyle(color: Colors.white.withValues(alpha: .92), fontSize: 13, height: 1.4)),
                  const SizedBox(height: 14),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kTealDark,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                    onPressed: () =>
                        whatsappAgency('Hello Evec Tours, I would like help planning a trip.'),
                    child: const Text('Chat on WhatsApp'),
                  ),
                ],
              ),
            ),
            const Icon(Icons.travel_explore, color: Colors.white24, size: 70),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
      child: Row(children: [
        Text(title, style: poppins(size: 18, weight: FontWeight.w800)),
        const Spacer(),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('See all',
              style: TextStyle(color: kTealDark, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _featuredList() {
    if (_loading) {
      return const SizedBox(height: 264, child: Center(child: CircularProgressIndicator(color: kTeal)));
    }
    if (_featured.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Text('No voyages yet — check back soon.', style: TextStyle(color: kMuted)),
      );
    }
    return SizedBox(
      height: 270,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 6, 12, 8),
        itemCount: _featured.length,
        itemBuilder: (_, i) {
          final v = _featured[i];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => VoyageDetailScreen(slug: v.slug, title: v.title),
            )),
            child: Container(
              width: 240,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 8))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Stack(children: [
                  Hero(
                    tag: 'voyage-${v.slug}',
                    child: AspectRatio(aspectRatio: 16 / 11, child: NetImage(v.image)),
                  ),
                  if (v.durationDays != null)
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Text('${v.durationDays} days',
                            style: poppins(size: 11, weight: FontWeight.w700, color: kTealDark)),
                      ),
                    ),
                ]),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.place, size: 13, color: kTeal),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(v.destination,
                            style: const TextStyle(color: kMuted, fontSize: 11.5),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(v.title,
                        style: poppins(size: 14.5, weight: FontWeight.w700, height: 1.15),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(formatPrice(v.price),
                        style: poppins(size: 15, weight: FontWeight.w800, color: kTealDark)),
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
