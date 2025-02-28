import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist_app/model/task_model.dart';
import 'package:todolist_app/widget/edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${task.dsp} | "),
            getDueDateText(context, task.date, task.iscompleted)
          ],
        ),
        trailing: Checkbox(
          value: task.iscompleted,
          onChanged: (bool? value) async {
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

  //คำนวณวันที่ครบกำหนด
  Widget getDueDateText(BuildContext context, DateTime dueDate, bool isCompleted) {
    if (isCompleted) {
      return Text("เสร็จแล้ว", style: TextStyle(color: Colors.blue));
    }

    final now = DateTime.now();
    final differenceHours = dueDate.difference(now).inHours;
    final differenceDays = dueDate.difference(now).inDays;
    final formattedTime = DateFormat('HH:mm').format(dueDate);

    if (dueDate.isBefore(now)) {
      return Text("เลยกำหนด", style: TextStyle(color: Colors.red));
    } else if (differenceDays == 0 && differenceHours < 24) {
      return Text("วันนี้ เวลา $formattedTime", style: TextStyle(color: Colors.orange));
    } else {
      return Text("$differenceDays วัน", style: TextStyle(color: Colors.green));
    }
  }
}
