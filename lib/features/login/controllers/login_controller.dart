import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sri_brijraj_web/features/login/services/login_service.dart';
import 'package:sri_brijraj_web/features/user_management/services/user_mangement_service.dart';
import 'package:sri_brijraj_web/features/web_nav/screens/web_nav_screen.dart';
import 'package:sri_brijraj_web/utils/alert_message_utils.dart';

class LoginController extends GetxController {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  var isLoading = false.obs;

  var obscuredText = true.obs;
  void togglePasswordVisibility() {
    obscuredText.value = !obscuredText.value;
  }

  var mobileNumberController = TextEditingController();
  var passwordController = TextEditingController();
  var hasAttemptedLogin = false.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    setupValidationListeners();
  }

  void setupValidationListeners() {
    mobileNumberController.addListener(validateForm);
    passwordController.addListener(validateForm);
  }

  void validateForm() {
    if (hasAttemptedLogin.value) {
      formKey.currentState?.validate();
    }
  }

  Future<void> login() async {
    isLoading.value = true;
    try {
      var response = await LoginService.login(
        username: mobileNumberController.text,
        password: passwordController.text,
        fcmToken: '',
      );

      if (response.isNotEmpty) {
        await secureStorage.write(
          key: 'userType',
          value: response['userType'].toString(),
        );
        await secureStorage.write(
          key: 'fullName',
          value: response['fullName'],
        );
        await secureStorage.write(
          key: 'userName',
          value: response['username'],
        );
        await secureStorage.write(
          key: 'userId',
          value: response['userID'].toString(),
        );

        // ADD THIS BLOCK
        final userId = response['userID'] as int;
        final accessList = await UserManagementService.fetchUserAccess(
          userId: userId,
        );
        final hasUserMgmtAccess = accessList.any(
          (a) => a.menuName.toLowerCase() == 'user rights' && a.access,
        );
        await secureStorage.write(
          key: 'hasUserMgmtAccess',
          value: hasUserMgmtAccess.toString(),
        );
      }

      Get.offAll(
        () => WebNavScreen(),
      );
    } catch (e) {
      showErrorDialog(
        'Login Failed',
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}