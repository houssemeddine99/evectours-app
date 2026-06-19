import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'models.dart';

/// "5200" / "5200.00" -> "5,200 TND" ; null/empty -> "Contact us".
String formatPrice(String? price) {
  if (price == null || price.trim().isEmpty) return 'Contact us';
  final v = double.tryParse(price);
  if (v == null) return price;
  final whole = v.round();
  final s = whole.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return 'TND ${buf.toString()}';
}

Future<void> launchExternal(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> callAgency() => launchExternal('tel:$kPhone');

Future<void> whatsappAgency([String? text]) {
  final t = text != null ? '?text=${Uri.encodeComponent(text)}' : '';
  return launchExternal('https://wa.me/$kWhatsApp$t');
}

Future<void> emailAgency({String? subject, String? body}) {
  final params = <String>[];
  if (subject != null) params.add('su=${Uri.encodeComponent(subject)}');
  if (body != null) params.add('body=${Uri.encodeComponent(body)}');
  final q = params.isEmpty ? '' : '&${params.join('&')}';
  return launchExternal(
      'https://mail.google.com/mail/?view=cm&fs=1&to=$kEmail$q');
}

/// A network image with graceful loading + fallback.
class NetImage extends StatelessWidget {
  const NetImage(this.url, {super.key, this.fit = BoxFit.cover});
  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return Image.network(
      url!,
      fit: fit,
      loadingBuilder: (c, child, p) =>
          p == null ? child : _placeholder(loading: true),
      errorBuilder: (c, e, s) => _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) => Container(
        color: kIvory,
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2, color: kGold))
            : const Icon(Icons.image_outlined, color: kHairline, size: 40),
      );
}

class VoyageCard extends StatelessWidget {
  const VoyageCard({super.key, required this.voyage, required this.onTap});
  final Voyage voyage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kHairline),
      ),
      color: kSurface,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 16 / 9, child: NetImage(voyage.image)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 15, color: kGold),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          voyage.destination,
                          style: const TextStyle(
                              color: kGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: .3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    voyage.title,
                    style: const TextStyle(
                        color: kInk, fontSize: 17, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        formatPrice(voyage.price),
                        style: const TextStyle(
                            color: kGoldDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      if (voyage.durationDays != null)
                        _Chip(icon: Icons.schedule, label: '${voyage.durationDays} days'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kIvory,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kHairline),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: kMuted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: kMuted)),
      ]),
    );
  }
}

/// Generic loading / error / retry view used by screens.
class StateView extends StatelessWidget {
  const StateView({super.key, this.loading = false, this.error, this.onRetry});
  final bool loading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: kGold));
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: kGold, size: 48),
            const SizedBox(height: 12),
            Text(error ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kInk, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (onRetry != null)
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: kGold, foregroundColor: Colors.white),
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
          ],
        ),
      ),
    );
  }
}
