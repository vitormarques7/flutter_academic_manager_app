import '../../models/discipline.dart';
import '../../models/schedule.dart';
import '../../models/study_cycle.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/schedule_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/user_profile_repository.dart';

class AcademicSetupException implements Exception {
  final String message;

  const AcademicSetupException(this.message);

  @override
  String toString() => message;
}

class AcademicSetupDisciplineDraft {
  final String name;
  final String teacher;
  final int workload;
  final int maxAbsences;
  final List<AcademicSetupScheduleDraft> schedules;

  const AcademicSetupDisciplineDraft({
    required this.name,
    this.teacher = '',
    this.workload = 0,
    this.maxAbsences = 12,
    this.schedules = const [],
  });
}

class AcademicSetupScheduleDraft {
  final List<int> weekdays;
  final int startTimeMinutes;
  final int endTimeMinutes;

  const AcademicSetupScheduleDraft({
    required this.weekdays,
    required this.startTimeMinutes,
    required this.endTimeMinutes,
  });
}

class AcademicSetupService {
  AcademicSetupService({
    StudyCycleRepository? studyCycleRepository,
    DisciplineRepository? disciplineRepository,
    ScheduleRepository? scheduleRepository,
    UserProfileRepository? userProfileRepository,
  }) : _studyCycleRepository = studyCycleRepository ?? StudyCycleRepository(),
       _disciplineRepository = disciplineRepository ?? DisciplineRepository(),
       _scheduleRepository = scheduleRepository ?? ScheduleRepository(),
       _userProfileRepository =
           userProfileRepository ?? UserProfileRepository();

  final StudyCycleRepository _studyCycleRepository;
  final DisciplineRepository _disciplineRepository;
  final ScheduleRepository _scheduleRepository;
  final UserProfileRepository _userProfileRepository;

  Future<String> saveSetup({
    required StudyCycleInput studyCycle,
    required List<AcademicSetupDisciplineDraft> disciplines,
  }) async {
    try {
      final studyCycleId = await _studyCycleRepository.createStudyCycle(
        studyCycle,
      );
      await _userProfileRepository.setActiveStudyCycleId(studyCycleId);

      for (final discipline in disciplines) {
        final disciplineName = discipline.name.trim();
        if (disciplineName.isEmpty) continue;

        final disciplineId = await _disciplineRepository.createDiscipline(
          DisciplineInput(
            name: disciplineName,
            teacher: discipline.teacher.trim(),
            workload: discipline.workload,
            maxAbsences: discipline.maxAbsences,
            colorValue: Schedule.colorValueForDisciplineName(disciplineName),
            studyCycleId: studyCycleId,
          ),
        );

        for (final schedule in discipline.schedules) {
          if (schedule.weekdays.isEmpty) continue;

          await _scheduleRepository.createSchedule(
            ScheduleInput(
              studyCycleId: studyCycleId,
              disciplineId: disciplineId,
              disciplineName: disciplineName,
              weekdays: schedule.weekdays,
              startTimeMinutes: schedule.startTimeMinutes,
              endTimeMinutes: schedule.endTimeMinutes,
              colorValue: Schedule.colorValueForDisciplineName(disciplineName),
            ),
          );
        }
      }

      return studyCycleId;
    } on StudyCycleRepositoryException catch (error) {
      throw AcademicSetupException(error.message);
    } on DisciplineRepositoryException catch (error) {
      throw AcademicSetupException(error.message);
    } on ScheduleRepositoryException catch (error) {
      throw AcademicSetupException(error.message);
    } on UserProfileRepositoryException catch (error) {
      throw AcademicSetupException(error.message);
    } catch (_) {
      throw const AcademicSetupException(
        'Não foi possível salvar sua configuração inicial. Tente novamente.',
      );
    }
  }
}
