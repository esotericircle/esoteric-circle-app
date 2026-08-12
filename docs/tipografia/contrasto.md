# Il censimento del contrasto

<!-- COPPIE_CENSITE: 85 -->
<!-- SOTTO_IL_CONTRASTO: 8 -->
<!-- Generato da tool/censimento_contrasto.dart. Non si scrive a mano: si rigenera. -->

Ordine P voce 14. Il censimento tipografico misura le DIMENSIONI e non vede questo difetto: `SOTTO_IL_PAVIMENTO: 0` resta vero mentre un testo e' illeggibile. Un testo a 18 punti in oro su avorio si legge peggio di uno a 14 in bianco su nero.

Il numero `SOTTO_IL_CONTRASTO` puo' solo SCENDERE: `test/tipografia_nel_dato_test.dart` lo rilegge da qui e cade se cresce. Stessa logica a cricchetto degli altri censimenti.

## Cosa entra nel conto, e cosa no

Entra ogni coppia INCHIOSTRO su SUPERFICIE che i token possono produrre, letta dai file dei token e non da un elenco scritto a mano: lib/design_system/tokens/color_tokens.dart, lib/design_system/tokens/regime_chiaro.dart. Un inchiostro si misura sulle superfici della sua famiglia cromatica, perche' il blu di Medora non compare mai sotto il rosso di Caligo.

**NON entra cio' che nasce a runtime**: un accento composto da `AccentoDelMaestro`, un'opacita' applicata dentro un widget, un vetro semitrasparente sopra una fotografia. Quei colori non stanno nei token e nessuna lettura statica li vede. Per loro esiste la misura sul fotogramma vero, `docs/tipografia/alba_contrasto.md`, che campiona il fondo RESO. Le due misure sono complementari, e credere che questa sola basti sarebbe il difetto di prima con un documento in piu'.

## I due numeri

| Grandezza | Valore |
| --- | ---: |
| Coppie censite | **85** |
| Sotto 4.5 a 1 | **8** |

## Le coppie, dalla peggiore alla migliore

