# Arquitetura

O app segue uma organizacao por camadas simples, adequada ao tamanho atual do
projeto. A tela pode instanciar repositories diretamente, mas a regra central e
manter Firebase/Firestore fora dos widgets e concentrar persistencia na camada
de repositories.

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
    setup/
  view/
    pages/
    shell/
    widgets/
```

## Fluxo de alto nivel

```txt
View/Page
  -> Service, quando o fluxo envolve mais de uma operacao
  -> Repository, quando a tela precisa ler ou salvar uma entidade
  -> Model/Input, para converter dados entre Dart e Firestore
  -> Firebase Auth / Cloud Firestore
```

Exemplos:

- `TasksPage` usa `TaskRepository` e `DisciplineRepository`.
- `SchedulePage` usa `ScheduleRepository`, `DisciplineRepository`,
  `SubjectEventRepository`, `StudyCycleRepository` e `UserProfileRepository`.
- Telas de setup usam `AcademicSetupService`, que coordena varios
  repositories.
- `AuthGatePage` usa `AuthService` e `UserDataBootstrapService` para decidir se
  o usuario vai para onboarding ou para o shell principal.

## Camadas

### config

Contem configuracoes globais:

- Rotas e helpers de navegacao em `AppRoutes`.
- Tema em `AppTheme`.
- Cores em `AppColors`.
- Tipografia em `AppTextStyles`.
- Tokens visuais em `AppDesignTokens`.
- Comportamento global de scroll em `AppScrollBehavior`.

### models

Contem as entidades da aplicacao e objetos de input usados para persistencia.
Os models sabem converter documentos do Firestore para objetos Dart e gerar
maps de criacao/edicao.

Entidades atuais:

- `AcademicTask` e `TaskInput`
- `Discipline` e `DisciplineInput`
- `Schedule` e `ScheduleInput`
- `StudyCycle` e `StudyCycleInput`
- `UserProfile`
- `Assessment` e `AssessmentInput`
- `SubjectNote` e `SubjectNoteInput`
- `SubjectEvent` e `SubjectEventInput`

### repositories

Contem o acesso a dados persistidos. Cada repository:

- le o usuario atual via `FirebaseAuth`;
- monta paths privados em `users/{uid}`;
- executa `snapshots`, `get`, `add`, `update` e `delete`;
- converte documentos para models;
- aplica filtros e ordenacao;
- traduz erros do Firebase para excecoes com mensagens em portugues.

Repositories atuais:

- `TaskRepository`
- `DisciplineRepository`
- `ScheduleRepository`
- `StudyCycleRepository`
- `UserProfileRepository`
- `AssessmentRepository`
- `SubjectNoteRepository`
- `SubjectEventRepository`

Regra importante: widgets de tela nao devem chamar `FirebaseFirestore`
diretamente. Chamadas ao Firestore devem passar por repositories.

### services

Contem integracoes externas ou casos de uso que coordenam mais de um
repository:

- `AuthService`: encapsula Firebase Auth, Google Sign-In e sincronizacao basica
  do documento `users/{uid}`.
- `UserDataBootstrapService`: garante documento raiz do usuario, resolve o
  ciclo ativo e faz backfill de `studyCycleId` em dados antigos.
- `AcademicSetupService`: cria ciclo academico, define ciclo ativo, cria
  disciplinas e cria horarios durante o setup inicial.

### view/pages

Contem telas completas:

- Autenticacao e onboarding.
- Configuracao inicial e criacao de novos ciclos.
- Home.
- Disciplinas e detalhes de disciplina.
- Tarefas.
- Agenda.
- Perfil e dados pessoais.

### view/widgets

Contem componentes reutilizaveis:

- Botoes.
- Cards.
- Dialogs.
- Inputs.
- Selectors.
- Componentes comuns, como header, bottom nav, empty states e surfaces.

## Inicializacao do app

Fluxo principal:

```txt
main()
  WidgetsFlutterBinding.ensureInitialized()
  initializeDateFormatting('pt_BR')
  Firebase.initializeApp(...)
  runApp(MyApp)
```

`MyApp` configura:

- `AppTheme.theme`
- `AppScrollBehavior`
- locale `pt_BR`
- `AppRoutes.routes`
- rota inicial `/auth`

## Autenticacao e bootstrap

`AuthGatePage` escuta `AuthService.authStateChanges`.

```txt
sem usuario autenticado
  -> WelcomePage

usuario autenticado
  -> UserDataBootstrapService.ensureCurrentUserData
     -> cria/atualiza users/{uid}
     -> resolve activeStudyCycleId
     -> faz backfill de tasks/schedules sem studyCycleId
  -> se nao houver ciclo ativo: StudentFilteringPage
  -> se houver ciclo ativo: MainShell
```

## Shell principal

`MainShell` controla a navegacao inferior entre:

```txt
0: HomePage
1: SubjectsPage
2: TasksPage
3: SchedulePage
```

Telas fora do shell, como `UserProfilePage`, `PersonalDataPage` e paginas de
detalhes, sao abertas por rotas ou `MaterialPageRoute`.

## Padrao recomendado para novas features

Para fluxos com persistencia:

1. Criar ou atualizar model em `lib/models`.
2. Criar ou atualizar repository em `lib/repositories`.
3. Manter chamadas ao Firestore dentro do repository.
4. Criar service quando a feature precisar coordenar varias entidades.
5. A tela deve chamar metodos de service/repository e tratar loading, erro e
   estados vazios.
6. Atualizar `docs/firestore_schema.md` e `firestore.rules` quando uma nova
   colecao for criada.
7. Adicionar testes unitarios para normalizacao, serializacao e regras de
   negocio locais.
