# Firebase e Firestore

## Servicos usados

- Firebase Core.
- Firebase Auth.
- Cloud Firestore.
- Google Sign-In.

## Inicializacao

O Firebase e inicializado uma unica vez em `lib/main.dart`:

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

Isso acontece antes de qualquer tela ser renderizada. As opcoes por plataforma
ficam em `lib/firebase_options.dart`, gerado pelo FlutterFire CLI.

## Autenticacao

`AuthService` encapsula:

- `authStateChanges`;
- usuario atual;
- login com e-mail e senha;
- cadastro com e-mail e senha;
- login com Google;
- reset de senha;
- logout;
- atualizacao de display name;
- sincronizacao basica com `users/{uid}`.

Erros do Firebase Auth sao mapeados para mensagens amigaveis em portugues.

## Bootstrap de usuario

Depois que o Firebase Auth informa um usuario autenticado, `AuthGatePage` chama
`UserDataBootstrapService.ensureCurrentUserData`.

Esse bootstrap:

- garante que o documento `users/{uid}` exista;
- grava `displayName` e `email` quando disponiveis;
- resolve `activeStudyCycleId`;
- se o usuario antigo nao tiver ciclo ativo, tenta usar o ciclo mais recente;
- preenche `studyCycleId` em tarefas e horarios antigos quando possivel.

Se nao houver ciclo ativo, o app direciona para selecao/configuracao de perfil.
Se houver ciclo ativo, o app entra no `MainShell`.

## Firestore

O acesso ao Firestore deve acontecer por repositories. Widgets de tela nao
devem chamar `FirebaseFirestore.instance` diretamente.

Mapa atual:

```txt
UserProfileRepository -> users/{uid}
StudyCycleRepository  -> users/{uid}/studyCycles/{cycleId}
DisciplineRepository  -> users/{uid}/disciplines/{disciplineId}
ScheduleRepository    -> users/{uid}/schedules/{scheduleId}
TaskRepository        -> users/{uid}/tasks/{taskId}
AssessmentRepository  -> users/{uid}/assessments/{assessmentId}
SubjectNoteRepository -> users/{uid}/subjectNotes/{noteId}
SubjectEventRepository -> users/{uid}/subjectEvents/{eventId}
```

Operacoes comuns dos repositories:

- `watch...`: observa colecoes em tempo real com `snapshots`.
- `fetch...`: busca uma lista pontual com `get`.
- `create...`: cria documento com `add`.
- `update...`: atualiza documento com `update`.
- `delete...`: remove documento com `delete`.
- `backfill...`: corrige documentos antigos quando necessario.

Quando nao ha usuario logado, os repositories lancam excecoes especificas com
mensagem em portugues, como `TaskRepositoryException` ou
`ScheduleRepositoryException`.

## Organizacao por usuario

O dono dos dados e definido pelo path:

```txt
users/{uid}/...
```

O app evita depender de um campo `userId` dentro de cada documento academico.
Isso simplifica regras de seguranca e consultas por usuario.

## Regras de seguranca

As regras locais ficam em:

```txt
firestore.rules
```

Modelo atual:

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read, write: if isOwner(userId);

      match /tasks/{taskId} {
        allow read, create, update, delete: if isOwner(userId);
      }

      match /schedules/{scheduleId} {
        allow read, create, update, delete: if isOwner(userId);
      }

      match /studyCycles/{cycleId} {
        allow read, create, update, delete: if isOwner(userId);
      }

      match /disciplines/{disciplineId} {
        allow read, create, update, delete: if isOwner(userId);
      }

      match /assessments/{assessmentId} {
        allow read, create, update, delete: if isOwner(userId);
      }

      match /subjectNotes/{noteId} {
        allow read, create, update, delete: if isOwner(userId);
      }

      match /subjectEvents/{eventId} {
        allow read, create, update, delete: if isOwner(userId);
      }
    }
  }
}
```

Essas regras permitem que um usuario leia e escreva somente documentos dentro
de `users/{uid}` quando o `uid` do path for igual ao `request.auth.uid`.

## Limitacao atual das regras

As regras validam propriedade, mas ainda nao validam tipos, campos obrigatorios
ou ranges de valores. Hoje essa normalizacao fica principalmente nos formularios
e models.

Melhoria recomendada: adicionar validacoes progressivas por colecao quando o
schema estabilizar.

## Publicacao das regras

O arquivo local nao altera o Firebase remoto automaticamente.

Para aplicar pelo console:

1. Firebase Console.
2. Cloud Firestore.
3. Aba Regras.
4. Colar conteudo de `firestore.rules`.
5. Publicar.

Tambem e possivel usar Firebase CLI quando o ambiente estiver configurado.

## App Check

O console pode sugerir App Check. Ele e util para protecao adicional contra uso
abusivo fora do app, mas nao e obrigatorio para o estagio atual de
desenvolvimento.