| Inchiostro | Superficie | Contrasto | Passa |
| --- | --- | ---: | --- |
| `goldDeep` | `auraSurface` | 3.12 | **NO** |
| `textMuted` | `auraSurface` | 3.23 | **NO** |
| `goldDeep` | `caligoSurface` | 3.70 | **NO** |
| `textMuted` | `caligoSurface` | 3.83 | **NO** |
| `goldDeep` | `auraDeep` | 4.06 | **NO** |
| `goldDeep` | `medoraSurface` | 4.15 | **NO** |
| `textMuted` | `auraDeep` | 4.19 | **NO** |
| `textMuted` | `medoraSurface` | 4.29 | **NO** |
| `goldDeep` | `caligoDeep` | 4.60 | si' |
| `goldDeep` | `neutralSurface` | 4.60 | si' |
| `textMuted` | `caligoDeep` | 4.75 | si' |
| `textMuted` | `neutralSurface` | 4.76 | si' |
| `goldDeep` | `medoraDeep` | 4.80 | si' |
| `textMuted` | `medoraDeep` | 4.97 | si' |
| `goldDeep` | `auraDeepest` | 4.97 | si' |
| `textMuted` | `auraDeepest` | 5.14 | si' |
| `goldDeep` | `medoraDeepest` | 5.16 | si' |
| `goldDeep` | `caligoDeepest` | 5.19 | si' |
| `goldDeep` | `neutralDeep` | 5.24 | si' |
| `textMuted` | `medoraDeepest` | 5.33 | si' |
| `textMuted` | `caligoDeepest` | 5.36 | si' |
| `textMuted` | `neutralDeep` | 5.41 | si' |
| `goldDeep` | `neutralDeepest` | 5.45 | si' |
| `textMuted` | `neutralDeepest` | 5.63 | si' |
| `gold` | `auraSurface` | 5.65 | si' |
| `textSecondary` | `auraSurface` | 6.68 | si' |
| `gold` | `caligoSurface` | 6.69 | si' |
| `gold` | `auraDeep` | 7.34 | si' |
| `gold` | `medoraSurface` | 7.50 | si' |
| `testoSuChiaro` | `superficieChiara` | 7.84 | si' |
| `textSecondary` | `caligoSurface` | 7.91 | si' |
| `gold` | `caligoDeep` | 8.32 | si' |
| `goldLight` | `auraSurface` | 8.32 | si' |
| `gold` | `neutralSurface` | 8.32 | si' |
| `textSecondary` | `auraDeep` | 8.67 | si' |
| `gold` | `medoraDeep` | 8.69 | si' |
| `textSecondary` | `medoraSurface` | 8.87 | si' |
| `gold` | `auraDeepest` | 8.99 | si' |
| `gold` | `medoraDeepest` | 9.33 | si' |
| `gold` | `caligoDeepest` | 9.39 | si' |
| `gold` | `neutralDeep` | 9.48 | si' |
| `goldBright` | `auraSurface` | 9.57 | si' |
| `textSecondary` | `caligoDeep` | 9.83 | si' |
| `textSecondary` | `neutralSurface` | 9.84 | si' |
| `gold` | `neutralDeepest` | 9.85 | si' |
| `goldLight` | `caligoSurface` | 9.86 | si' |
| `textSecondary` | `medoraDeep` | 10.28 | si' |
| `textPrimary` | `auraSurface` | 10.52 | si' |
| `textSecondary` | `auraDeepest` | 10.63 | si' |
| `goldLight` | `auraDeep` | 10.81 | si' |
| `textSecondary` | `medoraDeepest` | 11.03 | si' |
| `goldLight` | `medoraSurface` | 11.05 | si' |
| `textSecondary` | `caligoDeepest` | 11.10 | si' |
| `textSecondary` | `neutralDeep` | 11.20 | si' |
| `goldBright` | `caligoSurface` | 11.34 | si' |
| `textSecondary` | `neutralDeepest` | 11.65 | si' |
| `goldLight` | `caligoDeep` | 12.25 | si' |
| `goldLight` | `neutralSurface` | 12.26 | si' |
| `goldBright` | `auraDeep` | 12.43 | si' |
| `textPrimary` | `caligoSurface` | 12.46 | si' |
| `goldBright` | `medoraSurface` | 12.71 | si' |
| `goldLight` | `medoraDeep` | 12.81 | si' |
| `goldLight` | `auraDeepest` | 13.24 | si' |
| `textPrimary` | `auraDeep` | 13.66 | si' |
| `goldLight` | `medoraDeepest` | 13.74 | si' |
| `goldLight` | `caligoDeepest` | 13.83 | si' |
| `goldLight` | `neutralDeep` | 13.96 | si' |
| `textPrimary` | `medoraSurface` | 13.97 | si' |
| `goldBright` | `caligoDeep` | 14.09 | si' |
| `goldBright` | `neutralSurface` | 14.10 | si' |
| `goldLight` | `neutralDeepest` | 14.52 | si' |
| `goldBright` | `medoraDeep` | 14.72 | si' |
| `goldBright` | `auraDeepest` | 15.23 | si' |
| `textPrimary` | `caligoDeep` | 15.49 | si' |
| `textPrimary` | `neutralSurface` | 15.50 | si' |
| `goldBright` | `medoraDeepest` | 15.80 | si' |
| `goldBright` | `caligoDeepest` | 15.90 | si' |
| `goldBright` | `neutralDeep` | 16.05 | si' |
| `textPrimary` | `medoraDeep` | 16.19 | si' |
| `goldBright` | `neutralDeepest` | 16.69 | si' |
| `textPrimary` | `auraDeepest` | 16.74 | si' |
| `textPrimary` | `medoraDeepest` | 17.37 | si' |
| `textPrimary` | `caligoDeepest` | 17.48 | si' |
| `textPrimary` | `neutralDeep` | 17.64 | si' |
| `textPrimary` | `neutralDeepest` | 18.35 | si' |
