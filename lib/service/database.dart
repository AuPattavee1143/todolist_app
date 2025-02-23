import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolist_app/model/task_model.dart';

class Database {
  static Database myInstance = Database();

  Stream<List<TaskModel>> getAllTaskStream(){
    var reference = FirebaseFirestore.instance.collection('task');
    
    Query query = reference.orderBy('id', descending: true);
    var querysnapshot = query.snapshots();

    return querysnapshot.map((snapshot){
      return snapshot.docs.map((doc){
        return TaskModel.formMap(doc.data() as Map<String, dynamic>);}).toList();
    });
  }

  Future<void> setTask({required TaskModel task}) async{
    var reference = FirebaseFirestore.instance.doc('task/${task.id}');
    try {
      await reference.set(task.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask({required TaskModel task}) async{
    var reference = FirebaseFirestore.instance.doc('task/${task.id}');
    try {
      await reference.delete();
    } catch (e) {
      rethrow;
    }
  }
}