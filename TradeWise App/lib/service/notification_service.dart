import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
// import 'package:software_engineering_project/service/nav_bar.dart';
import '../service/nav_bar.dart' as nav_bar;
import '../pages/settings_page.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel',
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color.fromARGB(255, 9, 84, 5),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic Notifications Group',
        ),
      ],
      debug: true,
    );
    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (isAllowed) {
        await AwesomeNotifications().setListeners(
          onActionReceivedMethod: onActionReceivedMethod,
          onNotificationCreatedMethod: onNotificationCreatedMethod,
          onNotificationDisplayedMethod: onNotificationDisplayedMethod,
          onDismissActionReceivedMethod: onDismissActionReceiveMethod,
        );
      }
    });
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
    print(receivedNotification.category);

    if (receivedNotification.category == NotificationCategory.Recommendation) {
      create();
    }
  }

  static void create() {
    print(DateTime.now().hour);
    if (DateTime.now().hour < 10) {
      createAutomaticNineAmSchedule();
    } else {
      createAutomaticFourPmSchedule();
    }
  }

  static DateTime _getNextWeekdayTime(DateTime now, int hour, int minute) {
    DateTime nextTime = DateTime(now.year, now.month, now.day, hour, minute);
    while (nextTime.weekday == 6 || nextTime.weekday == 7) {
      nextTime = nextTime.add(const Duration(days: 1));
    }
    return nextTime;
  }

  static Future<void> createAutomaticNineAmSchedule() async {
    await NotificationService.showNotification(
      title:
          "${Emojis.money_money_bag + Emojis.time_ten_o_clock} Time to Trade!",
      body: "The stock market is about to open! Hop on to trading.",
      scheduled: true,
      category: NotificationCategory.Recommendation,
      interval: _getDayInterval(),
    );

    print(_getDayInterval);
  }

  static Future<void> createAutomaticFourPmSchedule() async {
    await NotificationService.showNotification(
      title: '${Emojis.smile_money_mouth_face} Time to check on your stocks!',
      body:
          "The stock market is about to close! Come check out your profits of the day",
      scheduled: true,
      category: NotificationCategory.Recommendation,
      interval: _getNightInterval(),
    );

    print(_getNightInterval());
  }

  static int _getDayInterval() {
    int dayInterval = 0;

    final time = DateTime.now();

    final nextMorningTime = _getNextWeekdayTime(time, 9, 52);
    dayInterval = nextMorningTime.difference(time).inSeconds;

    return dayInterval;
  }

  static int _getNightInterval() {
    int nightInterval = 0;

    final time = DateTime.now();

    final nextAfternoonTime = _getNextWeekdayTime(time, 16, 22);
    nightInterval = nextAfternoonTime.difference(time).inSeconds;

    debugPrint("nightInvertal $nightInterval");
    return nightInterval;
  }

  static Future<void> onDismissActionReceiveMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == "true") {
      nav_bar.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        ),
      );
    }
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
    final bool wakeUpScheen = true,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    Random random = Random();
    int randomId = random.nextInt(100000);

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: randomId,
          channelKey: 'scheduled_channel',
          title: title,
          body: body,
          actionType: actionType,
          notificationLayout: notificationLayout,
          summary: summary,
          category: category,
          payload: payload,
          bigPicture: bigPicture,
        ),
        actionButtons: actionButtons,
        schedule: scheduled
            ? NotificationInterval(
                interval: interval,
                timeZone:
                    await AwesomeNotifications().getLocalTimeZoneIdentifier(),
                preciseAlarm: true,
                repeats: false,
                allowWhileIdle: true,
              )
            : null);
  }
}
