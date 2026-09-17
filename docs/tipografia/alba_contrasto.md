# Il contrasto dell'Arcano dell'Alba, misurato

<!-- TESTI_MISURATI: 13 -->
<!-- SOTTO_LA_SOGLIA: 1 -->
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
| `arcano_alba_invito`, Scegli fra i ventidue arcani co... | prima del gesto | lib/features/rituals/arcano_dell_alba_screen.dart:302 | lettura | 20 | 400 | #F4F1E8 | #474F97 | **6.56** | 4.5 | si' |
| `arcano_alba_mischia`, Mischia | prima del gesto | non trovato nel sorgente | corpo o didascalia | 16 | 400 | #F0D77B | #171A3C | **11.77** | 4.5 | si' |
| `arcano_alba_taglia`, Taglia | prima del gesto | non trovato nel sorgente | corpo o didascalia | 16 | 400 | #F0D77B | #900000 | **6.73** | 4.5 | si' |
| `arcano_alba_titolo` | prima del gesto | lib/features/rituals/arcano_dell_alba_screen.dart:239 | titoloScheda | 20 | 600 | #F4F1E8 | #0F1934 | **15.38** | 3.0 | si' |
| `arcano_alba_invito`, Scegli fra i ventidue arcani co... | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:302 | lettura | 20 | 400 | #F4F1E8 | #131F3F | **14.35** | 4.5 | si' |
| `arcano_alba_faccia`, XII | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:389 | display a misura | 4 | 600 | #F0D77B | #463D2C | **7.49** | 4.5 | si' |
| `arcano_alba_faccia`, L'APPESO | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:389 | display a misura | 4 | 600 | #F0D77B | #03063F | **13.35** | 4.5 | si' |
| `alba_riga_dono` | a rito compiuto | lib/design_system/components/riga_del_dono.dart:54 | corpo o didascalia | 16 | 400 | #5A94FF | #2D3262 | **4.08** | 4.5 | **NO** |
| `arcano_alba_carta` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:421 | cerimoniale | 28 | 600 | #F0D77B | #0E1633 | **12.45** | 3.0 | si' |
| `arcano_alba_parola` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:431 | cerimonialeGrande | 34 | 700 | #F0D77B | #363976 | **7.34** | 3.0 | si' |
| `arcano_alba_dono`, Fai qualcosa di utile tenendolo... | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:438 | lettura | 20 | 400 | #F4F1E8 | #555596 | **5.95** | 4.5 | si' |
| `arcano_alba_medora`, I gesti che restano anonimi son... | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:446 | lettura | 20 | 400 | #DAD7D7 | #3A3A6E | **7.32** | 4.5 | si' |
| `arcano_alba_titolo` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:239 | titoloScheda | 20 | 600 | #F4F1E8 | #151C3B | **14.74** | 3.0 | si' |

## Sotto la soglia

- `alba_riga_dono` (a rito compiuto) a lib/design_system/components/riga_del_dono.dart:54: 4.08 contro 4.5 (#5A94FF su #2D3262, 16 punti)
