# Firestore schema

Este app organiza dados privados em documentos e subcolecoes por usuario.

## Caminhos

```txt
users/{uid}
users/{uid}/tasks/{taskId}
users/{uid}/studyCycles/{cycleId}
users/{uid}/disciplines/{disciplineId}
users/{uid}/schedules/{scheduleId}
```

O `{uid}` e o `uid` do Firebase Auth. O documento raiz `users/{uid}` agora
e criado automaticamente no login/cadastro/bootstrap do usuario para evitar
ancestrais inexistentes no console do Firestore.

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

Campos minimos:

```txt
title: string
subject: string
deadline: string
visualPriority: string
isChecked: boolean
studyCycleId: string | ausente
createdAt: timestamp
updatedAt: timestamp
```

Observacoes:

- `title` e obrigatorio na UI.
- `subject` e obrigatorio na UI, mas a lista de disciplinas ainda e fixa no
  `TaskDialog`.
- `deadline` usa `dd/mm/yyyy` quando informado, ou string vazia quando sem prazo.
- `visualPriority` aceita atualmente `Trabalho` ou `Prova`.
- `isChecked` nasce como `false` em `TaskInput.toCreateMap`.
- O dono da tarefa e definido pelo path `users/{uid}`, nao por um campo `userId`.
- `studyCycleId` e preenchido automaticamente pelo `TaskRepository` quando ha
  ciclo ativo.
- Documentos antigos sem `studyCycleId` continuam validos; o bootstrap tenta
  preencher esse campo quando encontra um ciclo ativo.

Exemplo:

```json
{
  "title": "Seminario de Java",
  "subject": "Programacao",
  "deadline": "26/06/2026",
  "visualPriority": "Trabalho",
  "isChecked": false,
  "studyCycleId": "cycle-id",
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
- `DisciplineRepository.watchDisciplines` e `fetchDisciplines` aceitam filtro
  por `studyCycleId`.

## schedules

Caminho:

```txt
users/{uid}/schedules/{scheduleId}
```

Campos atuais:

```txt
studyCycleId: string | ausente
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
- `studyCycleId` e salvo nos horarios criados pelo setup inicial e pode ser
  usado para filtrar horarios do ciclo academico ativo.
- Documentos antigos sem `studyCycleId` continuam validos; o bootstrap tenta
  preencher esse campo quando encontra um ciclo ativo.
- A tela de agenda ainda precisa ser integrada ao `ScheduleRepository` para
  abandonar os dados mockados.

Exemplo:

```json
{
  "studyCycleId": "cycle-id",
  "disciplineName": "Programacao",
  "weekdays": [1, 3],
  "startTimeMinutes": 480,
  "endTimeMinutes": 600,
  "colorValue": 4283518646,
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp"
}
```

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
```

Quando os schemas amadurecerem, uma melhoria possivel e validar tipos e campos
obrigatorios nas regras.
