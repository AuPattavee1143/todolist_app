import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todolist_app/widget/add_task_screen.dart';
import 'package:todolist_app/widget/login_screen.dart';
import 'package:todolist_app/widget/task_list.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
   final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
                title: const Text('Task'), 
                centerTitle: true,
                actions: user != null 
                ? [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        _signOut();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        enabled: false, 
                        child: Text(user?.email ?? "ไม่ทราบอีเมล",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 10),
                            Text("ออกจากระบบ"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]
                : null,
              ),

      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Icon(Icons.error_outline, size: 80, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Opacity(
                    opacity: 0.5,
                    child: Text("กรุณาเข้าสู่ระบบ", style: TextStyle(fontSize: 18,),),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text("เข้าสู่ระบบ"),
                  ),
                ],
              ),
            )
          : TaskList(),

      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => AddTaskScreen(),
                );
              },
            ),
    );
  }

  void _signOut() async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ออกจากระบบ"),
        content: Text("ยืนยันออกจากระบบหรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("ยืนยัน", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmLogout == true) {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }
}