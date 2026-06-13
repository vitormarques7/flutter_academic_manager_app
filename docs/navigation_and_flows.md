# Navegacao e fluxos

## Rotas

As rotas ficam em `lib/config/routes/app_routes.dart`.

```txt
/                         WelcomePage
/auth                     AuthGatePage
/login                    LoginPage
/register                 RegisterPage
/student-profile          StudentFilteringPage
/university-config        UniversityConfigPage
/high-school-config       HighSchoolConfigPage
/independent-config       IndependentConfigPage
/home                     MainShell
/subjects                 MainShell(initialIndex: 1)
/tasks                    MainShell(initialIndex: 2)
/schedule                 MainShell(initialIndex: 3)
/study-cycle-setup        StudyCycleSetupPage
/profile                  UserProfilePage
/personal-data            PersonalDataPage
```

## Fluxo de entrada

```txt
AuthGatePage
  usuario deslogado -> WelcomePage
  usuario logado
    -> UserDataBootstrapService.ensureCurrentUserData
    -> sem ciclo ativo: StudentFilteringPage
    -> com ciclo ativo: MainShell
```

## Fluxo de cadastro

```txt
WelcomePage
  -> RegisterPage
  -> Firebase Auth cria usuario
  -> users/{uid} e criado/atualizado
  -> StudentFilteringPage
  -> UniversityConfigPage | HighSchoolConfigPage | IndependentConfigPage
  -> AcademicSetupService.saveSetup
  -> MainShell
```

## Fluxo de login

```txt
WelcomePage
  -> LoginPage
  -> Firebase Auth autentica usuario
  -> users/{uid} e criado/atualizado se necessario
  -> MainShell
```

O `AuthGatePage` tambem cobre retomada de sessao quando o app abre com usuario
ja autenticado.

## Configuracao de estudante

### Universitario

Campos:

- Nome do curso.
- Periodo do curso, com dropdown de 1o a 12o periodo e "Prefiro nao informar".
- Disciplinas.
- Horarios das disciplinas.

### Ensino medio

Campos:

- Serie.
- Disciplinas.
- Horarios das disciplinas.

### Independente

Campos:

- Objetivo.
- Disciplinas.
- Horarios das disciplinas.

As telas de configuracao possuem rolagem unica: cabecalho, campos, disciplinas
e botoes rolam juntos.

Ao salvar, o app cria o ciclo academico, disciplinas e horarios no Firestore,
atualiza `users/{uid}.activeStudyCycleId` e so entao segue para a home.

Persistencia:

```txt
AcademicSetupService
  -> StudyCycleRepository.createStudyCycle
  -> UserProfileRepository.setActiveStudyCycleId
  -> DisciplineRepository.createDiscipline
  -> ScheduleRepository.createSchedule
```

## Fluxo de Home

```txt
HomePage
  -> UserProfileRepository.resolveActiveStudyCycleId
  -> StreamBuilder de tarefas, horarios, eventos e avaliacoes
  -> cards e alertas derivados dos dados reais
```

Se nao existir ciclo ativo, a Home exibe um painel para iniciar a configuracao.
O menu de ciclo permite ativar outro ciclo ou abrir `StudyCycleSetupPage` para
criar um novo.

## Fluxo de tarefas

```txt
TasksPage
  -> resolve ciclo ativo
  -> observa disciplinas reais do ciclo
  -> observa tarefas do ciclo
  FloatingAddButton -> TaskDialog em modo criacao
  tocar em TaskCard -> TaskDialog em modo edicao
```

A tela usa `StreamBuilder` com `TaskRepository.watchTasks()` e recalcula os
indicadores a partir da lista em tempo real:

- Total de tarefas.
- Pendentes.
- Concluidas.
- Tarefas para hoje.
- Tarefas atrasadas.
- Tarefas sem prazo.

Criacao:

```txt
TaskDialog valida campos
  -> TaskRepository.createTask
  -> Firestore users/{uid}/tasks/{taskId}
```

