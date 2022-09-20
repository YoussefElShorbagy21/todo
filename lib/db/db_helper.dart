import 'package:sqflite/sqflite.dart';
import 'package:todo/models/task.dart';

class DBHelper {
  static Database? database ;
  static const int _version = 1 ;
  static const String _tableName = 'tasks' ;

  static Future<void> initDb() async  {
    if (database != null)
      {
        print('not null database');
        return ;
      }else {
          try{

            String path = '${await getDatabasesPath()}task.db';
            print('in database path');
            database = await openDatabase(path,version: _version,
            onCreate: (Database database , int version) async{
              print('onCreate Database');
              await database.execute(
                'CREATE TABLE $_tableName ('
                  'id INTEGER PRIMARY KEY AUTOINCREMENT, '
                  'title STRING, note TEXT , date STRING,'
                  'startTime STRING, endTime STRING, '
                  'remind INTEGER , repeat STRING, '
                  'color INTEGER, '
                  'isCompleted INTEGER)',
              );
            });
            print('database CREATE') ;
          } catch (e) {
            print('Error : $e');
          }
        }
  }


  static Future<int> insert(Task? task) async
  {
    print('insert function called');
    try {
      return await database!.insert(_tableName, task!.toJson()) ;
    } on Exception catch (e) {
      print('We are here Error : $e');
      return 9000 ;
    }
  }

  static Future<int> delete(Task task) async
  {
    print('delete');
    return await database!.delete(_tableName,where: 'id = ? ' , whereArgs: [task.id]) ;
  }

  static Future<int> deleteAll() async
  {
    print('deleteAll');
    return await database!.delete(_tableName) ;
  }


  static Future<int> update(int id) async
  {
    print('update');
    return await database!.rawUpdate(
        'UPDATE tasks SET isCompleted = ?  WHERE id = ?',
        [1,id]) ;
  }

  static Future<List<Map<String, dynamic>>> query() async
  {
    print('query function called');
    try {
      return await database!.query(_tableName) ;
    } on Exception catch (e) {
   print('query : $e') ;
   return [] ;
    }
  }
}
