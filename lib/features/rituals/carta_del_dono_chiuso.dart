import 'package:flutter/material.dart';

import '../../core/rituals/daily_elements.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **LA CARD DEL DONO CHIUSO.** Ordine DD voce 05, 10 settembre 2026.
///
/// **Cosa l'ordine chiede alla lettera**: *la card chiusa deve dire quando si
/// apre, nel fuso dell'utente*.
///
/// **Perche' una card e non un divieto.** Un Dono che non si apre e basta e'
/// una funzione rotta; un Dono che dice **a che ora** si apre e' un
/// appuntamento, ed e' la differenza fra un'app che ti chiude una porta in
/// faccia e una che ti da' un orario.
///
/// **E il fuso e' quello di chi guarda, senza fare niente.** L'ora arriva gia'
/// calcolata da `FinestraDelDono.quandoSiApre`, che confronta ore locali con un
/// `DateTime` locale: sul telefono e' l'ora del telefono. Non si converte
/// niente, e proprio per questo non si puo' sbagliare la conversione.
///
/// **Nessun vicolo cieco**, che e' legge di casa: da qui si torna indietro con
/// un pulsante vero, e cio' che il Dono dara' e' scritto, cosi' l'attesa ha un
/// oggetto.
class CartaDelDonoChiuso extends StatelessWidget {
  const CartaDelDonoChiuso({
    super.key,
    required this.dono,
    required this.quandoSiApre,
    required this.palette,
  });

  final DailyElement dono;

  /// La frase gia' composta: *Si apre alle 07:00*.
  final String quandoSiApre;

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: Text(dono.title,
            style: TypographyTokens.titoloScheda()
                .copyWith(color: palette.goldSoft)),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded,
                    key: const Key('dono_chiuso_segno'),
                    size: 56,
                    color: palette.goldSoft.withValues(alpha: 0.8)),
                const SizedBox(height: SpacingTokens.md),
                // **L'ORA, GRANDE, ED E' LA COSA PER CUI QUESTA CARD ESISTE.**
                Text(
                  quandoSiApre,
                  key: const Key('dono_chiuso_quando'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.cerimonialeGrande()
                      .copyWith(color: palette.goldSoft),
                ),
                const SizedBox(height: SpacingTokens.sm),
                // **COSA TI DARA', cosi' l'attesa ha un oggetto.** Il testo
                // viene dal Dono e non da qui: e' la stessa riga che la
                // striscia mostra nel suo popup, e due copie divergono.
                // **DALLA PORTA UNICA, non con un Text diretto.** Un testo
                // nel ruolo lettura scritto a mano e' la famiglia delle due
                // porte, e una guardia la sorveglia: da questa porta il muro
                // di testo rientra da solo.
                ParagrafiDiLettura(
                  testo: dono.cosaTiResta,
                  key: const Key('dono_chiuso_cosa_ti_resta'),
                  textAlign: TextAlign.center,
                  stile: TypographyTokens.lettura()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.45),
                ),
                const SizedBox(height: SpacingTokens.lg),
                // **NESSUN VICOLO CIECO.**
                FilledButton(
                  key: const Key('dono_chiuso_indietro'),
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text('Torna al Cerchio',
                      style: TypographyTokens.etichetta()
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
