import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/models/notification.dart';
import 'package:lets_park/services/user_services.dart';
import 'package:lets_park/shared/navigation_drawer.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class Notifications extends StatefulWidget {
  final int _pageId = 4;
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SharedWidget _sharedWidgets = SharedWidget();
  final UserServices _userServices = UserServices();

  @override
  Widget build(BuildContext context) {
    List<UserNotification> notifications =
        globals.userData.getUserNotifications!;
    return Scaffold(
      key: _scaffoldKey,
      appBar: _sharedWidgets.appbarDrawer(
        title: "Notifications",
        onPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
      ),
      drawer: NavigationDrawer(currentPage: widget._pageId),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _userServices.getUserNotifications(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<UserNotification> newNotifications = [];
              snapshot.data!.docs.forEach((element) {
                newNotifications.add(UserNotification.fromJson(element.data()));
              });
              globals.userData.setUserNotifications = newNotifications;
              notifications = newNotifications;

              notifications.sort((notifA, notifB) {
                int timeA = notifA.getNotificationDate!;
                int timeB = notifB.getNotificationDate!;
                return timeB.compareTo(timeA);
              });
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return InkWell(
                  splashColor: Colors.blue.shade100,
                  highlightColor: Colors.blue.shade100,
                  onTap: () {},
                  child: Ink(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              notifications[index].isNewParking! == false &&
                                      notifications[index].isForRating! == false
                                  ? Image.asset(
                                      "assets/icons/parking-marker.png",
                                      scale: 2,
                                    )
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        notifications[index].getUserImage!,
                                      ),
                                      radius: 40,
                                    ),
                              notifications[index].isNewParking!
                                  ? Image.asset(
                                      "assets/icons/parking-marker.png",
                                      scale: 4,
                                    )
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(
                                          Icons.star_rounded,
                                          color: Colors.black,
                                          size: 26,
                                        ),
                                        Icon(
                                          Icons.star_rounded,
                                          color: Colors.yellow,
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: notifications[index].getUsername!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          height: 2,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " " +
                                            notifications[index].getMessage!,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _getFormattedTime(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      notifications[index].getNotificationDate!,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  String _getFormattedTime(DateTime time) {
    String formattedTime = "";
    DateTime arrival = DateTime(
      time.year,
      time.month,
      time.day,
    );

    arrival.compareTo(_getDateTimeNow()) == 0
        ? formattedTime += "Today at "
        : formattedTime += DateFormat('MMM. dd, yyyy ').format(arrival) + "at ";
    formattedTime += DateFormat("h:mm a").format(time);
    return formattedTime;
  }

  DateTime _getDateTimeNow() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
  }
}
