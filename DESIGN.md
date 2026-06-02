# DESIGN.md

## Product Source

Project name from `README.md` and `pubspec.yaml`: **academic_manager_app**.

The README currently contains the default Flutter starter copy: "A new Flutter project." The actual product direction is therefore taken from the application code, especially `lib/main.dart`, `lib/config/routes/app_routes.dart`, `lib/services/auth/auth_service.dart`, and the screens under `lib/view/pages`.

The app copy defines the product as a study organization experience:

> "Tudo que você precisa para uma boa organização dos seus estudos em um só lugar"

The interface is written primarily in Portuguese for Brazil and initializes date formatting with `pt_BR`.

## Native Product Shape

The app is organized around a student journey:

1. Enter the app through authentication.
2. Choose a student profile.
3. Configure studies based on that profile.
4. Use the main academic workspace: Início, Disciplinas, Tarefas, and Horário.
5. Inspect account/profile information and sign out.

This is not a catalog-first or document-first product. Its native shape is a **student academic dashboard** with four recurring study surfaces:

- Overview metrics and alerts
- Subjects
- Tasks
- Schedule/calendar

The main navigation labels are defined in `AppBottomNavBar`:

- `Início`
- `Disciplinas`
- `Tarefas`
- `Horário`

## Critical Files

### Application Entry

- `lib/main.dart`
  - Initializes Flutter bindings.
  - Initializes `pt_BR` date formatting.
  - Initializes Firebase using `DefaultFirebaseOptions.currentPlatform`.
  - Configures `MaterialApp`.
  - Sets `initialRoute` to `AppRoutes.authGate`.

### Routing

- `lib/config/routes/app_routes.dart`
  - Centralizes route names and route builders.
  - Provides helper methods for navigation and stack clearing.

Important route constants:

- `/auth`
- `/`
- `/login`
- `/register`
- `/student-profile`
- `/university-config`
- `/high-school-config`
- `/independent-config`
- `/home`
- `/subjects`
- `/tasks`
- `/schedule`
- `/profile`

### Authentication

- `lib/services/auth/auth_service.dart`
  - Wraps Firebase Authentication.
  - Supports email/password login.
  - Supports email/password registration.
  - Supports Google sign-in where available.
  - Supports password reset.
  - Supports sign out.
  - Maps Firebase auth errors into Portuguese user-facing messages.

Important user-facing auth messages include:

- `E-mail ou senha inválidos.`
- `Este e-mail já está cadastrado.`
- `Informe um e-mail válido.`
- `Sem conexão com a internet. Verifique sua rede e tente novamente.`
- `Login com Google não está disponível nesta plataforma.`
- `Não foi possível sair da conta. Tente novamente.`

### Auth Gate

- `lib/view/pages/auth_gate_page.dart`
  - Uses `StreamBuilder<User?>` over `authStateChanges`.
  - Shows a loading indicator while auth state is unknown.
  - Routes authenticated users to `MainShell`.
  - Routes unauthenticated users to `WelcomePage`.

### Main Shell

- `lib/view/shell/main_shell.dart`
  - Owns the current tab index.
  - Displays one of four pages:
    - `HomePage`
    - `SubjectsPage`
    - `TasksPage`
    - `SchedulePage`
  - Uses `AppBottomNavBar`.

## Current User Flows

### Welcome

File: `lib/view/pages/welcome_page.dart`

Primary copy:

- `Bem vindo`
- `Tudo que você precisa para uma boa organização dos seus estudos em um só lugar`

Actions:

- `Login`
- `Cadastrar`
- `Continuar com Google`

Google sign-in behavior:

- New users go to profile selection.
- Existing users go to home.

### Login

File: `lib/view/pages/login_page.dart`

Primary copy:

- `Bem vindo de volta`
- `E-mail`
- `Senha`
- `Esqueceu a senha?`
- `Entrar`
- `Ainda não possui um cadastro?`
- `Cadastrar`

Validation and feedback:

- Requires email.
- Requires valid email format.
- Requires password.
- Sends password reset email when possible.
- Shows feedback through `SnackBar`.

### Register

File: `lib/view/pages/register_page.dart`

Primary copy:

- `Vamos começar`
- `Nome`
- `E-mail`
- `Senha`
- `Confirme a senha`
- `Cadastrar`
- `Já possui uma conta?`
- `Login`

Validation:

- Requires name.
- Requires valid email.
- Requires password with at least 6 characters.
- Requires password confirmation to match.

After successful registration, the user is sent to student profile selection.

### Student Profile Selection

File: `lib/view/pages/filtering_page.dart`

Primary copy:

