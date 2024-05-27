import 'package:hive/hive.dart';
import 'package:dailyplanner/models/user_model.dart';
import 'hive_database.dart';

class UserController {
  static Future<void> addUser(User user) async {
    var box = await HiveDatabase.openUserBox();
    await box.put(user.username, user);
  }

  static Future<User?> getUser(String username) async {
    var box = await HiveDatabase.openUserBox();
    return box.get(username);
  }

  static Future<void> addActivity(String username, Activity activity) async {
    var box = await HiveDatabase.openUserBox();
    User? user = await box.get(username);

    if (user != null) {
      user.activities.add(activity);
      await box.put(username, user);
    }
  }

  static Future<void> removeActivity(String username, Activity activity) async {
    var box = await HiveDatabase.openUserBox();
    User? user = box.get(username);

    if (user != null) {
      user.activities.removeWhere((element) => element.id == activity.id);
      await box.put(username, user);
    }
  }

  static Future<List<Activity>> getUserActivities(String username) async {
    var box = await HiveDatabase.openUserBox();
    User? user = await box.get(username);

    return user?.activities ?? [];
  }

  static Future<void> addChecklistItem(String username, int item) async {
    var box = await HiveDatabase.openUserBox();
    User? user = await box.get(username);

    if (user != null) {
      user.checklist.add(item);
      await box.put(username, user);
    }
  }

  static Future<void> removeChecklistItem(String username, int item) async {
    var box = await HiveDatabase.openUserBox();
    User? user = await box.get(username);

    if (user != null) {
      user.checklist.remove(item);
      await box.put(username, user);
    }
  }

  static Future<void> toggleChecklistItem(String username, Activity activity) async {
    var box = await HiveDatabase.openUserBox();
    User? user = await box.get(username);

    if (user != null) {
      if (user.checklist.contains(activity.id)) {
        user.checklist.remove(activity.id);
      } else {
        user.checklist.add(activity.id);
      }
      await box.put(username, user);
    }
  }

  static Future<List<Activity>> getCheckedActivities(String username) async {
    var box = await HiveDatabase.openUserBox();
    User? user = box.get(username);
    List<Activity> checkedActivities = [];

    if (user != null) {
      for (var activity in user.activities) {
        if (user.checklist.contains(activity.id)) {
          checkedActivities.add(activity);
        }
      }
    }

    return checkedActivities;
  }
}
