# Arquitetura

O app segue uma organizacao simples por camadas, adequada para o tamanho atual
do projeto.

## Estrutura principal

```txt
lib/
  config/
    routes/
    scroll/
    theme/
  models/
  repositories/
  services/
    auth/
  view/
    pages/
    shell/
    widgets/
```

## Camadas

### config

Contem configuracoes globais:

- Rotas em `AppRoutes`.
- Tema em `AppTheme`.
- Cores em `AppColors`.
- Tipografia em `AppTextStyles`.
- Comportamento global de scroll em `AppScrollBehavior`.

### services

Contem servicos externos ou de infraestrutura.

Atualmente:

- `AuthService`: encapsula Firebase Auth e Google Sign-In.

### repositories

Contem acesso a dados persistidos.

Atualmente:

- `TaskRepository`: concentra todo acesso de tarefas ao Firestore.

Regra importante: widgets de tela nao devem chamar `FirebaseFirestore`
diretamente. Eles devem passar por repositories.

### models

Contem modelos de dados usados pela aplicacao.

Atualmente:

- `AcademicTask`
- `TaskInput`

### view/pages

Contem telas completas:

- Autenticacao.
- Configuracao inicial.
- Home.
- Disciplinas.
- Tarefas.
- Agenda.
- Perfil.

### view/widgets

Contem componentes reutilizaveis:

- Botoes.
- Cards.
- Dialogs.
- Inputs.
- Selectors.
- Componentes comuns, como header e bottom nav.

## Inicializacao do app

Fluxo principal:

```txt
main()
  initializeDateFormatting('pt_BR')
  Firebase.initializeApp(...)
  runApp(MyApp)
```

`MyApp` usa:

- `AppTheme.theme`
- `AppScrollBehavior`
- `AppRoutes.routes`
- rota inicial `/auth`

## Autenticacao

`AuthGatePage` escuta `AuthService.authStateChanges`.

- Se ha usuario logado: renderiza `MainShell`.
- Se nao ha usuario: renderiza `WelcomePage`.
- Enquanto carrega: mostra loading.

## Shell principal

`MainShell` controla a navegacao inferior entre:

```txt
0: HomePage
1: SubjectsPage
2: TasksPage
3: SchedulePage
```

## Padrao recomendado para novas features

Para fluxos com persistencia:

1. Criar model em `lib/models`.
2. Criar repository em `lib/repositories`.
3. Manter chamadas ao Firestore dentro do repository.
4. A tela chama metodos do repository.
5. UI trata loading, erro e estados vazios.
6. Documentar schema em `docs/firestore_schema.md`.
