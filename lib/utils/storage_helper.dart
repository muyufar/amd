import 'package:get_storage/get_storage.dart';

class StorageHelper {
  static final box = GetStorage();

  static String? getToken() => box.read('token');
  static void saveToken(String token) => box.write('token', token);
  static void removeToken() => box.remove('token');
}
