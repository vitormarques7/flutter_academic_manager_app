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

## Fluxo de tarefas

```txt
TasksPage
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
documento criado.

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
  FloatingAddButton -> SubjectDialog
```

O modal permite preencher:

- Nome.
- Professor.
- Carga horaria.
- Dias da semana.
- Horarios.

Estado atual: disciplinas criadas diretamente na `SubjectsPage` sao salvas em
`users/{uid}/disciplines`. Quando o usuario informa dias e horarios, a tela
tambem cria documentos em `users/{uid}/schedules`.

## Fluxo de agenda

`SchedulePage` mostra calendario mensal, aulas do dia selecionado e um card de
grade de horario.

Estado atual:

- As aulas do calendario vem de `ScheduleRepository.watchSchedules`.
- O calendario inicia no dia atual e usa `pt_BR`.
- Marcadores sao derivados dos dias recorrentes de cada horario.
- O card "Grade de Horario" alterna para uma visualizacao semanal com os
  horarios reais cadastrados.
- O botao `+` abre o modal real de horario e salva em `users/{uid}/schedules`.
- A acao de editar grade mostra mensagem de "em desenvolvimento".

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
- "Dados pessoais" ainda nao abre edicao.
- "Sair" chama `AuthService.signOut` e limpa a pilha para a welcome.
