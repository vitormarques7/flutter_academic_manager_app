import '../repositories/schedule_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/user_profile_repository.dart';

class UserDataBootstrapService {
  UserDataBootstrapService({
    UserProfileRepository? userProfileRepository,
    TaskRepository? taskRepository,
    ScheduleRepository? scheduleRepository,
  }) : _userProfileRepository =
           userProfileRepository ?? UserProfileRepository(),
       _taskRepository = taskRepository ?? TaskRepository(),
       _scheduleRepository = scheduleRepository ?? ScheduleRepository();

  final UserProfileRepository _userProfileRepository;
  final TaskRepository _taskRepository;
  final ScheduleRepository _scheduleRepository;

  Future<void> ensureCurrentUserData({
    String? displayName,
    String? email,
  }) async {
    await _userProfileRepository.ensureCurrentUserDocument(
      displayName: displayName,
      email: email,
    );

    final activeStudyCycleId = await _userProfileRepository
        .resolveActiveStudyCycleId();
    if (activeStudyCycleId == null) return;

    await _taskRepository.backfillStudyCycleId(activeStudyCycleId);
    await _scheduleRepository.backfillStudyCycleId(activeStudyCycleId);
  }
}
