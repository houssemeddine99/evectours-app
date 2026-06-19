import 'package:flutter/material.dart';

/// API + site
const String kApiBase = 'https://evectours.com/api/v1';
const String kSiteUrl = 'https://evectours.com';

/// Agency contact
const String kPhone = '+21698365730';
const String kWhatsApp = '21698365730';
const String kEmail = 'contact@evectours.com';
const String kMapsQuery = '36.094556,9.570250';

/// ── "Vibrant Ocean" palette ──────────────────────────────
const Color kTeal = Color(0xFF0D9488); // primary
const Color kTealDark = Color(0xFF0F766E);
const Color kTealSoft = Color(0xFF99F6E4); // light teal (on dark / tints)
const Color kCoral = Color(0xFFFB7185); // offers / discounts accent
const Color kBg = Color(0xFFF6FAFB); // scaffold background
const Color kSurface = Color(0xFFFFFFFF); // cards
const Color kInk = Color(0xFF0F172A); // headings
const Color kMuted = Color(0xFF64748B); // secondary text
const Color kLine = Color(0xFFE6EDEF); // hairline borders

/// Back-compat aliases so existing screens keep compiling, remapped to the new palette.
const Color kGold = kTeal;
const Color kGoldDark = kTealDark;
const Color kGoldSoft = kTealSoft;
const Color kIvory = kBg;
const Color kHairline = kLine;
const Color kEvecBlue = kTeal;
