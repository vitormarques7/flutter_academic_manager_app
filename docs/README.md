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
- Disciplinas ainda ficam em memoria local na tela `SubjectsPage`, apesar de ja
  existirem dados persistidos do setup.
- A tela de agenda/calendario possui dados mockados e uma visualizacao local
  de grade de horario, ainda sem ler o `ScheduleRepository`.
- A tela de perfil usa nome/e-mail do Firebase Auth, mas curso e periodo ainda
  sao mockados.
- Regras locais do Firestore ficam em `firestore.rules`.

## Comandos mais usados

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```
