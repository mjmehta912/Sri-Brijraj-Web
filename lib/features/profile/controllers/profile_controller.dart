import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sri_brijraj_web/features/login/screens/login_screen.dart';

class ProfileController extends GetxController {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  var isLoading = false.obs;

  var fullName = ''.obs;
  var userName = ''.obs;

  var hasUserMgmtAccess = false.obs; // ADD THIS

  Future<void> loadFullName() async {
    fullName.value = await secureStorage.read(key: 'fullName') ?? '';
  }

  Future<void> loadUserName() async {
    userName.value = await secureStorage.read(key: 'userName') ?? '';
  }

  // ADD THIS
  Future<void> loadUserManagementAccess() async {
    final val = await secureStorage.read(key: 'hasUserMgmtAccess');
    hasUserMgmtAccess.value = val == 'true';
  }

  Future<void> logOut() async {
    secureStorage.delete(key: 'fullName');
    secureStorage.delete(key: 'userName');
    secureStorage.delete(key: 'hasUserMgmtAccess'); // ADD THIS

    Get.offAll(() => LoginScreen());
  }
}