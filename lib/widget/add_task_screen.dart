import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todolist_app/model/task_model.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dspController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  void _addTask() {
    if (_titleController.text.isNotEmpty && _selectedDate != null) {
      FirebaseFirestore.instance.collection('task').add({
        'title': _titleController.text,
        'description': _dspController.text,
        'due_date': Timestamp.fromDate(_selectedDate!),
        'is_completed': false,
      }).then((docRef) {
        String docId = docRef.id;
        
        TaskModel newTask = TaskModel(
          id: docId,
          title: _titleController.text,
          dsp: _dspController.text,
          date: _selectedDate!,
          iscompleted: false,
        );

        docRef.update(newTask.toMap());

        Navigator.pop(context);
      });
    }
  }

  Future<void> _selectDate() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
          _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('เพิ่มงาน', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
          SizedBox(height: 10),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: "ชื่อ Task", prefixIcon: Icon(Icons.task),),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _dspController,
            decoration: InputDecoration(labelText: "รายละเอียด", prefixIcon: Icon(Icons.notes)),
          ),
          SizedBox(height: 10),
           TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'ครบกำหนด',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onTap: _selectDate, 
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addTask,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: Text("เพิ่ม Task"),
          ),
        ],
      ),
    );
  }
}