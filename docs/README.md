# Documentacao do Academic Manager App

Este diretorio concentra a documentacao tecnica e funcional do app. A ideia e
evitar conhecimento espalhado entre telas, comentarios e memoria de implementacao.

## Indice

- [Visao geral do projeto](project_overview.md)
- [Setup de desenvolvimento](development_setup.md)
- [Arquitetura](architecture.md)
- [Navegacao e fluxos](navigation_and_flows.md)
- [Firebase e Firestore](firebase.md)
- [Schema do Firestore](firestore_schema.md)
- [Sistema visual](design_system.md)
- [Testes manuais](manual_testing.md)
- [Lacunas conhecidas e proximos passos](known_gaps.md)

## Estado atual resumido

- Autenticacao com Firebase Auth.
- Firestore configurado por usuario em `users/{uid}` e subcolecoes.
- Tarefas persistem no Firestore via `TaskRepository`, com criacao,
  edicao, conclusao e exclusao, vinculando `studyCycleId` quando ha ciclo ativo.
- Setup academico inicial persiste `studyCycles`, `disciplines`, `schedules` e
  `activeStudyCycleId`.
- Disciplinas sao lidas do Firestore na tela `SubjectsPage`; criar disciplina
  pela tela tambem persiste a disciplina e seus horarios.
- A tela de agenda/calendario le horarios reais via `ScheduleRepository`,
  marca dias recorrentes, filtra a grade diaria pelo dia selecionado e permite
  criar novos horarios.
- A tela de perfil usa nome/e-mail do Firebase Auth e dados academicos reais do
  ciclo ativo.
- Regras locais do Firestore ficam em `firestore.rules`.

## Comandos mais usados

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```
