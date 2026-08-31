import 'package:flutter/material.dart';

import '../../core/tarot/tarot_reading.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import 'stesa_reveal.dart';
import 'stesa_tre_carte_screen.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// LA CARTA SI APRE AL TOCCO. Ordine BN voce 04.
///
/// Parole del fondatore: "voglio poter fare click su una carta e questa deve
/// ingrandirsi facendomi anche leggere i dettagli di quella carta che poi si
/// tratta della stessa descrizione che si trova sotto".
///
/// **LA DESCRIZIONE NON SI RISCRIVE, SI LEGGE DA DOVE GIA' VIVE.** Il testo e'
/// `letta.testo`, lo stesso oggetto che riempie la bolla piu' in basso: una
/// seconda copia sarebbe la famiglia delle due porte, e al primo che ne cambia
/// una la carta direbbe una cosa e la bolla un'altra.
///
/// **E' un momento, non solo una funzione**, come il fondatore ha approvato:
/// la carta si gira verso chi guarda occupando la scena, il suo elemento si
/// accende attorno riusando la fioritura che la stesa ha gia', e il testo sale
/// da sotto. Si chiude col tocco fuori, col gesto all'indietro del sistema e
/// col trascinamento verso il basso.
Future<void> mostraLaCartaIngrandita(
  BuildContext context, {
  required PosizioneLetta letta,
  required MaestroPalette palette,
}) {
  final riduciMovimento = MediaQuery.of(context).disableAnimations;
  return dialogoGeneraleDelCerchio<void>(
    context: context,
    // IL TOCCO FUORI CHIUDE: e' la prima delle tre uscite.
    barrierDismissible: true,
    barrierLabel: 'Chiudi la carta',
    // **IL VELO E' OPACO PIENO, ordine BU voce 01.** Parole del fondatore
    // sulla 2208: "perche' se faccio click su una carta il testo e' chiaro
    // sottolineato di giallo?". Non era una sottolineatura: a 0,72 passava
    // il ventotto per cento della schermata sotto, e i titoli oro della
    // lista finivano dietro le righe del testo, riga per riga. Un velo che
    // lascia leggere due cose insieme non e' un velo.
    barrierColor: Colors.black,
    // Con Riduci Movimento la carta si apre GIA' COMPOSTA: nessuna rotazione,
    // nessuna salita, e il testo c'e' lo stesso. Chi ha tolto le animazioni
    // non ha chiesto di rinunciare ai dettagli della carta.
    transitionDuration:
        riduciMovimento ? Duration.zero : const Duration(milliseconds: 420),
    pageBuilder: (context, entrata, uscita) => CartaIngrandita(
      letta: letta,
      palette: palette,
      entrata: entrata,
      riduciMovimento: riduciMovimento,
      // **IL FONDO DICHIARATO, ordine AL voce 04.** Questa porta non e' un
      // foglio di Material e non ha nessuna superficie da vestire: il fondo
      // e' il velo, e la carta ci galleggia sopra. Dirlo qui invece di
      // lasciarlo implicito e' cio' che l'enumerazione delle porte pretende,
      // e vale: una porta che non dichiara niente e' indistinguibile da una
      // che si e' dimenticata il fondo.
      backgroundColor: Colors.transparent,
    ),
  );
}

/// La scena della carta aperta.
class CartaIngrandita extends StatelessWidget {
  const CartaIngrandita({
    super.key,
    required this.letta,
    required this.palette,
    required this.entrata,
    required this.riduciMovimento,
    this.backgroundColor = Colors.transparent,
  });

  final PosizioneLetta letta;
  final MaestroPalette palette;
  final Animation<double> entrata;
  final bool riduciMovimento;

  /// Il fondo della scena, dichiarato e non ereditato: qui e' trasparente
  /// perche' sotto c'e' il velo, e la carta non ha nessuna superficie propria.
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final spec = RevealSpec.of(letta.drawn.card);
    final larghezza = MediaQuery.of(context).size.width;
    // La carta occupa la scena senza toccarne i bordi: resta una carta
    // guardata da vicino, non un fondale.
    final largaCarta = (larghezza * 0.62).clamp(160.0, 320.0);

