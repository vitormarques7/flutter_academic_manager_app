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

## Cores

Arquivo:

```txt
lib/config/theme/app_colors.dart
```

Cores principais:

```txt
primary: #514EB6
background: #F8F9FF
surface: #FFFFFF
surfaceAlt: #F4F5FD
textDark: #191820
textMedium: #444444
textLight: #6B6B6B
textMuted: #656565
danger: vermelho de alerta
```

## Tipografia

Arquivo:

```txt
lib/config/theme/app_text_styles.dart
```

Estilos principais:

- `headline1`: 40, bold.
- `headline2`: 32, bold.
- `headline3`: 24, bold.
- `bodyBold`: 16, bold.
- `bodyRegular`: 16, medium.
- `button`: 24, medium.
- `sectionLabel`: 12, bold, caps lock.

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
