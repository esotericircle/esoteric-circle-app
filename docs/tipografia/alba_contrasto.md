# Il contrasto dell'Arcano dell'Alba, misurato

<!-- TESTI_MISURATI: 25 -->
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
| `alba_invito_al_gesto` | prima del sole | non trovato nel sorgente | lettura | 20 | 400 | #F0D77B | #0C1A2E | **12.23** | 4.5 | si' |
| `arcano_alba_titolo` | prima del sole | lib/features/rituals/arcano_dell_alba_screen.dart:362 | titoloScheda | 20 | 600 | #F4F1E8 | #06101C | **16.92** | 3.0 | si' |
| `arcano_alba_richiamo` | prima del gesto | lib/features/rituals/arcano_dell_alba_screen.dart:445 | cerimoniale | 28 | 600 | #D4AF37 | #2F376E | **5.28** | 3.0 | si' |
| `arcano_alba_invito`, Scegli fra i ventidue arcani co... | prima del gesto | lib/features/rituals/arcano_dell_alba_screen.dart:452 | lettura | 20 | 400 | #F4F1E8 | #595DA8 | **5.23** | 4.5 | si' |
| `arcano_alba_mischia`, Mischia | prima del gesto | non trovato nel sorgente | display a misura | 16 | 600 | #F0D77B | #3F5099 | **5.22** | 4.5 | si' |
| `arcano_alba_taglia`, Taglia | prima del gesto | non trovato nel sorgente | display a misura | 16 | 600 | #F0D77B | #4555A1 | **4.80** | 4.5 | si' |
| `arcano_alba_titolo` | prima del gesto | lib/features/rituals/arcano_dell_alba_screen.dart:362 | titoloScheda | 20 | 600 | #F4F1E8 | #0E1832 | **15.55** | 3.0 | si' |
| `arcano_alba_richiamo` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:445 | cerimoniale | 28 | 600 | #D4AF37 | #111C3A | **7.98** | 3.0 | si' |
| `arcano_alba_invito`, Scegli fra i ventidue arcani co... | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:452 | lettura | 20 | 400 | #F4F1E8 | #0B1328 | **16.34** | 4.5 | si' |
| `arcano_alba_faccia`, XII | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:600 | display a misura | 3 | 600 | #F0D77B | #372817 | **9.95** | 4.5 | si' |
| `arcano_alba_faccia`, L'APPESO | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:600 | display a misura | 4 | 600 | #F0D77B | #050839 | **13.37** | 4.5 | si' |
| `alba_riga_dono` | a rito compiuto | lib/design_system/components/riga_del_dono.dart:54 | corpo o didascalia | 16 | 400 | #5A94FF | #0A1125 | **6.35** | 4.5 | si' |
| `arcano_alba_titolo_risposta` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:775 | cerimoniale | 28 | 600 | #F0D77B | #080E20 | **13.45** | 3.0 | si' |
| `arcano_alba_carta` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:787 | titoloScheda | 18 | 600 | #F0D77B | #080E1F | **13.46** | 4.5 | si' |
| `arcano_alba_etichetta_parola` | a rito compiuto | non trovato nel sorgente | display a misura | 16 | 600 | #F0D77B | #0C1126 | **13.09** | 4.5 | si' |
| `arcano_alba_parola` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:808 | cerimonialeGrande | 34 | 700 | #F0D77B | #0F142A | **12.75** | 3.0 | si' |
| `arcano_alba_uso_della_parola`, Tienila a mente quando devi sce... | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:817 | lettura | 20 | 400 | #D9D7D1 | #10152C | **12.48** | 4.5 | si' |
| `arcano_alba_etichetta_gesto` | a rito compiuto | non trovato nel sorgente | display a misura | 16 | 600 | #F0D77B | #090E1F | **13.44** | 4.5 | si' |
| `arcano_alba_dono`, Fai in segreto una cosa utile p... | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:677 | lettura | 20 | 400 | #F4F1E8 | #080D1E | **17.11** | 4.5 | si' |
| `arcano_alba_etichetta_perche` | a rito compiuto | non trovato nel sorgente | display a misura | 16 | 600 | #F0D77B | #070C1C | **13.64** | 4.5 | si' |
| `arcano_alba_perche`, Fare bene senza pubblico ti mos... | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:691 | lettura | 20 | 400 | #D8D6D0 | #080D1E | **13.25** | 4.5 | si' |
| `arcano_alba_pannello`, Condividi | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:502 | display a misura | 16 | 600 | #F0D77B | #090E20 | **13.43** | 4.5 | si' |
| `arcano_alba_pannello`, Segna nel Diario | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:502 | display a misura | 16 | 600 | #F0D77B | #0A0F20 | **13.35** | 4.5 | si' |
| `arcano_alba_pannello`, Parlane con Medora | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:502 | display a misura | 16 | 600 | #F4F1E8 | #2E4CA6 | **6.89** | 4.5 | si' |
| `arcano_alba_titolo` | a rito compiuto | lib/features/rituals/arcano_dell_alba_screen.dart:362 | titoloScheda | 20 | 600 | #F4F1E8 | #151C3B | **14.74** | 3.0 | si' |

Nessun testo sotto la sua soglia.
