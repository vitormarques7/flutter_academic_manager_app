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
/profile                  UserProfilePage
```

## Fluxo de entrada

```txt
AuthGatePage
  usuario logado -> MainShell
  usuario deslogado -> WelcomePage
```

## Fluxo de cadastro

```txt
WelcomePage
  -> RegisterPage
  -> StudentFilteringPage
  -> UniversityConfigPage | HighSchoolConfigPage | IndependentConfigPage
  -> MainShell
```

## Fluxo de login

```txt
WelcomePage
  -> LoginPage
  -> MainShell
```

## Configuracao de estudante

### Universitario

Campos:

- Nome do curso.
- Periodo do curso, com dropdown de 1o a 12o periodo e "Prefiro nao informar".
- Disciplinas.

### Ensino medio

Campos:

- Serie.
- Disciplinas.

### Independente

Campos:

- Objetivo.
- Disciplinas.

As telas de configuracao possuem rolagem unica: cabecalho, campos, disciplinas
e botoes rolam juntos.

## Fluxo de tarefas

```txt
TasksPage
  FloatingAddButton -> TaskDialog em modo criacao
  tocar em TaskCard -> TaskDialog em modo edicao
```

Criacao:

```txt
TaskDialog valida campos
  -> TaskRepository.createTask
  -> Firestore users/{uid}/tasks/{taskId}
```

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

## Fluxo de disciplinas

```txt
SubjectsPage
  FloatingAddButton -> SubjectDialog
```

O modal permite preencher:

- Nome.
- Professor.
- Carga horaria.
- Dias da semana.
- Horarios.

Estado atual: disciplinas sao mantidas em memoria local na `SubjectsPage`.
Elas ainda nao persistem no Firestore.

## Fluxo de agenda

`SchedulePage` mostra calendario e botoes futuros.

Estado atual:

- Lembretes estao mockados.
- Grade de horarios ainda nao foi implementada.
