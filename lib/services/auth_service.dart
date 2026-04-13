import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registra um novo usuário com e-mail e senha
  Future<User?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String birthDate,
    required String phone,
  }) async {
    try {
      // 1. Criar usuário no Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // 2. Salvar dados adicionais no Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'birth_date': birthDate,
          'phone': phone,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Login com e-mail e senha
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Stream que monitora o estado de autenticação
  Stream<User?> get user => _auth.authStateChanges();
}