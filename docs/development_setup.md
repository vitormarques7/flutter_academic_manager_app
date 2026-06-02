# Setup de desenvolvimento

## Requisitos

- Flutter instalado.
- Projeto Firebase configurado.
- Firebase Auth habilitado.
- Cloud Firestore criado.
- Navegador Chrome para testes web, se desejado.

## Dependencias principais

As principais dependencias do app sao:

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `google_sign_in`
- `intl`
- `table_calendar`

## Instalacao

Na raiz do projeto:

```bash
flutter pub get
```

## Executar

Chrome:

```bash
flutter run -d chrome
```

Dispositivo/emulador padrao:

```bash
flutter run
```

Quando uma dependencia de plugin e adicionada, como `cloud_firestore`, faca um
restart completo do app. Hot reload pode nao carregar o plugin corretamente.

## Verificacoes

```bash
flutter analyze
flutter test
```

## Firebase

O Firebase e inicializado em `lib/main.dart` antes de `runApp`:

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

As opcoes por plataforma ficam em `lib/firebase_options.dart`, gerado pelo
FlutterFire CLI.

## Regras locais

O arquivo `firebase.json` aponta para:

```txt
firestore.rules
```

Para aplicar regras no Firebase remoto, publique pelo console do Firebase ou
use Firebase CLI quando ela estiver configurada no ambiente.
