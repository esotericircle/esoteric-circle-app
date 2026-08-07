import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'navigation_controller.dart';
import 'vie_del_cerchio.dart';

/// Bottom bar a cinque voci: Santuario, i tre Maestri nell'ordine fisso
/// (Medora, Caligo, Aura) e il Cosmic Passport, distinto e staccato.
///
/// Le voci Maestro sono porte dirette al dominio del Maestro, non centrano il
/// busto: il cambio del centro nel Santuario avviene col carosello. Nel
/// Santuario resta acceso solo Santuario; le icone Maestro restano spente,
/// sono scorciatoie verso i domini.
class SantuarioBottomBar extends StatelessWidget {
  const SantuarioBottomBar({
    super.key,
    required this.view,
    required this.onSantuario,
    required this.onMaestro,
    required this.onPassport,
    this.maestroCorrente,
    this.fuoriDalGuscio = false,
  });

  /// Vero quando la schermata in cima e' una rotta spinta SOPRA il guscio
  /// (dominio, chat, Consiglio): le voci del guscio, Il Cerchio e Passport,
  /// restano SPENTE, perche' la vista sotto e' solo la provenienza. Ordine
  /// 2163, voce 6: nel Consiglio, arrivandoci dal Passport, la voce
  /// Passport restava accesa mentre la schermata era il Consiglio.
  final bool fuoriDalGuscio;

  /// Il Maestro di cui si sta guardando il dominio o la chat, quando si e'
  /// fuori dal guscio.
  ///
  /// **E' "dove sei", e da qui in avanti conta.** Finche' la barra viveva
  /// dentro il guscio le icone Maestro erano solo scorciatoie e restavano tutte
  /// spente, perche' da li' non si era mai "da" un Maestro. Adesso la barra si
  /// vede anche nel dominio e nella chat, e li' una voce accesa dice dove si e'
  /// invece di lasciarlo indovinare. Nullo dentro il guscio, dove a dirlo e'
  /// gia' la vista.
  final Maestro? maestroCorrente;

  final ShellView view;
  final VoidCallback onSantuario;
  final ValueChanged<Maestro> onMaestro;
  final VoidCallback onPassport;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onSantuarioView = view == ShellView.santuario;

