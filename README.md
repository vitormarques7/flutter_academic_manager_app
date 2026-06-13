# Academic Manager App

App Flutter para organizacao academica. O projeto permite acompanhar ciclos de
estudo, disciplinas, tarefas, agenda, notas, eventos e anotacoes.

## Stack

- Flutter.
- Firebase Auth.
- Cloud Firestore.
- Google Sign-In.
- `table_calendar`.

## Rodando localmente

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Documentacao

A documentacao principal fica em [`docs/`](docs/README.md).

Leitura recomendada:

- [`docs/project_overview.md`](docs/project_overview.md): visao funcional.
- [`docs/architecture.md`](docs/architecture.md): divisao de camadas.
- [`docs/data_layer.md`](docs/data_layer.md): models, repositories, services e
  CRUD.
- [`docs/firestore_schema.md`](docs/firestore_schema.md): colecoes e campos do
  Firestore.
- [`docs/manual_testing.md`](docs/manual_testing.md): roteiros de validacao.

## Firebase

Os dados privados seguem o padrao:

```txt
users/{uid}/...
```

As regras locais ficam em:

```txt
firestore.rules
```

Elas permitem acesso somente ao usuario autenticado dono do `{uid}`.
