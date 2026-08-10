# Censimento delle misure tipografiche scritte a mano

<!-- TOTALE_CENSITO: 237 -->
<!-- FILE_CENSITI: 60 -->
<!-- SOTTO_IL_PAVIMENTO: 0 -->
<!-- LETTURA_SOTTO_16: 0 -->
<!-- Generato da tool/censimento_tipografia.dart. Non si scrive a mano: si rigenera. -->

Ogni riga qui sotto e' un punto in cui la misura di un carattere e' decisa a mano invece di venire da un ruolo. Il numero totale puo' solo SCENDERE: `test/tipografia_nel_dato_test.dart` lo rilegge da questo documento e cade se qualcuno ne aggiunge una.

## Il metodo di misura

Si contano due forme, ed e' la stessa cosa vista da due lati: le chiamate ai token con misura esplicita (`TypographyTokens.body(size: 14)`) e i `fontSize:` letterali ovunque compaiano, dentro un `TextStyle`, dentro un `copyWith`, dentro un tema. Le chiamate senza misura, cioe' i ruoli, NON sono debito e non si contano: sono la meta.

Il sorgente si legge INTERO come una stringa sola, non riga per riga, perche' una chiamata spezzata su tre righe e' una misura esplicita come le altre e una ricerca a righe non la vedrebbe mai. E' il difetto della vecchia misura, che si fermava alla riga singola. Se il totale torna piccolo, la prima ipotesi non e' che il debito sia piccolo: e' che la ricerca sia sbagliata.

Il guadagno del metodo non e' dichiarato, e' misurato: confrontando questo elenco con quello di una ricerca a righe sulla stessa base, due punti compaiono solo qui, `lib/design_system/components/guida_del_respiro.dart:251` e `lib/features/santuario/sky_overview_screen.dart:1130`, perche' in tutti e due la misura sta sulla riga sotto al nome del token. Sono pochi oggi e sarebbero molti il giorno che qualcuno riformatta il file.

## I tre numeri

| Grandezza | Valore |
| --- | --- |
| Misure esplicite sotto `lib/` | **237** |
| File che ne contengono | **60** |
| Sotto il pavimento assoluto di 12 | **0** |
| Sotto 16 in contesto di lettura | **0** |

Contesto di lettura vuol dire testo che si legge e non si guarda: la famiglia del corpo (`body`) e i `fontSize` sciolti, che nell'app stanno quasi sempre su testo narrato. Le etichette cerimoniali in maiuscoletto e i titoli restano fuori, perche' li' sotto sedici punti e' una scelta di composizione, non un problema di lettura.

## Dove il pavimento NON arriva, e perche'

Il pavimento vive dentro i token, quindi governa chi passa da loro, e un `TextStyle` costruito a mano gli sfugge per costruzione: nessun assert lo prende, solo questo censimento. Oggi non gli sfugge nessuno, quindi qui sopra non ce n'e' nessun elenco: il rimando a una sezione che non esiste era la prima cosa che questo documento diceva di falso.

L'unico punto che ha DIRITTO di scegliere la propria misura e' l'anello curvo della ruota archetipica (`lib/features/maestri/aura/archetype/archetype_wheel.dart`), dove i dodici nomi si dispongono lungo una circonferenza e la taglia si calcola per farceli stare: nessun ruolo puo' saperlo in anticipo. Quel punto si costruisce lo stile a mano proprio per questo, e la ragione sta scritta accanto al codice.

