import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_brijraj_web/constants/color_constants.dart';
import 'package:sri_brijraj_web/features/profile/controllers/profile_controller.dart';
import 'package:sri_brijraj_web/features/reports/screens/report_filter_screen.dart';
import 'package:sri_brijraj_web/features/reset_password/screens/reset_password_screen.dart';
import 'package:sri_brijraj_web/styles/textstyles.dart';
import 'package:sri_brijraj_web/features/user_management/screens/user_management_screen.dart';
import 'package:sri_brijraj_web/widgets/app_button.dart';
import 'package:sri_brijraj_web/widgets/app_paddings.dart';
import 'package:sri_brijraj_web/widgets/app_size_extensions.dart';
import 'package:sri_brijraj_web/widgets/app_spacings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _controller.loadFullName();
    _controller.loadUserName();
    _controller.loadUserManagementAccess(); // ADD THIS
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorwhite,
      body: Padding(
        padding: AppPaddings.ph16,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'SRI BRIJRAJ',
                style: TextStyles.kBoldInstrumentSans(
                  fontSize: FontSize.k40FontSize,
                  color: kColorPrimary,
                ),
              ),
              Obx(
                () => Text(
                  _controller.fullName.value,
                  style: TextStyles.kSemiBoldInstrumentSans(
                    fontSize: FontSize.k24FontSize,
                    color: kColorSecondary,
                  ),
                ),
              ),
              AppSpaces.v50,
              AppButton(
                onPressed: () => Get.to(() => ReportFilterScreen()),
                buttonHeight: 50,
                buttonWidth: 0.4.screenWidth,
                title: 'Download Report',
              ),
              AppSpaces.v20,
              AppButton(
                onPressed: () => Get.to(
                  () => ResetPasswordScreen(userName: _controller.userName.value),
                ),
                buttonHeight: 50,
                buttonWidth: 0.4.screenWidth,
                title: 'Reset Password',
              ),
              AppSpaces.v20,
              AppButton(
                onPressed: () => _controller.logOut(),
                buttonHeight: 50,
                buttonWidth: 0.4.screenWidth,
                title: 'Logout',
              ),
              AppSpaces.v20,

              // ADD THIS BLOCK
              Obx(
                () => _controller.hasUserMgmtAccess.value
                    ? AppButton(
                        onPressed: () => Get.to(
                          () => const UserManagementScreen(),
                        ),
                        buttonHeight: 50,
                        buttonWidth: 0.4.screenWidth,
                        title: 'User Rights',
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}