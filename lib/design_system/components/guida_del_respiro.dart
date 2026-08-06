import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/rituals/tempi_del_respiro.dart';
import '../tokens/typography_tokens.dart';

/// LA GUIDA DEL RESPIRO: la figura si espande mentre l'aria entra e si
/// contrae mentre esce, e i giri si contano da soli.
///
/// **Cosa c'era prima.** Il rito dichiarava una cadenza in una frase, per
/// esempio "sei tempi dentro e sei fuori, tre volte", e poi lasciava contare a
/// mente davanti a un simbolo fermo. Era un foglio di istruzioni da eseguire,
/// non un rito da compiere: la differenza e' che un rito ti accompagna.
///
/// **Il testo resta, e cambia mestiere.** Continua a dire cosa si fa, ma come
/// spiegazione e non come comando da tenere a memoria mentre si respira.
///
/// **Riduci Movimento non lascia un vuoto.** La figura smette di espandersi,
/// perche' e' esattamente il movimento che quell'impostazione chiede di
/// togliere, e al suo posto resta il conteggio scritto, che avanza uguale. Chi
/// ha attivato quell'impostazione non perde il rito: perde l'animazione.
class GuidaDelRespiro extends StatefulWidget {
  const GuidaDelRespiro({
    super.key,
    required this.tempi,
    required this.colore,
    this.figura,
    this.onFinito,
    this.chiaveDellaFigura,
  });

  /// Chi ha bisogno di sapere DOVE sta la figura che respira la aggancia qui.
  ///
  /// Serve al Soffio, che deve far cadere il disco luminoso della scena
  /// esattamente attorno a questo anello: senza una chiave sulla figura si
  /// misurerebbe il centro della colonna, che comprende anche il conteggio
  /// sotto e sta quindi piu' in basso del centro dell'anello.
  final GlobalKey? chiaveDellaFigura;

  /// La cadenza dichiarata dal rito del giorno.
  final TempiDelRespiro tempi;

  /// Il colore del Maestro di turno.
  final Color colore;

  /// La figura che respira. Nulla per il cerchio dichiarato qui sotto, che e'
  /// un RIPIEGO e lo dice: quando il rito porta un simbolo suo, quello passa
  /// di qui e il cerchio non si vede mai.
  final Widget? figura;

  /// Chiamato una volta sola, quando l'ultimo giro si chiude.
  final VoidCallback? onFinito;

  @override
  State<GuidaDelRespiro> createState() => _GuidaDelRespiroState();
}

