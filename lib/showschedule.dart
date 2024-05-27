import 'package:flutter/material.dart';
import 'package:dailyplanner/models/user_model.dart';
import 'package:dailyplanner/user_controller.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:dailyplanner/notification_service.dart';

class ScheduleListPage extends StatefulWidget {
  final String username;

  ScheduleListPage({required this.username});

  @override
  _ScheduleListPageState createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  late Future<List<Activity>> _activities;
  late Future<User?> _user;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchExpanded = false;
  String _selectedTimeZone = 'WIB';

  @override
  void initState() {
    super.initState();
    _activities = UserController.getUserActivities(widget.username);
    _user = UserController.getUser(widget.username);
    _initTimezone();
    NotificationService.init();
    _scheduleNotifications();
  }

  Future<void> _initTimezone() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

  Future<void> _scheduleNotifications() async {
    await NotificationService.cancelAllNotifications(); // Batalkan semua notifikasi lama
    final activities = await _activities;
    final now = tz.TZDateTime.now(tz.local); // Waktu saat ini dalam zona waktu lokal

    for (var i = 0; i < activities.length; i++) {
      final activity = activities[i];
      final startTime = activity.startTime;

      // Pemeriksaan apakah waktu notifikasi masih di masa depan
      if (startTime.isAfter(now)) {
        final notificationTime = startTime.subtract(Duration(hours: 1)); // Satu jam sebelum waktu mulai

        // Buat ID notifikasi yang unik
        int uniqueId = _generateNotificationId(activity.id);

        // Jadwalkan notifikasi hanya jika waktu notifikasi masih di masa depan
        await NotificationService.scheduleNotification(
          uniqueId,
          'Upcoming Activity',
          'Your activity "${activity.title}" will start in one hour.',
          notificationTime,
        );
      }
    }
  }

  // Fungsi untuk menghasilkan ID notifikasi yang unik berdasarkan ID aktivitas
  int _generateNotificationId(int activityId) {
    // Menggunakan fungsi hash untuk menghasilkan nilai integer yang unik dari ID aktivitas
    return activityId.hashCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchExpanded
            ? TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search schedules...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white60),
          ),
          style: TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        )
            : Text('Schedule List', style: TextStyle(color: Colors.white),),
        actions: [
          _isSearchExpanded
              ? IconButton(
            icon: Icon(Icons.close, color: Colors.white,),
            onPressed: () {
              setState(() {
                _isSearchExpanded = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          )
              : IconButton(
            icon: Icon(Icons.search, color: Colors.white,),
            onPressed: () {
              setState(() {
                _isSearchExpanded = true;
              });
            },
          ),
        ],
        backgroundColor: Color(0xFF8f14b8),
      ),
      backgroundColor: Color(0xFFc553ec),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['WIB', 'WITA', 'WIT', 'London'].map((String timeZone) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTimeZone = timeZone;
                    });
                  },
                  child: Text(timeZone, style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTimeZone == timeZone ? Color(0xFF8f14b8) : Colors.grey,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<User?>(
              future: _user,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError) {
                  return Center(child: Text('Error loading user'));
                }

                final user = userSnapshot.data;
                return FutureBuilder<List<Activity>>(
                  future: _activities,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading schedules'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No schedules found'));
                    }

                    final activities = snapshot.data!.where((activity) {
                      return activity.title.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();

                    return GridView.builder(
                      padding: EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScheduleDetailPage(activity: activity),
                              ),
                            );
                          },
                          child: Card(
                            color: Color(0xFF8f14b8),
                            child: ListTile(
                              title: Text(
                                activity.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat.yMMMd().format(activity.activityDate),
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                  Text(
                                    '${_getTimeInTimeZone(activity.startTime, _selectedTimeZone)} - ${_getTimeInTimeZone(activity.endTime, _selectedTimeZone)}',
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ],
                              ),
                              trailing: Checkbox(
                                value: user?.checklist.contains(activity.id) ?? false,
                                onChanged: (value) {
                                  setState(() {
                                    UserController.toggleChecklistItem(widget.username, activity);
                                  });
                                },
                                activeColor: Colors.white,
                                checkColor: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeInTimeZone(DateTime time, String timeZone) {
    switch (timeZone) {
      case 'WITA':
        return DateFormat.Hm().format(time.add(Duration(hours: 1)));
      case 'WIT':
        return DateFormat.Hm().format(time.add(Duration(hours: 2)));
      case 'London':
        return DateFormat.Hm().format(_convertToLondonTime(time));
      case 'WIB':
      default:
        return DateFormat.Hm().format(time);
    }
  }

  DateTime _convertToLondonTime(DateTime dateTime) {
    final londonTime = dateTime.toUtc().add(Duration(hours: 1));
    return londonTime;
  }
}


class ScheduleDetailPage extends StatelessWidget {
  final Activity activity;

  ScheduleDetailPage({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF8f14b8),
      ),
      backgroundColor: Color(0xFFc553ec),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              color: Color(0xFF8f14b8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow('Location', activity.location),
                    SizedBox(height: 16),
                    Text(
                      'Description',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      activity.description,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}

