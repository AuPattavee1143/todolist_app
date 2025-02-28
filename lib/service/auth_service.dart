import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // สมัครสมาชิก
  Future<String?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
      });

      return null; // สมัครสำเร็จ
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // เข้าสู่ระบบ
  Future<String?> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // เข้าสู่ระบบสำเร็จ
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ออกจากระบบ
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ตรวจสอบสถานะการล็อกอิน
  User? get currentUser => _auth.currentUser;
}