class _GuidaDelRespiroState extends State<GuidaDelRespiro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motore = AnimationController(
    vsync: this,
    duration: widget.tempi.intero,
  );
  bool _avvisato = false;

  /// Vero finche' l'apertura e' a video, cioe' prima che il conteggio parta.
  ///
  /// **Il rito comincia con una frase da leggere.** Prima il conteggio partiva
  /// subito e la persona si trovava dentro un respiro guidato senza sapere che
  /// stava per cominciare: la parola grande cambiava e lei rincorreva.
  bool _apertura = true;
  Timer? _viaLApertura;

  bool get _riduciMovimento => MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();
    if (!widget.tempi.reggono) return;
    _motore.addStatusListener((s) {
      if (s == AnimationStatus.completed && !_avvisato) {
        _avvisato = true;
        widget.onFinito?.call();
      }
    });
    // L'apertura resta due secondi pieni, poi parte il conteggio: e' l'unico
    // timer di questa schermata, e serve a dare il tempo di leggere.
    _viaLApertura = Timer(ParoleDelRespiro.attesaDellApertura, () {
      if (!mounted) return;
      setState(() => _apertura = false);
      _motore.forward();
    });
  }

  @override
  void dispose() {
    _viaLApertura?.cancel();
    _motore.dispose();
    super.dispose();
  }

  /// Dove siamo adesso. Nullo a respiro finito, oppure quando i tempi non
  /// reggono: in tutti e due i casi non c'e' un momento da mostrare.
  MomentoDelRespiro? get _momento => widget.tempi
      .momento(widget.tempi.intero * _motore.value);

  @override
  Widget build(BuildContext context) {
    if (!widget.tempi.reggono) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _motore,
      builder: (context, _) {
        final m = _momento;
        // A respiro finito la figura resta ferma alla sua misura piena: non si
        // dissolve e non torna al minimo, perche' un rito compiuto non si
        // cancella da solo.
        final misura = m?.misura ?? 1.0;
        final figura = widget.figura ?? _CerchioDiRipiego(colore: widget.colore);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // IL MOVIMENTO, che Riduci Movimento toglie. La figura resta, alla
            // sua misura piena: senza scala non c'e' respiro da guardare, ma
            // c'e' ancora qualcosa da guardare.
            Transform.scale(
              key: const Key('respiro_figura'),
              scale: _riduciMovimento ? 1.0 : misura,
              // La chiave sta sul FIGLIO e non sulla scala: un `Transform` non
              // cambia la misura del riquadro che occupa, quindi il suo
              // rettangolo direbbe la posizione a riposo anche mentre la figura
              // si espande, e chi la insegue si fermerebbe un po' fuori centro.
              child: KeyedSubtree(
                key: widget.chiaveDellaFigura,
                child: figura,
              ),
            ),
            const SizedBox(height: 16),
            // LA PAROLA GRANDE, che dice il GESTO e non dove va l'aria.
            //
            // Tre momenti e tre parole: prima del conteggio "Preparati a
            // respirare", durante "Inspira" ed "Espira", alla fine "Il respiro
            // e' compiuto". I testi stanno in `ParoleDelRespiro`, non qui:
            // sono approvati, e il giorno che cambiano non devono esserci due
            // posti da allineare.
            //
            // **Il cambio di parola e' SECCO con Riduci Movimento**, e con una
            // dissolvenza breve altrimenti: una parola che sfuma mentre il
            // corpo cambia gesto arriva in ritardo sul gesto.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // La superficie serve: nel Soffio il fondale e' un prato
                // chiaro, e una parola chiara su un prato chiaro non si legge.
                // Il contrasto contro questo velo si misura, e sta in
                // `test/il_respiro_si_capisce_test.dart`.
                color: veloDelConteggio,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: _riduciMovimento
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    child: Text(
                      _apertura
                          ? ParoleDelRespiro.preparati
                          : (m == null
                              ? ParoleDelRespiro.compiuto
                              : m.parola),
                      key: ValueKey<String>(_apertura
                          ? 'apertura'
                          : (m == null ? 'fine' : m.parola)),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.display(size: 26).copyWith(
                        color: inchiostroDelConteggio,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // LA RIGA DI SERVIZIO, smorzata: dice la forma del rito
                  // prima, il giro durante. Non compete con la parola grande,
                  // perche' non e' lei a guidare.
                  Text(
                    _apertura
                        ? ParoleDelRespiro.formaDi(widget.tempi)
                        : (m == null
                            ? ''
                            : ParoleDelRespiro.giro(m.giro, widget.tempi.giri)),
                    key: const Key('respiro_conteggio'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.label(size: 12).copyWith(
                      color: inchiostroDelConteggio.withValues(alpha: 0.72),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Il velo dietro il conteggio e il suo inchiostro, dichiarati qui perche' e'
/// qui che si dipingono. Il Soffio li rilegge da qui per le proprie superfici,
/// cosi' la misura del contrasto vale su quello che si vede davvero e i due
/// veli della stessa schermata non possono diventare due grigi diversi.
const Color veloDelConteggio = Color(0xEB0B1410);
const Color inchiostroDelConteggio = Color(0xFFF3EFE6);

/// Il cerchio che respira quando il rito non porta una figura sua.
///
/// **DICHIARA DI ESSERE UN RIPIEGO**, e lo dichiara qui e non in un commento
/// lontano: e' una forma neutra, non il simbolo di nessuno, e serve perche' la
/// guida funzioni anche dove l'arte non e' ancora arrivata. Un cerchio vuoto
/// senza questa nota diventa, dopo un mese, un cerchio vuoto che qualcuno
/// difende.
class _CerchioDiRipiego extends StatelessWidget {
  const _CerchioDiRipiego({required this.colore});

  final Color colore;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colore.withValues(alpha: 0.7), width: 2),
        gradient: RadialGradient(
          colors: [
            colore.withValues(alpha: 0.22),
            colore.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
