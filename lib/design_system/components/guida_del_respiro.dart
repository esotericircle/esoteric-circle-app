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
  });

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
    _motore.forward();
  }

  @override
  void dispose() {
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
              child: figura,
            ),
            const SizedBox(height: 16),
            // IL CONTEGGIO, che resta sempre. E' l'unica cosa che chi ha
            // Riduci Movimento ha al posto dell'animazione, quindi non puo'
            // dipendere dall'animazione per esistere.
            //
            // **HA UNA SUPERFICIE SUA, e ne aveva bisogno.** Era un testo
            // posato sulla scena: nel Soffio finiva sui raggi del soffione, che
            // nella fase di luce piena sono chiari, e il grigio chiaro su
            // chiaro non si leggeva. Il velo lo stacca dal fondo qualunque cosa
            // ci sia sotto, e il contrasto si misura contro il velo invece che
            // contro una scena che cambia.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: veloDelConteggio,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                m == null
                    ? 'Respiro compiuto'
                    : '${m.parola} · giro ${m.giro} di ${widget.tempi.giri}',
                key: const Key('respiro_conteggio'),
                textAlign: TextAlign.center,
                style: TypographyTokens.label(size: 13).copyWith(
                  color: m == null ? widget.colore : inchiostroDelConteggio,
                  letterSpacing: 1.6,
                ),
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
