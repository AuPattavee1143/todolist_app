import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todolist_app/model/task_model.dart';
import 'package:todolist_app/widget/task_tile.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final CollectionReference tasksCollection =
        FirebaseFirestore.instance.collection('task');

    
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:  tasksCollection.snapshots(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Center(child: Text('เกิดข้อผิดพลาด'),);
        }
        if (snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }

        var tasks = snapshot.data!.docs
          .map((doc) => TaskModel.formMap(doc.data() as Map<String, dynamic>))
          .toList();

          var incompleteTasks = tasks.where((task) => !task.iscompleted).toList();
          var completedTasks = tasks.where((task) => task.iscompleted).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              // แสดงงานที่ยังไม่เสร็จ
              Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Column(
                  children: [
                    ListTile(
                      title: Text('งานของฉัน',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    ),
                    if(incompleteTasks.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(100),
                        child: Center(
                          child: Text('ช่วงนี้ว่าง', style:TextStyle(fontSize: 20, color: Colors.grey),),
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
              
              // แสดงงานที่เสร็จแล้ว
              Visibility(
                visible: completedTasks.isNotEmpty,
                child:Card(
                  margin: EdgeInsets.all(10),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent, // ซ่อนเส้น Divider ของ ExpansionTile
                    ),
                    child: ExpansionTile(
                      title: Text('เสร็จแล้ว (${completedTasks.length})',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      children: completedTasks.map((task) => TaskTile(task: task)).toList(),
                    )
                  )
                ), 
              )
            ],
          )
        );
      }
    ); 
  }
}