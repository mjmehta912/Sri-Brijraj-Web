import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sri_brijraj_web/constants/api_constants.dart';
import 'package:sri_brijraj_web/features/user_management/models/user_management_model.dart';

class UserManagementService {
  static Future<List<UserModelDm>> fetchUsers() async {
  final url = Uri.parse('$kBaseUrl/User/users');

  final headers = {
    'Content-Type': 'application/json',
  };

  final response = await http.get(
    url,
    headers: headers,
  );

  if (response.statusCode == 200) {
    final dynamic decoded = json.decode(response.body);
    final List<dynamic> data =
        decoded is List ? decoded : (decoded['data'] ?? []);

    return data
        .map(
          (json) => UserModelDm.fromJson(json),
        )
        .toList();
  } else {
    throw 'Failed to fetch users: ${response.body}';
  }
}

  static Future<List<UserAccessModelDm>> fetchUserAccess({
    required int userId,
  }) async {
    final url = Uri.parse('$kBaseUrl/User/userAccess?userId=$userId');

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      return data
          .map(
            (json) => UserAccessModelDm.fromJson(json),
          )
          .toList();
    } else {
      throw 'Failed to fetch user access: ${response.body}';
    }
  }

    static Future<Map<String, dynamic>> setUserAccess({
    required int userId,
    required int menuId,
    required bool access,
    int? subMenuId,
  }) async {
    final url = Uri.parse('$kBaseUrl/User/setAccess');
    final headers = {'Content-Type': 'application/json'};
    final body = {
      'UserId': userId,
      'MENUID': menuId,
      'Access': access,
      if (subMenuId != null) 'SUBMENUID': subMenuId,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode != 200) {
      throw responseData['message'];
    }

    return responseData;
  }
}