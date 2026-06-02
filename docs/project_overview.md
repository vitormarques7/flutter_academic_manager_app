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

As telas de configuracao ainda nao persistem esses dados no Firestore.

### Home

A home mostra:

- Saudacao com primeiro nome do usuario.
- Card de desempenho.
- Card de frequencia.
- Proximas tarefas mockadas.
- Alertas mockados.

### Disciplinas

A tela de disciplinas mostra uma lista local/mockada de disciplinas.

Ela permite:

- Buscar disciplina por nome ou professor.
- Abrir detalhes da disciplina.
- Criar uma nova disciplina localmente por modal.
- Informar dias e horarios da disciplina no modal, preparando dados para a
  futura grade de horarios.

### Tarefas

A tela de tarefas usa Firestore em tempo real.

Ela permite:

- Listar tarefas do usuario logado.
- Filtrar por todas, pendentes e concluidas.
- Criar tarefa.
- Editar tarefa.
- Marcar tarefa como concluida ou pendente.
- Validar titulo obrigatorio.
- Validar prazo quando informado.

### Agenda

A tela de agenda mostra um calendario mensal com `table_calendar`.

Estado atual:

- Um lembrete mockado aparece no calendario.
- Os botoes de adicionar lembrete e ver grade exibem mensagens de "em desenvolvimento".

## Funcionalidades ainda pendentes

- Persistir disciplinas no Firestore.
- Persistir horarios em `users/{uid}/schedules/{scheduleId}`.
- Integrar disciplinas reais ao dropdown de tarefas.
- Trocar cards mockados da home por dados reais.
- Implementar grade de horarios.
- Implementar lembretes de atividade.
