/// I COMANDI DIPINTI DEL RESPIRO DELLA LUNA. Ordine FX aggiunta FXA.02, 16
/// ottobre 2026.
///
/// Il fondatore, sull'anteprima della collana composta dal codice: *"Non
/// avevo chiesto di evitare grafica procedurale?"*. In tutto il Respiro ogni
/// pulsante, pannello e finestra usa i pezzi dipinti di
/// `assets/img/respiro_della_luna/comandi/`; il testo e' testo Flutter posato
/// sopra, chiaro sul velluto e scuro sull'argento del pulsante premuto.
///
/// **COME SI ALLUNGANO SENZA DEFORMARSI.** Il pulsante largo e' un'immagine a
/// nove parti ([ImmagineANoveParti]): gli angoli con le lune e le stelle
/// restano alla loro misura, si allunga o si accorcia solo la fascia
/// centrale, che e' velluto liscio fra due fili d'argento dritti. Non si usa
/// `centerSlice` di Flutter perche' sa solo allungare: un pulsante piu'
/// stretto della sua misura naturale, o un pannello piu' basso, fanno cadere
/// un'asserzione del motore (presa dall'anteprima del pulsante). L'altezza e' fissa e decide la scala, cosi'
/// gli angoli hanno sempre la stessa misura a schermo. Il pannello ha la falce
/// al centro del bordo alto, che una fascia allungata deformerebbe: la sua
/// scala si sceglie in modo che la larghezza naturale coincida con quella
/// disponibile, e allora si allunga solo in altezza, dove i bordi laterali
/// sono fili dritti. Il pulsante tondo ha una misura sola.
library;

import 'package:flutter/material.dart';

import '../../design_system/components/la_conferma_della_spesa.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

const String _comandi = 'assets/img/respiro_della_luna/comandi/';

/// Il testo sul velluto: chiaro, quasi bianco, come l'argento delle cornici.
const Color coloreSulVelluto = Color(0xFFF1ECE2);

/// Il testo sull'argento del pulsante premuto: il blu del velluto.
const Color coloreSullArgento = Color(0xFF14204A);

/// **LA CORNICE DEL PULSANTE LARGO, INTORNO A UN CONTENUTO.** Ordine GD, il
/// fondatore sul Realme guardando la Sinastria evolutiva: *"mi piace la
/// grafica cornice del pulsante «scopri la compatibilità», ma dovrebbe essere
/// ripreso"*. E' la stessa pittura del [PulsanteDipinto] (gli angoli d'oro, il
/// filo, il velluto blu), a nove parti e alla stessa scala degli ornamenti di
/// un pulsante alto 54 punti: cresce in altezza col suo contenuto (una scelta
/// con due righe, un campo del modulo) senza che gli angoli si deformino.
/// [scelta] usa la pittura del pulsante premuto, per la voce scelta.
class CorniceDipinta extends StatelessWidget {
  const CorniceDipinta({super.key, required this.child, this.scelta = false});

  final Widget child;
  final bool scelta;

  /// La scala degli ornamenti: quella di un [PulsanteDipinto] alto 54.
  static const double scala = PulsanteDipinto.altezzaDellImmagine / 54;

  /// Il margine dentro la cornice: oltre gli angoli e oltre il filo alto.
  static const EdgeInsets margine = EdgeInsets.fromLTRB(28, 18, 24, 18);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ImmagineANoveParti(
            asset: scelta
                ? PulsanteDipinto.immaginePremuta
                : PulsanteDipinto.immagine,
            misura: scelta ? const Size(1132, 323) : const Size(1133, 323),
            taglio:
                scelta ? PulsanteDipinto.taglioPremuto : PulsanteDipinto.taglio,
            scala: scala,
          ),
        ),
        Padding(padding: margine, child: child),
      ],
    );
  }
}

/// **IL PULSANTE LARGO, A NOVE PARTI.** Misure dell'immagine: 1133 per 323
/// (premuto 1132 per 323); gli ornamenti degli angoli finiscono entro 210
/// pixel da ciascun lato, il filo alto entro 110 e quello basso da 213.
class PulsanteDipinto extends StatefulWidget {
  const PulsanteDipinto({
    super.key,
    required this.testo,
    required this.onTap,
    this.altezza = 54,
    this.larghezzaPiena = false,
  });

  final String testo;
  final VoidCallback? onTap;
  final double altezza;

  /// Se occupa tutta la larghezza disponibile invece di quella del testo.
  final bool larghezzaPiena;

  static const String immagine = '${_comandi}pulsante_largo_v1.webp';
  static const String immaginePremuta =
      '${_comandi}pulsante_largo_premuto_v1.webp';
  static const double altezzaDellImmagine = 323;
  static const Rect taglio = Rect.fromLTRB(210, 110, 923, 213);
  static const Rect taglioPremuto = Rect.fromLTRB(210, 110, 922, 213);

  @override
  State<PulsanteDipinto> createState() => _PulsanteDipintoState();
}

class _PulsanteDipintoState extends State<PulsanteDipinto> {
  bool _premuto = false;

