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
  Database db = Database.myInstance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dspController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task.title;
    _dspController.text = widget.task.dsp;
    _selectedDate = widget.task.date;
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
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
              PopupMenuItem(
                value: 'delete',
                child: Text("ลบ"),
              ),
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
                prefixIcon: Icon(Icons.task)
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _dspController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.notes)),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'เลือกวันที่',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _selectDate,
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

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    }
  }

  void _toggleCompletion() async {
    TaskModel updatedTask = TaskModel(
      id: widget.task.id,
      title: widget.task.title,
      dsp: widget.task.dsp,
      date: widget.task.date,
      iscompleted: !widget.task.iscompleted,
    );

    await db.setTask(task: updatedTask);
    setState(() {
      widget.task.iscompleted = !widget.task.iscompleted;
      Navigator.of(context).pop();
    });
  }

  void _confirmDelete() async {
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

  Widget btnSave(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        TaskModel updatedTask = TaskModel(
          id: widget.task.id,
          title: _titleController.text,
          dsp: _dspController.text,
          date: _selectedDate ?? widget.task.date,
          iscompleted: widget.task.iscompleted,
        );
        await db.setTask(task: updatedTask);
        Navigator.of(context).pop();
      },
      child: Text("บันทึก"),
    );
  }
}
