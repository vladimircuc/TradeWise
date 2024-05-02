import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/notification_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../models/profit_at_time.dart';
import '../service/controller.dart';
import '../service/nav_bar.dart';
import '../service/notification_service.dart';
import 'auth/landing_page.dart';
import 'portfolio.dart';

//imports for portfolio page

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String userId = "";
  final db = DataBase_Controller();

  //initialize for notifs
  int interval = 0;
  bool _notificationsAllowed = false;

  //initialize for username/pp
  String userName = "";
  File? image;

  //initialize for portfolio
  Map<String, double> dataMap = {};
  List<ProfitInTime> chartData = [];
  bool areThereStocks = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userId = user.uid; // Assign userId if user is logged in
        dataMap = dataMap;
      });
    }
    getUsers(); // Invoke getUsers here or wherever it makes sense after userId is set
    getProfilePicture();
  }

  Future selectImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      // final imageTemporary = File(image.path);

      final imagePermanent = await saveImagePermanently(image.path);

      setState(() => this.image = imagePermanent);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }

    // _image = img;
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    await db.saveProfilePicture(userId, imagePath);

    return File(imagePath).copy(image.path);
  }

  Future<void> getProfilePicture() async {
    String pathName = await db.getProfilePicture(userId);

    setState(() {
      image = File(pathName);
    });
  }

  Future<void> _toggleNotificationPermission(bool allow) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_allowed', allow);
    setState(() {
      _notificationsAllowed = allow;
    });
  }

  void _showNotificationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Allow Notifications"),
          content: const Text("Our app would like to send you notifications"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _toggleNotificationPermission(false);
                Navigator.pop(context);
              },
              child: const Text('Don\'t Allow',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  )),
            ),
            TextButton(
              onPressed: () async {
                _toggleNotificationPermission(true);
                AwesomeNotifications()
                    .requestPermissionToSendNotifications()
                    .then((_) {
                  Navigator.pop(context);
                  NotificationService.initializeNotification();
                  _createAutomaticSchedule();
                  // _createAutomaticFourPmSchedule();
                });
              },
              child: const Text('Allow',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
            )
          ],
        );
      },
    );
  }

  Future<void> _createAutomaticSchedule() async {
    String title = "";
    String body = "";
    if (DateTime.now().hour < 10) {
      title =
          "${Emojis.money_money_bag + Emojis.time_ten_o_clock} Time to Trade!";
      body = "The stock market is about to open! Hop on to trading.";
    } else {
      title = "${Emojis.smile_money_mouth_face} Time to check on your stocks!";
      body =
          "The stock market is about to close! Come check out your profits of the day";
    }
    await NotificationService.showNotification(
      title: title,
      body: body,
      scheduled: true,
      category: NotificationCategory.Recommendation,
      interval: _getInterval(),
    );
  }

  void goToPortof(BuildContext context) async {
    await data();

    await getListforProfits();

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => PortfolioPage(
          navigatorKey: navigatorKey,
          userId: userId,
          dataMap: dataMap,
          chartData: chartData,
          areThereStocks: areThereStocks,
        ),
      ));
    }
  }

  Future<void> data() async {
    dataMap = await db.getDataForChart(userId);

    if (dataMap.isEmpty) {
      dataMap["buy some stuff man"] = 0;
      areThereStocks = false;
    }

    setState(() {
      // This will trigger a rebuild with the updated dataMap
    });
  }

  Future<void> getListforProfits() async {
    chartData = await db.getProfits(userId);

    setState(() {});
  }

  DateTime _getNextWeekdayTime(DateTime now, int hour, int minute) {
    DateTime nextTime = DateTime(now.year, now.month, now.day, hour, minute);
    while (nextTime.weekday == 6 || nextTime.weekday == 7) {
      nextTime = nextTime.add(const Duration(days: 1));
    }
    return nextTime;
  }

//im getting the interval on when I should schedule the notifications. Let's see how to implement it
  int _getInterval() {
    int interval2 = 0;
    final time = DateTime.now();

    if (time.hour < 9) {
      final nextDayTime = _getNextWeekdayTime(time, 9, 50);
      interval2 = nextDayTime.difference(time).inSeconds;
    } else {
      final nextAfternoonTime = _getNextWeekdayTime(time, 4, 20);
      interval2 = nextAfternoonTime.difference(time).inSeconds;
    }

    return interval2;
  }

  void getUsers() async {
    if (userId.isNotEmpty) {
      userName = await db.getUserName(userId);
      setState(() {
        // Update UI after fetching stocks
        userName = userName;
      });
    }
  }

  Future<void> _showEditUsernameDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newUsername = userName;
        return AlertDialog(
          title: const Text('Edit Username'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Enter new username'),
            onChanged: (value) {
              newUsername = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  userName = newUsername;
                });
                await db.updateUserName(userId, newUsername);
                Navigator.of(context).pop();
              },
              child: const Text('Save changes'),
            ),
          ],
        );
      },
    );
  }

  void changeUserName() async {
    if (userId.isNotEmpty) {}
  }

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Ensure sign out completes
    // Instead of using Navigator.pushReplacementNamed, consider clearing all routes and pushing the landing page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LandingPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text("Settings",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    image != null
                        ? CircleAvatar(
                            radius: 50,
                            child: ClipOval(
                              child: Image.file(
                                image!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          )
                        : const CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFdoXe8AoCq0BUuu6LhgSGqwUdMUwdLdyPnQ&usqp=CAU"),
                          ),
                    Positioned(
                      bottom: -13,
                      left: 60,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Hello $userName!',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        )),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      iconSize: 17,
                      onPressed: () => _showEditUsernameDialog(context),
                    )
                  ],
                ),
                // const Spacer(),
                const SizedBox(
                  height: 170,
                ),
                NotificationButton(
                    text: 'Troubleshoot Notifications',
                    onPressed: () async {
                      await NotificationService.showNotification(
                        title: 'This is a tester notification',
                        body:
                            'When you receive notifications from our app, they will look like this',
                        category: NotificationCategory.Status,
                      );
                    }),
                NotificationButton(
                  text: 'Change Notification Settings',
                  onPressed: () => _showNotificationPermissionDialog(context),
                ),
                NotificationButton(
                    onPressed: () => goToPortof(context),
                    text: "View Portfolio"),
                const SizedBox(
                  height: 70,
                ),
                NotificationButton(
                  onPressed: () async {
                    await FirebaseAuth.instance
                        .signOut(); // Ensure sign out completes
                    // Instead of using Navigator.pushReplacementNamed, consider clearing all routes and pushing the landing page
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LandingPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  text: "Sign Out",
                ),
                // const Spacer(),
                const SizedBox(
                  height: 40,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
