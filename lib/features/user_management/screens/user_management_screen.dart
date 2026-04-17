import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_brijraj_web/constants/color_constants.dart';
import 'package:sri_brijraj_web/styles/textstyles.dart';
import 'package:sri_brijraj_web/features/user_management/controller/user_management_controller.dart';
import 'package:sri_brijraj_web/features/user_management/models/user_management_model.dart';
import 'package:sri_brijraj_web/widgets/app_paddings.dart';
import 'package:sri_brijraj_web/widgets/app_spacings.dart';
import 'package:sri_brijraj_web/widgets/app_text_form_field.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserManagementController _controller =
      Get.put(UserManagementController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorwhite,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isWide = screenWidth > 900;
          final paddingH = screenWidth > 1200 ? 40.0 : 20.0;
          final paddingV = screenWidth > 1200 ? 20.0 : 10.0;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: paddingH,
              vertical: paddingV,
            ),
            child: isWide
                ? _WideLayout(controller: _controller)
                : _NarrowLayout(controller: _controller),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wide layout: user list on the left, access panel on the right
// ─────────────────────────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.controller});
  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: user list
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _SearchBar(controller: controller),
              AppSpaces.v12,
              Expanded(child: _UserList(controller: controller)),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Right: access panel
        Expanded(
          flex: 3,
          child: Obx(() {
            if (controller.selectedUserId.value == null) {
              return Center(
                child: Text(
                  'Select a user to manage access.',
                  style: TextStyles.kMediumInstrumentSans(
                    color: kColorSecondary,
                    fontSize: 14,
                  ),
                ),
              );
            }

            final user = controller.userList.firstWhereOrNull(
              (u) => u.userId == controller.selectedUserId.value,
            );

            if (user == null) return const SizedBox();

            return _AccessPanel(user: user, controller: controller);
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Narrow layout: stacked — list on top, access panel below when a user is selected
// ─────────────────────────────────────────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.controller});
  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchBar(controller: controller),
        AppSpaces.v12,
        Expanded(
          child: Obx(() {
            // If a user is selected, show the access panel instead
            if (controller.selectedUserId.value != null) {
              final user = controller.userList.firstWhereOrNull(
                (u) => u.userId == controller.selectedUserId.value,
              );
              if (user != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    TextButton.icon(
                      onPressed: () {
                        controller.selectedUserId.value = null;
                        controller.accessList.clear();
                      },
                      icon: const Icon(Icons.arrow_back, color: kColorPrimary),
                      label: Text(
                        'Back to Users',
                        style: TextStyles.kMediumInstrumentSans(
                          color: kColorPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    AppSpaces.v8,
                    Expanded(
                      child: _AccessPanel(user: user, controller: controller),
                    ),
                  ],
                );
              }
            }
            return _UserList(controller: controller);
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 600
            ? constraints.maxWidth * 0.5
            : double.infinity;
        return SizedBox(
          width: width,
          child: AppTextFormField(
            controller: controller.searchController,
            hintText: 'Search User',
            onChanged: (query) => controller.searchQuery.value = query,
          ),
        );
      },
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({required this.controller});
  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: kColorDarkBlue),
        );
      }
      if (controller.filteredUserList.isEmpty) {
        return Center(
          child: Text(
            'No users found.',
            style: TextStyles.kBoldInstrumentSans(color: kColorSecondary),
          ),
        );
      }
      return ListView.builder(
        itemCount: controller.filteredUserList.length,
        itemBuilder: (context, index) {
          final user = controller.filteredUserList[index];
          return _UserCard(user: user, controller: controller);
        },
      );
    });
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.controller});
  final UserModelDm user;
  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedUserId.value == user.userId;
      return Card(
        color: isSelected ? kColorPrimary.withOpacity(0.07) : kColorwhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? kColorPrimary : kColorBlack,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => controller.toggleUserPanel(userId: user.userId),
          child: Padding(
            padding: AppPaddings.p16,
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: kColorPrimary.withOpacity(0.15),
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyles.kBoldInstrumentSans(
                      color: kColorPrimary,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + username
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyles.kBoldInstrumentSans(
                          color: kColorPrimary,
                          fontSize: 16,
                        ),
                      ),
                      AppSpaces.v4,
                      Text(
                        user.username,
                        style: TextStyles.kMediumInstrumentSans(
                          color: kColorSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Mobile + chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user.mobileNo,
                      style: TextStyles.kMediumInstrumentSans(
                        color: kColorBlack,
                        fontSize: 13,
                      ),
                    ),
                    AppSpaces.v4,
                    Icon(
                      isSelected
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_right,
                      color: kColorPrimary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Access panel — shown on the right (wide) or full screen (narrow)
// ─────────────────────────────────────────────────────────────────────────────
class _AccessPanel extends StatelessWidget {
  const _AccessPanel({required this.user, required this.controller});
  final UserModelDm user;
  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User header card
        Card(
          color: kColorwhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: kColorPrimary, width: 1.5),
          ),
          child: Padding(
            padding: AppPaddings.p16,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: kColorPrimary,
                  radius: 24,
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyles.kBoldInstrumentSans(
                      color: kColorwhite,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyles.kBoldInstrumentSans(
                        color: kColorPrimary,
                        fontSize: 18,
                      ),
                    ),
                    AppSpaces.v4,
                    Text(
                      user.username,
                      style: TextStyles.kMediumInstrumentSans(
                        color: kColorSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AppSpaces.v12,

        Text(
          'User Access',
          style: TextStyles.kBoldInstrumentSans(
            color: kColorPrimary,
            fontSize: 16,
          ),
        ),
        AppSpaces.v8,

        Expanded(
          child: Obx(() {
            if (controller.isAccessLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: kColorDarkBlue),
              );
            }
            if (controller.accessList.isEmpty) {
              return Center(
                child: Text(
                  'No access data found.',
                  style: TextStyles.kBoldInstrumentSans(
                    color: kColorSecondary,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: controller.accessList.length,
              itemBuilder: (context, index) {
                final access = controller.accessList[index];
                return _AccessRow(
                  access: access,
                  user: user,
                  controller: controller,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({
    required this.access,
    required this.user,
    required this.controller,
  });
  final UserAccessModelDm access;
  final UserModelDm user;
  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kColorwhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: kColorBlack, width: 1),
      ),
      child: Padding(
        padding: AppPaddings.p16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              access.menuName,
              style: TextStyles.kMediumInstrumentSans(
                color: kColorPrimary,
                fontSize: 15,
              ),
            ),
            Obx(
              () => Switch(
                value: access.access,
                activeColor: kColorPrimary,
                onChanged: controller.isUpdatingAccess.value
                    ? null
                    : (value) {
                        controller.setUserAccess(
                          userId: user.userId,
                          menuId: access.menuId,
                          access: value,
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}