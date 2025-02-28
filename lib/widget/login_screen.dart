import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolist_app/widget/homepage.dart';
import 'package:todolist_app/widget/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("เข้าสู่ระบบ")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "อีเมล", prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "รหัสผ่าน", prefixIcon: Icon(Icons.lock)),
            ),
            SizedBox(height: 20),
            btnLogin(context),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
              }, 
              child: Text("สมัครสมาชิก"),
            ),
          ],
        ),
      ),
    );
  }

  Widget btnLogin(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("กรุณากรอกอีเมลและรหัสผ่าน")));
          return;
        }

        try {
          await _auth.signInWithEmailAndPassword(email: email, password: password);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: ${e.toString()}")));
        }
      }, 
      child: Text("เข้าสู่ระบบ"),
    );
  }
}
