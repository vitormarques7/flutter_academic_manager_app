# Lacunas conhecidas e proximos passos

Este arquivo registra pontos ainda incompletos para evitar confundir mock,
prototipo, fluxo real e melhoria futura.

## Produto e UX

### Metricas academicas

- A Home ja usa dados reais para tarefas, horarios, eventos e notas.
- Frequencia ainda nao e calculada a partir de presencas reais.
- Media geral e media por disciplina usam avaliacoes cadastradas, mas ainda nao
  consideram pesos, recuperacao, tipos de avaliacao ou regras especificas de
  cada instituicao.

Proximo passo recomendado: modelar regras de avaliacao/frequencia antes de
adicionar calculos mais avancados.

### Edicao de entidades complementares

Os fluxos de detalhes de disciplina permitem criar e excluir:

- notas;
- eventos;
- anotacoes.

Ainda falta implementar edicao dessas entidades depois de criadas.

### Lembretes

Ainda nao ha lembretes locais ou notificacoes push para:

- tarefas proximas do prazo;
- eventos proximos;
- horarios de aula;
- rotina de estudo.

## Persistencia e consistencia

### Regras do Firestore

As regras atuais garantem propriedade por usuario, mas nao validam schema.

Melhorias possiveis:

- validar campos obrigatorios por colecao;
- validar tipos;
- validar ranges, como nota entre 0 e 10;
- impedir campos inesperados quando o schema estabilizar.

### Operacoes multi-documento

Alguns fluxos escrevem em mais de uma colecao:

- setup academico cria ciclo, disciplinas e horarios;
- criacao de disciplina pode criar horarios;
- exclusao de disciplina remove horarios vinculados.

Hoje esses fluxos sao executados sequencialmente em services/pages/repository.
Se o produto exigir atomicidade mais forte, avaliar batches ou transactions nos
pontos apropriados.

### Cascatas de exclusao

`deleteDisciplineWithSchedules` remove a disciplina e horarios relacionados,
mas outras entidades relacionadas por `disciplineId` continuam existindo:

- tarefas;
- avaliacoes;
- eventos;
- anotacoes.

Isso pode ser desejado para preservar historico, mas precisa de uma decisao de
produto. Se a escolha for remover tudo, a cascata deve ser ampliada com cuidado.

## Testes automatizados

Estado atual:

- Testes unitarios para models e inputs principais.
- Testes de helpers de data.
- Testes simples para excecoes de repositories.

Proximos testes recomendados:

- Repositories com fake/mock de Firestore e Firebase Auth.
- `AcademicSetupService` com fakes para validar orquestracao.
- `UserDataBootstrapService` para cenarios com e sem ciclo ativo.
- Widget tests para `TaskDialog`, `SubjectDialog` e `ScheduleEditorSheet`.
- Widget tests dos fluxos de configuracao inicial.
- Testes de regressao para troca de ciclo ativo.

## Infraestrutura futura

Possiveis caminhos, ainda nao implementados:

```txt
users/{uid}/activityReminders/{reminderId}
users/{uid}/attendanceRecords/{recordId}
```

Observacao: essas subcolecoes ainda nao existem nas regras locais. Inclua em
`firestore.rules` e documente em `docs/firestore_schema.md` antes de usar.

## Documentacao futura

Manter estes documentos atualizados junto das features:

- `docs/firestore_schema.md` sempre que uma colecao ou campo mudar.
- `docs/data_layer.md` sempre que um repository/service novo for criado.
- `docs/manual_testing.md` sempre que um fluxo de UI mudar.
