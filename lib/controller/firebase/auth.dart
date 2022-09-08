import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> registerWithEmailAndPassword(
    String email, String password) {
  return FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password);
}

Future<UserCredential> signInWithEmailAndPassword(
    String email, String password) {
  return FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);
}

Future<void> logout() {
  return FirebaseAuth.instance.signOut();
}

User getCurrentUser() {
  return FirebaseAuth.instance.currentUser!;
}
