import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/models/task.dart';
import 'package:todo/services/notification_services.dart';
import 'package:todo/services/theme_services.dart';
import 'package:todo/ui/pages/add_task_page.dart';
import 'package:todo/ui/size_config.dart';
import 'package:todo/ui/widgets/button.dart';
import 'package:todo/ui/widgets/task_tile.dart';
import '../../../controllers/task_controller.dart';
import '../../theme.dart';
import 'package:intl/intl.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter_svg/flutter_svg.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late NotifyHelper notifyHelper ;
  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper() ;
    notifyHelper.initializeNotification() ;
    _taskController.getTask();
  }

  final TaskController _taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now() ;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
           ThemeServices().switchTheme();

           notifyHelper.displayNotitfication(title: 'ThemeChange', body: 'body');

          },
          icon: Icon(
            Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
            size: 24,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
        actions:  [
          IconButton(
            icon: Icon( Icons.cleaning_services_outlined ,
         size: 24,
         color: Get.isDarkMode ? Colors.white : darkGreyClr,
        ), onPressed: () {
              notifyHelper.cancelAllNotification();
          _taskController.deleteAllTask();
        },
      ),
          const CircleAvatar(
            backgroundImage: AssetImage('images/person.jpeg'),
            radius: 20,
          ),
          const SizedBox(width: 20,)
        ],
      ),
      body: Column(
        children:
        [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(height: 6,),
          _showTasks(),
        ],
      ),
    ) ;
  }

  Widget _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20,right: 1,top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
            [
              Text( DateFormat.yMMMMd().format(DateTime.now()),style: Themes().subHeadingStyle,),
              Text('Today' ,style: Themes().headingStyle,),
            ],
          ),
          MyButton(label: '+ Add Tasks', onTap: () async{
            await Get.to(const AddTaskPage());
            _taskController.getTask() ;
          }),
          const SizedBox(),
        ],
      ),
    );
  }

  Widget _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 6 ,left: 20),
      child: DatePicker(
        DateTime.now(),
        width: 70,
        height: 100,
        selectedTextColor: Colors.white,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        dateTextStyle:GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:Colors.grey,
            ) ,
        ),
        dayTextStyle: GoogleFonts.lato(
    textStyle: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
      color:Colors.grey,

    ),
        ),
        monthTextStyle: GoogleFonts.lato (
        textStyle: const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.grey

    ),
        ),
        onDateChange: (date)
        {
          setState(() {
            _selectedDate = date ;
          });
        },
      ),
    );
  }

  Future<void> _onRefresh ()async{
   await _taskController.getTask();
  }
  Widget _showTasks() {
    return Expanded(
      child: Obx((){
        if (_taskController.taskList.isEmpty) {
          return _noTaskMsg();
        }
        else
          {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                scrollDirection: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                itemBuilder: (BuildContext context, int index) {

                  if(_taskController.taskList[index].repeat == 'Daily'||
                      _taskController.taskList[index].date == DateFormat.yMd().format(_selectedDate) ||
                      (_taskController.taskList[index].repeat == 'Weekly' &&
                          _selectedDate.
                          difference(DateFormat.yMd().parse(_taskController.taskList[index].date!)).inDays % 7 == 0)
                  || (_taskController.taskList[index].repeat == 'Monthly' && DateFormat.yMd().parse(_taskController.taskList[index].date!) == _selectedDate.day)
                  )
                  {
                    // var hour = _taskController.taskList[index].startTime.toString()
                    //     .split(':')[0];
                    // var min = _taskController.taskList[index].startTime.toString()
                    //     .split(':')[1];

                    var  date = DateFormat.jm().parse(_taskController.taskList[index].startTime!);
                    var myTime = DateFormat('HH:mm').format(date);
                    notifyHelper.scheduledNotification(
                        int.parse(myTime.split(':')[0]),
                        int.parse(myTime.split(':')[1]),
                        _taskController.taskList[index]);
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 1375),
                      child: SlideAnimation(
                        horizontalOffset: 300,
                        child: FadeInAnimation(
                          child: GestureDetector(
                            onTap: () =>
                                showBottomSheet(
                                    context, _taskController.taskList[index]),
                            child: TaskTile(_taskController.taskList[index],),
                          ),
                        ),
                      ),
                    );
                  }
                  else {
                    return Container();
                  }
                },
                itemCount: _taskController.taskList.length,
              ),
            );
          }
      }));
  }

  _noTaskMsg() {
    return Expanded(
      child:  Stack(
        children:
        [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 2000),
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  direction: SizeConfig.orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical,
                  children:
                  [
                    SizeConfig.orientation == Orientation.landscape ?   const SizedBox(height: 6,) :  const SizedBox(height: 250,),
                    SvgPicture.asset('images/task.svg',
                      color: primaryClr.withOpacity(0.5),
                      height: 150,
                      semanticsLabel: 'Task',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                      child: Text('You do not have any tasks yet! \nAdd new tasks to make your days productive',
                        style: Themes().subtitleStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizeConfig.orientation == Orientation.landscape ?   const SizedBox(height: 120,) :  const SizedBox(height: 180,),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  showBottomSheet(BuildContext context , Task task){
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 4),
          width: SizeConfig.screenWidth,
          height: (SizeConfig.orientation == Orientation.landscape) ?
          (task.isCompleted == 1
              ? SizeConfig.screenHeight *0.6
              : SizeConfig.screenHeight * 0.8)
          : (task.isCompleted == 1
              ? SizeConfig.screenHeight * 0.30
              : SizeConfig.screenHeight * 0.39),
          color: Get.isDarkMode ? darkGreyClr : Colors.white,
          child: Column(
            children: [
              Flexible(
                  child: Container(
                    height: 6,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                    ),
                  ),
              ),
              const SizedBox(height: 20,),
              task.isCompleted  == 1 ? Container() : _bulidBottomSheet(
                  label: 'Task Completed',
                   onTap: () {
                     notifyHelper.cancelNotification(task);
                     _taskController.markTaskCompleted(task.id!);
                     Get.back();
                   }
                  , clr: primaryClr),

              _bulidBottomSheet(
                  label: 'delete Completed',
                  onTap: () {
                    notifyHelper.cancelNotification(task);
                    _taskController.deletedTask(task);
                    Get.back();
                  }
                  , clr: Colors.red[300]!),
              Divider(color: Get.isDarkMode ? Colors.grey : darkGreyClr,),
              _bulidBottomSheet(
                  label: 'Cancel',
                  onTap: () => Get.back()
                  , clr: primaryClr),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }


  _bulidBottomSheet({
    required String label,
    required Function() onTap,
    required Color clr ,
    bool isClose = false,}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose ? Get.isDarkMode ? Colors.grey[600]! : Colors.grey[300]! : clr ,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr ,
        ),
        child: Center(
          child: Text(
            label ,
            style : isClose ? Themes().titleStyle : Themes().titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