    // **LA BARRA SI PORTA IL SUO MATERIAL, e da oggi le serve.** Le sue voci
    // sono `InkWell`, che pretende un `Material` antenato: dentro il guscio
    // glielo dava lo Scaffold, ma sopra il Navigator non c'e' nessuno Scaffold
    // e la barra non si costruiva affatto. Trasparente, perche' il fondo lo
    // dipinge gia' il gradiente qui sotto, e in un posto solo: cosi' vale
    // ovunque la si monti, e non dipende da chi la monta.
    // LA FASCIA DEL TITOLO HA UN FONDO, ordine 2163 voce 7: il gradiente
    // partiva da alpha zero in cima, e la scritta ESPLORA si stampava sopra
    // le carte che passavano dietro. La misura NON e' indovinata: e'
    // l'altezza vera del titolo, dipinta qui sotto con lo stesso stile, piu'
    // il respiro sopra di lui. Fino a quella quota il fondo e' quasi pieno.
    final pittoreDelTitolo = TextPainter(
      text: TextSpan(
        text: titolo,
        style: TypographyTokens.label(size: 11)
            .copyWith(letterSpacing: 3.2),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final fasciaDelTitolo =
        SpacingTokens.sm + pittoreDelTitolo.height + 2;

    return Material(
      type: MaterialType.transparency,
      child: Container(
      decoration: BoxDecoration(
        // OPACA, per la stessa regola della voce 1: una trasparenza
        // semplice lascia leggere cio' che passa dietro, e il differenziale
        // a pixel lo denuncia con qualunque velo. Il colore e' COMPOSTO:
        // in cima un filo piu' chiaro, in fondo il fondale pieno, cosi' la
        // profondita' resta senza che il contenuto attraversi il titolo.
        // La fascia del titolo e' misurata dal testo vero qui sopra.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(
                palette.surfaceElevated.withValues(alpha: 0.25),
                palette.deepest),
            Color.alphaBlend(
                palette.surfaceElevated.withValues(alpha: 0.10),
                palette.deepest),
            palette.deepest,
          ],
          stops: [
            0.0,
            (fasciaDelTitolo / altezzaResa).clamp(0.0, 1.0),
            1.0,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.sm,
          ),
          // LE VOCI VENGONO DALL'ELENCO UNICO, non da qui.
          //
          // Il nome, il disegno e l'ordine stanno in `ViaDelCerchio`. Qui
          // restano le cose che appartengono davvero alla barra, cioe' quale
          // voce e' accesa e cosa succede al tocco.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // IL TITOLO, IN ORO. Sta sopra le voci, piccolo, senza icona e
              // senza tocco, e la sua riga e' alta quanto una lettera. Il
              // colore si legge da [coloreDelTitolo], un punto solo: chi lo
              // scrive a mano qui dentro fa cadere una prova.
              Text(
                titolo,
                key: const Key('barra_titolo'),
                style: TypographyTokens.label(size: 11).copyWith(
                  color: coloreDelTitolo(palette),
                  letterSpacing: 3.2,
                ),
              ),
              const SizedBox(height: 2),
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final via in ViaDelCerchio.tutte) ...[
                // Il Passport, staccato dai Maestri da un filo verticale.
                if (via.specie == SpecieDiVia.passport)
                  Container(
                    width: 1,
                    height: 34,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: palette.gold.withValues(alpha: 0.2),
                  ),
                _BarItem(
                  // La chiave dichiara QUALE voce e': da quando la striscia
                  // delle arti vive anche in home, il nome di un Maestro a
                  // video non e' piu' uno solo, e chi deve toccare la barra
                  // la nomina per chiave, non per testo.
                  key: Key('barra_voce_${via.id}'),
                  label: via.etichetta,
                  icona: via.icona,
                  // DOVE SEI, ACCESA. Dentro il guscio lo dice la vista: nel
                  // Santuario le icone Maestro restano spente, perche' li' sono
                  // scorciatoie e non lo stato del centro. Fuori dal guscio lo
                  // dice il Maestro di cui si sta guardando il dominio o la
                  // chat, e allora la sua voce si accende.
                  selected: switch (via.specie) {
                    SpecieDiVia.cerchio => !fuoriDalGuscio &&
                        maestroCorrente == null &&
                        onSantuarioView,
                    SpecieDiVia.maestro => via.maestro == maestroCorrente,
                    SpecieDiVia.passport => !fuoriDalGuscio &&
                        maestroCorrente == null &&
                        view == ShellView.passport,
                  },
                  onTap: () => switch (via.specie) {
                    SpecieDiVia.cerchio => onSantuario(),
                    SpecieDiVia.maestro => onMaestro(via.maestro!),
                    SpecieDiVia.passport => onPassport(),
                  },
                ),
              ],
            ],
          ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Il titolo della barra, deciso da Mauro il 6 agosto 2026.
  static const String titolo = 'ESPLORA';

  /// L'altezza resa della barra intera, titolo compreso: la stessa misura
  /// che `BarraDelCerchio.altezza` dichiara e che una prova confronta con
  /// la resa vera. Vive qui perche' serve al gradiente per convertire la
  /// fascia del titolo in uno stop, senza importare la barra (che importa
  /// questo file).
  static const double altezzaResa = 123;

  /// IL COLORE DEL TITOLO: L'ORO DELLA PALETTE. Deciso da Mauro il 7 agosto
  /// 2026, e SUPERA la decisione del mattino del 6 agosto che lo voleva nel
  /// grigio del testo smorzato. Quella decisione nasceva da una misura vera,
  /// cinque voci dorate piu' un titolo dorato facevano una fascia illeggibile,
  /// ma Mauro l'ha cambiata: chi legge la vecchia decisione NON lo rimetta
  /// grigio. Il colore vive QUI e in nessun altro posto: una prova legge
  /// questo punto e cade se qualcuno lo scrive a mano altrove.
  static Color coloreDelTitolo(MaestroPalette palette) => palette.gold;
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icona,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Il disegno dell'icona, colore e lato decisi qui dentro perche' lo stato
  /// attivo e la dimensione ottica sono della barra, non della singola voce.
  /// Prima era un `IconData`, e un `IconData` non puo' essere una falce dentro
  /// un anello: la voce del Cerchio non esiste fra le icone di Material.
  final Widget Function(Color colore, double lato) icona;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final Color color = selected ? palette.goldSoft : ColorTokens.textMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? palette.primary.withValues(alpha: 0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? palette.gold.withValues(alpha: 0.8)
                        : Colors.transparent,
                    width: 1.2,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: palette.glow.withValues(alpha: 0.5),
                            blurRadius: 18,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: icona(color, 21),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
