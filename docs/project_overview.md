# Visao geral do projeto

O Academic Manager App e um app Flutter para organizacao academica. Ele ajuda o
estudante a acompanhar ciclos de estudo, disciplinas, tarefas, agenda, notas,
eventos e anotacoes.

## Publico-alvo

O app atende tres perfis de estudante:

- Estudante universitario.
- Estudante de ensino medio.
- Estudante independente, como vestibular, concurso ou estudos livres.

## Funcionalidades atuais

### Autenticacao

- Cadastro com nome, e-mail e senha.
- Login com e-mail e senha.
- Login com Google quando a plataforma suporta.
- Recuperacao de senha por e-mail.
- Controle de sessao via `AuthGatePage`.
- Criacao/atualizacao automatica do documento `users/{uid}` apos login ou
  cadastro.

### Configuracao inicial

Depois do cadastro, o usuario escolhe seu perfil de estudante e passa por uma
tela de configuracao:

- Universitario: curso, periodo, disciplinas e horarios.
- Ensino medio: serie, disciplinas e horarios.
- Independente: objetivo, disciplinas e assuntos iniciais opcionais.

As telas de configuracao persistem o ciclo academico, disciplinas e horarios no
Firestore. O ciclo criado tambem passa a ser salvo como `activeStudyCycleId` em
`users/{uid}`.

### Ciclos de estudo

- O usuario pode ter mais de um ciclo academico.
- O ciclo ativo fica em `users/{uid}.activeStudyCycleId`.
- Home, disciplinas, tarefas, agenda e perfil usam o ciclo ativo como contexto.
- A Home possui seletor de ciclo e entrada para criar novo ciclo.
- A tela de dados pessoais permite editar dados do ciclo ativo e ativar outro
  ciclo existente.

### Home

A Home consome dados reais do Firestore para o ciclo ativo:

- Tarefas pendentes/concluidas por `TaskRepository`.
- Proxima aula por `ScheduleRepository`.
- Eventos proximos por `SubjectEventRepository`.
- Media geral por `AssessmentRepository`.
- Alertas derivados de tarefas atrasadas, entregas de hoje, eventos proximos,
  grade vazia ou ausencia de notas.
- Para ciclos independentes, a Home prioriza tarefas, revisoes, horas estudadas
  na semana e assuntos pendentes, sem alertas de falta ou media minima.

Quando nao ha ciclo ativo, a Home mostra uma chamada para configurar o primeiro
ciclo de estudos.

### Disciplinas

A tela de disciplinas usa Firestore em tempo real.

Ela permite:

- Buscar disciplina por nome ou professor.
- Ver resumo com total de disciplinas, media geral e quantidade de notas.
- Abrir detalhes da disciplina.
- Criar nova disciplina no Firestore por modal.
- Informar dias e horarios no modal, criando horarios em
  `users/{uid}/schedules`.
- Excluir disciplina junto com horarios vinculados.
- No ciclo independente, criar disciplina usa um modal de disciplina e assuntos,
  sem professor, faltas, carga horaria ou horarios.

### Detalhes de disciplina

A tela de detalhes da disciplina usa dados reais relacionados a disciplina:

- Notas em `users/{uid}/assessments`.
- Tarefas relacionadas em `users/{uid}/tasks`.
- Eventos em `users/{uid}/subjectEvents`.
- Anotacoes em `users/{uid}/subjectNotes`.

Ela permite criar e excluir notas, eventos e anotacoes.
No ciclo independente, tambem permite registrar sessoes de estudo e gerenciar
assuntos a ver/vistos.

### Tarefas

A tela de tarefas usa Firestore em tempo real.

Ela permite:

- Listar tarefas do usuario logado.
- Filtrar pelo ciclo academico ativo.
- Usar disciplinas reais no dropdown do `TaskDialog`.
- Ver resumo de progresso, pendencias, tarefas para hoje e tarefas atrasadas.
- Filtrar por pendentes, concluidas e todas.
- Criar tarefa.
- Editar tarefa.
- Marcar tarefa como concluida ou pendente.
- Excluir tarefa com confirmacao.
- Validar titulo obrigatorio.
- Validar disciplina obrigatoria.
- Validar prazo quando informado.
- Vincular novas tarefas ao ciclo academico ativo quando ele existe.

### Agenda

A tela de agenda mostra um calendario mensal com `table_calendar`.

Estado atual:

- O calendario inicia no dia atual.
- Horarios reais do Firestore marcam dias recorrentes no calendario.
- Eventos proximos tambem aparecem na agenda.
- O card "Grade de Horario" abre uma visualizacao semanal com horarios reais.
- A edicao da grade permite criar, atualizar e excluir horarios via
  `ScheduleEditorSheet`.
- O botao `+` na agenda cria eventos academicos em `subjectEvents`.
- No ciclo independente, a agenda oculta a grade de aulas e permite usar eventos
  do tipo `Revisão`, opcionalmente ligados a assuntos.

### Perfil e dados pessoais

A tela de perfil mostra:

- Nome e e-mail vindos do Firebase Auth.
- Dados academicos vindos do ciclo ativo:
  - curso e periodo para universitario;
  - ano letivo para ensino medio;
  - meta para estudante independente.
- Acao de logout real via `AuthService.signOut`.
- Acesso a tela de dados pessoais.

A tela de dados pessoais permite:

- Ver nome, e-mail, ciclo ativo e disciplinas do ciclo.
- Atualizar o nome do usuario.
- Editar dados do ciclo ativo.
- Ativar outro ciclo existente.

## Funcionalidades ainda pendentes

- Validar schemas e campos obrigatorios nas regras do Firestore.
- Adicionar edicao para notas, eventos e anotacoes; hoje esses fluxos criam e
  excluem.
- Expandir testes automatizados para repositories com Firebase fake/mock.
- Evoluir metricas academicas, como frequencia real e calculos por disciplina.
- Implementar lembretes de atividade, se o produto seguir por esse caminho.
