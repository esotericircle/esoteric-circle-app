# Il contrasto dell'Arcano dell'Alba, misurato

<!-- TESTI_MISURATI: 18 -->
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
| `arcano_alba_richiamo` | prima del gesto | lib/features/rituals/arcano_dell_alba_screen.dart:315 | cerimoniale | 28 | 600 | #D4AF37 | #38407B | **4.57** | 3.0 | si' |
| `arcano_alba_invito`, Scegli fra i ventidue arcani co... | prima del gesto | lib/features/rituals/arcano_dell_alba_screen.dart:322 | lettura | 20 | 400 | #F4F1E8 | #575BA6 | **5.39** | 4.5 | si' |
| `arcano_alba_mischia`, Mischia | prima del gesto | non trovato nel sorgente | display a misura | 16 | 600 | #F0D77B | #2E4080 | **6.81** | 4.5 | si' |
| `arcano_alba_taglia`, Taglia | prima del gesto | non trovato nel sorgente | display a misura | 16 | 600 | #F0D77B | #4857A0 | **4.68** | 4.5 | si' |
| `arcano_alba_titolo` | prima del gesto | lib/features/rituals/arcano_dell_alba_screen.dart:239 | titoloScheda | 20 | 600 | #F4F1E8 | #0F1934 | **15.38** | 3.0 | si' |
| `arcano_alba_richiamo` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:315 | cerimoniale | 28 | 600 | #D4AF37 | #131F3F | **7.71** | 3.0 | si' |
| `arcano_alba_invito`, Scegli fra i ventidue arcani co... | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:322 | lettura | 20 | 400 | #F4F1E8 | #0A1226 | **16.49** | 4.5 | si' |
| `arcano_alba_faccia`, XII | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:441 | display a misura | 3 | 600 | #F0D77B | #5C5962 | **4.81** | 4.5 | si' |
| `arcano_alba_faccia`, L'APPESO | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:441 | display a misura | 4 | 600 | #F0D77B | #050838 | **13.39** | 4.5 | si' |
| `alba_riga_dono` | a rito compiuto | lib/design_system/components/riga_del_dono.dart:54 | corpo o didascalia | 16 | 400 | #5A94FF | #10162F | **6.04** | 4.5 | si' |
| `arcano_alba_carta` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:500 | cerimoniale | 28 | 600 | #F0D77B | #0C1126 | **13.09** | 3.0 | si' |
| `arcano_alba_etichetta_parola` | a rito compiuto | non trovato nel sorgente | display a misura | 16 | 600 | #D4AF37 | #070C1D | **9.25** | 4.5 | si' |
| `arcano_alba_parola` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:518 | cerimonialeGrande | 34 | 700 | #F0D77B | #070C1C | **13.64** | 3.0 | si' |
| `arcano_alba_uso_della_parola` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:525 | lettura | 20 | 400 | #D8D6D0 | #0A1024 | **12.99** | 4.5 | si' |
| `arcano_alba_etichetta_gesto` | a rito compiuto | non trovato nel sorgente | display a misura | 16 | 600 | #D4AF37 | #0D1227 | **8.81** | 4.5 | si' |
| `arcano_alba_dono`, Fai qualcosa di utile tenendolo... | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:538 | lettura | 20 | 400 | #F4F1E8 | #10142A | **16.09** | 4.5 | si' |
| `arcano_alba_medora`, I gesti che restano anonimi son... | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:546 | lettura | 20 | 400 | #D4D2CD | #0C1024 | **12.40** | 4.5 | si' |
| `arcano_alba_titolo` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:239 | titoloScheda | 20 | 600 | #F4F1E8 | #151C3B | **14.74** | 3.0 | si' |

Nessun testo sotto la sua soglia.