    // **IL MATERIAL, ED E' LA CAUSA VERA DELLE RIGHE GIALLE. Ordine BV voce
    // 01.** Il fondatore le ha viste ancora sulla 2209, col velo gia' nero
    // pieno: non erano trasparenza, erano righe DISEGNATE. Un testo che non
    // ha un `Material` fra i suoi antenati ricade sul `DefaultTextStyle` di
    // sistema, che porta `TextDecoration.underline` doppia e gialla; una
    // rotta costruita con `showGeneralDialog` non ne ha nessuno, e l'ordine
    // AL voce 04 lo aveva perfino scritto in un commento senza vederne la
    // conseguenza. **Il tipo e' `transparency`**: serve lo stile, non una
    // superficie, e il fondo deve restare il velo.
    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
      color: backgroundColor,
      child: Semantics(
        label: 'La carta ${letta.drawn.card.name} aperta, '
            'tocca fuori per chiudere',
        child: GestureDetector(
          // IL TOCCO FUORI, di nuovo: il velo lo intercetta, ma chi tocca il
          // margine della colonna deve chiudere lo stesso.
          onTap: () => Navigator.of(context).maybePop(),
          // IL TRASCINAMENTO VERSO IL BASSO, terza uscita: il gesto che tutti
          // provano su una cosa che si e' alzata.
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) > 200) {
              Navigator.of(context).maybePop();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg, vertical: SpacingTokens.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _laCarta(context, spec, largaCarta),
                    const SizedBox(height: SpacingTokens.lg),
                    _ilTesto(context),
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

  /// La carta che si gira verso chi guarda, con l'elemento acceso attorno.
  Widget _laCarta(BuildContext context, RevealSpec spec, double largaCarta) {
    final carta = SizedBox(
      width: largaCarta,
      child: AspectRatio(
        aspectRatio: kTarotAspect,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // L'ELEMENTO SI ACCENDE ATTORNO, e non e' un effetto nuovo: e' la
            // stessa fioritura che la carta ha avuto quando e' uscita.
            Positioned.fill(
              child: ElementalReveal(
                key: const Key('carta_ingrandita_fioritura'),
                spec: spec,
                progress: riduciMovimento ? 1 : entrata.value,
                palette: palette,
              ),
            ),
            FacciaDellaCarta(
              key: const Key('carta_ingrandita_figura'),
              drawn: letta.drawn,
              palette: palette,
            ),
          ],
        ),
      ),
    );
    if (riduciMovimento) return carta;
    // La rotazione verso chi guarda: parte di taglio e si posa dritta.
    return AnimatedBuilder(
      animation: entrata,
      builder: (context, child) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateY((1 - Curves.easeOutCubic.transform(entrata.value)) * 0.7)
          ..scaleByDouble(
              0.86 + 0.14 * entrata.value, 0.86 + 0.14 * entrata.value, 1, 1),
        child: child,
      ),
      child: carta,
    );
  }

  /// Il testo che sale da sotto: la STESSA descrizione della bolla.
  Widget _ilTesto(BuildContext context) {
    final blocco = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(letta.drawn.card.name.toUpperCase(),
            key: const Key('carta_ingrandita_nome'),
            style: TypographyTokens.titoloScheda()
                .copyWith(color: palette.goldSoft, letterSpacing: 1.1)),
        const SizedBox(height: SpacingTokens.xs),
        // **IL NARRATO PASSA DALLA PORTA COMUNE, ordine AL.** Era un `Text`
        // diretto nel ruolo lettura, cioe' la famiglia delle due porte: da
        // li' il muro di testo torna, e la carta aperta e' proprio il posto
        // dove il testo ha piu' spazio per diventarlo.
        ParagrafiDiLettura(
            key: const Key('carta_ingrandita_testo'),
            testo: letta.testo,
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
      ],
    );
    if (riduciMovimento) return blocco;
    return AnimatedBuilder(
      animation: entrata,
      builder: (context, child) => Opacity(
        opacity: entrata.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - Curves.easeOut.transform(entrata.value))),
          child: child,
        ),
      ),
      child: blocco,
    );
  }
}
