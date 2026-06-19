// Data models for the Evec Tours API.

class Voyage {
  final int? id;
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
    this.id,
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
        id: j['id'] is int ? j['id'] : int.tryParse('${j['id'] ?? ''}'),
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

class AppUser {
  final int id;
  final String username;
  final String email;
  final String? tel;
  final String? imageUrl;
  final bool isAdmin;
  AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.tel,
    this.imageUrl,
    this.isAdmin = false,
  });
  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
        username: j['username'] ?? '',
        email: j['email'] ?? '',
        tel: j['tel'],
        imageUrl: j['image_url'],
        isAdmin: j['is_admin'] == true,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'tel': tel,
        'image_url': imageUrl,
        'is_admin': isAdmin,
      };
}

class Booking {
  final int? id;
  final String? reference;
  final String? voyageTitle;
  final String? destination;
  final int? people;
  final String? totalPrice;
  final String? status;
  final String? paymentStatus;
  final String? date;
  Booking({
    this.id,
    this.reference,
    this.voyageTitle,
    this.destination,
    this.people,
    this.totalPrice,
    this.status,
    this.paymentStatus,
    this.date,
  });
  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'] is int ? j['id'] : int.tryParse('${j['id'] ?? ''}'),
        reference: j['reference'],
        voyageTitle: j['voyage_title'],
        destination: j['destination'],
        people: j['people'] is int ? j['people'] : int.tryParse('${j['people'] ?? ''}'),
        totalPrice: j['total_price']?.toString(),
        status: j['status'],
        paymentStatus: j['payment_status'],
        date: j['date'],
      );
}

class AdminStats {
  final int voyages;
  final int reservations;
  final int paid;
  final int pending;
  final num revenue;
  final int users;
  AdminStats({
    this.voyages = 0,
    this.reservations = 0,
    this.paid = 0,
    this.pending = 0,
    this.revenue = 0,
    this.users = 0,
  });
  factory AdminStats.fromJson(Map<String, dynamic> j) => AdminStats(
        voyages: j['voyages'] ?? 0,
        reservations: j['reservations'] ?? 0,
        paid: j['paid'] ?? 0,
        pending: j['pending'] ?? 0,
        revenue: j['revenue'] ?? 0,
        users: j['users'] ?? 0,
      );
}

class AdminReservation {
  final int? id;
  final String? voyageTitle;
  final String? destination;
  final String? customer;
  final String? email;
  final int? people;
  final String? totalPrice;
  final String? status;
  final String? paymentStatus;
  final String? date;
  AdminReservation({
    this.id,
    this.voyageTitle,
    this.destination,
    this.customer,
    this.email,
    this.people,
    this.totalPrice,
    this.status,
    this.paymentStatus,
    this.date,
  });
  factory AdminReservation.fromJson(Map<String, dynamic> j) => AdminReservation(
        id: j['id'] is int ? j['id'] : int.tryParse('${j['id'] ?? ''}'),
        voyageTitle: j['voyage_title'],
        destination: j['destination'],
        customer: j['customer'],
        email: j['email'],
        people: j['people'] is int ? j['people'] : int.tryParse('${j['people'] ?? ''}'),
        totalPrice: j['total_price']?.toString(),
        status: j['status'],
        paymentStatus: j['payment_status'],
        date: j['date'],
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
