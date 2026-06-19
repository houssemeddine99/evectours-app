import 'package:flutter/material.dart';

import '../api.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets.dart';

class VoyageDetailScreen extends StatefulWidget {
  const VoyageDetailScreen({super.key, required this.slug, this.title});
  final String slug;
  final String? title;

  @override
  State<VoyageDetailScreen> createState() => _VoyageDetailScreenState();
}

class _VoyageDetailScreenState extends State<VoyageDetailScreen> {
  Voyage? _v;
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
      final v = await Api.voyage(widget.slug);
      if (mounted) setState(() => _v = v);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load this voyage.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _bookingText {
    final v = _v;
    if (v == null) return 'Hello, I am interested in a voyage.';
    final dur = v.durationDays != null ? ', ${v.durationDays} days' : '';
    return 'Hello Evec Tours, I am interested in this trip: ${v.title} '
        '(${v.destination}$dur). Please send me details and availability.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Voyage')),
      bottomNavigationBar: _v == null ? null : _bookingBar(),
      body: _loading || _error != null
          ? StateView(loading: _loading, error: _error, onRetry: _load)
          : _content(_v!),
    );
  }

  Widget _content(Voyage v) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AspectRatio(aspectRatio: 16 / 10, child: NetImage(v.image)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.place_outlined, size: 16, color: kGold),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(v.destination.toUpperCase(),
                      style: const TextStyle(
                          color: kGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          letterSpacing: .6)),
                ),
              ]),
              const SizedBox(height: 8),
              Text(v.title,
                  style: const TextStyle(
                      color: kInk, fontSize: 24, fontWeight: FontWeight.w800, height: 1.15)),
              const SizedBox(height: 18),
              _infoRow(v),
              if (v.country != null) ...[
                const SizedBox(height: 18),
                _countryCard(v.country!),
              ],
              if (v.carbon?.co2PerPerson != null) ...[
                const SizedBox(height: 14),
                _carbonRow(v.carbon!),
              ],
              if (v.description.isNotEmpty) ...[
                const SizedBox(height: 22),
                const Text('About this journey',
                    style: TextStyle(color: kInk, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(v.description,
                    style: const TextStyle(color: kMuted, height: 1.6, fontSize: 14.5)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(Voyage v) {
    final items = <List<dynamic>>[
      [Icons.payments_outlined, 'From', formatPrice(v.price)],
      if (v.durationDays != null)
        [Icons.schedule, 'Duration', '${v.durationDays} days'],
      [Icons.flight_takeoff, 'Type', 'Premium'],
    ];
    return Row(
      children: items
          .map((it) => Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  decoration: BoxDecoration(
                    color: kIvory,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kHairline),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(it[0] as IconData, color: kGold, size: 20),
                    const SizedBox(height: 8),
                    Text(it[1] as String,
                        style: const TextStyle(color: kMuted, fontSize: 11, letterSpacing: .4)),
                    const SizedBox(height: 2),
                    Text(it[2] as String,
                        style: const TextStyle(
                            color: kInk, fontSize: 14, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ))
          .toList(),
    );
  }

  Widget _countryCard(Country c) {
    Widget fact(IconData i, String label, String? value) {
      if (value == null || value.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(i, size: 16, color: kGold),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: kMuted, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: kInk, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kHairline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(c.flagEmoji ?? '🏳', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text('Destination info — ${c.name}',
              style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 14)),
        ]),
        const SizedBox(height: 12),
        fact(Icons.account_balance, 'Capital', c.capital),
        fact(Icons.translate, 'Language', c.language),
        fact(Icons.payments, 'Currency', c.currency),
        fact(Icons.schedule, 'Timezone', c.timezone),
      ]),
    );
  }

  Widget _carbonRow(Carbon c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kHairline),
      ),
      child: Row(children: [
        const Text('🌍', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Carbon footprint: ${c.co2PerPerson} kg CO₂ / person'
            '${c.label != null ? ' · ${c.label}' : ''}',
            style: const TextStyle(color: kMuted, fontSize: 12.5),
          ),
        ),
      ]),
    );
  }

  Widget _bookingBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(top: BorderSide(color: kHairline)),
        ),
        child: Row(children: [
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => whatsappAgency(_bookingText),
              icon: const Icon(Icons.chat, size: 20),
              label: const Text('Book via WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 8),
          _circleBtn(Icons.call, kGold, callAgency),
          const SizedBox(width: 8),
          _circleBtn(Icons.mail_outline, kEvecBlue,
              () => emailAgency(subject: 'Booking inquiry: ${_v!.title}', body: _bookingText)),
        ]),
      ),
    );
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withValues(alpha: .12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(12), child: Icon(icon, color: color, size: 22)),
      ),
    );
  }
}
