import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_brijraj_web/features/user_management/models/user_management_model.dart';
import 'package:sri_brijraj_web/features/user_management/services/user_mangement_service.dart';
import 'package:sri_brijraj_web/utils/alert_message_utils.dart';

class UserManagementController extends GetxController {
  var isLoading = false.obs;
  var isAccessLoading = false.obs;
  var isUpdatingAccess = false.obs;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  var userList = <UserModelDm>[].obs;
  var filteredUserList = <UserModelDm>[].obs;
  var accessList = <UserAccessModelDm>[].obs;

  // Tracks which userId's access panel is expanded (null = none)
  var selectedUserId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    debounceSearchQuery();
  }

  void debounceSearchQuery() {
    debounce(
      searchQuery,
      (_) => _filterUsers(),
      time: const Duration(milliseconds: 300),
    );
  }

  void _filterUsers() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredUserList.assignAll(userList);
    } else {
      filteredUserList.assignAll(
        userList.where(
          (user) =>
              user.fullName.toLowerCase().contains(query) ||
              user.username.toLowerCase().contains(query) ||
              user.mobileNo.contains(query),
        ),
      );
    }
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final fetched = await UserManagementService.fetchUsers();
      userList.assignAll(fetched);
      filteredUserList.assignAll(fetched);
    } catch (e) {
      showErrorDialog('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserAccess({required int userId}) async {
    try {
      isAccessLoading.value = true;
      accessList.clear();
      selectedUserId.value = userId;
      final fetched = await UserManagementService.fetchUserAccess(
        userId: userId,
      );
      accessList.assignAll(fetched);
    } catch (e) {
      showErrorDialog('Error', e.toString());
    } finally {
      isAccessLoading.value = false;
    }
  }

  Future<void> setUserAccess({
    required int userId,
    required int menuId,
    required bool access,
  }) async {
    try {
      isUpdatingAccess.value = true;
      final response = await UserManagementService.setUserAccess(
        userId: userId,
        menuId: menuId,
        access: access,
      );

      final message = response['message'] as String;
      final isSuccess = message.toLowerCase().contains('granted');

      if (isSuccess) {
        final index = accessList.indexWhere((a) => a.menuId == menuId);
        if (index != -1) {
          accessList[index] = UserAccessModelDm(
            menuId: accessList[index].menuId,
            menuName: accessList[index].menuName,
            access: access,
          );
          accessList.refresh();
        }
        showSuccessDialog('Success', message);
      } else {
        await fetchUserAccess(userId: userId);
        showSuccessDialog('Success', message);
      }
    } catch (e) {
      await fetchUserAccess(userId: userId);
      showErrorDialog('Error', e.toString());
    } finally {
      isUpdatingAccess.value = false;
    }
  }

  void toggleUserPanel({required int userId}) {
    if (selectedUserId.value == userId) {
      selectedUserId.value = null;
      accessList.clear();
    } else {
      fetchUserAccess(userId: userId);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}