Quando existe ciclo academico ativo, `TaskRepository` inclui `studyCycleId` no
documento criado. Quando a disciplina foi escolhida de uma lista real, tambem
inclui `disciplineId`.

Edicao:

```txt
TaskDialog preenchido com dados existentes
  -> TaskRepository.updateTask
```

Conclusao:

```txt
Checkbox do TaskCard
  -> TaskRepository.updateCompletion
```

Exclusao:

```txt
TaskDialog em modo edicao
  -> botao "Excluir tarefa"
  -> confirmacao
  -> TaskRepository.deleteTask
```

## Fluxo de disciplinas

```txt
SubjectsPage
  -> resolve ciclo ativo
  -> DisciplineRepository.watchDisciplines
  -> AssessmentRepository.watchAssessments
  FloatingAddButton -> SubjectDialog
```

O modal permite preencher:

- Nome.
- Professor.
- Carga horaria.
- Dias da semana.
- Horarios.

Ao salvar, a tela cria a disciplina em `users/{uid}/disciplines` e cria
documentos de horario em `users/{uid}/schedules` quando o usuario informa dias
e horarios.

Exclusao:

```txt
SubjectsPage
  -> sheet de selecao de disciplina
  -> confirmacao
  -> DisciplineRepository.deleteDisciplineWithSchedules
```

## Fluxo de detalhes de disciplina

```txt
SubjectDetailsPage
  -> AssessmentRepository.watchAssessments(disciplineId)
  -> TaskRepository.watchTasks(studyCycleId)
  -> SubjectEventRepository.watchEvents(disciplineId)
  -> SubjectNoteRepository.watchNotes(disciplineId)
```

A tela permite:

- Criar e excluir notas.
- Criar e excluir eventos.
- Criar e excluir anotacoes.
- Ver tarefas relacionadas a disciplina.
- Navegar para detalhes de evento ou anotacao.

## Fluxo de agenda

`SchedulePage` mostra calendario mensal, aulas do dia selecionado, eventos do
dia e um card de grade de horario.

Estado atual:

- As aulas do calendario vem de `ScheduleRepository.watchSchedules`.
- Eventos vem de `SubjectEventRepository.watchEvents`.
- Disciplinas vem de `DisciplineRepository.watchDisciplines`.
- O calendario inicia no dia atual e usa `pt_BR`.
- Marcadores sao derivados dos dias recorrentes de cada horario e de eventos.
- O card "Grade de Horario" alterna para uma visualizacao semanal com os
  horarios reais cadastrados.
- A acao de editar grade abre `ScheduleEditorSheet`, que cria, atualiza e
  exclui horarios.
- O botao `+` abre `ScheduleEventDialog` para criar evento academico.

## Fluxo de perfil

```txt
PageHeader/avatar ou rota /profile
  -> UserProfilePage
```

Estado atual:

- Nome e e-mail vem do usuario autenticado.
- Dados academicos sao carregados a partir do ciclo ativo:
  - universitario mostra curso e periodo;
  - ensino medio mostra ano letivo;
  - independente mostra meta.
- "Dados pessoais" abre `PersonalDataPage`.
- "Sair" chama `AuthService.signOut` e limpa a pilha para a welcome.

## Fluxo de dados pessoais

```txt
PersonalDataPage
  -> AuthService.currentUser
  -> UserProfileRepository.fetchCurrentUserProfile
  -> UserProfileRepository.resolveActiveStudyCycleId
  -> StudyCycleRepository.fetchStudyCycles
  -> DisciplineRepository.fetchDisciplines
```

A tela permite:

- Conferir nome e e-mail.
- Atualizar nome via `AuthService.updateDisplayName`.
- Conferir ciclo ativo e disciplinas do ciclo.
- Editar dados do ciclo ativo via `StudyCycleRepository.updateStudyCycle`.
- Ativar outro ciclo via `UserProfileRepository.setActiveStudyCycleId`.
