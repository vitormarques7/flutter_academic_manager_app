class UserProfile {
  final String? course;
  final String? periodLabel;
  final String? studentType;
  final String? goal;
  final bool onboardingCompleted;

  const UserProfile({
    this.course,
    this.periodLabel,
    this.studentType,
    this.goal,
    this.onboardingCompleted = false,
  });

  factory UserProfile.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const UserProfile();

    return UserProfile(
      course: data['course'] as String?,
      periodLabel: data['periodLabel'] as String?,
      studentType: data['studentType'] as String?,
      goal: data['goal'] as String?,
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
    );
  }

  String? get primaryLabel {
    final courseText = course?.trim();
    if (courseText != null && courseText.isNotEmpty) return courseText;

    final goalText = goal?.trim();
    if (goalText != null && goalText.isNotEmpty) return goalText;

    return _studentTypeLabel;
  }

  String? get secondaryLabel {
    final periodText = periodLabel?.trim();
    if (periodText != null && periodText.isNotEmpty) return periodText;

    return null;
  }

  String? get studentTypeLabel => _studentTypeLabel;

  String? get _studentTypeLabel {
    return switch (studentType) {
      'universitario' => 'Estudante universitário',
      'ensino_medio' => 'Estudante de ensino médio',
      'independente' => 'Estudante independente',
      _ => null,
    };
  }
}

class UserProfileInput {
  final String? course;
  final String? periodLabel;
  final String? studentType;
  final String? goal;
  final bool? onboardingCompleted;

  const UserProfileInput({
    this.course,
    this.periodLabel,
    this.studentType,
    this.goal,
    this.onboardingCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      if (course != null) 'course': course,
      if (periodLabel != null) 'periodLabel': periodLabel,
      if (studentType != null) 'studentType': studentType,
      if (goal != null) 'goal': goal,
      if (onboardingCompleted != null)
        'onboardingCompleted': onboardingCompleted,
    };
  }
}
