class User {
  String username;
  String email;
  String password; // In a real app, passwords should be hashed and secured

  User({required this.username, required this.email, required this.password});
}