import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/task.dart';
import 'package:todo/ui/widgets/button.dart';

import '../theme.dart';
import '../widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());

  final TextEditingController _titleController = TextEditingController() ;
  final TextEditingController _noteController = TextEditingController() ;


  DateTime _selectedDate = DateTime.now() ;
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String _endTime = DateFormat('hh:mm a').format(DateTime.now().add(const Duration(minutes: 15))).toString();

  int _selectedRemind = 5 ;
  List<int> remindList = [5,10,15,20] ;
  String _selectedRepeat = 'None' ;
  List<String> repeatList = ['None','Daily','Weekly','Monthly'];
  int _selectedColor = 0 ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Get.back();
          },
          icon: const Icon(Icons.arrow_back,size: 24, color: primaryClr,),
        ),
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage('images/person.jpeg'),
            radius: 20,
          ),
          SizedBox(width: 20,)
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children:
            [
              Text('Add Task (ShabiGabi)',
              style: Themes().headingStyle,),
               InputField(
                title: 'Title',
                note: 'Enter title here',
                controller: _titleController,
              ),

              InputField(
                title: 'Note',
                note: 'Enter note here',
                controller: _noteController,
              ),

              InputField(
                title: 'Date',
                note: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  onPressed: () => _getDateFromUser(),
                  icon: const Icon(Icons.calendar_today,
                  color: Colors.grey,),
                ),
              ),

              Row(
                children:
                [
                  Expanded(
                    child: InputField(
                      title: 'Start Time',
                      note: _startTime,
                      widget: IconButton(
                          onPressed: () => _getTimeFromUser(isStartTime: true),
                          icon: const Icon(Icons.access_time_rounded,
                            color: Colors.grey,),
                        )
                    ),
                  ),
                  const SizedBox(width: 20,),
                  Expanded(
                    child: InputField(
                      title: 'End Time',
                      note: _endTime,
                        widget: IconButton(
                          onPressed: () => _getTimeFromUser(isStartTime: false ),
                          icon: const Icon(Icons.access_time_rounded,
                            color: Colors.grey,),
                        ),
                    ),
                  ),
                ],
              ),

              InputField(
                title: 'Remind',
                note: '$_selectedRemind minutes early',
                widget: Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                        items: remindList.map<DropdownMenuItem<String>>((int e) => DropdownMenuItem<String>(
                          value: e.toString(),
                            child: Text('$e',style: const TextStyle(color: Colors.white,),)),).toList(),
                      icon: const Icon(Icons.keyboard_arrow_down_sharp,color: Colors.grey,),
                      iconSize: 32,
                      elevation: 4,
                      underline:  Container(height: 0,),
                      style: Themes().subtitleStyle,
                      onChanged: (String? value)
                      {
                        setState(() {
                          _selectedRemind = int.parse(value!) ;
                        });
                      },
                    ),
                    const SizedBox(width: 6,),
                  ],
                ),
              ),

              InputField(
                title: 'Repeat',
                note: _selectedRepeat ,
                widget: Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                      items: repeatList.map<DropdownMenuItem<String>>((String e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e,style: const TextStyle(color: Colors.white,),)),).toList(),
                      icon: const Icon(Icons.keyboard_arrow_down_sharp,color: Colors.grey,),
                      iconSize: 32,
                      elevation: 4,
                      underline:  Container(height: 0,),
                      style: Themes().subtitleStyle,
                      onChanged: (String? value)
                      {
                        setState(() {
                          _selectedRepeat = value! ;
                        });
                      },
                    ),
                    const SizedBox(width: 6,),
                  ],
                ),
              ),

              const SizedBox(height: 18,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Color',style: Themes().titleStyle,),
                      const SizedBox(height: 8,),
                      Wrap(
                        children:List<Widget>.
                        generate(3, (index) => GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _selectedColor = index ;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CircleAvatar(
                                    backgroundColor: index == 0 ?
                                    primaryClr :
                                    index == 1 ?
                                    pinkClr : orangeClr,
                                    radius: 14,
                                    child:_selectedColor == index ? const Icon(
                                      Icons.done,
                                      size: 16,
                                      color: Colors.white,
                                    ) : null ,
                                  ),
                                ),
                              ),
                          ),
                      ),
                    ],
                  ),
                  MyButton(label: 'Create Task', onTap: (){
                    _validateData();
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _validateData(){
    if(_titleController.text.isNotEmpty && _noteController.text.isNotEmpty)
      {
        _addTasksToDB();
        Get.back();
      }
    else if (_titleController.text.isEmpty || _noteController.text.isEmpty)
    {
      Get.snackbar(
          'required',
          'All fields are required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: pinkClr,
        icon: const Icon(Icons.warning_amber_rounded,color: Colors.red,),
      );
    }
    else
      {
        print('');
      }
  }

  _addTasksToDB() async {
    int value = await _taskController.addTask(
      task:Task(
        title: _titleController.text,
        note: _noteController.text,
        isCompleted: 0,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
      ),);
    print('value : $value');
  }

  _getDateFromUser() async {
   DateTime? _pickedDate = await showDatePicker(context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2030),
    );
   if(_pickedDate != null )
     {
       setState(() {
         _selectedDate = _pickedDate! ;
       });
     }
   else
     {
       print('object');
     }

  }

  _getTimeFromUser({required bool isStartTime})  async{
    TimeOfDay? _pickedTime = await showTimePicker(
        context: context,
        initialTime: isStartTime ?
        TimeOfDay.fromDateTime(DateTime.now()) :
        TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 15))),
    );
    String _formattedTime = _pickedTime!.format(context);
    if(isStartTime)
      {
        setState(() {
          _startTime = _formattedTime ;
        });
      }
    else if(!isStartTime)
      {
        setState(() {
          _endTime = _formattedTime ;
        });
      }
      else print('');
    if(_pickedTime != null )
    {

    }
    else
    {
      print('object');
    }
  }


}
