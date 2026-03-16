import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class NarrativeAICall {
  static Future<ApiCallResponse> call({
    String? action = '',
    String? userId = '',
    String? sessionId = '',
    String? choiceId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "action": "${escapeStringForJson(action)}",
  "user_id": "${escapeStringForJson(userId)}",
  "session_id": "${escapeStringForJson(sessionId)}",
  "choice_id": "${escapeStringForJson(choiceId)}",
  "myth_id": "gilgamesh_enkidu",
  "player_name": "Viajero",
  "difficulty": "normal",
  "language": "es"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'narrativeAI',
      apiUrl: 'https://wtkohxujhvaxoablfevz.supabase.co/functions/v1/narrative',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0a29oeHVqaHZheG9hYmxmZXZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzOTg0NjQsImV4cCI6MjA4Nzk3NDQ2NH0.Ga3SgxGPxGk5Y5FWbYSRJ_MkKy5P3XO-dW5N-MIl8T0',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? narrative(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.narrative''',
      ));
  static String? sessionId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.session_id''',
      ));
  static List? choices(dynamic response) => getJsonField(
        response,
        r'''$.choices''',
        true,
      ) as List?;
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
