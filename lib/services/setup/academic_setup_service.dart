import '../../models/discipline.dart';
import '../../models/schedule.dart';
import '../../models/study_topic.dart';
import '../../models/study_cycle.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/schedule_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/study_topic_repository.dart';
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
  final List<String> initialTopics;

  const AcademicSetupDisciplineDraft({
    required this.name,
    this.teacher = '',
    this.workload = 0,
    this.maxAbsences = 12,
    this.schedules = const [],
    this.initialTopics = const [],
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
    StudyTopicRepository? studyTopicRepository,
    UserProfileRepository? userProfileRepository,
  }) : _studyCycleRepository = studyCycleRepository ?? StudyCycleRepository(),
       _disciplineRepository = disciplineRepository ?? DisciplineRepository(),
       _scheduleRepository = scheduleRepository ?? ScheduleRepository(),
       _studyTopicRepository = studyTopicRepository ?? StudyTopicRepository(),
       _userProfileRepository =
           userProfileRepository ?? UserProfileRepository();

  final StudyCycleRepository _studyCycleRepository;
  final DisciplineRepository _disciplineRepository;
  final ScheduleRepository _scheduleRepository;
  final StudyTopicRepository _studyTopicRepository;
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
      final isIndependent = studyCycle.type == StudyCycleType.independent;

      for (final discipline in disciplines) {
        final disciplineName = discipline.name.trim();
        if (disciplineName.isEmpty) continue;

        final disciplineId = await _disciplineRepository.createDiscipline(
          DisciplineInput(
            name: disciplineName,
            teacher: isIndependent ? '' : discipline.teacher.trim(),
            workload: isIndependent ? 0 : discipline.workload,
            maxAbsences: isIndependent ? 12 : discipline.maxAbsences,
            colorValue: Schedule.colorValueForDisciplineName(disciplineName),
            studyCycleId: studyCycleId,
          ),
        );

        for (final entry in discipline.initialTopics.asMap().entries) {
          final topicTitle = entry.value.trim();
          if (topicTitle.isEmpty) continue;

          await _studyTopicRepository.createTopic(
            StudyTopicInput(
              studyCycleId: studyCycleId,
              disciplineId: disciplineId,
              disciplineName: disciplineName,
              title: topicTitle,
              position: entry.key,
            ),
          );
        }

        if (isIndependent) continue;

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
    } on StudyTopicRepositoryException catch (error) {
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
