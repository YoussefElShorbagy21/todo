import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo/ui/pages/notification/notification_screen.dart';

import '../models/task.dart';

class NotifyHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  String selectedNotificationPayload = '';
  final BehaviorSubject<String> selectNotificationSubject =
  BehaviorSubject<String>();


  initializeNotification () async
  {
    tz.initializeTimeZones();
    _configureSelectNotificationSubject();
    await _configureLocalTimeZone();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('appicon');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,);
  }

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectNotificationSubject.add(payload!);
    await Get.to(NotificationScreen(payload: payload));
  }

  displayNotitfication({required String title,required String body}) async
  {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        0,title, body, notificationDetails,
        payload: 'Default_Sound');
  }



  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    Get.dialog(
      Text(body!),
    );
  }


  cancelNotification(Task task)  async{
    await flutterLocalNotificationsPlugin.cancel(task.id!);
  }
  cancelAllNotification()  async{
    await flutterLocalNotificationsPlugin.cancelAll();
  }
  scheduledNotification(int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id!,
        task.title!,
        task.note!,
        // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        _nextInstanceOfTenAM(hour, minutes,  task.remind!, task.repeat!, task.date!)! ,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${task.title}|${task.note}|${task.startTime}|',
    );
  }

  tz.TZDateTime? _nextInstanceOfTenAM(int hour, int minutes,int remind,String repeat,String date) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    var formattedDate = DateFormat.yMd().parse(date);
    final tz.TZDateTime formattedDateLocal = tz.TZDateTime.from(formattedDate, tz.local);
    tz.TZDateTime? scheduledDate =
    tz.TZDateTime(tz.local, formattedDateLocal.year, formattedDateLocal.month, formattedDateLocal.day, hour, minutes);

    scheduledDate = afterRemind(remind, scheduledDate);

    if (scheduledDate!.isBefore(now)) {
      if(repeat == 'Daily')
        {
          scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, (formattedDate.day)+1, hour, minutes);
        }
      if(repeat == 'Weekly')
      {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, (formattedDate.day)+7, hour, minutes);
      }
      if(repeat == 'Monthly')
      {
        scheduledDate = tz.TZDateTime(tz.local, now.year, (formattedDate.month)+1,formattedDate.day, hour, minutes);
      }
      scheduledDate = afterRemind(remind, scheduledDate);
    }

    print('final scheduledDate : $scheduledDate');
    return scheduledDate;
  }

 tz.TZDateTime? afterRemind(int remind , tz.TZDateTime scheduledDate)
 {
   if(remind == 5)
   {
     return scheduledDate = scheduledDate.subtract(const Duration(minutes: 5));
   }
   if(remind == 10)
   {
     return scheduledDate = scheduledDate.subtract(const Duration(minutes: 10));
   }
   if(remind == 15)
   {
     return scheduledDate = scheduledDate.subtract(const Duration(minutes: 15));
   }
   if(remind == 20)
   {
     return scheduledDate = scheduledDate.subtract(const Duration(minutes: 20));
   }
   return null;
 }
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      debugPrint('My payload is $payload');
      await Get.to(() => NotificationScreen(payload: payload));
    });
  }

}
