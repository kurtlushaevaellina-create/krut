import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:track_dev/core/repository/time_entries.dart';
import 'package:track_dev/data/source/local/local_storage_source.dart';
import 'package:track_dev/data/source/local/default_local_storage_source.dart';
import 'package:track_dev/data/source/redmine/default_redmine_api_source.dart';
import 'package:track_dev/data/source/redmine/fake_redmine_api_source.dart';
import 'package:track_dev/data/source/redmine/redmine_api_source.dart';
import 'package:track_dev/data/source/redmine/auth/auth_session.dart';
import 'package:track_dev/core/repository/preferences.dart';
import 'package:track_dev/core/repository/time.dart';
import 'package:track_dev/data/preferences_repository.dart';
import 'package:track_dev/data/time_repository.dart';
import 'package:track_dev/core/repository/projects.dart';
import 'package:track_dev/data/projects_repository.dart';
import 'package:track_dev/data/time_entries_repository.dart';
import 'package:track_dev/data/user_repository.dart';
import 'package:track_dev/core/repository/user.dart';
import 'package:track_dev/core/repository/issues.dart';
import 'package:track_dev/data/issues_repository.dart';
import 'package:track_dev/data/auth_repository.dart';
import 'package:track_dev/core/repository/auth.dart';

final sharedPreferencesAsyncProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final localStorageSourceProvider = Provider<LocalStorageSource>((ref) {
  return DefaultLocalStorageSource(ref.watch(sharedPreferencesAsyncProvider));
});

final redmineSessionStore = Provider<RedmineSessionStore>(
  (ref) => RedmineSessionStore(ref.watch(localStorageSourceProvider)),
);

final redmineApiSourceProvider = Provider<RedmineApiSource>((ref) {
  return DefaultRedmineApiSource(
    dio: Dio(),
    sessionStore: ref.watch(redmineSessionStore),
  );
  return FakeRedmineApiSource();
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return LocalPreferencesRepository(ref.watch(localStorageSourceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localStorage: ref.watch(localStorageSourceProvider),
    apiSource: ref.watch(redmineApiSourceProvider),
    sessionStore: ref.watch(redmineSessionStore),
  );
});

final timeRepositoryProivder = Provider<TimeRepository>((ref) {
  return LocalTimeRepository(ref.watch(localStorageSourceProvider));
});

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepositoryImpl(apiSource: ref.watch(redmineApiSourceProvider));
});

final timeEntriesRepositoryProvider = Provider<TimeEntriesRepository>((ref) {
  return TimeEntriesRepositoryImpl(
    apiSource: ref.watch(redmineApiSourceProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(apiSource: ref.watch(redmineApiSourceProvider));
});

final issuesRepositoryProvider = Provider<IssuesRepository>((ref) {
  return IssuesRepositoryImpl(apiSource: ref.watch(redmineApiSourceProvider));
});
