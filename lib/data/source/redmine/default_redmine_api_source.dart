import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';

import 'package:dio/dio.dart';

import 'redmine_api_source.dart';
import 'models/shared.dart';
import 'models/query.dart';
import 'models/error.dart';
import 'auth/credentials.dart';
import 'auth/auth_session.dart';
import 'package:track_dev/core/models/paginated_result.dart';

class DefaultRedmineApiSource implements RedmineApiSource {
  final Dio _dio;
  final RedmineSessionStore _sessionStore;

  DefaultRedmineApiSource({required this._dio, required this._sessionStore});

  Future<Response<dynamic>> _send(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final options = Options(responseType: ResponseType.json, method: method);
    final session = await _sessionStore.read();
    if (session == null) {
      _log.severe("Can't perform any request: Server url is not known");
      throw RedmineApiException(
        'Unkwnown host: Session is not defined',
        NotFoundErrorKind(),
      );
    }

    final headers = <String, dynamic>{};
    switch (session.credentials) {
      case RedmineBasicAuthCredentials(:final username, :final password):
        headers[HttpHeaders.authorizationHeader] = _basicAuthHeader(
          username,
          password,
        );
      case RedmineApiKeyCredentials(:final apiKey):
        headers['X-Redmine-API-Key'] = apiKey;
    }

    try {
      return await _dio.request<dynamic>(
        '${session.baseUrl}$path',
        data: data,
        queryParameters: queryParameters,
        options: options.copyWith(headers: headers),
      );
    } on DioException catch (e) {
      throw RedmineApiException(_messageFromDio(e), _kindFromDio(e), cause: e);
    } on FormatException catch (e) {
      throw RedmineApiException(
        'Invalid response format',
        UnexpectedResponseErrorKind(e.message),
        cause: e,
      );
    } on Object catch (e) {
      throw RedmineApiException(
        'Unexpected client error',
        UnknownErrorKind(detail: e.toString()),
        cause: e,
      );
    }
  }

