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
- Firestore configurado para tarefas em `users/{uid}/tasks/{taskId}`.
- Tarefas persistem no Firestore via `TaskRepository`.
- Disciplinas ainda ficam em memoria local na tela `SubjectsPage`.
- A tela de agenda/calendario ainda possui dados mockados e botoes de fluxo futuro.
- Regras locais do Firestore ficam em `firestore.rules`.

## Comandos mais usados

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```
