class User {
  String name;
  String email;
  int loyaltyPoints;

  User({
    required this.name,
    required this.email,
    this.loyaltyPoints = 0,
  });

  void addPoints(int points) {
    loyaltyPoints += points;
  }
}
