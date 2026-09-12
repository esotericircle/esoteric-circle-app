import 'package:flutter/material.dart';

import '../../core/synastry/cielo_della_sinastria.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../design_system/components/vip_frame.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// LA CARTA DEL VIP SI APRE AL TOCCO. Ordine BO voce 08.
///
/// **Parole del fondatore**: "la Carta vip deve essere ingrandibile al click".
/// Era il difetto 2, e la ricognizione lo ha confermato: nella schermata della
/// Sinastria il ritratto del VIP era l'unica cosa a non rispondere al dito.
///
/// **NESSUN VOLTO REALE VIENE ANIMATO**, vincolo V3: il ritratto si apre e sta
/// fermo, si muove soltanto la luce che gli passa sopra.
Future<void> mostraIlRitrattoIngrandito(
  BuildContext context, {
  required Vip vip,
  required MaestroPalette palette,
}) {
  final riduciMovimento = MediaQuery.of(context).disableAnimations;
  return dialogoGeneraleDelCerchio<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Chiudi la carta',
    barrierColor: Colors.black.withValues(alpha: 0.78),
    transitionDuration:
        riduciMovimento ? Duration.zero : const Duration(milliseconds: 380),
    pageBuilder: (context, entrata, uscita) => RitrattoIngrandito(
      vip: vip,
      palette: palette,
      entrata: entrata,
      riduciMovimento: riduciMovimento,
      // Il fondo e' il velo: qui non c'e' nessuna superficie di Material da
      // vestire, e dirlo e' cio' che l'enumerazione delle porte pretende.
      backgroundColor: Colors.transparent,
    ),
  );
}

/// La scena del ritratto aperto.
class RitrattoIngrandito extends StatelessWidget {
  const RitrattoIngrandito({
    super.key,
    required this.vip,
    required this.palette,
    required this.entrata,
    required this.riduciMovimento,
    this.backgroundColor = Colors.transparent,
  });

