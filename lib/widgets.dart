import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'models.dart';

/// Poppins helper for headings (matches the website's display font).
TextStyle poppins({
  double? size,
  FontWeight weight = FontWeight.w700,
  Color color = kInk,
  double? height,
  double spacing = 0,
}) =>
    GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );

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
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kHairline),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'voyage-${voyage.slug}',
                  child: AspectRatio(aspectRatio: 16 / 9, child: NetImage(voyage.image)),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: .42)],
                        stops: const [0.5, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(left: 12, bottom: 12, child: _pill(Icons.place, voyage.destination)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(voyage.title,
                      style: poppins(size: 17, weight: FontWeight.w700, height: 1.15),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(children: [
                    Text(formatPrice(voyage.price),
                        style: poppins(size: 16, weight: FontWeight.w800, color: kGoldDark)),
                    const Spacer(),
                    if (voyage.durationDays != null)
                      _Chip(icon: Icons.schedule, label: '${voyage.durationDays} days'),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
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

/// ── Auth form building blocks ──────────────────────────
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboard,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c));
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kMuted),
          filled: true,
          fillColor: kSurface,
          border: border(kHairline),
          enabledBorder: border(kHairline),
          focusedBorder: border(kGold),
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.label, required this.onPressed, this.loading = false});
  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
            backgroundColor: kGold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15)),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}

class AuthError extends StatelessWidget {
  const AuthError(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3C2C2)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Color(0xFFB91C1C), size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13))),
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
