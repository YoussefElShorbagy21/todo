import 'package:get/get.dart';
import 'package:todo/db/db_helper.dart';
import '../models/task.dart';

class TaskController extends GetxController{

  final RxList<Task> taskList = <Task>[].obs;


   Future<int> addTask({Task? task})
  {
    return DBHelper.insert(task);
  }

   Future<void> getTask() async {
   final List<Map<String , dynamic>> tasks = await DBHelper.query() ;
   taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

 void deletedTask(Task task) async {
    await DBHelper.delete(task);
    getTask();
  }

  void markTaskCompleted(int id) async {
    await DBHelper.update(id);
    getTask();
  }

  void deleteAllTask() async{
    await DBHelper.deleteAll();
    getTask();
  }
}
