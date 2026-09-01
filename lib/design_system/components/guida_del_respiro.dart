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

  /// IL NUMERO DEL CONTO ALLA ROVESCIA, nullo fuori dal conto.
  ///
  /// ORDINE 2163, VOCE 11: il respiro partiva DA SOLO, con un timer di due
  /// secondi dopo la frase di apertura. Mauro vuole che parta quando decide
  /// lui: sotto la frase c'e' un pulsante vero, al tocco parte il conto da
  /// 3 a 0, un numero al secondo, deterministico, e SOLO alla fine comincia
  /// il respiro. Niente parte prima del tocco.
  int? _conto;
  Timer? _battitoDelConto;

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
  }

  /// Il tocco della persona: parte il conto, un numero al secondo.
  void _cominciaIlConto() {
    if (_conto != null || !_apertura) return;
    setState(() => _conto = 3);
    _battitoDelConto = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      final prossimo = _conto! - 1;
      if (prossimo < 0) {
        t.cancel();
        setState(() {
          _conto = null;
          _apertura = false;
        });
        _motore.forward();
      } else {
        setState(() => _conto = prossimo);
      }
    });
  }

  @override
  void dispose() {
    _battitoDelConto?.cancel();
    _motore.dispose();
    super.dispose();
  }

  /// Dove siamo adesso. Nullo a respiro finito, oppure quando i tempi non
  /// reggono: in tutti e due i casi non c'e' un momento da mostrare.
  MomentoDelRespiro? get _momento =>
      widget.tempi.momento(widget.tempi.intero * _motore.value);

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
        final figura =
            widget.figura ?? _CerchioDiRipiego(colore: widget.colore);
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
            // **LA PILLOLA HA UN TETTO, ordine 2168 voce 3, e la causa non
            // era quella che sembrava.** L'ordine diceva che a decidere la
            // larghezza fosse la parola "Preparati a respirare": misurato,
            // quella parola sta in 238 punti, mentre a spingere la pillola a
            // occupare TUTTI i 360 punti dello schermo era la RIGA DI
            // SERVIZIO sotto, "Quattro tempi dentro, quattro fuori. Tre
            // volte.", larga 328 punti piu' i margini. Stringere il solo
            // titolo non avrebbe cambiato niente a video.
            //
            // Il tetto sta al 72 per cento della larghezza disponibile: il
            // titolo ci sta intero su una riga, la riga di servizio va a
            // capo, ed e' testo secondario che su due righe si legge uguale.
            // Vale per tutti e tre i riti che montano questa guida.
            LayoutBuilder(
              builder: (context, vincoli) => ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: vincoli.maxWidth.isFinite
                      ? vincoli.maxWidth * quotaDellaPillola
                      : double.infinity,
                ),
                child: Container(
                  key: const Key('respiro_velo'),
                  // Il respiro laterale scende da sedici a quattordici: dentro
                  // il tetto della pillola servono quei due punti perche' la
                  // parola piu' lunga resti su una riga sola invece di spezzarsi.
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    // La superficie serve: nel Soffio il fondale e' un prato
                    // chiaro, e una parola chiara su un prato chiaro non si legge.
                    // Il contrasto contro questo velo si misura, e sta in
                    // `test/il_respiro_si_capisce_test.dart`.
                    color: veloDelConteggio,
                    // **RAGGIO FINITO, NON LO STADIO**, ordine 2171 voce 7.
                    //
                    // Con 999 il contenitore diventa una pillola: gli angoli
                    // curvano di meta' della sua altezza, e questo velo e' alto
                    // piu' di cento punti quando porta il conto. Misurato
                    // sull'anteprima a 360 punti: alla quota della prima riga di
                    // lettere il velo cominciava a 250 mentre il testo cominciava
                    // a 220, e a destra il velo finiva a 832 mentre il testo
                    // arrivava a 860. La P e la E finali stavano FUORI dalla
                    // superficie scura, sul prato chiaro, che e' esattamente il
                    // difetto di contrasto per cui questo velo esiste.
                    //
                    // Ventotto punti sono la curvatura giusta per un riquadro di
                    // questa altezza: gli angoli restano morbidi e nessuna lettera
                    // esce. La prova non guarda piu' se la parola sta su una riga,
                    // che era vero anche mentre le lettere erano fuori: guarda che
                    // ogni pixel sotto il titolo sia velo e non prato.
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_conto != null)
                        // IL CONTO ALLA ROVESCIA: numeri grandi che
                        // rimpiccioliscono e svaniscono, uno al secondo. Con
                        // Riduci Movimento appaiono e spariscono secchi, senza
                        // rimpicciolire: il conto resta.
                        SizedBox(
                          height: 84,
                          child: Center(
                            child: _riduciMovimento
                                ? Text('$_conto',
                                    key: ValueKey<int>(_conto!),
                                    // **SESSANTAQUATTRO PER RIEMPIRE UN
                                    // CERCHIO DI OTTANTAQUATTRO.** Ordine CE
                                    // voce 11: e' un numero che si guarda, non
                                    // un titolo che si legge, e la sua misura
                                    // viene dall'altezza del cerchio che lo
                                    // ospita.
                                    style: TypographyTokens.display(size: 64)
                                        .copyWith(
                                            color: inchiostroDelConteggio))
                                : TweenAnimationBuilder<double>(
                                    key: ValueKey<int>(_conto!),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 900),
                                    builder: (context, t, _) => Transform.scale(
                                      scale: 1.25 - 0.55 * t,
                                      child: Opacity(
                                        opacity: (1.0 - t).clamp(0.0, 1.0),
                                        child: Text('$_conto',
                                            style: TypographyTokens.display(
                                                    size: 64)
                                                .copyWith(
                                                    color:
                                                        inchiostroDelConteggio)),
                                      ),
                                    ),
                                  ),
                          ),
                        )
                      else
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
                            // DICIOTTO E NON VENTISEI, ordine 2168 voce 3, e la
                            // misura viene dal riquadro reso e non dal
                            // carattere: a ventisei "Preparati a respirare"
                            // faceva una pillola larga TUTTI i 360 punti dello
                            // schermo del fondatore, cioe' il cento per cento, e
                            // la parola sola comandava la scena col mandala
                            // dietro. La regola vale per tutti e tre i riti che
                            // montano questa guida: un caso speciale per il
                            // Soffio sarebbe un'altra regola su una porta sola.
                            style: TypographyTokens.titoloScheda().copyWith(
                              color: inchiostroDelConteggio,
                              letterSpacing: 0.4,
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
                                : ParoleDelRespiro.giro(
                                    m.giro, widget.tempi.giri)),
                        key: const Key('respiro_conteggio'),
                        textAlign: TextAlign.center,
                        style: TypographyTokens.label(size: 12).copyWith(
                          color: inchiostroDelConteggio.withValues(alpha: 0.72),
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (_apertura && _conto == null) ...[
                        const SizedBox(height: 10),
                        // UN PULSANTE VERO con area di tocco piena, non una
                        // scritta. Il testo e' uno dei due ammessi dall'ordine.
                        TextButton(
                          key: const Key('respiro_tocca'),
                          onPressed: _cominciaIlConto,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            backgroundColor:
                                inchiostroDelConteggio.withValues(alpha: 0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                              side: BorderSide(
                                  color: inchiostroDelConteggio.withValues(
                                      alpha: 0.55)),
                            ),
                          ),
                          child: Text(ParoleDelRespiro.tocca,
                              style: TypographyTokens.label(size: 13).copyWith(
                                  color: inchiostroDelConteggio,
                                  letterSpacing: 0.6)),
                        ),
                      ],
                    ],
                  ),
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
/// QUANTO LARGA PUO' FARSI LA PILLOLA DELLA PAROLA, in frazione della
/// larghezza disponibile. Ordine 2168 voce 3: senza tetto arrivava al cento
/// per cento dello schermo del fondatore, e la scritta comandava la scena col
/// mandala dietro. Il numero sta qui perche' una prova possa leggerlo e
/// misurarlo sul riquadro reso.
/// SETTANTA E NON SETTANTADUE: con la quota esattamente uguale alla soglia
/// della prova, l'arrotondamento in virgola mobile la faceva sforare di un
/// milionesimo. Il margine si prende nel PRODOTTO, non allentando la prova.
const double quotaDellaPillola = 0.70;

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
