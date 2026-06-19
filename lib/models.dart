// Data models for the Evec Tours API.

class Voyage {
  final String slug;
  final String title;
  final String destination;
  final String? price;
  final int? durationDays;
  final String? image;
  final String summary;

  // Detail-only fields
  final String description;
  final List<String> images;
  final String? startDate;
  final String? endDate;
  final Carbon? carbon;
  final Country? country;
  final Offer? offer;

  Voyage({
    required this.slug,
    required this.title,
    required this.destination,
    this.price,
    this.durationDays,
    this.image,
    this.summary = '',
    this.description = '',
    this.images = const [],
    this.startDate,
    this.endDate,
    this.carbon,
    this.country,
    this.offer,
  });

  factory Voyage.fromList(Map<String, dynamic> j) => Voyage(
        slug: j['slug'] ?? '',
        title: j['title'] ?? '',
        destination: j['destination'] ?? '',
        price: j['price']?.toString(),
        durationDays: j['duration_days'] is int
            ? j['duration_days']
            : int.tryParse('${j['duration_days'] ?? ''}'),
        image: j['image'],
        summary: j['summary'] ?? '',
      );

  factory Voyage.fromDetail(Map<String, dynamic> j) => Voyage(
        slug: j['slug'] ?? '',
        title: j['title'] ?? '',
        destination: j['destination'] ?? '',
        price: j['price']?.toString(),
        durationDays: j['duration_days'] is int
            ? j['duration_days']
            : int.tryParse('${j['duration_days'] ?? ''}'),
        image: j['image'],
        description: j['description'] ?? '',
        images: (j['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        startDate: j['start_date'],
        endDate: j['end_date'],
        carbon: j['carbon'] != null ? Carbon.fromJson(j['carbon']) : null,
        country: j['country'] != null ? Country.fromJson(j['country']) : null,
        offer: j['offer'] != null ? Offer.fromJson(j['offer']) : null,
      );
}

class Carbon {
  final num? co2PerPerson;
  final num? distanceKm;
  final String? label;
  Carbon({this.co2PerPerson, this.distanceKm, this.label});
  factory Carbon.fromJson(Map<String, dynamic> j) => Carbon(
        co2PerPerson: j['co2_per_person'],
        distanceKm: j['distance_km'],
        label: j['label'],
      );
}

class Country {
  final String name;
  final String? flagSvg;
  final String? flagEmoji;
  final String? capital;
  final String? language;
  final String? currency;
  final String? timezone;
  Country({
    required this.name,
    this.flagSvg,
    this.flagEmoji,
    this.capital,
    this.language,
    this.currency,
    this.timezone,
  });
  factory Country.fromJson(Map<String, dynamic> j) => Country(
        name: j['name'] ?? '',
        flagSvg: j['flag_svg'],
        flagEmoji: j['flag_emoji'],
        capital: j['capital'],
        language: j['language'],
        currency: j['currency'],
        timezone: j['timezone'],
      );
}

class Offer {
  final String title;
  final String description;
  final num? discountPercentage;
  final String? voyageTitle;
  final String? voyageSlug;
  final String? endDate;
  Offer({
    required this.title,
    this.description = '',
    this.discountPercentage,
    this.voyageTitle,
    this.voyageSlug,
    this.endDate,
  });
  factory Offer.fromJson(Map<String, dynamic> j) => Offer(
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        discountPercentage: j['discount_percentage'],
        voyageTitle: j['voyage_title'],
        voyageSlug: j['voyage_slug'],
        endDate: j['end_date'],
      );
}