Le misure PROPORZIONALI a un contenitore (l'iniziale dentro l'avatar, il numero dentro l'emblema) non sono debito ma non sono nemmeno libere: si appoggiano al pavimento con un `math.max`, cosi' un cerchio piccolo non produce una lettera illeggibile. Se l'iniziale non ci sta, il problema e' il cerchio.

## Il debito, file per file

| File | Misure | Sotto 12 | Lettura sotto 16 |
| --- | ---: | ---: | ---: |
| `lib/features/rituals/sunset_rune_screen.dart` | 18 | 0 | 0 |
| `lib/features/maestri/caligo/animal/guide_animal_screen.dart` | 14 | 0 | 0 |
| `lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart` | 11 | 0 | 0 |
| `lib/features/rituals/dream_rite_screen.dart` | 11 | 0 | 0 |
| `lib/features/santuario/sky_overview_screen.dart` | 11 | 0 | 0 |
| `lib/features/account/dati_di_nascita_screen.dart` | 10 | 0 | 0 |
| `lib/features/pricing/pricing_screen.dart` | 10 | 0 | 0 |
| `lib/features/maestri/maestro_screen.dart` | 8 | 0 | 0 |
| `lib/features/passport/cosmic_passport_screen.dart` | 8 | 0 | 0 |
| `lib/features/identity/widgets/identity_widgets.dart` | 7 | 0 | 0 |
| `lib/features/settings/settings_screen.dart` | 7 | 0 | 0 |
| `lib/features/maestri/ask/ask_maestri_screen.dart` | 6 | 0 | 0 |
| `lib/features/synastry/sinastria_vip_screen.dart` | 6 | 0 | 0 |
| `lib/design_system/components/guida_del_respiro.dart` | 5 | 0 | 0 |
| `lib/features/identity/circle_seal_screen.dart` | 5 | 0 | 0 |
| `lib/features/maestri/aura/archetype/archetype_share_card.dart` | 5 | 0 | 0 |
| `lib/features/synastry/sinastria_gallery_screen.dart` | 5 | 0 | 0 |
| `lib/design_system/components/consulto_del_cielo_view.dart` | 4 | 0 | 0 |
| `lib/features/account/account_screen.dart` | 4 | 0 | 0 |
| `lib/features/rituals/breath_destiny_screen.dart` | 4 | 0 | 0 |
| `lib/features/santuario/widgets/tue_arti_view.dart` | 4 | 0 | 0 |
| `lib/core/permissions/app_permission.dart` | 3 | 0 | 0 |
| `lib/features/account/profile_screen.dart` | 3 | 0 | 0 |
| `lib/features/maestri/art_intro_screen.dart` | 3 | 0 | 0 |
| `lib/features/maestri/aura/face/face_share_card.dart` | 3 | 0 | 0 |
| `lib/features/maestri/aura/meditation/meditation_screen.dart` | 3 | 0 | 0 |
| `lib/features/maestri/caligo/rune/rune_share_card.dart` | 3 | 0 | 0 |
| `lib/features/pricing/upgrade_invite.dart` | 3 | 0 | 0 |
| `lib/features/rituals/ritual_gift_card.dart` | 3 | 0 | 0 |
| `lib/features/tarot/stesa_share_card.dart` | 3 | 0 | 0 |
| `lib/core/diagnosi/racconto_della_corsa.dart` | 2 | 0 | 0 |
| `lib/core/permissions/avviso_del_permesso.dart` | 2 | 0 | 0 |
| `lib/design_system/components/feature_sheet.dart` | 2 | 0 | 0 |
| `lib/design_system/components/vip_frame.dart` | 2 | 0 | 0 |
| `lib/features/horoscope/oroscopo_share_card.dart` | 2 | 0 | 0 |
| `lib/features/identity/widgets/birth_companions.dart` | 2 | 0 | 0 |
| `lib/features/maestri/caligo/animal/animal_journey.dart` | 2 | 0 | 0 |
| `lib/features/maestri/caligo/animal/guide_animal_share_card.dart` | 2 | 0 | 0 |
| `lib/features/maestri/chat/widgets/chat_suggestions.dart` | 2 | 0 | 0 |
| `lib/features/passport/specchio_dei_dati.dart` | 2 | 0 | 0 |
| `lib/features/rituals/dawn_rite_screen.dart` | 2 | 0 | 0 |
| `lib/features/rituals/day_oracle_screen.dart` | 2 | 0 | 0 |
| `lib/features/rituals/dream_rite_card.dart` | 2 | 0 | 0 |
| `lib/features/rituals/ritual_view.dart` | 2 | 0 | 0 |
| `lib/features/rituals/sunset_rune_card.dart` | 2 | 0 | 0 |
| `lib/features/synastry/sinastria_share_card.dart` | 2 | 0 | 0 |
| `lib/features/tarot/tarot_card_art.dart` | 2 | 0 | 0 |
| `lib/design_system/components/art_card.dart` | 1 | 0 | 0 |
| `lib/design_system/components/feature_tile.dart` | 1 | 0 | 0 |
| `lib/design_system/components/interruttore_del_cerchio.dart` | 1 | 0 | 0 |
| `lib/design_system/components/riga_del_dono.dart` | 1 | 0 | 0 |
| `lib/design_system/components/section_title.dart` | 1 | 0 | 0 |
| `lib/features/angels/angelo_ingrandito.dart` | 1 | 0 | 0 |
| `lib/features/debug/app_check_debug_view.dart` | 1 | 0 | 0 |
| `lib/features/home/widgets/demo_controls.dart` | 1 | 0 | 0 |
| `lib/features/maestri/chat/widgets/chat_empty_state.dart` | 1 | 0 | 0 |
| `lib/features/maestri/chat/widgets/diagnostics_dialog.dart` | 1 | 0 | 0 |
| `lib/features/maestri/domain_screen.dart` | 1 | 0 | 0 |
| `lib/features/onboarding/widgets/stardust_name.dart` | 1 | 0 | 0 |
| `lib/features/tarot/tarot_cartiglio.dart` | 1 | 0 | 0 |

