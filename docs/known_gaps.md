# Lacunas conhecidas e proximos passos

Este arquivo registra pontos ainda incompletos para evitar confundir mock,
prototipo e fluxo real.

## Dados ainda mockados ou locais

### Home

- Card de desempenho e frequencia sao mockados.
- Proximas tarefas sao mockadas.
- Alertas sao mockados.

### Disciplinas

- A lista de disciplinas da `SubjectsPage` e local/mockada.
- O modal cria disciplina em memoria, sem Firestore.
- Dias e horarios da disciplina sao coletados localmente, mas ainda nao
  alimentam a agenda.

### Dropdown de disciplinas em tarefas

- O dropdown de disciplinas do `TaskDialog` usa lista fixa:
  - Programacao
  - Calculo I
  - Banco de Dados
  - Inteligencia Artificial

Proximo passo recomendado: criar `SubjectRepository` e alimentar o dropdown com
disciplinas reais do usuario.

### Agenda

- Lembretes de atividade sao mockados.
- Grade de horarios ainda nao existe.
- Botoes da agenda exibem mensagens de "em desenvolvimento".

## Persistencia pendente

Criar repositories futuros:

```txt
SubjectRepository
ScheduleRepository
UserProfileRepository
```

## Firestore futuro

Possiveis caminhos:

```txt
users/{uid}/subjects/{subjectId}
users/{uid}/schedules/{scheduleId}
users/{uid}/activityReminders/{reminderId}
```

## Regras futuras

As regras atuais liberam leitura/escrita para qualquer documento dentro de
`users/{uid}` quando o usuario autenticado e dono daquele `uid`.

Quando os schemas amadurecerem, uma melhoria possivel e validar tipos e campos
obrigatorios nas regras.

## Testes automatizados

Estado atual:

- Ha teste unitario simples para `AuthException`.

Proximos testes recomendados:

- Validacao de prazo de tarefa.
- Mapeamento de `AcademicTask`.
- `TaskRepository` com fake/mock de Firestore.
- Widget test do `TaskDialog`.
- Widget test dos fluxos de configuracao inicial.
