# Visao geral do projeto

O Academic Manager App e um app Flutter para organizacao academica. Ele permite
que estudantes acompanhem disciplinas, tarefas, agenda e informacoes gerais de
desempenho.

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

### Configuracao inicial

Depois do cadastro, o usuario escolhe seu perfil de estudante e passa por uma
tela de configuracao:

- Universitario: curso, periodo e disciplinas.
- Ensino medio: serie e disciplinas.
- Independente: objetivo e disciplinas.

As telas de configuracao persistem o ciclo academico, disciplinas e horarios no
Firestore. O ciclo criado tambem passa a ser salvo como `activeStudyCycleId` em
`users/{uid}`.

### Home

A home mostra:

- Saudacao com primeiro nome do usuario.
- Card de foco do dia com media, frequencia, proxima aula e tarefas pendentes.
- Indicadores de media, frequencia e pendencias.
- Proximas tarefas mockadas.
- Alertas mockados.

### Disciplinas

A tela de disciplinas usa Firestore em tempo real.

Ela permite:

- Buscar disciplina por nome ou professor.
- Ver resumo com total de disciplinas do ciclo ativo.
- Abrir detalhes da disciplina.
- Criar uma nova disciplina no Firestore por modal.
- Informar dias e horarios da disciplina no modal, criando horarios em
  `users/{uid}/schedules`.

### Tarefas

A tela de tarefas usa Firestore em tempo real.

Ela permite:

- Listar tarefas do usuario logado.
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
- Horarios reais do Firestore marcam os dias recorrentes no calendario.
- O card "Grade de Horario" abre uma visualizacao semanal com horarios reais.
- O botao `+` abre o modal real de horario e salva em `users/{uid}/schedules`.
- A edicao da grade ainda exibe mensagem de "em desenvolvimento".

### Perfil

A tela de perfil mostra:

- Nome e e-mail vindos do usuario autenticado no Firebase Auth.
- Dados academicos vindos do ciclo ativo:
  - curso e periodo para universitario;
  - ano letivo para ensino medio;
  - meta para estudante independente.
- Acao de logout real via `AuthService.signOut`.
- Tile "Dados pessoais" ainda sem fluxo implementado.

## Funcionalidades ainda pendentes

- Integrar disciplinas reais ao dropdown de tarefas.
- Trocar cards mockados da home por dados reais.
- Implementar lembretes de atividade.