- `Qual o seu perfil de estudante?`
- `Personalize sua experiência selecionando o perfil que mais se encaixa com você`

Profile cards:

- `Estudante Universitário`
  - `Estudantes de Graduação, Pós ou Pesquisa`
- `Estudante de Ensino Médio`
  - `1º, 2º ou 3º ano`
- `Estudante Independente`
  - `Estudando para Vestibular, Concurso ou outros`

### Study Configuration

Files:

- `lib/view/pages/university_config_page.dart`
- `lib/view/pages/high_school_config_page.dart`
- `lib/view/pages/independent_config_page.dart`

Shared copy:

- `Configure seus estudos`
- `Personalize seu ambiente de estudos para começar`
- `DISCIPLINAS`
- `Salvar e continuar`

University-specific label:

- `NOME DO CURSO`

High-school-specific label:

- `SÉRIE`

Series options:

- `1º Ano`
- `2º Ano`
- `3º Ano`
- `4º Ano`

Independent-specific label:

- `OBJETIVO (EX: OAB, CONCURSO...)`

Current save behavior is simulated with `Future.delayed`. Academic configuration is not yet persisted.

### Home

File: `lib/view/pages/home_page.dart`

The home screen greets the user using the first name from Firebase `displayName`.

Primary labels:

- `Olá, {firstName}`
- `VISÃO GERAL`
- `CARD DE DESEMPENHO`
- `Média geral`
- `CARD DE FREQUÊNCIA`
- `Percentual total`
- `PRÓXIMAS TAREFAS`
- `ALERTAS`

Current visible sample values:

- Average: `8.5`
- Frequency: `92%`
- Tasks:
  - `Entrega de trabalho - Programação`
  - `Revisar matéria de BD`
  - `Revisar matéria de Cálculo 1`
- Alert:
  - `Prova de Cálculo`

These values are currently hardcoded in the UI.

### Subjects

File: `lib/view/pages/subjects_page.dart`

Primary labels:

- `Suas Disciplinas`
- `Pesquise por disciplina`
- `MINHAS DISCIPLINAS`

Current subject data is mock data:

- `Programação`
- `Cálculo I`
- `Cálculo II`

Each subject includes:

- `name`
- `teacher`
- `frequency`
- `average`
- `workload`

Subject cards show:

- Discipline name
- Teacher
- `Frequência`
- `Média atual`

### Subject Details

File: `lib/view/pages/subject_details_page.dart`

Primary labels:

- `Detalhes da disciplina`
- `Carga horária: {workload}h`
- `Média geral`
- `Avaliações`
- `Tarefas relacionadas`
- `Avaliações`
- `Tarefas`

This screen is structured for future entries under evaluations and related tasks.

### Tasks

File: `lib/view/pages/tasks_page.dart`

Primary labels:

- `Suas Tarefas`
- `LISTA DE TAREFAS`

Filter options:

- `Todas`
- `Pendentes`
- `Concluídas`

Task card terminology:

- `Disciplina: {subject}`
- `Prazo: {deadline}`

Current task data is mock data.

### Schedule

File: `lib/view/pages/schedule_page.dart`

The schedule surface is calendar-first and uses `table_calendar`.

Primary actions:

- `Adicionar Lembrete de atividade`
- `Ver grade de horários`

Current reminder value:

- `Entrega de atividade`

Current in-development messages:

- `Criação de lembrete em desenvolvimento.`
- `Grade de horários em desenvolvimento.`

The calendar:

- Uses locale `pt_BR`.
- Starts week on Sunday.
- Supports horizontal swipe.
- Renders one marker for days with reminders.
- Supports dates from 2020-01-01 to 2035-12-31.

### User Profile

File: `lib/view/pages/user_profile_page.dart`

Primary labels:

- `CONFIGURAÇÕES`
- `Dados pessoais`
- `Sair`

Profile values:

- Display name from Firebase, or `Usuário`
- Email from Firebase, or `E-mail não disponível`
- `Engenharia de software`
- `5° Periodo`

The course and period values are currently hardcoded.

## Visual Identity

The visual system is defined mostly in:

- `lib/config/theme/app_colors.dart`
- `lib/config/theme/app_text_styles.dart`
- `lib/config/theme/app_theme.dart`
- Reusable widgets under `lib/view/widgets`

### Colors

Core color values:

