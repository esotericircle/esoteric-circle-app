# Censimento dei vuoti verticali

<!-- VUOTI_CENSITI: 147 -->
<!-- FILE_CON_VUOTI: 62 -->
<!-- VUOTI_ECCESSIVI: 3 -->
<!-- Generato da tool/censimento_spazi.dart. Non si scrive a mano: si rigenera. -->

## Cosa misura, e cosa no

Misura i vuoti verticali DICHIARATI nel sorgente: `SizedBox(height: n)` e i riempimenti verticali scritti col numero. Non misura il vuoto che nasce da uno `Spacer`, da un `MainAxisAlignment` o dalla distanza fra due `Positioned`, perche'quello esiste solo a video. Chi legge sa dunque dove il vuoto e' stato SCRITTO, non quanto vuoto la persona vede: sono due domande diverse e questa risponde alla prima.

| Grandezza | Valore |
| --- | --- |
| Vuoti verticali dichiarati | **147** |
| File che ne contengono | **62** |
| Oltre la soglia di 48 punti | **3** |

## Da dove viene la soglia

La soglia NON e' scelta, e' derivata dalla distribuzione qui sotto, come la saturazione dell'oro a 0,50 sta in mezzo al vuoto fra 0,35 e 0,65. I vuoti si addensano sui valori della scala di spaziatura e la coda si assottiglia subito dopo: la soglia sta dove la densita' crolla.

| Punti | Quante volte |
| ---: | ---: |
| 0 | 1 |
| 2 | 80 |
| 3 | 8 |
| 4 | 24 |
| 5 | 1 |
| 6 | 12 |
| 7 | 2 |
| 8 | 6 |
| 9 | 2 |
| 10 | 3 |
| 12 | 1 |
| 16 | 1 |
| 24 | 1 |
| 40 | 1 |
| 44 | 1 |
| 60 | 1 |
| 72 | 1 |
| 90 | 1 |

## I vuoti oltre la soglia

- `lib/features/settings/interruttore_della_misura.dart:61` sizedBox 72 punti
- `lib/features/synastry/sinastria_share_card.dart:132` padding 60 punti
- `lib/features/synastry/sinastria_vip_screen.dart:753` padding 90 punti

## I vuoti, file per file

| File | Vuoti | Oltre soglia |
| --- | ---: | ---: |
| `lib/features/passport/cosmic_passport_screen.dart` | 7 | 0 |
| `lib/features/santuario/daily_strip.dart` | 6 | 0 |
| `lib/features/synastry/sinastria_share_card.dart` | 6 | 1 |
| `lib/features/tarot/tarot_selectors.dart` | 6 | 0 |
| `lib/design_system/components/guida_del_respiro.dart` | 5 | 0 |
| `lib/features/identity/widgets/identity_widgets.dart` | 5 | 0 |
| `lib/features/santuario/santuario_screen.dart` | 5 | 0 |
| `lib/core/diagnosi/racconto_della_corsa.dart` | 4 | 0 |
| `lib/features/horoscope/oroscopo_screen.dart` | 4 | 0 |
| `lib/features/maestri/maestro_screen.dart` | 4 | 0 |
| `lib/features/pricing/pricing_screen.dart` | 4 | 0 |
| `lib/features/shell/santuario_bottom_bar.dart` | 4 | 0 |
| `lib/features/tarot/stesa_tre_carte_screen.dart` | 4 | 0 |
| `lib/features/horoscope/oroscopo_share_card.dart` | 3 | 0 |
| `lib/features/identity/circle_seal_screen.dart` | 3 | 0 |
| `lib/features/maestri/caligo/animal/guide_animal_screen.dart` | 3 | 0 |
| `lib/features/maestri/caligo/rune/rune_share_card.dart` | 3 | 0 |
| `lib/features/onboarding/onboarding_screen.dart` | 3 | 0 |
| `lib/features/santuario/sky_overview_screen.dart` | 3 | 0 |
| `lib/features/sigilli/sentiero_screen.dart` | 3 | 0 |
| `lib/features/tarot/stesa_share_card.dart` | 3 | 0 |
| `lib/features/account/account_screen.dart` | 2 | 0 |
| `lib/features/angels/angels_screen.dart` | 2 | 0 |
| `lib/features/horoscope/answer_depth.dart` | 2 | 0 |
| `lib/features/maestri/aura/archetype/archetype_share_card.dart` | 2 | 0 |
| `lib/features/maestri/aura/archetype/archetype_test_screen.dart` | 2 | 0 |
| `lib/features/maestri/aura/face/face_constellation_screen.dart` | 2 | 0 |
| `lib/features/maestri/aura/face/face_share_card.dart` | 2 | 0 |
| `lib/features/maestri/caligo/animal/guide_animal_share_card.dart` | 2 | 0 |
| `lib/features/maestri/caligo/rune/rune_draw_screen.dart` | 2 | 0 |
| `lib/features/maestri/chat/widgets/chat_bubble.dart` | 2 | 0 |
| `lib/features/maestri/chat/widgets/chat_composer.dart` | 2 | 0 |
| `lib/features/onboarding/risveglio_journey.dart` | 2 | 0 |
| `lib/features/rituals/ritual_gift_card.dart` | 2 | 0 |
| `lib/features/rituals/sunset_rune_card.dart` | 2 | 0 |
| `lib/features/rituals/sunset_rune_screen.dart` | 2 | 0 |
| `lib/features/settings/riga_di_messa_a_punto.dart` | 2 | 0 |
| `lib/features/sigilli/la_mappa_del_sentiero.dart` | 2 | 0 |
| `lib/features/synastry/sinastria_vip_screen.dart` | 2 | 1 |
| `lib/core/permissions/avviso_del_permesso.dart` | 1 | 0 |
| `lib/design_system/components/art_card.dart` | 1 | 0 |
| `lib/design_system/components/borsellino.dart` | 1 | 0 |
| `lib/design_system/components/riga_del_consiglio.dart` | 1 | 0 |
| `lib/features/account/notifiche_screen.dart` | 1 | 0 |
| `lib/features/calendario/calendario_degli_eventi_screen.dart` | 1 | 0 |
| `lib/features/debug/app_check_debug_view.dart` | 1 | 0 |
| `lib/features/intro/sequenza_intro.dart` | 1 | 0 |
| `lib/features/maestri/ask/ask_maestri_screen.dart` | 1 | 0 |
| `lib/features/maestri/aura/meditation/meditation_screen.dart` | 1 | 0 |
| `lib/features/maestri/chat/maestro_chat_screen.dart` | 1 | 0 |
| `lib/features/maestri/chat/widgets/diagnostics_dialog.dart` | 1 | 0 |
| `lib/features/maestri/domain_screen.dart` | 1 | 0 |
| `lib/features/onboarding/natal_chart_reveal.dart` | 1 | 0 |
| `lib/features/onboarding/riquadro_della_scelta.dart` | 1 | 0 |
| `lib/features/rituals/dream_rite_card.dart` | 1 | 0 |
| `lib/features/settings/interruttore_della_misura.dart` | 1 | 1 |
| `lib/features/settings/riga_che_apre.dart` | 1 | 0 |
| `lib/features/settings/settings_screen.dart` | 1 | 0 |
| `lib/features/sigilli/card_del_traguardo.dart` | 1 | 0 |
| `lib/features/sigilli/disegno_del_sentiero.dart` | 1 | 0 |
| `lib/features/synastry/sinastria_gallery_screen.dart` | 1 | 0 |
| `lib/features/tarot/stesa_fan.dart` | 1 | 0 |
