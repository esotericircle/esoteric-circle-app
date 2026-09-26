# I DONI, MISURA PER MISURA

Ordine CQ voce 6.01, 4 settembre 2026. **Terza volta che il fondatore lo
chiede**: ordine CO voce 13, poi CQ voce 2.10, ora questa.

**Perche' le prime due volte non e' bastato.** L'ordine CO voce 13 ha alzato la
prosa a diciotto e ha lasciato le etichette a dodici in duecentotre punti
dell'app: il referto stesso lo ha scritto. L'ordine CQ voce 2.11 ha portato le
etichette a quattordici. Tutte e due le volte **e' salito un ruolo alla volta**,
mentre la richiesta era su tutto cio' che si legge dentro i Doni.

Qui salgono **tutti** i ruoli che i cinque Doni usano, e la tavola dice quali
con che numero.

## LA TAVOLA DEI RUOLI

| ruolo | prima | dopo | dove si legge nei Doni |
| --- | ---: | ---: | --- |
| `cerimonialeGrande` | 34 | 34 | la parola del giorno, gia' grande |
| `cerimoniale` | 28 | 28 | il nome dell'Arcano, gia' grande |
| `titoloSezione` | 22 | 22 | i titoli di sezione, gia' grandi |
| **`titoloDiSchermata`** | **20** | **22** | "Alza il telefono verso il cielo", il titolo del Sigillo |
| **`titoloScheda`** | **18** | **20** | il titolo della scheda di ogni Dono |
| **`titoloDiRiga`** | **16** | **17** | le righe di comando, i pulsanti |
| **`lettura`** | **18** | **20** | **il responso**, il testo lungo di tutti e cinque i Doni |
| **`corpo`** | **16** | **17** | il conteggio, le righe di servizio |
| **`didascalia`** | **16** | **17** | la riga di chi parla, le note |
| **`etichetta`** | **14** | **15** | le etichette in maiuscoletto, i cartellini |

**Sette ruoli su dieci salgono.** I tre che restano fermi sono gia' sopra i
ventidue punti, cioe' erano gia' grandi e alzarli ancora spingerebbe i titoli
fuori dalle loro righe senza che nessuno li legga meglio.

## COSA NON SALE, E PERCHE'

**La barra del Santuario resta a dodici.** Ha una costante sua,
`SantuarioBottomBar.misuraDellaVoce`, e non passa da questi ruoli: l'ordine CF
voce 03 le aveva tolto ventidue punti di altezza per far respirare le schermate,
e alzarne il testo gliene restituirebbe otto. La barra non e' un Dono.

## COME SI RIFA' QUESTA MISURA

I numeri stanno tutti in `lib/design_system/tokens/typography_tokens.dart`, un
punto solo. La guardia `test/il_censimento_dei_caratteri_test.dart` conta chi
scavalca i ruoli scrivendosi la misura a mano, che e' il modo in cui un ruolo
alzato qui puo' non arrivare a video.
