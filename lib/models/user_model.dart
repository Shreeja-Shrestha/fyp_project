class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String tagline;
  final int trips;
  final int bookings;
  final int wishlist;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.tagline,
    required this.trips,
    required this.bookings,
    required this.wishlist,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      tagline: json['tagline'],
      trips: json['trips'],
      bookings: json['bookings'],
      wishlist: json['wishlist'],
    );
  }
}

// GLOBAL — accessible everywhere
UserModel? loggedInUser;
