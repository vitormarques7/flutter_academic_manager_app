# Firestore schema

Este app organiza dados privados em documentos e subcolecoes por usuario.

## Caminhos

```txt
users/{uid}
users/{uid}/tasks/{taskId}
users/{uid}/studyCycles/{cycleId}
users/{uid}/disciplines/{disciplineId}
users/{uid}/schedules/{scheduleId}
users/{uid}/assessments/{assessmentId}
users/{uid}/subjectNotes/{noteId}
users/{uid}/subjectEvents/{eventId}
users/{uid}/studySessions/{sessionId}
users/{uid}/studyTopics/{topicId}
```

O `{uid}` e o `uid` do Firebase Auth. O documento raiz `users/{uid}` e criado
automaticamente no login/cadastro/bootstrap do usuario para evitar ancestrais
inexistentes no console do Firestore.

## Convencoes gerais

- O dono do dado e definido pelo path `users/{uid}`.
- Documentos academicos nao precisam de campo `userId`.
- `studyCycleId` liga uma entidade ao ciclo academico.
- `disciplineId` liga uma entidade a uma disciplina especifica.
- `createdAt` e `updatedAt` usam `FieldValue.serverTimestamp()`.
- Alguns modelos aceitam campos ausentes para manter compatibilidade com dados
  antigos.

## users

Caminho:

```txt
users/{uid}
```

Campos atuais:

```txt
displayName: string | ausente
email: string | ausente
activeStudyCycleId: string | ausente
createdAt: timestamp
updatedAt: timestamp
```

Observacoes:

- `activeStudyCycleId` aponta para o ciclo academico atualmente ativo em
  `users/{uid}/studyCycles/{cycleId}`.
- Se um usuario antigo ainda nao tiver `activeStudyCycleId`, o bootstrap tenta
  inferir o ciclo mais recente e grava esse campo.
- Esse documento tambem ajuda o console do Firestore a exibir as subcolecoes do
  usuario de forma previsivel.

## tasks

Caminho:

```txt
users/{uid}/tasks/{taskId}
```

Campos atuais:

```txt
studyCycleId: string | ausente
disciplineId: string | ausente
title: string
subject: string
deadline: string
visualPriority: string
description: string
isChecked: boolean
createdAt: timestamp
updatedAt: timestamp
```

Observacoes:

- `title` e obrigatorio na UI.
- `disciplineId` vem da disciplina selecionada quando disponivel.
- `subject` guarda o nome da disciplina para exibicao e compatibilidade.
- O dropdown do `TaskDialog` e alimentado por `DisciplineRepository`.
- `deadline` usa `dd/mm/yyyy` quando informado, ou string vazia quando sem
  prazo.
- `visualPriority` aceita atualmente `Trabalho`, `Prova`, `Estudo`, `Seminário`, `Leitura` ou `Pesquisa`.
- `description` e opcional na UI e pode ser string vazia.
- `isChecked` nasce como `false` em `TaskInput.toCreateMap`.
- `studyCycleId` e preenchido automaticamente pelo `TaskRepository` quando ha
  ciclo ativo.
- Documentos antigos sem `studyCycleId` continuam validos; o bootstrap tenta
  preencher esse campo quando encontra um ciclo ativo.

Exemplo:

```json
{
  "studyCycleId": "cycle-id",
  "disciplineId": "discipline-id",
  "title": "Seminario de Java",
  "subject": "Programacao",
  "deadline": "26/06/2026",
  "visualPriority": "Trabalho",
  "description": "Apresentar arquitetura do projeto.",
  "isChecked": false,
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp"
}
```

## studyCycles

Caminho:

```txt
users/{uid}/studyCycles/{cycleId}
```

Campos atuais:

```txt
type: string
courseName: string | null
period: number | null
schoolYear: number | null
goal: string | null
createdAt: timestamp
updatedAt: timestamp
```

Valores de `type`:

```txt
university
highSchool
independent
```

Observacoes:

- `courseName` e usado por ciclos universitarios.
- `period` e usado por ciclos universitarios.
- `schoolYear` e usado por ciclos de ensino medio.
- `goal` e usado por ciclos independentes.
- `StudyCycleRepository.compareByMostRecent` ordena por `updatedAt` ou
  `createdAt`.

## disciplines

Caminho:

```txt
users/{uid}/disciplines/{disciplineId}
```

Campos atuais:

```txt
name: string
teacher: string
workload: number
colorValue: number
studyCycleId: string
createdAt: timestamp
updatedAt: timestamp
```

Observacoes:

- Disciplinas criadas no setup inicial recebem o `studyCycleId` do ciclo criado
  naquele mesmo fluxo.
- Disciplinas criadas na `SubjectsPage` usam o ciclo ativo.
- `colorValue` e usado na agenda e nos cards.
- `DisciplineRepository.watchDisciplines` e `fetchDisciplines` aceitam filtro
  por `studyCycleId`.
- `deleteDisciplineWithSchedules` remove tambem horarios vinculados.

## schedules

Caminho:

```txt
users/{uid}/schedules/{scheduleId}
```

Campos atuais:

```txt
studyCycleId: string | ausente
disciplineId: string | ausente
disciplineName: string
weekdays: number[]
startTimeMinutes: number
endTimeMinutes: number
colorValue: number
createdAt: timestamp
updatedAt: timestamp
```

Observacoes:

