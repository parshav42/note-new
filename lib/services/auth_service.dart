import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // 🔹 Sign in method returns "Success" or error message
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message; // return Firebase error message
    } catch (e) {
      return e.toString();
    }
  }

  // 🔹 Sign up method returns "Success" or error message
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 🔹 Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 🔹 Current user
  User? get currentUser => _auth.currentUser;
}
