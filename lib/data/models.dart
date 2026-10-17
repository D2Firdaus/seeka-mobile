/// Model data mengikuti skema ERD (users, categories, locations, items,
/// item_images). Kunci JSON = nama kolom ERD (snake_case) agar pemetaan ke
/// database nanti tinggal 1:1. Persistensi saat ini masih JSON lokal.
library;

enum ItemType { kehilangan, ditemukan }

enum ItemStatus { aktif, diklaim }

enum Role { user, admin }

String? _iso(DateTime? d) => d?.toIso8601String();

DateTime _ts(dynamic v, [DateTime? fallback]) =>
    DateTime.tryParse(v as String? ?? '') ?? fallback ?? DateTime.now();

/// Tabel `users`.
class User {
  final int id;
  final String name;
  final String email;
  String password;
  final Role role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = Role.user,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Akun terhapus (soft delete) tetap dipakai utk resolusi nama pelapor.
  bool get aktif => deletedAt == null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role.name,
        'created_at': _iso(createdAt),
        'updated_at': _iso(updatedAt),
        'deleted_at': _iso(deletedAt),
      };

  static User fromJson(Map<String, dynamic> j) => User(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        password: j['password'] as String? ?? '',
        role: Role.values.firstWhere(
          (r) => r.name == j['role'],
          orElse: () => Role.user,
        ),
        createdAt: _ts(j['created_at']),
        updatedAt: _ts(j['updated_at']),
        deletedAt: j['deleted_at'] == null ? null : _ts(j['deleted_at']),
      );
}

/// Tabel `categories` & `locations` (struktur kolom sama).
/// Arsip = soft delete (`deletedAt` terisi).
class RefItem {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  RefItem({
    required this.id,
    required this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get aktif => deletedAt == null;

  RefItem copyWith({String? name, DateTime? updatedAt}) => RefItem(
        id: id,
        name: name ?? this.name,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': _iso(createdAt),
        'updated_at': _iso(updatedAt),
        'deleted_at': _iso(deletedAt),
      };

  static RefItem fromJson(Map<String, dynamic> j) => RefItem(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? '',
        createdAt: _ts(j['created_at']),
        updatedAt: _ts(j['updated_at']),
        deletedAt: j['deleted_at'] == null ? null : _ts(j['deleted_at']),
      );
}

/// Tabel `items` — laporan penemuan/kehilangan.
/// `nomorWa` adalah kolom tambahan di luar ERD (kontak per laporan).
class Item {
  final String id;
  final int userId;
  final int categoryId;
  final int locationId;
  final ItemType type;
  final String title;
  final String description;
  final DateTime dateEvent;
  final ItemStatus status;
  final String nomorWa;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Item({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.locationId,
    required this.type,
    required this.title,
    required this.description,
    required this.dateEvent,
    required this.nomorWa,
    this.status = ItemStatus.aktif,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get badge => type == ItemType.ditemukan ? 'DITEMUKAN' : 'KEHILANGAN';

  bool get diklaim => status == ItemStatus.diklaim;

  Item copyWith({
    int? userId,
    int? categoryId,
    int? locationId,
    ItemType? type,
    String? title,
    String? description,
    DateTime? dateEvent,
    ItemStatus? status,
    String? nomorWa,
    DateTime? updatedAt,
  }) =>
      Item(
        id: id,
        userId: userId ?? this.userId,
        categoryId: categoryId ?? this.categoryId,
        locationId: locationId ?? this.locationId,
        type: type ?? this.type,
        title: title ?? this.title,
        description: description ?? this.description,
        dateEvent: dateEvent ?? this.dateEvent,
        status: status ?? this.status,
        nomorWa: nomorWa ?? this.nomorWa,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'category_id': categoryId,
        'location_id': locationId,
        'type': type.name,
        'title': title,
        'description': description,
        'date_event': dateEvent.toIso8601String(),
        'status': status.name,
        'nomor_wa': nomorWa,
        'created_at': _iso(createdAt),
        'updated_at': _iso(updatedAt),
        'deleted_at': _iso(deletedAt),
      };

  static Item fromJson(Map<String, dynamic> j) => Item(
        id: j['id'] as String? ?? '',
        userId: (j['user_id'] as num?)?.toInt() ?? 0,
        categoryId: (j['category_id'] as num?)?.toInt() ?? 0,
        locationId: (j['location_id'] as num?)?.toInt() ?? 0,
        type: ItemType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => ItemType.kehilangan,
        ),
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        dateEvent: _ts(j['date_event']),
        status: ItemStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => ItemStatus.aktif,
        ),
        nomorWa: j['nomor_wa'] as String? ?? '',
        createdAt: _ts(j['created_at']),
        updatedAt: _ts(j['updated_at']),
        deletedAt: j['deleted_at'] == null ? null : _ts(j['deleted_at']),
      );
}

/// Tabel `item_images` — foto laporan, 1 item bisa punya banyak foto.
class ItemImage {
  final int id;
  final String itemId;
  final String path;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ItemImage({
    required this.id,
    required this.itemId,
    required this.path,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_id': itemId,
        'path': path,
        'created_at': _iso(createdAt),
        'updated_at': _iso(updatedAt),
        'deleted_at': _iso(deletedAt),
      };

  static ItemImage fromJson(Map<String, dynamic> j) => ItemImage(
        id: (j['id'] as num?)?.toInt() ?? 0,
        itemId: j['item_id'] as String? ?? '',
        path: j['path'] as String? ?? '',
        createdAt: _ts(j['created_at']),
        updatedAt: _ts(j['updated_at']),
        deletedAt: j['deleted_at'] == null ? null : _ts(j['deleted_at']),
      );
}