- Primary: `#514EB6`
- Background: `#F8F9FF`
- Text dark: `#191820`
- Text medium: `#444444`
- Text light: `#6B6B6B`
- Text muted: `#656565`
- Text on primary: `#E7E7E7`
- Nav active: `#514EB6`
- Nav inactive: `#656565`
- Auth field background: `#5F5CC4`
- Auth field border: `#FFFFFF`
- Default field border: `#514EB6`
- Default field background: `#F8F9FF`
- Divider: `#514EB6`
- Chip selected: `#514EB6`
- Chip unselected: `#F8F9FF`
- Chip border: `#514EB6`

Frequently used card surface:

- `#EFF0FB`

Frequently used shadow:

- `#66587DBD`
- `#4C514EB6`
- `#3F000000`

### Typography

The app theme sets `fontFamily` to `Inter`.

Type styles from `AppTextStyles`:

- `headline1`: 40px, weight 700
- `headline2`: 32px, weight 700
- `headline3`: 24px, weight 700
- `bodyBold`: 16px, weight 700, line height 1.38
- `bodyRegular`: 16px, weight 500, line height 1.38
- `button`: 24px, weight 500
- `sectionLabel`: 12px, weight 700, letter spacing 0.5
- `navLabel`: 12px, weight 500
- `fieldPlaceholder`: 16px, weight 400
- `cardTitle`: 24px, weight 700
- `cardSubtitle`: 14px, weight 400

Several existing styles use letter spacing `-1`. The bottom navigation overrides label letter spacing to `0`.

### Shape and Spacing Patterns

Observed component patterns:

- Primary and secondary buttons are 65px tall.
- Main rounded button radius is 35px.
- Auth form panels use a top radius of 45px.
- Profile cards use 18px radius.
- Academic cards often use 15px radius.
- Task checkbox container uses 10px radius.
- Bottom navigation selected state uses 18px radius.
- Horizontal page padding commonly appears as 24px or 37px.
- Cards commonly use `Offset(0, 4)` shadows.

### Components

Reusable widget groups:

- Buttons:
  - `PrimaryButton`
  - `SecondaryButton`
  - `CancelButton`
  - `BackImageButton`
  - `FloatingAddButton`
  - `AddDisciplineButton`
  - `DisciplineDeleteButton`
- Inputs:
  - `AuthTextField`
  - `ConfigTextField`
  - `SearchField`
  - `DisciplineSetupCard`
  - `DisciplineSetupList`
  - `VisibilityToggle`
- Cards:
  - `SubjectCard`
  - `TaskCard`
  - `ProfileCard`
- Common:
  - `AppLogo`
  - `AppBottomNavBar`
  - `PageHeader`
  - `SectionLabel`
  - `OrDivider`
- Selectors:
  - `TaskFilterChip`
  - `SeriesSelector`
  - `WeekdaySelector`

## Data and Persistence

Authentication data is real and comes from Firebase Authentication.

Academic data is currently local or hardcoded in widgets:

- Subjects are defined in `SubjectsPage`.
- Tasks are defined in `TasksPage`.
- Home metrics, alerts, and upcoming tasks are hardcoded in `HomePage`.
- Schedule reminders are defined in `SchedulePage`.
- User academic profile labels in `UserProfilePage` are hardcoded.
- Study configuration screens simulate saving with `Future.delayed`.

No repository layer, domain models, or Firestore persistence layer currently exists in `lib/`.

## Current Goals Implied by the Code

The existing code points to these concrete product goals:

1. Let users authenticate with email/password or Google.
2. Route users based on authentication state.
3. Ask new users to select a student profile.
4. Collect study configuration according to that profile.
5. Provide a main dashboard for academic overview.
6. Provide dedicated areas for disciplines, tasks, and schedule.
7. Keep the UI consistent through shared colors, text styles, buttons, cards, and navigation.

## Known Incomplete Areas

These are visible in code as mock data, TODO comments, hardcoded values, or in-development messages:

- Add discipline action in `SubjectsPage`.
- Add task action in `TasksPage`.
- Personal data editing in `UserProfilePage`.
- Reminder creation in `SchedulePage`.
- Schedule grid in `SchedulePage`.
- Firebase persistence for academic data.
- Real profile/course/period values after onboarding.
- Real evaluations and related tasks in subject details.

## Design Direction for Future Work

Future changes should preserve the existing product language and visual system:

- Keep Portuguese UI terminology already used in the app.
- Keep the four-part main navigation: `Início`, `Disciplinas`, `Tarefas`, `Horário`.
- Keep `#514EB6` as the primary action and active navigation color.
- Use `#F8F9FF` as the main background.
- Use `#EFF0FB` for academic cards where the current UI already does.
- Reuse existing shared widgets before creating new visual patterns.
- Treat Firebase Auth as the current source of identity.
- Add persistence behind the existing screens without changing their visible terminology unless the codebase changes first.

