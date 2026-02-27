class AppUser {
  final String id;
  final String email;
  final String name;
  final double monthlyBudget;
  final double spentThisMonth;
  final int coins;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.monthlyBudget = 0.0,
    this.spentThisMonth = 0.0,
    this.coins = 0,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['user_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      monthlyBudget: (json['monthlyBudget'] ?? 0).toDouble(),
      spentThisMonth: (json['spentThisMonth'] ?? 0).toDouble(),
      coins: json['coins'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'email': email,
      'name': name,
      'monthlyBudget': monthlyBudget,
      'spentThisMonth': spentThisMonth,
      'coins': coins,
    };
  }
}
