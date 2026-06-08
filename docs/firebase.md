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

Isso acontece antes de qualquer tela ser renderizada.

## Autenticacao

`AuthService` encapsula:

- `authStateChanges`
- usuario atual
- login com e-mail e senha
- cadastro com e-mail e senha
- login com Google
- reset de senha
- logout

Erros do Firebase Auth sao mapeados para mensagens amigaveis em portugues.

## Firestore

O acesso ao Firestore deve acontecer por repositories.

Atualmente:

```txt
TaskRepository -> users/{uid}/tasks/{taskId}
```

Nao deve haver chamadas a `FirebaseFirestore.instance` dentro de widgets de
tela.

Operacoes atuais do `TaskRepository`:

- `watchTasks`: observa tarefas do usuario logado em tempo real e ordena por
  `createdAt` decrescente quando disponivel.
- `createTask`: cria tarefa com `isChecked: false`.
- `updateTask`: altera campos editaveis da tarefa.
- `updateCompletion`: marca tarefa como concluida ou pendente.
- `deleteTask`: remove tarefa.

Quando nao ha usuario logado, o repository lanca `TaskRepositoryException` com
mensagem em portugues.

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
    }
  }
}
```

Essas regras permitem que um usuario leia e escreva somente documentos dentro
de `users/{uid}` quando o `uid` do path for igual ao `request.auth.uid`.

## Publicacao das regras

O arquivo local nao altera o Firebase remoto automaticamente.

Para aplicar pelo console:

1. Firebase Console.
2. Cloud Firestore.
3. Aba Regras.
4. Colar conteudo de `firestore.rules`.
5. Publicar.

## App Check

O console pode sugerir App Check. Ele e util para protecao adicional contra uso
abusivo fora do app, mas nao e obrigatorio para o estagio atual de
desenvolvimento.
