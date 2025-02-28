import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist_app/model/task_model.dart';
import 'package:todolist_app/service/database.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Database db = Database.myInstance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dspController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task.title;
    _dspController.text = widget.task.dsp;
    _selectedDateTime = widget.task.date;
    _dateTimeController.text =
        DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไข Task'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'delete', child: Text("ลบ")),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.task),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _dspController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _dateTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'เลือกวันและเวลา',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _selectDateTime,
            ),
            SizedBox(height: 16),
            btnSave(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleCompletion,
        label: Text(widget.task.iscompleted ? "ทำเครื่องหมายว่าไม่เสร็จ" : "ทำเครื่องหมายว่าเสร็จ"),
        icon: Icon(widget.task.iscompleted ? Icons.close : Icons.check),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedDateTime = finalDateTime;
          _dateTimeController.text =
              DateFormat('dd/MM/yyyy (HH:mm)').format(finalDateTime);
        });
      }
    }
  }

  void _toggleCompletion() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      if (user.uid != widget.task.userID) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("คุณไม่สามารถแก้ไข task นี้ได้!"),
        ));
        return;
      }

      TaskModel updatedTask = TaskModel(
        id: widget.task.id,
        title: widget.task.title,
        dsp: widget.task.dsp,
        date: widget.task.date,
        iscompleted: !widget.task.iscompleted, // เปลี่ยนสถานะ
        userID: user.uid,
      );

      await db.setTask(task: updatedTask);
      setState(() {
        widget.task.iscompleted = updatedTask.iscompleted;
        Navigator.pop(context);
      });
    }
  }

  void _confirmDelete() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      if (user.uid != widget.task.userID) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("คุณไม่สามารถลบ task นี้ได้!"),
        ));
        return;
      }

      bool? confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("ลบ Task?"),
          content: Text("คุณต้องการลบ Task นี้หรือไม่?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("ลบ"),
            ),
          ],
        ),
      );
      if (confirmDelete == true) {
        await db.deleteTask(task: widget.task);
        Navigator.of(context).pop();
      }
    }
  }

  Widget btnSave(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final User? user = _auth.currentUser;
        if (user != null) {
          TaskModel updatedTask = TaskModel(
            id: widget.task.id,
            title: _titleController.text,
            dsp: _dspController.text,
            date: _selectedDateTime ?? widget.task.date,
            iscompleted: widget.task.iscompleted,
            userID: user.uid,
          );
          await db.setTask(task: updatedTask);
          Navigator.of(context).pop();
        }
      },
      child: Text("บันทึก"),
    );
  }
}
