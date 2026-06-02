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

## Autenticacao

### Cadastro valido

1. Abrir app sem usuario logado.
2. Ir para cadastro.
3. Preencher nome, e-mail valido, senha e confirmacao.
4. Clicar em cadastrar.

Resultado esperado:

- Usuario e criado no Firebase Auth.
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
5. Confirmar disciplina.
6. Salvar e continuar.

Resultado esperado:

- Campos rolam junto com o cabecalho.
- Dropdown de periodo mostra lista limitada e rolavel.
- Botao salvar navega para home.

### Ensino medio

1. Selecionar perfil ensino medio.
2. Escolher serie.
3. Adicionar disciplina.
4. Salvar e continuar.

Resultado esperado:

- Layout permanece responsivo.
- Cabecalho rola junto com conteudo quando ha muitas disciplinas.

### Independente

1. Selecionar perfil independente.
2. Preencher objetivo.
3. Adicionar disciplinas.
4. Salvar e continuar.

Resultado esperado:

- Layout permanece responsivo.

## Tarefas

### Criacao valida

1. Fazer login.
2. Ir para "Suas Tarefas".
3. Clicar no botao `+`.
4. Preencher titulo.
5. Selecionar disciplina.
6. Informar prazo de hoje ou futuro, ou deixar vazio.
7. Escolher prioridade visual.
8. Salvar.

Resultado esperado:

- Modal mostra loading.
- Documento e criado em `users/{uid}/tasks/{taskId}`.
- Tarefa aparece na lista.

### Criacao invalida

1. Abrir modal de nova tarefa.
2. Tentar salvar sem titulo.
3. Tentar salvar com data invalida.
4. Tentar salvar com data passada.

Resultado esperado:

- Modal exibe erro de validacao.
- Nenhum documento incompleto e salvo.

### Edicao

1. Tocar em uma tarefa existente.
2. Alterar titulo, prazo ou prioridade.
3. Salvar.

Resultado esperado:

- Documento existente e atualizado.
- A tarefa permanece no mesmo usuario.

### Cancelamento

1. Abrir nova tarefa.
2. Preencher dados.
3. Clicar em cancelar ou fechar.

Resultado esperado:

- Dados nao sao salvos.

### Filtros

1. Criar tarefas pendentes e concluidas.
2. Alternar entre filtros "Todas", "Pendentes" e "Concluidas".

Resultado esperado:

- Lista muda conforme filtro.

## Firestore/regras

### Revisao de regras

1. Publicar `firestore.rules`.
2. Criar tarefa com usuario A.
3. Entrar com usuario B.

Resultado esperado:

- Usuario B nao ve tarefas do usuario A.

## Disciplinas

1. Ir para "Suas Disciplinas".
2. Clicar no botao `+`.
3. Criar disciplina com nome.
4. Selecionar dias e horarios.
5. Salvar.

Resultado esperado:

- Disciplina aparece localmente na lista.
- Dados ainda nao persistem depois de reiniciar o app.

## Agenda

1. Ir para agenda.
2. Navegar entre dias.
3. Clicar em botoes de adicionar lembrete e ver grade.

Resultado esperado:

- Calendario responde a selecao.
- Botoes mostram mensagem de fluxo em desenvolvimento.
