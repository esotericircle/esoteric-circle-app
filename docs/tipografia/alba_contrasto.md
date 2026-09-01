# Il contrasto del Rito dell'Alba, misurato

<!-- TESTI_MISURATI: 10 -->
<!-- SOTTO_LA_SOGLIA: 0 -->
<!-- Generato da test/l_alba_si_legge_test.dart. Non si scrive a mano: si rigenera. -->

Ordine P voce 11: **nessuna correzione prima che questa tabella esista.** Ogni riga e' misurata su un fotogramma vero della schermata, alla misura reale del telefono, 360 per 797 punti logici.

## Come si misura, e perche' cosi'

Il **fondo** non si calcola: si campiona. Il pannello del dono e' un vetro semitrasparente e sfocato sopra una scena di sole, quindi il colore dietro una lettera non e' quello dichiarato dal vetro ne' quello dell'immagine: e' cio' che esce dalla composizione. Si legge il colore PIU' FREQUENTE nella fascia alta del rientro di ogni testo, dove non passa nessuna lettera. La moda e non la media, perche' una lettera che sbordasse nella fascia sposterebbe la media verso l'inchiostro e il contrasto risulterebbe migliore del vero.

Il **file e la riga** si trovano cercando nel sorgente la chiave con cui il testo si presenta a video, non si scrivono a mano.

Il **contrasto** e' il rapporto WCAG di luminanza relativa, calcolato da `AccentoDelMaestro.contrastoFra`, che e' la stessa porta da cui passa il colore degli accenti: due copie della stessa formula divergono.

Le **soglie** vengono da `RegimeChiaro`: 4.5 a 1 per il testo di lettura e di corpo, 3.0 a 1 per i titoli da 24 punti in su o da 19 in grassetto, 4.5 a 1 per le etichette, senza sconti, perche' sono le piu' piccole.

## La tabella

| Testo | File e riga | Ruolo | Misura | Peso | Inchiostro | Fondo reso | Contrasto | Soglia | Passa |
| --- | --- | --- | ---: | ---: | --- | --- | ---: | ---: | --- |
| `alba_riga_dono` | lib/design_system/components/riga_del_dono.dart:54 | corpo o didascalia | 16 | 400 | #084F3B | #DCDED2 | **6.99** | 4.5 | si' |
| `alba_orientamento` | lib/features/rituals/ritual_gift_card.dart:172 | lettura | 18 | 400 | #2A2213 | #DCDED2 | **11.54** | 4.5 | si' |
| `alba_etichetta_parola` | lib/features/rituals/ritual_gift_card.dart:201 | corpo o didascalia | 16 | 400 | #554627 | #D0D5CB | **6.10** | 4.5 | si' |
| `alba_perche_della_parola` | lib/features/rituals/ritual_gift_card.dart:222 | corpo o didascalia | 16 | 400 | #2A2213 | #DEDFD3 | **11.67** | 4.5 | si' |
| `alba_base_toggle` | lib/features/rituals/ritual_gift_card.dart:352 | corpo o didascalia | 16 | 400 | #084F3B | #F8F4E3 | **8.63** | 4.5 | si' |
| `alba_base_etichetta_perché_questo_rito` | lib/features/rituals/ritual_gift_card.dart:474 | corpo o didascalia | 16 | 400 | #554627 | #E5E1D1 | **6.96** | 4.5 | si' |
| `alba_base_valore_perché_questo_rito` | lib/features/rituals/ritual_gift_card.dart:489 | corpo o didascalia | 16 | 400 | #2A2213 | #CBCDC2 | **9.76** | 4.5 | si' |
| `alba_base_etichetta_ancora_natale` | lib/features/rituals/ritual_gift_card.dart:474 | corpo o didascalia | 16 | 400 | #554627 | #C2C6BD | **5.26** | 4.5 | si' |
| `alba_base_valore_ancora_natale` | lib/features/rituals/ritual_gift_card.dart:489 | corpo o didascalia | 16 | 400 | #2A2213 | #CDCEC2 | **9.88** | 4.5 | si' |
| `alba_titolo` | lib/features/rituals/dawn_rite_screen.dart:514 | titoloScheda | 20 | 600 | #F4F1E8 | #0A0F17 | **17.00** | 3.0 | si' |

Nessun testo sotto la sua soglia.
