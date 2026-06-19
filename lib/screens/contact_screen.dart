import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          const Text('Get in touch',
              style: TextStyle(color: kInk, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Our travel experts reply fast — 7 days a week.',
              style: TextStyle(color: kMuted, fontSize: 14.5, height: 1.5)),
          const SizedBox(height: 22),
          _tile(
            icon: Icons.chat,
            color: const Color(0xFF25D366),
            title: 'WhatsApp',
            subtitle: 'Chat with an agent',
            onTap: () => whatsappAgency(
                'Hello Evec Tours, I would like some information.'),
          ),
          _tile(
            icon: Icons.call,
            color: kGold,
            title: 'Call us',
            subtitle: kPhone,
            onTap: callAgency,
          ),
          _tile(
            icon: Icons.mail_outline,
            color: kEvecBlue,
            title: 'Email us',
            subtitle: kEmail,
            onTap: () => emailAgency(subject: 'Travel inquiry — Evec Tours'),
          ),
          _tile(
            icon: Icons.location_on_outlined,
            color: const Color(0xFFE05A2B),
            title: 'Find us',
            subtitle: 'Open in Maps',
            onTap: () => launchExternal(
                'https://www.google.com/maps/search/?api=1&query=$kMapsQuery'),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => launchExternal(kSiteUrl),
              child: const Text('Visit evectours.com',
                  style: TextStyle(color: kGoldDark, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kHairline),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(color: kInk, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: kMuted)),
        trailing: const Icon(Icons.chevron_right, color: kMuted),
      ),
    );
  }
}