  final Vip vip;
  final MaestroPalette palette;
  final Animation<double> entrata;
  final bool riduciMovimento;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final larghezza = MediaQuery.of(context).size.width;
    final larga = (larghezza * 0.78).clamp(180.0, 420.0);
    // **IL MATERIAL, ordine BV voce 01, stessa causa della carta ingrandita.**
    // Senza un Material fra gli antenati, ogni testo di questa rotta ricade
    // sul DefaultTextStyle di sistema e prende la sottolineatura doppia e
    // gialla. Il tipo e' transparency: serve lo stile, non una superficie, e
    // il fondo deve restare il velo.
    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: backgroundColor,
        child: Semantics(
          label: 'La carta di ${vip.name} aperta, tocca fuori per chiudere',
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            // IL TRASCINAMENTO VERSO IL BASSO, terza uscita.
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0) > 200) {
                Navigator.of(context).maybePop();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _laFigura(larga),
                      const SizedBox(height: SpacingTokens.md),
                      Text(vip.name.toUpperCase(),
                          key: const Key('ritratto_nome'),
                          textAlign: TextAlign.center,
                          style: TypographyTokens.titoloScheda().copyWith(
                              color: palette.goldSoft, letterSpacing: 1.2)),
                      if (vip.hasCategory) ...[
                        const SizedBox(height: SpacingTokens.xxs),
                        Text(vip.category,
                            key: const Key('ritratto_categoria'),
                            style: TypographyTokens.didascalia()
                                .copyWith(color: ColorTokens.textSecondary)),
                      ],
                      const SizedBox(height: SpacingTokens.sm),
                      Text(_laRigaDellaNascita(),
                          key: const Key('ritratto_nascita'),
                          textAlign: TextAlign.center,
                          style: TypographyTokens.corpo()
                              .copyWith(color: ColorTokens.textPrimary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// **Data e luogo, e nient'altro che sia stato inventato.** Il luogo c'e'
  /// per tutti e cinquanta col dossier della voce BO.01; se un giorno
  /// mancasse, la riga porta la sola data invece di una frase di circostanza.
  String _laRigaDellaNascita() {
    final luogo = vip.luogoDiNascita;
    if (luogo == null) return vip.note;
    return '${vip.note}, ${luogo.esteso}';
  }

  Widget _laFigura(double larga) {
    final figura = SizedBox(
      key: const Key('ritratto_figura'),
      width: larga,
      // **IL RAPPORTO E' QUELLO DELL'ARTWORK, ordine CF voce 12.**
      //
      // **Rilievo del fondatore, verbatim**: "nella sinastria vip se
      // ingrandisco la Carta del vip, questa e' schiacciata
      // verticalmente". Aveva ragione, e il numero e' esatto: il
      // riquadro imponeva 0,78, lo `Stack` con `StackFit.expand` passava
      // vincoli STRETTI ai figli, e sotto vincoli stretti l'`AspectRatio`
      // a 2 su 3 di `VipFrame` non poteva cambiare misura, quindi il suo
      // rapporto veniva ignorato. Con `BoxFit.fill` l'immagine si
      // stirava: l'altezza giusta e' 1,5 volte la larghezza, quella
      // reale era 1,282, cioe' **una compressione verticale del 14,53
      // per cento**.
      //
      // **Adesso il numero non si scrive piu': si legge da `VipFrame`**,
      // che e' l'unico posto dove il rapporto dell'artwork e' dichiarato.
      height: larga / VipFrame.aspect,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // **LA CARTA INGRANDITA PORTA I SUOI CARTIGLI. Ordine CC voce
            // 06i.**
            //
            // Rilievo del fondatore, 29 agosto 2026, verbatim: "quando
            // ingrandisco la Carta del vip, i testi nei cartigli della carta
            // spariscono".
            //
            // **Aveva ragione, e la causa e' una regola del progetto.** Gli
            // artwork dei VIP hanno i cartigli VUOTI: il nome e la data si
            // posano a runtime, cosi' un set solo di immagini vale per tutte
            // le lingue. Qui si montava `Image.asset` nudo, cioe' l'arte senza
            // chi la posa: la cornice c'era e i cartigli restavano bianchi.
            //
            // `VipFramedPortrait` e' il componente che quei due testi li
            // scrive, ed e' lo stesso che la porta della Sinastria e la card
            // da condividere usano gia': una porta sola per i cartigli.
            VipFramedPortrait(
              palette: palette,
              name: vip.name,
              date: vip.note,
              sign: vip.sign.symbol,
              vipAsset: vip.hasImage ? vip.fullPath : null,
            ),
            // LA LUCE, l'unica cosa che si muove sul ritratto.
            IgnorePointer(
              child: AnimatedBuilder(
                animation: entrata,
                builder: (context, _) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1 + entrata.value * 2, -1),
                      end: Alignment(entrata.value * 2, 1),
                      colors: [
                        Colors.transparent,
                        palette.goldSoft.withValues(alpha: 0.20),
                        Colors.transparent,
                      ],
                      stops: const [0.35, 0.5, 0.65],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (riduciMovimento) return figura;
    return AnimatedBuilder(
      animation: entrata,
      builder: (context, child) => Opacity(
        opacity: entrata.value,
        child:
            Transform.scale(scale: 0.92 + 0.08 * entrata.value, child: child),
      ),
      child: figura,
    );
  }
}

/// LA LETTURA SI ESPLORA. Ordine BO voce 08.
///
/// **Invece di leggere un muro di testo**, si tocca il filo dell'aspetto e si
/// apre cosa significa. Il testo mostrato non e' scritto qui: e'
/// `AspettoDiSinastria.fatto` e `AspettoDiSinastria.significato`, gli stessi
/// oggetti da cui nasce il responso. Due testi scritti in due posti per la
/// stessa cosa divergono al primo che ne cambia uno.
Future<void> mostraIlSignificatoDellAspetto(
  BuildContext context, {
  required AspettoDiSinastria aspetto,
  required MaestroPalette palette,
}) {
  return foglioDelCerchio<void>(
    context: context,
    backgroundColor: palette.surface,
    builder: (context) => Padding(
      key: const Key('sinastria_significato'),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg,
          SpacingTokens.lg, SpacingTokens.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(aspetto.titolo.toUpperCase(),
              key: const Key('sinastria_significato_titolo'),
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 1.4)),
          const SizedBox(height: SpacingTokens.xs),
          // **QUI IL TRANSITO SI DICE PER INTERO, col nome e col verbo.**
          // Ordine CC voce 06h. Il fondatore l'ha scritto cosi': "deve
          // esserci il nome: "il mercurio di Fedez e' in sestile con la tua
          // venere"". `fatto` vive dentro una frase piu' lunga e li' il verbo
          // sarebbe di troppo; qui la riga sta da sola.
          ParagrafiDiLettura(
              key: const Key('sinastria_significato_fatto'),
              testo: aspetto.laFrase,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary)),
          const SizedBox(height: SpacingTokens.xs),
          Text('A ${aspetto.gradi} dall\'angolo esatto.',
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary)),
          const SizedBox(height: SpacingTokens.sm),
          ParagrafiDiLettura(
            key: const Key('sinastria_significato_testo'),
            testo: aspetto.significato,
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary),
          ),
        ],
      ),
    ),
  );
}
