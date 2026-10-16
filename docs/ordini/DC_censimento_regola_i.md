# DC.19, IL CENSIMENTO DELLE GUARDIE SOTTO LA REGOLA I

Ordine DC voce 19, 10 settembre 2026. Numeri **misurati**, non stimati.

## Che cosa cerca la Regola I

> Una guardia che sorveglia qualcosa di visibile misura **i pixel dipinti**,
> non i numeri che li generano, e li misura **nella finestra vera** dove quella
> cosa convive con tutto il resto.

Nasce da un difetto mio dell'ordine DB, in due livelli:

1. il loto prometteva il **54 per cento** e ne dipingeva **18**, perche' la
   guardia interrogava la formula invece della forma;
2. riparato, occupava il 54 per cento **del suo riquadro** e il **35 dello
   schermo**, perche' la seconda misura non esisteva.

## I numeri

| | quante |
| --- | ---: |
| Prove che asseriscono su dimensione, posizione, colore, contrasto, sovrapposizione o visibilita' | **212** |
| Di queste, **guardano i pixel dipinti** | **56** |
| Di queste, **interrogano una formula o una scatola** | **156** |

**Come si e' contato.** Una prova e' *visiva* se il suo codice usa `getRect`,
`getSize`, `getCenter`, `localToGlobal`, `getTransformTo`, `overlaps`,
`Rect.from`, `fontSize`, o nomina contrasto, larghezza, altezza,
sovrapposizione. Guarda i *pixel* se usa `toByteData`, `toImageSync`,
`toImage`, `rawRgba`, `PictureRecorder`, `RenderRepaintBoundary` o un golden.

**I commenti si tolgono prima di contare.** Una prova che nomina i pixel in un
commento non li guarda, ed e' la famiglia di difetti piu' frequente di questo
progetto: l'asserzione che pesca il proprio commento.

## Le quarantadue sulle schermate gia' rifiutate

Sono quelle in cui il difetto **ha gia' colpito**, ed e' il sottoinsieme che la
voce 19 chiede di riscrivere.

### Meditazione, il loto respinto due volte, 10

`art_catalog_test.dart`, `corredo_anteprime_test.dart`,
`emblema_di_aura_test.dart`, `il_loto_ha_cinque_fiori_test.dart`,
`la_discesa_arriva_al_punto_test.dart`,
`la_parola_voce_resta_allaudio_test.dart`,
`la_scena_di_attesa_si_vede_test.dart`,
`le_descrizioni_hanno_una_misura_sola_test.dart`,
`tue_arti_schermata_test.dart`, `una_barra_sola_test.dart`

### Costellazione del Viso, i responsi inventati, 15

`due_volti_danno_misure_diverse_test.dart`, `face_screen_test.dart`,
`gli_eos_volano_nel_borsellino_test.dart`, `il_censimento_dei_grigi_test.dart`,
`il_responso_del_viso_non_e_sempre_lo_stesso_test.dart`,
`il_volto_non_si_misura_schiacciato_test.dart`,
`l_invito_porta_il_suo_premio_test.dart`,
`la_figura_della_card_nasce_dalle_misure_test.dart`,
`la_striscia_dei_doni_non_ruba_spazio_test.dart`,
`le_rune_mantengono_le_promesse_test.dart`, `oroscopo_tipografia_test.dart`,
`ronda_dei_motori_test.dart`, `sigillo_schermata_test.dart`,
`sky_overview_test.dart`, `una_festa_alla_volta_test.dart`

### Animale Guida, la funzione buttata li', 4

`il_responso_si_legge_ovunque_test.dart`, `il_riquadro_della_scelta_test.dart`,
`onboarding_test.dart`, `trionfi_dopo_il_numero_test.dart`

### Passaporto, la carta comparsa senza porta, 7

`chi_misura_il_testo_usa_la_scala_test.dart`, `icona_cerchio_test.dart`,
`identita_nascita_test.dart`, `il_passaporto_non_si_copre_test.dart`,
`la_barra_sottile_e_la_casa_unica_test.dart`,
`lo_spazio_dentro_lo_scroll_test.dart`, `santuario_test.dart`

### La barra col cuore e la "i", 6

`barra_arte_non_si_copre_test.dart`, `i_sentieri_non_hanno_il_cuore_test.dart`,
`il_cuore_e_centrato_col_titolo_test.dart`,
`il_cuore_e_il_tooltip_non_si_toccano_test.dart`,
`il_cuore_non_copre_niente_test.dart`,
`il_cuore_sta_sempre_nello_stesso_angolo_test.dart`

## Che cosa e' stato fatto oggi, e che cosa resta

**Scritte nuove sotto la Regola I, tutte sui pixel dipinti:**

| guardia | cosa misura sui pixel |
| --- | --- |
| `la_discesa_riempie_lo_schermo_test.dart` | il tunnel al 100% della scena, l'animale al 67,4% in piena luce, il varco della nebbia che scopre 16.313 pixel |
| `la_rivelazione_non_mente_sul_calcolo_test.dart` | la carta finale al 75,9% dell'altezza, e 576 istanti confrontati col calcolo |
| `il_cuore_e_il_tooltip_non_si_toccano_test.dart` | i due controlli dipinti, misurati **sull'icona e non sull'area di tocco** |

**Gia' riscritta nell'ordine DB**, ed e' quella da cui la Regola I nasce:
`il_loto_riempie_la_scena_test.dart`, che dipinge il loto su una tela e conta
i pixel, **e misura anche la quota sullo schermo e non solo sul riquadro**.

**LE ALTRE RESTANO PER UN ORDINE SUCCESSIVO, e sono trentanove.** Non le
riscrivo oggi, e la ragione va detta invece di nasconderla: **riscriverne
trentanove alla cieca dentro un ordine che ne porta gia' ventuno vorrebbe dire
toccare trentanove reti di protezione in un giorno solo**, senza vedere rossa
nessuna delle zone che proteggono. E' esattamente il modo in cui una guardia
si degrada in silenzio, che e' il difetto da cui il registro delle guardie e'
nato.

**Il secondo livello, dichiarato per ciascuna riscritta**, come la voce 19
chiede:

- `il_loto_riempie_la_scena_test.dart`: **misurava dentro il riquadro**, e da
  sola quella meta' e' costata un giro intero. Adesso monta la scena vera in
  una finestra dove testo e figura si contendono l'altezza.
- `la_discesa_riempie_lo_schermo_test.dart`: nasce gia' con la misura sullo
  schermo, e la prova del tunnel **non guarda un anello solo** ma conta i
  pixel che cambiano fra due stati della scena.
- `la_rivelazione_non_mente_sul_calcolo_test.dart`: misura l'altezza dipinta
  sulla tela intera.
- `il_cuore_e_il_tooltip_non_si_toccano_test.dart`: **la prima stesura
  misurava l'area di tocco**, che in una `Row` e' adiacente per costruzione, e
  accusava un difetto che a video non c'era. Corretta a misurare l'icona.
