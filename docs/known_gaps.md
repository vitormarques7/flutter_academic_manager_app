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
- O setup inicial ja persiste disciplinas e horarios no Firestore, mas a
  `SubjectsPage` ainda nao consome esses dados reais.
- Media, frequencia e carga horaria das disciplinas criadas localmente ainda
  usam valores iniciais simples.

### Dropdown de disciplinas em tarefas

- O dropdown de disciplinas do `TaskDialog` usa lista fixa:
  - Programacao
  - Calculo I
  - Banco de Dados
  - Inteligencia Artificial

Proximo passo recomendado: alimentar o dropdown com `DisciplineRepository` e
filtrar pelo ciclo academico ativo.

### Agenda

- Aulas do calendario sao mockadas.
- A grade de horarios existe como visualizacao local/mockada, sem Firestore.
- A grade nao e alimentada pelas disciplinas criadas no app.
- Editar grade exibe mensagem de "em desenvolvimento".

### Perfil

- Curso e periodo da tela de perfil sao mockados.
- O tile "Dados pessoais" ainda nao abre fluxo de edicao.
- As configuracoes iniciais de estudante ja sao persistidas em `studyCycles`,
  `disciplines`, `schedules` e no `activeStudyCycleId` do documento do usuario,
  mas a tela de perfil ainda nao le esses dados reais.

## Persistencia pendente

Repositories ja criados e ainda pendentes de integracao completa na UI:

```txt
DisciplineRepository
ScheduleRepository
StudyCycleRepository
UserProfileRepository
```

## Firestore futuro

Possiveis caminhos:

```txt
users/{uid}/subjects/{subjectId}
users/{uid}/activityReminders/{reminderId}
```

Observacao: `subjects` e `activityReminders` ainda nao existem nas regras
locais. Inclua essas subcolecoes em `firestore.rules` antes de usar.

## Regras futuras

As regras atuais liberam leitura/escrita para o documento `users/{uid}` e para
as subcolecoes `tasks`, `schedules`, `studyCycles` e `disciplines` quando o
usuario autenticado e dono daquele `uid`.

Quando os schemas amadurecerem, uma melhoria possivel e validar tipos e campos
obrigatorios nas regras.

## Testes automatizados

Estado atual:

- Ha teste unitario simples para `AuthException`.
- Ha testes unitarios para `AcademicTask.fromMap`.
- Ha testes unitarios para `TaskInput.toCreateMap` e `TaskInput.toUpdateMap`.

Proximos testes recomendados:

- Validacao de prazo de tarefa.
- `TaskRepository` com fake/mock de Firestore.
- Widget test do `TaskDialog`.
- Widget test dos fluxos de configuracao inicial.
- Widget test de exclusao de tarefa.
