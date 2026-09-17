# Il contrasto dell'Arcano dell'Alba, misurato

<!-- TESTI_MISURATI: 8 -->
<!-- SOTTO_LA_SOGLIA: 0 -->
<!-- Generato da test/l_alba_si_legge_test.dart. Non si scrive a mano: si rigenera. -->

Ordine P voce 11: **nessuna correzione prima che questa tabella esista.** Ogni riga e' misurata su un fotogramma vero della schermata, alla misura reale del telefono, 360 per 797 punti logici.

## Come si misura, e perche' cosi'

Il **fondo** non si calcola: si campiona. Il pannello del dono e' un vetro semitrasparente e sfocato sopra una scena di sole, quindi il colore dietro una lettera non e' quello dichiarato dal vetro ne' quello dell'immagine: e' cio' che esce dalla composizione. Si legge il colore PIU' FREQUENTE nella fascia alta del rientro di ogni testo, dove non passa nessuna lettera. La moda e non la media, perche' una lettera che sbordasse nella fascia sposterebbe la media verso l'inchiostro e il contrasto risulterebbe migliore del vero.

Il **file e la riga** si trovano cercando nel sorgente la chiave con cui il testo si presenta a video, non si scrivono a mano.

Il **contrasto** e' il rapporto WCAG di luminanza relativa, calcolato da `AccentoDelMaestro.contrastoFra`, che e' la stessa porta da cui passa il colore degli accenti: due copie della stessa formula divergono.

Le **soglie** vengono da `RegimeChiaro`: 4.5 a 1 per il testo di lettura e di corpo, 3.0 a 1 per i titoli da 24 punti in su o da 19 in grassetto, 4.5 a 1 per le etichette, senza sconti, perche' sono le piu' piccole.

## La tabella

| Testo | Momento | File e riga | Ruolo | Misura | Peso | Inchiostro | Fondo reso | Contrasto | Soglia | Passa |
| --- | --- | --- | --- | ---: | ---: | --- | --- | ---: | ---: | --- |
| `arcano_alba_invito` | prima del gesto | lib/features/rituals/arcano_dell_alba_screen.dart:229 | lettura | 20 | 400 | #F4F1E8 | #010208 | **18.35** | 4.5 | si' |
| `arcano_alba_titolo` | prima del gesto | lib/features/rituals/arcano_dell_alba_screen.dart:212 | titoloScheda | 20 | 600 | #F4F1E8 | #03060F | **17.93** | 3.0 | si' |
| `alba_riga_dono` | a rito compiuto | lib/design_system/components/riga_del_dono.dart:54 | corpo o didascalia | 16 | 400 | #5A94FF | #010208 | **7.02** | 4.5 | si' |
| `arcano_alba_carta` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:418 | cerimoniale | 28 | 600 | #F0D77B | #010208 | **14.52** | 3.0 | si' |
| `arcano_alba_parola` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:428 | cerimonialeGrande | 34 | 700 | #F0D77B | #010208 | **14.52** | 3.0 | si' |
| Pratica una resa gentile verso ... | a rito compiuto | senza chiave | lettura | 20 | 400 | #F4F1E8 | #010208 | **18.35** | 4.5 | si' |
| `arcano_alba_medora` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:444 | lettura | 20 | 400 | #D2D0C9 | #010208 | **13.38** | 4.5 | si' |
| `arcano_alba_titolo` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:212 | titoloScheda | 20 | 600 | #F4F1E8 | #0B0B1B | **17.25** | 3.0 | si' |

Nessun testo sotto la sua soglia.
