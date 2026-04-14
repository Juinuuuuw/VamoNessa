import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Cria um documento básico com o e-mail
      final email = user.email ?? '';
      final newUser = UserModel(
        uid: user.uid,
        email: email,
        firstName: email.split('@').first, // fallback inicial
        lastName: '',
      );
      await docRef.set(newUser.toMap());
      return newUser;
    }

    return UserModel.fromFirestore(doc);
  }

  /// Atualiza nome e sobrenome
  Future<void> updateName(String firstName, String lastName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    await _firestore.collection('users').doc(user.uid).update({
      'first_name': firstName,
      'last_name': lastName,
    });
  }

  /// Faz upload de uma nova foto de perfil e retorna a URL
  Future<String> uploadProfilePicture(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final fileName =
        'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('profile_pictures/$fileName');
    await ref.putFile(imageFile);
    final downloadUrl = await ref.getDownloadURL();

    await _firestore.collection('users').doc(user.uid).update({
      'photo_url': downloadUrl,
    });

    return downloadUrl;
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
