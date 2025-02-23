import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String id;
  String title;
  String dsp;
  DateTime date;
  bool iscompleted;


  TaskModel({
    required this.id, 
    required this.title, 
    required this.dsp, 
    required this.date, 
    required this.iscompleted
    });

  factory TaskModel.formMap(Map<String, dynamic> task){
    if(task.isEmpty){
      throw ArgumentError('ไม่มีอะไรทั้งนั้นเเหละ');
    }else{
      var obj = TaskModel(
        id: task['id'] ?? '', 
        title: task['title'], 
        dsp: task['description'],
        date: (task['due_date'] as Timestamp).toDate(),
        iscompleted: task['is_completed']
        );
        return obj;
    }
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> data;
      data = {
        'id' : id,
        'title' : title,
        'description' : dsp,
        'due_date' : Timestamp.fromDate(date),
        'is_completed': iscompleted
      };
      return data;
  }
}