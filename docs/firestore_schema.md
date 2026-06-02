# Firestore schema

Este app organiza dados privados em subcolecoes por usuario.

## Caminhos

```txt
users/{uid}
users/{uid}/tasks/{taskId}
users/{uid}/schedules/{scheduleId}
```

O `{uid}` e o `uid` do Firebase Auth.

## users

Documento reservado para dados gerais do usuario.

Estado atual: o app ainda nao grava perfil academico em `users/{uid}`.

Campos futuros provaveis:

```txt
displayName: string
studentProfile: string
courseName: string
coursePeriod: number | null
goal: string
createdAt: timestamp
updatedAt: timestamp
```

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
createdAt: timestamp
updatedAt: timestamp
```

Observacoes:

- `title` e obrigatorio na UI.
- `deadline` usa `dd/mm/yyyy` quando informado, ou string vazia quando sem prazo.
- `deadline` deve ser hoje ou uma data futura.
- `visualPriority` aceita atualmente `Trabalho` ou `Prova`.
- O dono da tarefa e definido pelo path `users/{uid}`, nao por um campo `userId`.

Exemplo:

```json
{
  "title": "Seminario de Java",
  "subject": "Programacao",
  "deadline": "26/06/2026",
  "visualPriority": "Trabalho",
  "isChecked": false,
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp"
}
```

## schedules

Caminho:

```txt
users/{uid}/schedules/{scheduleId}
```

Campos minimos:

```txt
subjectId: string
subjectName: string
weekdayIndex: number
startTime: string
endTime: string
createdAt: timestamp
updatedAt: timestamp
```

Observacoes:

- `weekdayIndex` segue o padrao do app: `0` domingo, `1` segunda, ..., `6` sabado.
- `startTime` e `endTime` usam `HH:mm`.
- Uma disciplina com varios dias/horarios pode gerar varios documentos em `schedules`.
- O modal de disciplina ja coleta dias e horarios localmente, mas ainda nao persiste no Firestore.

Exemplo:

```json
{
  "subjectId": "subject-id",
  "subjectName": "Programacao",
  "weekdayIndex": 1,
  "startTime": "08:00",
  "endTime": "10:00",
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp"
}
```

## Regras

As regras versionadas em `firestore.rules` permitem acesso apenas quando
`request.auth.uid` e igual ao `{uid}` do path.
