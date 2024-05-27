import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dailyplanner/models/user_model.dart';

class HiveDatabase {
  static Future<void> init() async {
    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ActivityAdapter());
  }

  static Future<Box<User>> openUserBox() async {
    return await Hive.openBox<User>('userBox');
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
