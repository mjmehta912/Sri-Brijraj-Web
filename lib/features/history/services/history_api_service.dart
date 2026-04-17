import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:sri_brijraj_web/constants/api_constants.dart';
import 'package:sri_brijraj_web/features/history/models/history_model_dm.dart';

class HistoryService {
  static Future<List<HistoryModelDm>> fetchHistory({
    String slipNo = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final url = Uri.parse(
      '$kBaseUrl/data/history?SlipNo=$slipNo&PageSize=$pageSize&PageNumber=$pageNumber',
    );

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map(
            (json) => HistoryModelDm.fromJson(json),
          )
          .toList();
    } else {
      throw 'Failed to fetch history: ${response.body}';
    }
  }

  static Future<Uint8List?> downloadSlip({
    required String slipNo,
  }) async {
    final url = Uri.parse(
      '$kBaseUrl/data/print?SlipNo=$slipNo',
    );

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw 'Failed to download PDF';
    }
  }

  static Future<void> deleteSlip({
    required String slipNo,
  }) async {
    final url = Uri.parse('$kBaseUrl/data/delete');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'SlipNo': slipNo}),
    );

    if (response.statusCode != 200) {
      try {
        final decoded = json.decode(response.body);
        throw decoded['message'] ?? decoded['error'] ?? 'Failed to delete slip';
      } catch (_) {
        throw 'Failed to delete slip (${response.statusCode}): ${response.body}';
      }
    }
  }
}