  RedmineErrorKind _kindFromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutErrorKind();
      case DioExceptionType.cancel:
        return const RequestCanceledErrorKind();
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return const NoConnectionErrorKind();
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) return const SessionExpiredErrorKind();
        if (status == 403) return const ForbiddenErrorKind();
        if (status == 404) return const NotFoundErrorKind();
        if (status == 409) return const ConflictErrorKind();
        if (status == 422) {
          return ValidationErrorKind(errors: _errorsFromBody(e.response?.data));
        }
        return NetworkErrorKind(code: status);
      case DioExceptionType.unknown:
        return const NoConnectionErrorKind();
    }
  }

  String _messageFromDio(DioException e) {
    final status = e.response?.statusCode;
    if (status != null) return 'HTTP $status';
    return e.message ?? 'Request failed';
  }

  Map<String, List<String>> _errorsFromBody(dynamic data) {
    final json = _asMap(data);
    final errors = <String, List<String>>{};
    final rawErrors = json['errors'];
    if (rawErrors is Map) {
      for (final entry in rawErrors.entries) {
        final values = entry.value;
        if (values is List) {
          errors[entry.key.toString()] = values
              .map((e) => e.toString())
              .toList(growable: false);
        } else {
          errors[entry.key.toString()] = <String>[values.toString()];
        }
      }
    } else if (rawErrors is List) {
      errors['base'] = rawErrors
          .map((e) => e.toString())
          .toList(growable: false);
    } else if (rawErrors is String) {
      errors['base'] = <String>[rawErrors];
    }
    return errors;
  }

  static PaginatedResult<T> _paginated<T>(
    JsonMap json,
    String listKey,
    T Function(JsonMap) parse,
  ) {
    final items = (json[listKey] as List? ?? const [])
        .map((e) => parse(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
    return PaginatedResult<T>(
      items: items,
      totalCount: json['total_count'] as int?,
      offset: json['offset'] as int? ?? 0,
      limit: json['limit'] as int? ?? items.length,
    );
  }

  @override
  Future<bool> checkBeacon(String servername) async {
    final uri = Uri.tryParse(servername);
    if (uri == null) return false;

    try {
      final response = await _dio.getUri<dynamic>(
        uri,
        options: Options(
          method: 'GET',
          responseType: ResponseType.plain,
          followRedirects: true,
          validateStatus: (_) => true,
        ),
      );

      final status = response.statusCode;
      return status == 200 || status == 401 || status == 403;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<RedmineUser> fetchCurrentUser() async {
    final response = await _send('GET', '/users/current.json');
    return RedmineUser.fromJson(_asMap(response.data)['user'] as JsonMap);
  }

  @override
  Future<PaginatedResult<RedmineProject>> listProjects({
    int offset = 0,
    int limit = 25,
  }) async {
    final response = await _send(
      'GET',
      '/projects.json',
      queryParameters: {'offset': offset, 'limit': limit},
    );
    return _paginated(
      _asMap(response.data),
      'projects',
      RedmineProject.fromJson,
    );
  }

  @override
  Future<PaginatedResult<RedmineTimeEntry>> listTimeEntries({
    int offset = 0,
    int limit = 25,
    int? userId,
    String? projectId,
    int? issueId,
    DateTime? spentOnFrom,
    DateTime? spentOnTo,
  }) async {
    final response = await _send(
      'GET',
      '/time_entries.json',
      queryParameters: _compact({
        'offset': offset,
        'limit': limit,
        'user_id': userId,
        'project_id': projectId,
        'issue_id': issueId,
        // 'spent_on': _spentOnQuery(spentOnFrom, spentOnTo),
        'from': spentOnFrom != null ? _ymd(spentOnFrom) : null,
        'to': spentOnTo != null ? _ymd(spentOnTo) : null,
      }),
    );
    return _paginated(
      _asMap(response.data),
      'time_entries',
      RedmineTimeEntry.fromJson,
    );
  }

  @override
  Future<RedmineTimeEntry> createTimeEntry(
    CreateTimeEntryRequest request,
  ) async {
    final response = await _send(
      'POST',
      '/time_entries.json',
      data: request.toJson(),
    );
    return RedmineTimeEntry.fromJson(
      _asMap(response.data)['time_entry'] as JsonMap,
    );
  }

  @override
  Future<void> deleteTimeEntry(int id) async {
    await _send('DELETE', '/time_entries/$id.json');
  }

  @override
  Future<List<RedmineTimeEntryActivity>> listTimeEntryActivities() async {
    final response = await _send(
      'GET',
      '/enumerations/time_entry_activities.json',
    );
    final json = _asMap(response.data);
    return (json['time_entry_activities'] as List? ?? const [])
        .map(
          (e) => RedmineTimeEntryActivity.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<PaginatedResult<RedmineIssue>> listIssues({
    int offset = 0,
    int limit = 25,
    String? sort,
    int? projectId,
    int? subprojectId,
    int? trackerId,
    String? statusId,
    String? assignedToId,
    int? parentId,
    String? issueId,
  }) async {
    final response = await _send(
      'GET',
      '/issues.json',
      queryParameters: _compact({
        'offset': offset,
        'limit': limit,
        'sort': sort,
        'project_id': projectId,
        'subproject_id': subprojectId,
        'tracker_id': trackerId,
        'status_id': statusId,
        'assigned_to_id': assignedToId,
        'parent_id': parentId,
        'issue_id': issueId,
      }),
    );
    return _paginated(_asMap(response.data), 'issues', RedmineIssue.fromJson);
  }

  @override
  Future<List<RedmineIssueCategory>> listIssueCategories(
    String projectId,
  ) async {
    final response = await _send(
      'GET',
      '/projects/$projectId/issue_categories.json',
    );
    final json = _asMap(response.data);
    return (json['issue_categories'] as List? ?? const [])
        .map(
          (e) => RedmineIssueCategory.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList(growable: false);
  }
}

JsonMap _asMap(dynamic data) {
  if (data is JsonMap) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is String && data.trim().isNotEmpty) {
    return Map<String, dynamic>.from(jsonDecode(data) as Map);
  }

  _log.warning("Unable to convert data to map");
  return <String, dynamic>{};
}

Map<String, dynamic> _compact(Map<String, dynamic> input) {
  input.removeWhere((_, value) => value == null);
  return input;
}

String _ymd(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _basicAuthHeader(String username, String password) =>
    'Basic ${base64Encode(utf8.encode('$username:$password'))}';

final _log = Logger('DefaultRedmineApiSource');
