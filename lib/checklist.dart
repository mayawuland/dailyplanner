import 'package:flutter/material.dart';
import 'package:dailyplanner/models/user_model.dart';
import 'package:dailyplanner/user_controller.dart';
import 'package:intl/intl.dart';

class MarkAsDonePage extends StatefulWidget {
  final String username;

  MarkAsDonePage({required this.username});

  @override
  _MarkAsDonePageState createState() => _MarkAsDonePageState();
}

class _MarkAsDonePageState extends State<MarkAsDonePage> {
  late Future<List<Activity>> _checkedActivities;

  @override
  void initState() {
    super.initState();
    _checkedActivities = UserController.getCheckedActivities(widget.username);
  }

  Future<void> _removeActivity(Activity activity) async {
    // Remove activity from checklist
    await UserController.removeChecklistItem(widget.username, activity.id);
    // Remove activity from user's activities list
    await UserController.removeActivity(widget.username, activity);
    // Refresh checked activities list
    setState(() {
      _checkedActivities = UserController.getCheckedActivities(widget.username);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark As Done', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF8f14b8),
      ),
      backgroundColor: Color(0xFFc553ec),
      body: FutureBuilder<List<Activity>>(
        future: _checkedActivities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading checked activities'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No checked activities found'));
          }

          final checkedActivities = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _checkedActivities = UserController.getCheckedActivities(widget.username);
              });
            },
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1.5,
              ),
              itemCount: checkedActivities.length,
              itemBuilder: (context, index) {
                final activity = checkedActivities[index];
                return Card(
                  color: Color(0xFF8f14b8),
                  child: ListTile(
                    title: Text(activity.title, style: TextStyle(color: Colors.white),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat.yMMMd().format(activity.activityDate), style: TextStyle(color: Colors.white, fontSize: 12),),
                        Text('${DateFormat.Hm().format(activity.startTime)} - ${DateFormat.Hm().format(activity.endTime)}', style: TextStyle(color: Colors.white, fontSize: 12),),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red,),
                      onPressed: () => _removeActivity(activity),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
