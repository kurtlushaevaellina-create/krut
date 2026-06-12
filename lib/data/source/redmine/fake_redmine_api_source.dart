import 'redmine_api_source.dart';
import 'models/shared.dart';
import 'models/query.dart';
import 'package:track_dev/core/models/paginated_result.dart';

class FakeRedmineApiSource implements RedmineApiSource {
  FakeRedmineApiSource({
    RedmineUser? currentUser,
    List<RedmineProject>? projects,
    List<RedmineTimeEntry>? timeEntries,
    List<RedmineIssue>? issues,
    List<RedmineTimeEntryActivity>? activities,
    Map<int, List<RedmineIssueCategory>>? issueCategoriesByProjectId,
  })  : _currentUser = currentUser ?? const RedmineUser(id: 1, login: 'demo', firstname: 'Demo', lastname: 'User', mail: 'demo@example.com'),
        _projects = projects ?? const [
          RedmineProject(id: 1, name: 'Redmine', identifier: 'redmine'),
          RedmineProject(id: 2, name: 'Website', identifier: 'website'),
        ],
        _timeEntries = timeEntries ?? [
          RedmineTimeEntry(id: 501, hours: 2.5, userId: 1, spentOn: DateTime.now().subtract(Duration(days: 3)), projectId: 1, issueId: 101, activityId: 9),
          RedmineTimeEntry(id: 502, hours: 1.0, userId: 1, spentOn: DateTime.now().subtract(Duration(days: 4)), projectId: 2, issueId: 102, activityId: 9),
        ],
        _issues = issues ?? const [
          RedmineIssue(id: 101, assignedToId: 1, subject: 'Fix login page',  projectId: 1, status: RedmineIssueStatus(id: 1, name: 'New', isClosed: false), priorityId: 4),
          RedmineIssue(id: 102, assignedToId: 1, subject: 'Update docs', projectId: 2, status: RedmineIssueStatus(id: 1, name: 'New', isClosed: false), priorityId: 3),
        ],
        _activities = activities ?? const [
          RedmineTimeEntryActivity(id: 8, name: 'Design'),
          RedmineTimeEntryActivity(id: 9, name: 'Development', isDefault: true),
        ],
        _issueCategoriesByProjectId = issueCategoriesByProjectId ?? const {
          1: [RedmineIssueCategory(id: 11, name: 'Backend', projectId: 1)],
          2: [RedmineIssueCategory(id: 21, name: 'Content', projectId: 2)],
        };

  final RedmineUser _currentUser;
  final List<RedmineProject> _projects;
  final List<RedmineTimeEntry> _timeEntries;
  final List<RedmineIssue> _issues;
  final List<RedmineTimeEntryActivity> _activities;
  final Map<int, List<RedmineIssueCategory>> _issueCategoriesByProjectId;
  int _nextTimeEntryId = 600;

  @override
  Future<bool> checkBeacon(String servername) async => true;

  @override
  Future<RedmineUser> fetchCurrentUser() async => _currentUser;

  @override
  Future<PaginatedResult<RedmineProject>> listProjects({int offset = 0, int limit = 25}) async {
    final items = _projects.skip(offset).take(limit).toList(growable: false);
    return PaginatedResult(items: items, totalCount: _projects.length, offset: offset, limit: limit);
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
    Iterable<RedmineTimeEntry> out = _timeEntries;
    if (userId != null) out = out.where((e) => e.userId == userId);
    if (projectId != null) out = out.where((e) => e.projectId?.toString() == projectId);
    if (issueId != null) out = out.where((e) => e.issueId == issueId);
    if (spentOnFrom != null || spentOnTo != null) {
      out = out.where((e) {
        final date = e.spentOn;
        if (date == null) return false;
        if (spentOnFrom != null && date.isBefore(DateTime(spentOnFrom.year, spentOnFrom.month, spentOnFrom.day))) return false;
        if (spentOnTo != null && date.isAfter(DateTime(spentOnTo.year, spentOnTo.month, spentOnTo.day, 23, 59, 59))) return false;
        return true;
      });
    }
    final filtered = out.toList(growable: false);
    return PaginatedResult(
      items: filtered.skip(offset).take(limit).toList(growable: false),
      totalCount: filtered.length,
      offset: offset,
      limit: limit,
    );
  }

  @override
  Future<RedmineTimeEntry> createTimeEntry(CreateTimeEntryRequest request) async {
    final entry = RedmineTimeEntry(
      id: _nextTimeEntryId++,
      hours: request.hours,
      spentOn: request.spentOn,
      comment: request.comments,
      activityId: request.activityId,
      projectId: request.projectId,
      issueId: request.issueId,
      userId: _currentUser.id,
      createdOn: DateTime.now(),
      updatedOn: DateTime.now(),
    );
    _timeEntries.add(entry);
    return entry;
  }

  @override
  Future<void> deleteTimeEntry(int id) async {
    _timeEntries.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<RedmineTimeEntryActivity>> listTimeEntryActivities() async => List.unmodifiable(_activities);

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
    Iterable<RedmineIssue> out = _issues;
    if (projectId != null) out = out.where((e) => e.projectId == projectId);
    if (trackerId != null) out = out.where((e) => e.trackerId == trackerId);
    if (statusId != null) out = out.where((e) => e.status?.id.toString() == statusId);
    if (assignedToId != null) out = out.where((e) => e.assignedToId?.toString() == assignedToId);
    if (parentId != null) out = out.where((e) => e.id == parentId);
    if (issueId != null) {
      final ids = issueId.split(',').map((e) => e.trim()).toSet();
      out = out.where((e) => ids.contains(e.id.toString()));
    }
    final filtered = out.toList(growable: false);
    return PaginatedResult(
      items: filtered.skip(offset).take(limit).toList(growable: false),
      totalCount: filtered.length,
      offset: offset,
      limit: limit,
    );
  }

  @override
  Future<List<RedmineIssueCategory>> listIssueCategories(String projectId) async {
    final pid = int.tryParse(projectId);
    if (pid != null && _issueCategoriesByProjectId.containsKey(pid)) {
      return List.unmodifiable(_issueCategoriesByProjectId[pid]!);
    }
    final project = _projects.where((p) => p.identifier == projectId).toList();
    if (project.isEmpty) return const [];
    return List.unmodifiable(_issueCategoriesByProjectId[project.first.id] ?? const []);
  }
}