  void _premi(bool giu) {
    if (widget.onTap == null) return;
    setState(() => _premuto = giu);
  }

  @override
  Widget build(BuildContext context) {
    final attivo = widget.onTap != null;
    final scala = PulsanteDipinto.altezzaDellImmagine / widget.altezza;
    // Il lato degli angoli a schermo, che il testo non deve invadere.
    final angolo = PulsanteDipinto.taglio.left / scala;
    final fondo = ImmagineANoveParti(
      asset:
          _premuto ? PulsanteDipinto.immaginePremuta : PulsanteDipinto.immagine,
      misura: _premuto ? const Size(1132, 323) : const Size(1133, 323),
      taglio: _premuto ? PulsanteDipinto.taglioPremuto : PulsanteDipinto.taglio,
      scala: scala,
    );
    // **IL TESTO SI RIMPICCIOLISCE, NON SI TAGLIA**: "Comincia una nuova
    // co..." nell'anteprima del pulsante. Un comando tagliato dai puntini
    // non si legge, e l'utente non deve indovinare cosa fa.
    final testo = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        widget.testo,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TypographyTokens.titoloScheda()
            .copyWith(color: _premuto ? coloreSullArgento : coloreSulVelluto),
      ),
    );
    return Semantics(
      button: true,
      enabled: attivo,
      label: widget.testo,
      excludeSemantics: true,
      child: Opacity(
        opacity: attivo ? 1 : 0.45,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _premi(true),
          onTapUp: (_) => _premi(false),
          onTapCancel: () => _premi(false),
          onTap: widget.onTap,
          child: ConstrainedBox(
            // Mai piu' stretto dei due angoli affiancati.
            constraints: BoxConstraints(minWidth: angolo * 2.2),
            child: SizedBox(
              height: widget.altezza,
              width: widget.larghezzaPiena ? double.infinity : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: fondo),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: angolo * 0.8),
                    child: testo,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// **IL PULSANTE TONDO**, per i comandi piccoli: una misura sola, nessun
/// allungamento. Dentro, un testo breve o un'immagine dipinta.
class PulsanteTondoDipinto extends StatelessWidget {
  const PulsanteTondoDipinto({
    super.key,
    required this.figlio,
    required this.onTap,
    required this.etichetta,
    this.lato = 48,
  });

  final Widget figlio;
  final VoidCallback? onTap;
  final String etichetta;
  final double lato;

  static const String immagine = '${_comandi}pulsante_tondo_v1.webp';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: etichetta,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: lato,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(immagine,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
              Padding(padding: EdgeInsets.all(lato * 0.2), child: figlio),
            ],
          ),
        ),
      ),
    );
  }
}

/// **IL PANNELLO DIPINTO**, per i testi e le finestre. Immagine 731 per 915:
/// angoli e falce entro 140 pixel dai lati e 160 dall'alto, il velluto
/// libero fra 160 e 755 in altezza.
class PannelloDipinto extends StatelessWidget {
  const PannelloDipinto({super.key, required this.child});

  final Widget child;

  static const String immagine = '${_comandi}pannello_v1.webp';
  static const double larghezzaDellImmagine = 731;
  static const double altezzaDellImmagine = 915;
  static const Rect taglio = Rect.fromLTRB(140, 160, 591, 755);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, vincoli) {
      final larghezza = vincoli.hasBoundedWidth ? vincoli.maxWidth : 320.0;
      final scala = larghezzaDellImmagine / larghezza;
      return ConstrainedBox(
        // Mai piu' basso della falce in cima e della cornice in fondo.
        constraints: BoxConstraints(
            minHeight:
                (taglio.top + (altezzaDellImmagine - taglio.bottom)) / scala),
        child: Stack(
          children: [
            Positioned.fill(
              child: ImmagineANoveParti(
                  asset: immagine,
                  misura:
                      const Size(larghezzaDellImmagine, altezzaDellImmagine),
                  taglio: taglio,
                  scala: scala),
            ),
            Padding(
              // Dentro la cornice: sotto la falce in alto, oltre i fili d'argento
              // ai lati e in basso.
              padding: EdgeInsets.fromLTRB(
                  70 / scala, 130 / scala, 70 / scala, 90 / scala),
              child: child,
            ),
          ],
        ),
      );
    });
  }
}

/// **LA FINESTRA DIPINTA**: un dialogo del Cerchio (`dialogoDelCerchio`, il
/// velo di legge) con dentro il pannello dipinto, al posto di un
/// `AlertDialog` a sfondo pieno.
Future<T?> finestraDipinta<T>(
  BuildContext context, {
  required String titolo,
  required Widget contenuto,
  required List<Widget> Function(BuildContext) azioni,
  Key? chiave,
}) {
  return dialogoDelCerchio<T>(
    context: context,
    builder: (c) => Dialog(
      key: chiave,
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.xl),
      child: PannelloDipinto(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titolo,
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: MaestroPalette.neutral.goldSoft)),
            const SizedBox(height: SpacingTokens.sm),
            DefaultTextStyle.merge(
              style: TypographyTokens.corpo().copyWith(color: coloreSulVelluto),
              textAlign: TextAlign.center,
              child: contenuto,
            ),
            const SizedBox(height: SpacingTokens.md),
            for (final a in azioni(c)) ...[
              a,
              const SizedBox(height: SpacingTokens.xs),
            ],
          ],
        ),
      ),
    ),
  );
}

