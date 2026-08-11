import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';

/// App-owned Riverpod lifetime around UserProfile's framework-free factory.
final userProfilePortsProvider = Provider<UserProfilePorts>(
    (ref) => createUserProfilePorts(_userProfileDependencyReader(ref)));

UserProfileDependencyReader _userProfileDependencyReader(Ref ref) =>
    <T>(UserProfileDependency dependency) {
      switch (dependency) {
        case UserProfileDependency.database:
          return ref.watch(databaseProvider) as T;
        case UserProfileDependency.sharedPreferences:
          return ref.watch(sharedPreferencesProvider) as T;
        case UserProfileDependency.remoteMutationExecutor:
          return ref.watch(remoteMutationExecutorProvider) as T;
        case UserProfileDependency.outboxWriter:
          return ref.watch(driftOutboxWriterProvider) as T;
      }
    };
