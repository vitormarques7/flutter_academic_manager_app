# Camada de dados e servicos

Este documento explica onde o CRUD acontece e qual e o papel de models,
repositories e services.

## Resumo rapido

```txt
Model
  define a estrutura em Dart e sabe converter Firestore <-> objeto

Input
  representa dados de formulario e gera maps para create/update

Repository
  executa CRUD no Firestore, sempre dentro de users/{uid}

Service
  coordena fluxos maiores, autenticacao ou varias escritas relacionadas
```

## Firestore como backend

O app nao possui backend proprio. O cliente Flutter usa Firebase diretamente:

- Firebase Auth identifica o usuario e fornece `uid`.
- Cloud Firestore guarda os dados privados.
- Regras em `firestore.rules` impedem acesso a dados de outro usuario.
- Streams do Firestore alimentam UI em tempo real com `StreamBuilder`.

Todos os dados academicos ficam abaixo de:

```txt
users/{uid}
```

O `uid` vem de `FirebaseAuth.currentUser`.

## Responsabilidade dos models

Models representam dados ja carregados ou prontos para exibicao:

- guardam campos tipados;
- leem `DocumentSnapshot<Map<String, dynamic>>`;
- aplicam defaults seguros para campos ausentes;
- convertem `Timestamp` para `DateTime`;
- oferecem helpers de exibicao, ordenacao ou normalizacao simples.

Inputs representam dados vindos de formularios:

- geram `toCreateMap`;
- geram `toUpdateMap`;
- adicionam `createdAt` apenas na criacao;
- atualizam `updatedAt` em criacao/edicao;
- usam `FieldValue.serverTimestamp()` para timestamps de servidor.

Exemplo de padrao:

```txt
AcademicTask.fromFirestore(document, uid)
TaskInput.toCreateMap()
TaskInput.toUpdateMap()
```

## Responsabilidade dos repositories

Repositories sao a fronteira de persistencia. Eles devem ser o unico lugar onde
a aplicacao fala com `FirebaseFirestore`.

Responsabilidades comuns:

- obter o usuario atual;
- lancar excecao amigavel quando nao ha usuario autenticado;
- montar a colecao privada correta;
- executar consultas pontuais ou streams;
- converter documentos para models;
- aplicar filtros por `studyCycleId` e/ou `disciplineId`;
- ordenar resultados para a UI;
- encapsular `FirebaseException` em excecoes especificas.

## Mapa dos repositories

| Repository | Colecao | Leitura | Escrita |
| --- | --- | --- | --- |
| `UserProfileRepository` | `users/{uid}` | `watchCurrentUserProfile`, `fetchCurrentUserProfile`, `resolveActiveStudyCycleId` | `ensureCurrentUserDocument`, `setActiveStudyCycleId`, `updateCurrentUserProfile` |
| `StudyCycleRepository` | `users/{uid}/studyCycles` | `watchStudyCycles`, `fetchStudyCycles` | `createStudyCycle`, `updateStudyCycle`, `renameUniversityCourse`, `deleteStudyCycle` |
| `DisciplineRepository` | `users/{uid}/disciplines` | `watchDisciplines`, `fetchDisciplines` | `createDiscipline`, `updateDiscipline`, `deleteDiscipline`, `deleteDisciplineWithSchedules` |
| `ScheduleRepository` | `users/{uid}/schedules` | `watchSchedules`, `fetchSchedules` | `createSchedule`, `updateSchedule`, `deleteSchedule`, `backfillStudyCycleId` |
| `TaskRepository` | `users/{uid}/tasks` | `watchTasks` | `createTask`, `updateTask`, `updateCompletion`, `deleteTask`, `backfillStudyCycleId` |
| `AssessmentRepository` | `users/{uid}/assessments` | `watchAssessments` | `createAssessment`, `deleteAssessment` |
| `SubjectNoteRepository` | `users/{uid}/subjectNotes` | `watchNotes` | `createNote`, `deleteNote` |
| `SubjectEventRepository` | `users/{uid}/subjectEvents` | `watchEvents` | `createEvent`, `deleteEvent` |

## Responsabilidade dos services

Services existem quando o fluxo passa de um CRUD simples.

### AuthService

Responsavel por:

- `authStateChanges`;
- usuario atual;
- login com e-mail/senha;
- cadastro com e-mail/senha;
- login com Google;
- recuperacao de senha;
- logout;
- atualizacao de nome no Firebase Auth e em `users/{uid}`;
- criacao/atualizacao do documento raiz do usuario apos login/cadastro.

### UserDataBootstrapService

Roda quando um usuario autenticado entra pelo `AuthGatePage`.

Responsavel por:

- garantir `users/{uid}`;
- resolver `activeStudyCycleId`;
- inferir o ciclo ativo mais recente se o documento antigo ainda nao tiver esse
  campo;
- preencher `studyCycleId` em tarefas e horarios antigos quando possivel.

### AcademicSetupService

Usado pelas telas de configuracao inicial e criacao de novos ciclos.

Responsavel por:

- criar `studyCycles/{cycleId}`;
- gravar esse ciclo como `activeStudyCycleId`;
- criar disciplinas;
- criar horarios vinculados as disciplinas.

## Fluxos de exemplo

### Criar tarefa

```txt
TasksPage
  -> TaskDialog
  -> TaskInput
  -> TaskRepository.createTask
     -> resolve ciclo ativo, se necessario
     -> users/{uid}/tasks.add(...)
  -> StreamBuilder recebe nova lista via watchTasks
```

### Criar disciplina com horarios

```txt
SubjectsPage
  -> SubjectDialog
  -> DisciplineRepository.createDiscipline
  -> ScheduleRepository.createSchedule para cada grupo de horario
  -> streams de disciplinas/agenda atualizam a UI
```

### Setup academico inicial

```txt
UniversityConfigPage | HighSchoolConfigPage | IndependentConfigPage
  -> AcademicSetupService.saveSetup
     -> StudyCycleRepository.createStudyCycle
     -> UserProfileRepository.setActiveStudyCycleId
     -> DisciplineRepository.createDiscipline
     -> ScheduleRepository.createSchedule
  -> MainShell
```

## Convencoes importantes

- O dono do dado e definido pelo path `users/{uid}`, nao por campo `userId`.
- `studyCycleId` separa dados entre ciclos academicos do mesmo usuario.
- `disciplineId` e usado quando a entidade pertence a uma disciplina
  especifica.
- Alguns dados antigos sem `studyCycleId` ainda sao aceitos para manter
  compatibilidade; bootstrap e repositories tentam normalizar isso.
- O app usa ordenacao local em alguns repositories para evitar depender de
  indices compostos antes de eles serem necessarios.

## Cuidados ao evoluir

- Ao criar nova colecao, atualize `firestore.rules` e `docs/firestore_schema.md`.
- Ao adicionar campos obrigatorios, atualize o model, o input e os testes.
- Evite fazer regras de negocio pesadas dentro de widgets.
- Se uma operacao precisar escrever em varias colecoes, prefira um service.
- Se a operacao precisar ser atomica, considere batch ou transaction no
  repository/service apropriado.
