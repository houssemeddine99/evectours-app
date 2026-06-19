import 'package:flutter/material.dart';

import '../api.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<Offer> _offers = [];
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
      final o = await Api.offers();
      if (mounted) setState(() => _offers = o);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load offers.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offers')),
      body: _loading || _error != null
          ? StateView(loading: _loading, error: _error, onRetry: _load)
          : RefreshIndicator(
              color: kGold,
              onRefresh: _load,
              child: _offers.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 90),
                      Icon(Icons.local_offer_outlined, size: 54, color: kHairline),
                      SizedBox(height: 12),
                      Center(
                        child: Text('No active offers right now',
                            style: TextStyle(color: kMuted, fontSize: 16)),
                      ),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _offers.length,
                      itemBuilder: (_, i) => _offerCard(_offers[i]),
                    ),
            ),
    );
  }

  Widget _offerCard(Offer o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x73B8862E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (o.discountPercentage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: kGold, borderRadius: BorderRadius.circular(20)),
                child: Text('-${o.discountPercentage}%',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            const Spacer(),
            if (o.endDate != null)
              Text('Until ${o.endDate}',
                  style: const TextStyle(color: kMuted, fontSize: 12)),
          ]),
          const SizedBox(height: 12),
          Text(o.title,
              style: const TextStyle(color: kInk, fontSize: 17, fontWeight: FontWeight.w700)),
          if (o.voyageTitle != null) ...[
            const SizedBox(height: 4),
            Text(o.voyageTitle!, style: const TextStyle(color: kGoldDark, fontSize: 13)),
          ],
          if (o.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(o.description,
                style: const TextStyle(color: kMuted, height: 1.5, fontSize: 14)),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white),
            onPressed: () => whatsappAgency(
                'Hello Evec Tours, I am interested in your offer: ${o.title}.'),
            icon: const Icon(Icons.chat, size: 18),
            label: const Text('Claim via WhatsApp'),
          ),
        ],
      ),
    );
  }
}
