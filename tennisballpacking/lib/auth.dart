import 'package:firebase_auth/firebase_auth.dart';

class Auth {

  Future<User> handlesignup(String email, String password) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final User user = result.user!;
    return user;
  }

  Future<User> handlesignin(String email, String password) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final User user = result.user!;
    return user;
  }
}
