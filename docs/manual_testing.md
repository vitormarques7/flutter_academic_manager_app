# Testes manuais

Este arquivo lista roteiros manuais para validar os fluxos atuais.

## Base

Antes de testar:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Observacao: os testes automatizados atuais cobrem models, inputs, excecoes de
repositories, `AuthException` e helpers de data brasileira.

## Autenticacao

### Cadastro valido

1. Abrir app sem usuario logado.
2. Ir para cadastro.
3. Preencher nome, e-mail valido, senha e confirmacao.
4. Clicar em cadastrar.

Resultado esperado:

- Usuario e criado no Firebase Auth.
- Documento raiz e criado/atualizado em `users/{uid}`.
- App navega para selecao de perfil.

### Cadastro invalido

1. Tentar cadastrar sem nome.
2. Tentar cadastrar com e-mail invalido.
3. Tentar cadastrar com senha menor que 6 caracteres.
4. Tentar cadastrar com confirmacao diferente.

Resultado esperado:

- Formulario mostra erro.
- Cadastro nao acontece.

### Login

1. Entrar com e-mail e senha validos.

Resultado esperado:

- App navega para home.
- Documento raiz do usuario existe em `users/{uid}` com `displayName`, `email`,
  `createdAt` e `updatedAt` quando esses dados estiverem disponiveis.
- Se o usuario nao tiver ciclo ativo, o app direciona para selecao de perfil.

### Recuperacao de senha

1. Digitar e-mail valido na tela de login.
2. Clicar em "Esqueceu a senha?".

Resultado esperado:

- App mostra mensagem de envio de link.

## Configuracao inicial

### Universitario

1. Selecionar perfil universitario.
2. Preencher curso.
3. Escolher periodo no dropdown.
4. Adicionar disciplina.
5. Informar dias e horarios.
6. Confirmar disciplina.
7. Salvar e continuar.

Resultado esperado:

- Campos rolam junto com o cabecalho.
- Dropdown de periodo mostra lista limitada e rolavel.
- Botao salvar mostra loading e navega para home apenas apos sucesso.
- Documento e criado em `users/{uid}/studyCycles/{cycleId}`.
- `users/{uid}` recebe `activeStudyCycleId`.
- Disciplinas sao criadas em `users/{uid}/disciplines`.
- Horarios informados sao criados em `users/{uid}/schedules` com
  `studyCycleId` e `disciplineId`.

### Ensino medio

1. Selecionar perfil ensino medio.
2. Escolher serie.
3. Adicionar disciplina.
4. Informar horarios.
5. Salvar e continuar.

Resultado esperado:

- Layout permanece responsivo.
- Cabecalho rola junto com conteudo quando ha muitas disciplinas.
- Serie, disciplinas e horarios sao persistidos no Firestore.

### Independente

1. Selecionar perfil independente.
2. Preencher objetivo.
3. Adicionar disciplinas.
4. Informar horarios.
5. Salvar e continuar.

Resultado esperado:

- Layout permanece responsivo.
- Objetivo, disciplinas e horarios sao persistidos no Firestore.

## Home

1. Entrar com usuario que possui ciclo ativo.
2. Criar uma disciplina com horario.
3. Criar tarefas pendentes, concluidas e com prazo.
4. Criar uma nota nos detalhes da disciplina.
5. Criar um evento na agenda ou nos detalhes da disciplina.
6. Voltar para Home.

Resultado esperado:

- Home mostra saudacao com primeiro nome.
- Painel usa dados do ciclo ativo.
- Media reflete notas cadastradas.
- Proxima aula vem da grade.
- Tarefas proximas e alertas refletem dados reais.
- Eventos proximos aparecem no resumo.
- Menu de ciclo permite trocar o ciclo ativo.

## Tarefas

### Criacao valida

1. Fazer login.
2. Garantir que ha pelo menos uma disciplina no ciclo ativo.
3. Ir para "Suas Tarefas".
4. Clicar no botao `+`.
5. Preencher titulo.
6. Selecionar disciplina no dropdown real.
7. Informar prazo de hoje ou futuro, ou deixar vazio.
8. Escolher prioridade visual.
9. Salvar.

Resultado esperado:

- Modal mostra loading.
- Documento e criado em `users/{uid}/tasks/{taskId}`.
- Documento recebe `studyCycleId` quando ha ciclo academico ativo.
- Documento recebe `disciplineId` quando a disciplina veio do Firestore.
- Tarefa aparece na lista.
- Resumo de progresso e contadores sao atualizados.

### Criacao invalida

1. Abrir modal de nova tarefa.
2. Tentar salvar sem titulo.
3. Tentar salvar sem disciplina.
4. Tentar salvar com data invalida.
5. Tentar salvar com data passada.

Resultado esperado:

- Modal exibe erro de validacao.
- Nenhum documento incompleto e salvo.

### Edicao

1. Tocar em uma tarefa existente.
2. Alterar titulo, prazo, disciplina, descricao ou prioridade.
3. Salvar.

