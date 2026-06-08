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
textDark: #191820
textMedium: #444444
textLight: #6B6B6B
textMuted: #656565
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

## Padroes de layout

- Telas principais usam `SafeArea`.
- Listas longas usam `SingleChildScrollView`.
- O comportamento global de scroll vem de `AppScrollBehavior`.
- Cards usam fundo `#EFF0FB`, borda arredondada e sombra leve.
- Botoes principais usam roxo com cantos arredondados grandes.

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
```

## Dialogs

Dialogs atuais:

- `TaskDialog`
- `SubjectDialog`
- `ScheduleDialog`

Padrao visual:

- Container branco.
- Borda `#E2E4F0`.
- Raio de 16 ou mais.
- Titulo roxo.
- Campos com borda clara.
- Acoes no rodape.
- Estados de loading/erro dentro do modal quando ha operacao assincrona.

Observacao: `ScheduleDialog` existe como componente, mas a `SchedulePage`
atual usa uma grade mockada e nao abre esse dialog no fluxo principal.

## Observacoes de consistencia

- Evitar chamadas diretas a cores soltas quando ja houver equivalente em `AppColors`.
- Preferir componentes existentes antes de criar novos.
- Novos formularios devem manter validacao clara e mensagens em portugues.
