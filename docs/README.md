# Documentacao do Academic Manager App

Este diretorio concentra a documentacao tecnica e funcional do app. A ideia e
evitar conhecimento espalhado entre telas, comentarios e memoria de
implementacao.

## Indice

- [Visao geral do projeto](project_overview.md)
- [Setup de desenvolvimento](development_setup.md)
- [Arquitetura](architecture.md)
- [Camada de dados e servicos](data_layer.md)
- [Navegacao e fluxos](navigation_and_flows.md)
- [Firebase e Firestore](firebase.md)
- [Schema do Firestore](firestore_schema.md)
- [Sistema visual](design_system.md)
- [Testes manuais](manual_testing.md)
- [Lacunas conhecidas e proximos passos](known_gaps.md)

## Estado atual resumido

- App Flutter para organizacao academica com perfis universitario, ensino medio
  e estudo independente.
- Autenticacao com Firebase Auth, e-mail/senha, Google Sign-In quando suportado
  e recuperacao de senha.
- Persistencia em Cloud Firestore isolada por usuario no padrao
  `users/{uid}` e subcolecoes privadas.
- Setup academico inicial cria ciclo de estudo, disciplinas, horarios e grava
  `activeStudyCycleId`.
- Home, disciplinas, tarefas, agenda, perfil e detalhes de disciplina consomem
  dados reais do Firestore por repositories.
- Repositories concentram CRUD, streams em tempo real, filtros por ciclo e
  tratamento de erros de persistencia.
- Services cuidam de autenticacao, bootstrap de dados do usuario e
  orquestracao do setup academico.
- Regras locais do Firestore ficam em `firestore.rules`.

## Comandos mais usados

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Onde olhar primeiro

- Para entender o app como produto: `project_overview.md`.
- Para entender como o codigo esta dividido: `architecture.md`.
- Para entender CRUD, repositories, models e services: `data_layer.md`.
- Para conferir colecoes e campos no Firestore: `firestore_schema.md`.
- Para testar manualmente os fluxos principais: `manual_testing.md`.