Resultado esperado:

- Documento existente e atualizado.
- A tarefa permanece no mesmo usuario.
- Lista atualiza via stream.

### Conclusao

1. Marcar uma tarefa pendente como concluida.
2. Desmarcar a mesma tarefa.

Resultado esperado:

- Campo `isChecked` muda no Firestore.
- Contadores e filtros refletem a mudanca.

### Exclusao

1. Tocar em uma tarefa existente.
2. Clicar em "Excluir tarefa".
3. Confirmar a exclusao.

Resultado esperado:

- Documento e removido de `users/{uid}/tasks/{taskId}`.
- Modal fecha.
- Tarefa deixa de aparecer na lista.

### Filtros

1. Criar tarefas pendentes e concluidas.
2. Alternar entre filtros "Todas", "Pendentes" e "Concluidas".

Resultado esperado:

- Lista muda conforme filtro.

## Disciplinas

### Criacao

1. Ir para "Suas Disciplinas".
2. Clicar no botao `+`.
3. Criar disciplina com nome.
4. Selecionar dias e horarios.
5. Salvar.

Resultado esperado:

- Disciplina aparece na lista via stream do Firestore.
- Documento e criado em `users/{uid}/disciplines/{disciplineId}`.
- Horarios informados sao criados em `users/{uid}/schedules`.
- Ao reiniciar ou fazer logout/login, a disciplina continua aparecendo.

### Busca

1. Criar disciplinas com nomes e professores diferentes.
2. Buscar por parte do nome.
3. Buscar por parte do professor.

Resultado esperado:

- Lista filtra localmente os resultados carregados do ciclo ativo.

### Exclusao

1. Abrir acao de excluir disciplina.
2. Selecionar uma disciplina que tenha horarios.
3. Confirmar exclusao.

Resultado esperado:

- Disciplina e removida.
- Horarios vinculados a ela tambem sao removidos.
- Agenda deixa de mostrar os horarios daquela disciplina.

## Detalhes de disciplina

1. Abrir uma disciplina.
2. Criar uma nota.
3. Criar um evento.
4. Criar uma anotacao.
5. Criar uma tarefa para a mesma disciplina pela tela de tarefas.
6. Voltar aos detalhes da disciplina.

Resultado esperado:

- Nota aparece na secao de avaliacoes e altera a media.
- Evento aparece na lista de eventos relacionados.
- Anotacao aparece na lista de anotacoes.
- Tarefa relacionada aparece nos detalhes.
- Excluir nota/evento/anotacao remove o documento correspondente.

## Agenda

1. Ir para agenda.
2. Navegar entre dias usando setas, swipe ou selecao no calendario.
3. Selecionar hoje, o dia anterior/proximo e trocar de mes.
4. Abrir o card "Grade de Horario".
5. Editar a grade criando um horario.
6. Editar um horario existente.
7. Excluir um horario existente.
8. Voltar para o calendario.
9. Clicar no botao `+` e criar um evento.

Resultado esperado:

- Calendario responde a selecao e permanece em `pt_BR`.
- Dias recorrentes com horarios salvos exibem marcador no calendario.
- Eventos exibem marcador no calendario.
- Ao trocar de dia, a lista mostra apenas horarios daquele dia da semana e
  eventos daquele dia.
- Dias sem horario mostram estado vazio.
- A grade semanal abre em uma nova visualizacao dentro da tela com dados reais.
- Criar, editar e excluir horario atualiza `users/{uid}/schedules`.
- Criar evento salva em `users/{uid}/subjectEvents`.

## Perfil e dados pessoais

1. Fazer login.
2. Abrir a tela de perfil.
3. Conferir nome e e-mail.
4. Conferir curso/periodo, ano letivo ou meta conforme o perfil cadastrado.
5. Tocar em "Dados pessoais".
6. Atualizar o nome.
7. Editar os dados academicos do ciclo ativo.
8. Ativar outro ciclo, se existir.
9. Voltar ao perfil e a Home.
10. Tocar em "Sair".

Resultado esperado:

- Nome e e-mail refletem o usuario autenticado quando disponiveis.
- Dados academicos refletem o ciclo ativo salvo no Firestore.
- Nome atualizado aparece no Firebase Auth e em `users/{uid}`.
- Alteracoes do ciclo ativo aparecem no perfil/Home.
- Troca de ciclo altera os dados exibidos nas telas principais.
- "Sair" desloga e volta para a tela inicial.

## Firestore/regras

### Isolamento por usuario

1. Publicar `firestore.rules`.
2. Criar dados com usuario A.
3. Entrar com usuario B.

Resultado esperado:

- Usuario B nao ve dados do usuario A.
- Tentativas manuais de acessar path de outro usuario devem falhar por
  `permission-denied`.

### Colecoes cobertas

Validar leitura/escrita nas colecoes:

- `tasks`
- `schedules`
- `studyCycles`
- `disciplines`
- `assessments`
- `subjectNotes`
- `subjectEvents`
