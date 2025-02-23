import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todolist_app/model/task_model.dart';
import 'package:todolist_app/widget/edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  const TaskTile({super.key, required this.task });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(task.dsp),
        trailing: Checkbox(
          value: task.iscompleted,
          onChanged: (bool? value) async {
            // อัปเดตสถานะใน Firestore
            await FirebaseFirestore.instance
                .collection('task')
                .doc(task.id)
                .update({'is_completed': value});
          },
        ),
        onTap: () {
          _navigateToEditScreen(context, task);
        },
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task),
      ),
    );
  }
}