/// **LA CONFERMA DELLA SPESA, VESTITA COI PEZZI DIPINTI** (FXA.03). Testi,
/// saldo e consenso restano quelli di `LaConfermaDellaSpesa`; qui cambia solo
/// il vestito. Le chiavi sono le stesse della conferma comune.
Widget confermaDipinta(
    BuildContext c, String titolo, String corpo, String conferma, bool attiva) {
  return Dialog(
    key: const Key('conferma_spesa'),
    backgroundColor: Colors.transparent,
    elevation: 0,
    insetPadding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg, vertical: SpacingTokens.xl),
    child: PannelloDipinto(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titolo,
              key: const Key('conferma_spesa_titolo'),
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: MaestroPalette.neutral.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text(corpo,
              key: const Key('conferma_spesa_corpo'),
              textAlign: TextAlign.center,
              style:
                  TypographyTokens.corpo().copyWith(color: coloreSulVelluto)),
          const SizedBox(height: SpacingTokens.md),
          PulsanteDipinto(
            key: const Key('conferma_spesa_procedi'),
            testo: conferma,
            larghezzaPiena: true,
            onTap: attiva ? () => Navigator.of(c).pop(true) : null,
          ),
          const SizedBox(height: SpacingTokens.xs),
          PulsanteDipinto(
            key: const Key('conferma_spesa_non_ora'),
            testo: LaConfermaDellaSpesa.nonOra,
            larghezzaPiena: true,
            onTap: () => Navigator.of(c).pop(false),
          ),
        ],
      ),
    ),
  );
}

/// **LA BARRA CRESCE COL TESTO** (FXA.04). Col testo ingrandito dal sistema
/// il titolo va a capo su due righe e in 56 punti non ci sta: sborda sopra la
/// barra (preso dalla prova a 320-430 punti e a 1,3). L'altezza segue
/// l'ingrandimento, fino a 1,4 volte.
double altezzaDellaBarraDelRespiro(BuildContext context) {
  final s = MediaQuery.textScalerOf(context).scale(1);
  return s <= 1.05 ? kToolbarHeight : kToolbarHeight * 1.1 * s.clamp(1.0, 1.4);
}

/// **L'IMMAGINE A NOVE PARTI**, fatta di nove ritagli della stessa pittura.
/// [taglio] e' la parte centrale in pixel dell'immagine, [scala] quanti pixel
/// dell'immagine fanno un punto a schermo: i quattro angoli restano alla loro
/// misura (taglio diviso scala), le quattro fasce si allungano o si
/// accorciano su un asse solo, il centro su tutti e due. Nessun disegno: ogni
/// parte e' l'immagine dipinta, ritagliata e posata.
class ImmagineANoveParti extends StatelessWidget {
  const ImmagineANoveParti({
    super.key,
    required this.asset,
    required this.misura,
    required this.taglio,
    required this.scala,
  });

  final String asset;
  final Size misura;
  final Rect taglio;
  final double scala;

  @override
  Widget build(BuildContext context) {
    final immagine = AssetImage(asset);
    return LayoutBuilder(builder: (context, v) {
      final w = v.maxWidth, h = v.maxHeight;
      // Le colonne e le righe di origine (pixel) e di arrivo (punti).
      final sx = [0.0, taglio.left, taglio.right, misura.width];
      final sy = [0.0, taglio.top, taglio.bottom, misura.height];
      final sinistra = taglio.left / scala;
      final destra = (misura.width - taglio.right) / scala;
      final alto = taglio.top / scala;
      final basso = (misura.height - taglio.bottom) / scala;
      final dx = [0.0, sinistra, (w - destra).clamp(sinistra, w), w];
      final dy = [0.0, alto, (h - basso).clamp(alto, h), h];
      final parti = <Widget>[];
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          final sw = sx[c + 1] - sx[c], sh = sy[r + 1] - sy[r];
          final dw = dx[c + 1] - dx[c], dh = dy[r + 1] - dy[r];
          if (sw <= 0 || sh <= 0 || dw <= 0 || dh <= 0) continue;
          final kx = dw / sw, ky = dh / sh;
          parti.add(Positioned(
            left: dx[c],
            top: dy[r],
            width: dw,
            height: dh,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: 0,
                minHeight: 0,
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: Transform.translate(
                  offset: Offset(-sx[c] * kx, -sy[r] * ky),
                  child: SizedBox(
                    width: misura.width * kx,
                    height: misura.height * ky,
                    child: Image(
                        image: immagine,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                  ),
                ),
              ),
            ),
          ));
        }
      }
      return Stack(clipBehavior: Clip.none, children: parti);
    });
  }
}
