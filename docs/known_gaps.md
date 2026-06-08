# Lacunas conhecidas e proximos passos

Este arquivo registra pontos ainda incompletos para evitar confundir mock,
prototipo e fluxo real.

## Dados ainda mockados ou locais

### Home

- Card de desempenho e frequencia sao mockados.
- Proximas tarefas sao mockadas.
- Alertas sao mockados.

### Disciplinas

- Media e frequencia das disciplinas ainda usam valores iniciais simples.
- A tela de detalhes da disciplina ainda nao le dados completos do Firestore.

### Dropdown de disciplinas em tarefas

- O dropdown de disciplinas do `TaskDialog` usa lista fixa:
  - Programacao
  - Calculo I
  - Banco de Dados
  - Inteligencia Artificial

Proximo passo recomendado: alimentar o dropdown com `DisciplineRepository` e
filtrar pelo ciclo academico ativo.

### Agenda

- Editar grade exibe mensagem de "em desenvolvimento".

### Perfil

- O tile "Dados pessoais" ainda nao abre fluxo de edicao.

## Persistencia pendente

As principais colecoes academicas ja possuem repositories e parte da UI
integrada. Ainda falta consumir dados reais em telas especificas:

- Tarefas: alimentar o dropdown de disciplinas com `DisciplineRepository`.
- Detalhes de disciplina: carregar dados completos do Firestore.

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