- `weekdays` segue o padrao do app: `0` domingo, `1` segunda, ..., `6` sabado.
- Horarios sao persistidos como minutos desde `00:00`.
- Um documento de horario pode representar multiplos dias da semana.
- `disciplineId` liga o horario a uma disciplina quando disponivel.
- `disciplineName` e mantido para exibicao e compatibilidade.
- `studyCycleId` e salvo nos horarios criados pelo setup inicial e pode ser
  usado para filtrar horarios do ciclo academico ativo.
- Documentos antigos sem `studyCycleId` continuam validos; o bootstrap tenta
  preencher esse campo quando encontra um ciclo ativo.
- A tela de agenda usa `ScheduleRepository.watchSchedules` para observar os
  horarios do ciclo academico ativo.

Exemplo:

```json
{
  "studyCycleId": "cycle-id",
  "disciplineId": "discipline-id",
  "disciplineName": "Programacao",
  "weekdays": [1, 3],
  "startTimeMinutes": 480,
  "endTimeMinutes": 600,
  "colorValue": 4283518646,
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp"
}
```

## assessments

Caminho:

```txt
users/{uid}/assessments/{assessmentId}
```

Campos atuais:

```txt
studyCycleId: string | ausente
disciplineId: string | ausente
disciplineName: string
title: string
dateLabel: string
grade: number
createdAt: timestamp
updatedAt: timestamp
```

Observacoes:

- `grade` e normalizada pelo model para o intervalo de 0 a 10.
- `dateLabel` usa `dd/mm/yyyy` quando informado.
- A Home usa todas as avaliacoes do ciclo ativo para calcular media geral.
- A tela de disciplinas usa avaliacoes para calcular medias por disciplina.
- A tela de detalhes de disciplina permite criar e excluir avaliacoes.

Exemplo:

```json
{
  "studyCycleId": "cycle-id",
  "disciplineId": "discipline-id",
  "disciplineName": "Banco de Dados",
  "title": "Prova 1",
  "dateLabel": "10/06/2026",
  "grade": 8.5,
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp"
}
```

## subjectNotes

Caminho:

```txt
users/{uid}/subjectNotes/{noteId}
```

Campos atuais:

```txt
studyCycleId: string | ausente
disciplineId: string | ausente
disciplineName: string
title: string
content: string
createdAt: timestamp
updatedAt: timestamp
```

Observacoes:

- Anotacoes aparecem nos detalhes da disciplina.
- O fluxo atual permite criar e excluir anotacoes.

## subjectEvents

Caminho:

```txt
users/{uid}/subjectEvents/{eventId}
```

Campos atuais:

```txt
studyCycleId: string | ausente
disciplineId: string | ausente
disciplineName: string
title: string
type: string
eventDate: timestamp
startTimeMinutes: number | ausente
endTimeMinutes: number | ausente
topicIds: string[]
description: string
createdAt: timestamp
updatedAt: timestamp
```

Valores atuais de `type`:

```txt
Prova
Revisão
Palestra
Seminário
Entrega
Aula extra
Outro
```

Observacoes:

- `eventDate` e salvo como timestamp, normalizado para data sem horario.
- `startTimeMinutes` e `endTimeMinutes` sao opcionais.
- `topicIds` liga revisoes a assuntos quando informado.
- `description` pode ser string vazia.
- A agenda usa eventos futuros para marcar e listar compromissos.
- A Home usa eventos proximos para alertas e resumo.
- Detalhes de disciplina permitem criar e excluir eventos daquela disciplina.

## studySessions

Caminho:

```txt
users/{uid}/studySessions/{sessionId}
```

Campos atuais:

```txt
studyCycleId: string | ausente
disciplineId: string | ausente
disciplineName: string
studiedAt: timestamp
durationMinutes: number
topicIds: string[]
notes: string
createdAt: timestamp
updatedAt: timestamp
```

Observacoes:

- Usado principalmente por ciclos independentes.
- `studiedAt` e normalizado para data sem horario.
- `durationMinutes` representa o tempo estudado naquela sessao.
- Totais de horas sao calculados a partir das sessoes.
- `topicIds` pode registrar quais assuntos foram trabalhados na sessao.

## studyTopics

Caminho:

```txt
users/{uid}/studyTopics/{topicId}
```

Campos atuais:

```txt
studyCycleId: string | ausente
disciplineId: string | ausente
disciplineName: string
title: string
status: string
position: number
seenAt: timestamp | ausente
createdAt: timestamp
updatedAt: timestamp
```

Valores atuais de `status`:

```txt
todo
seen
```

Observacoes:

- Usado principalmente por ciclos independentes.
- `todo` representa assunto a ver.
- `seen` representa assunto visto.
- `position` mantem a ordem simples do checklist por disciplina.
- `seenAt` e preenchido quando o assunto e marcado como visto.

## Regras

As regras versionadas em `firestore.rules` permitem acesso apenas quando
`request.auth.uid` e igual ao `{uid}` do path.

As regras atuais cobrem explicitamente:

```txt
users/{uid}
users/{uid}/tasks/{taskId}
users/{uid}/schedules/{scheduleId}
users/{uid}/studyCycles/{cycleId}
users/{uid}/disciplines/{disciplineId}
users/{uid}/assessments/{assessmentId}
users/{uid}/subjectNotes/{noteId}
users/{uid}/subjectEvents/{eventId}
users/{uid}/studySessions/{sessionId}
users/{uid}/studyTopics/{topicId}
```

Quando os schemas amadurecerem, uma melhoria possivel e validar tipos e campos
obrigatorios nas regras.
