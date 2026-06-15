# Sistema visual

O app usa uma identidade visual clara, com roxo como cor primaria e fundo claro.

## Tema

Arquivo principal:

```txt
lib/config/theme/app_theme.dart
```

O tema global define:

- Fonte `Roboto`.
- `ColorScheme` baseado em `AppColors.primary`.
- Tema de inputs.
- Tema de botoes elevados.
- `useMaterial3: true`.

## Cores e Tema Adaptativo

O app suporta tema claro e escuro usando a extensão de tema `AppThemeColors`. Componentes migrados para o tema adaptativo resolvem cores via `context.appColors`.

Cores principais do sistema visual:

- **primary**: Roxo institucional (#514EB6 no tema claro, #7774E8 no tema escuro).
- **background**: Fundo de telas (#F7F8FD no claro, #10121A no escuro).
- **surface**: Fundo de cards/sheets (#FFFFFF no claro, #181B25 no escuro).
- **textDark**: Cor para títulos e texto de alto contraste (#191820 no claro, #F4F6FF no escuro).
- **textMedium**: Texto principal de contraste médio (#3E3D4A no claro, #D8DBEA no escuro).
- **textLight** / **textMuted**: Texto de menor peso (#6B6F80 no claro, #B7BCCF / #A2A8BC no escuro).
- **success**: Verde usado para tarefas e estados positivos (#16834A no claro, #65D994 no escuro).
- **event**: Rosa/vermelho usado para eventos da disciplina (#DB2777 no claro, #FFFF8ABE no escuro).
- **danger**: Vermelho para erros e exclusão (#B42318 no claro, #FF8580 no escuro).

## Tipografia

Arquivo:

```txt
lib/config/theme/app_text_styles.dart
```

Estilos principais (Roboto):

- `headline1`: 36, w900 (bold ultra-pesado).
- `headline2`: 28, w900 (bold ultra-pesado).
- `headline3`: 22, w800.
- `bodyBold`: 16, w800.
- `bodyRegular`: 16, w500 (medium).
- `button`: 24, w500.
- `sectionLabel`: 12, w700, caps lock (espaçamento de 0.7).
- `navLabel`: 12, w500.
- `cardTitle`: 24, w700.


## Tokens visuais

Arquivo:

```txt
lib/config/theme/app_design_tokens.dart
```

Use tokens compartilhados para:

- raios;
- sombras;
- espacamentos;
- bordas;
- superficies.

## Padroes de layout

- Telas principais usam `SafeArea`.
- Listas longas usam `SingleChildScrollView`.
- O comportamento global de scroll vem de `AppScrollBehavior`.
- Cards usam superficies claras, bordas suaves e sombra leve.
- Botoes principais usam roxo com cantos arredondados grandes.
- Estados vazios usam `EmptyStateCard`.
- Containers de area de conteudo devem preferir `AppSurface` quando fizer
  sentido.

## Componentes comuns

```txt
PageHeader
SectionLabel
FloatingAddButton
AppBottomNavBar
PrimaryButton
CancelButton
SecondaryButton
SearchField
SummaryMetricTile
ListSectionHeader
MetadataChip
EmptyStateCard
AppSurface
```

## Dialogs e sheets

Dialogs/sheets principais:

- `TaskDialog`
- `SubjectDialog`
- `ScheduleDialog`
- `ScheduleEventDialog`
- `ScheduleEditorSheet`
- Dialogs internos de nota, evento e anotacao em `SubjectDetailsPage`
- Sheets internos de ciclo em `HomePage` e `PersonalDataPage`

Padrao visual:

- Container claro.
- Borda leve.
- Raio consistente com os tokens.
- Titulo em destaque.
- Campos com borda clara.
- Acoes no rodape.
- Estados de loading/erro dentro do modal quando ha operacao assincrona.

Observacao: `ScheduleDialog` e usado no setup academico. A edicao da grade na
agenda usa `ScheduleEditorSheet`, que abre dialogs internos para criar/editar
horarios reais em `users/{uid}/schedules`.

## Observacoes de consistencia

- Evitar chamadas diretas a cores soltas quando ja houver equivalente em
  `AppColors`.
- Preferir componentes existentes antes de criar novos.
- Novos formularios devem manter validacao clara e mensagens em portugues.
- Novas telas devem tratar loading, erro e estado vazio.
- Se um widget usa dados em tempo real, mantenha o estado visual previsivel
  durante reconnect/loading do Firestore.
