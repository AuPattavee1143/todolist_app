import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todolist_app/model/task_model.dart';
import 'package:todolist_app/widget/task_tile.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('task');

  late String _userID;

  @override
  void initState() {
    super.initState();
    _userID = _auth.currentUser!.uid; // ดึง uid ของผู้ใช้ที่ล็อกอิน
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: tasksCollection.where('userID', isEqualTo: _userID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        var tasks = snapshot.data!.docs
            .map((doc) => TaskModel.formMap(doc.data() as Map<String, dynamic>))
            .toList();

        var incompleteTasks = tasks.where((task) => !task.iscompleted).toList();
        var completedTasks = tasks.where((task) => task.iscompleted).toList();

        incompleteTasks.sort((a, b) => a.date.compareTo(b.date));
        completedTasks.sort((a, b) => a.date.compareTo(b.date));

        return SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'งานของฉัน (${incompleteTasks.length})',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (incompleteTasks.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(100),
                        child: Center(
                          child: Text(
                            'ช่วงนี้ว่าง',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: incompleteTasks.length,
                        itemBuilder: (context, index) =>
                            TaskTile(task: incompleteTasks[index]),
                      ),
                  ],
                ),
              ),

              Visibility(
                visible: completedTasks.isNotEmpty,
                child: Card(
                  margin: EdgeInsets.all(10),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent, // ซ่อนเส้น Divider ของ ExpansionTile
                    ),
                    child: ExpansionTile(
                      title: Text(
                        'เสร็จแล้ว (${completedTasks.length})',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      children: completedTasks
                          .map((task) => TaskTile(task: task))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
