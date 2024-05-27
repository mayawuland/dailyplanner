import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String password;

  @HiveField(2)
  final List<Activity> activities;

  @HiveField(3)
  final List<int> checklist;

  User({
    required this.username,
    required this.password,
    List<Activity>? activities,
    List<int>? checklist,
  })  : activities = activities ?? [],
        checklist = checklist ?? [];
}

@HiveType(typeId: 1)
class Activity {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime activityDate;

  @HiveField(4)
  final DateTime startTime;

  @HiveField(5)
  final DateTime endTime;

  @HiveField(6)
  final String location;

  Activity(
      this.id,
      this.title,
      this.description,
      this.activityDate,
      this.startTime,
      this.endTime,
      this.location,
      );
}
