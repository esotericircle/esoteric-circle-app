import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../maestri/domain_screen.dart';
import '../../core/onboarding/onboarding_controller.dart';
import '../../services/app_services.dart';
import 'esplora_schermate.dart';
import 'navigation_controller.dart';

/// ESPLORA: la via breve verso il Cerchio e verso i tre domini, sempre a
/// portata ma mai di mezzo.
///
/// **Perche' esiste.** Da una chat si passa al Consiglio, dal Consiglio a un
/// altro Maestro, e tornare alla home diventa lungo. Esplora accorcia quella
/// strada senza aggiungere un altro posto in cui perdersi.
///
/// **Dove vive la decisione.** In un punto solo: `EsploraScope`, montato nel
/// `builder` di `MaterialApp`, che avvolge il Navigator intero e quindi vede
/// anche le rotte spinte sopra il guscio, comprese le chat, che hanno un
/// proprio Scaffold. Nessuna schermata decide da se' se mostrarla: quello che
/// deve succedere sta scritto in `esplora_schermate.dart`.

/// Segnala allo scope che la pila di navigazione e' cambiata.
///
/// Tiene anche l'elenco dei TIPI di schermata nella pila, che serve alla regola
/// contro il doppione: e' il tipo, non un nome di rotta. Dare un nome a ogni
/// rotta vorrebbe dire toccare tutte le fabbriche e sperare che nessuno se ne
/// dimentichi domani; il tipo e' gia' il criterio con cui l'elenco classifica,
/// quindi la porta resta una.
class EsploraObservatore extends NavigatorObserver {
  final ValueNotifier<int> cambi = ValueNotifier<int>(0);

  /// Le rotte vive, dal fondo della pila alla cima.
  final List<Route<dynamic>> pila = <Route<dynamic>>[];

  void _segnala() => cambi.value++;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pila.add(route);
    _segnala();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pila.remove(route);
    _segnala();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pila.remove(route);
    _segnala();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) pila.remove(oldRoute);
    if (newRoute != null) pila.add(newRoute);
    _segnala();
  }
}

/// Il punto unico: legge l'elenco, decide, e disegna la striscia sopra tutto.
class EsploraScope extends StatefulWidget {
  const EsploraScope({
    super.key,
    required this.observatore,
    required this.child,
  });

  final EsploraObservatore observatore;
  final Widget child;

  @override
  State<EsploraScope> createState() => _EsploraScopeState();
}

class _EsploraScopeState extends State<EsploraScope> {
  bool _aperta = false;
  String? _schermata;

  /// Vero se questa e' la primissima apertura dell'app in assoluto.
  ///
  /// Si legge una volta sola e si tiene: `onboarding.done` diventa vero appena
  /// il Risveglio finisce, e da quel momento la risposta cambierebbe. Senza
  /// questo fermo la striscia si sarebbe aperta da sola al primo ritorno alla
  /// home invece che alla prima apertura, cioe' quasi subito e per sempre.
  bool? _primissimaApertura;

  @override
  void initState() {
    super.initState();
    widget.observatore.cambi.addListener(_pilaCambiata);
    // LA PRIMA PASSATA VA FATTA A MANO. La rotta iniziale viene spinta prima
    // che questo scope si monti, quindi l'osservatore non la annuncia mai:
    // senza questa riga la striscia non compariva affatto sulla home.
    _pilaCambiata();
  }

  @override
  void dispose() {
    widget.observatore.cambi.removeListener(_pilaCambiata);
    super.dispose();
  }

  void _pilaCambiata() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(_aggiornaSchermata);
    });
  }

  /// Cerca nell'albero la schermata piu' in alto fra quelle dichiarate.
  ///
  /// Si guarda il TIPO del widget, non un nome di rotta. Le rotte si impilano
  /// nell'Overlay in ordine, quindi l'ultima dichiarata che si incontra
  /// visitando l'albero e' quella che la persona sta guardando.
  void _aggiornaSchermata() {
    String? trovata;
    void visita(Element e) {
      final nome = e.widget.runtimeType.toString();
      if (presenzaPerSchermata.containsKey(nome)) trovata = nome;
      e.visitChildren(visita);
    }

    context.visitChildElements(visita);
    _schermata = trovata;
  }

  @override
  Widget build(BuildContext context) {
    // La primissima apertura si legge appena l'onboarding ha risolto, poi il
    // valore resta fermo.
    final onboarding = context.watch<OnboardingController>();
    if (_primissimaApertura == null && onboarding.resolved) {
      _primissimaApertura = onboarding.needsOnboarding;
      if (_primissimaApertura!) _aperta = true;
    }

    final presenza = presenzaPerSchermata[_schermata];
    final siVede = presenza == PresenzaEsplora.presente;

    // LE SI FA POSTO, non le si mette sopra il contenuto.
    //
    // Esplora e' un `Positioned` sopra tutto: senza questo, in chat copriva
    // meta' del campo di scrittura e il pulsante di invio, e li rendeva anche
    // INTOCCABILI, perche' i tocchi finivano su di lei. Si aggiunge la sua
    // altezza al padding basso, che e' il canale da cui ogni `SafeArea` gia'
    // esistente prende le sue distanze: cosi' la correzione sta qui, in un
    // posto solo, e non dentro le schermate.
    final mq = MediaQuery.of(context);
    final quantoOccupa = !siVede
        ? 0.0
        : (_aperta
            ? EsploraStriscia.altezzaAperta
            : EsploraStriscia.altezzaLinguetta);

    return Stack(
      children: [
        // LO SCORRIMENTO GOVERNA LA STRISCIA, e nient'altro. Scorrendo verso il
        // basso, cioe' mentre si legge, la striscia si ritrae a linguetta;
        // scorrendo verso l'alto torna. E' il gesto che tutti conoscono, e non
        // va spiegato.
        //
        // **Nessun timer.** Una chiusura automatica dopo qualche secondo e' la
        // distrazione che si voleva togliere, e ha un difetto peggiore: se la
        // striscia si abbassa mentre il dito ci sta andando, il tocco va a
        // vuoto oppure colpisce cio' che sta sotto.
        NotificationListener<UserScrollNotification>(
          onNotification: (n) {
            if (!siVede) return false;
            if (n.direction == ScrollDirection.reverse && _aperta) {
              setState(() => _aperta = false);
            } else if (n.direction == ScrollDirection.forward && !_aperta) {
              setState(() => _aperta = true);
            }
            return false;
          },
          child: MediaQuery(
            data: mq.copyWith(
              padding: mq.padding.copyWith(
                  bottom: mq.padding.bottom + quantoOccupa),
              viewPadding: mq.viewPadding.copyWith(
                  bottom: mq.viewPadding.bottom + quantoOccupa),
            ),
            child: widget.child,
          ),
        ),
        if (siVede)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: EsploraStriscia(
              aperta: _aperta,
              onLinguetta: () => setState(() => _aperta = true),
              onChiudi: () => setState(() => _aperta = false),
            ),
          ),
      ],
    );
  }
}

/// La striscia: una linguetta sottile che si apre, e mai un vicolo cieco.
class EsploraStriscia extends StatelessWidget {
  const EsploraStriscia({
    super.key,
    required this.aperta,
    required this.onLinguetta,
    required this.onChiudi,
  });

  final bool aperta;
  final VoidCallback onLinguetta;
  final VoidCallback onChiudi;

  /// QUANTO SPAZIO SI PRENDE, in punti logici.
  ///
  /// Serve a farle posto invece che a coprirci sotto: `EsploraScope` aggiunge
  /// questi punti al padding basso, cosi' ogni `SafeArea` gia' esistente ne
  /// tiene conto da sola e nessuna schermata deve saperlo.
  ///
  /// **Sono due numeri che descrivono una resa, quindi scadono se la striscia
  /// cambia forma.** Li sorveglia `test/esplora_si_comporta_test.dart`, che
  /// disegna la striscia davvero e confronta l'altezza vera con questi valori:
  /// senza quella prova sarebbero due costanti che dichiarano il falso, ed e'
  /// gia' successo su questo progetto.
  static const double altezzaLinguetta = 35;
  static const double altezzaAperta = 62;

  /// Il titolo a video. Un sostantivo e non un verbo: su una linguetta sottile
  /// un sostantivo si legge come l'etichetta di un luogo, un verbo come un
  /// comando di cui non si sa dove porti.
  static const String titolo = 'Esplora';

  @override
  Widget build(BuildContext context) {
    // LA PALETTE SI LEGGE DALLA SUA FONTE, non da MaestroScope.
    //
    // Esplora vive nel builder di MaterialApp, quindi sta SOPRA lo scope del
    // Maestro: `context.palette` qui non trova niente e l'assert cade. Il dato
    // pero' e' lo stesso che lo scope legge, `MaestroController.activeKey`, e
    // preso da li' la striscia resta tinta del Maestro attivo senza aprire una
    // seconda porta sullo stesso dato.
    final palette =
        MaestroPalette.forKey(context.watch<MaestroController>().activeKey);
    // Con Riduci Movimento il cambio di stato e' immediato, senza transizione.
    final senzaMoto = MediaQuery.of(context).disableAnimations;
    final durata =
        senzaMoto ? Duration.zero : const Duration(milliseconds: 220);

    return AnimatedSize(
      duration: durata,
      alignment: Alignment.bottomCenter,
      child: aperta
          ? _Aperta(palette: palette, onChiudi: onChiudi)
          : _Linguetta(palette: palette, onTap: onLinguetta),
    );
  }
}

class _Linguetta extends StatelessWidget {
  const _Linguetta({required this.palette, required this.onTap});

  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${EsploraStriscia.titolo}, apri le vie',
      child: GestureDetector(
        key: const Key('esplora_linguetta'),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: palette.deepest.withValues(alpha: 0.92),
            border: Border(
                top: BorderSide(
                    color: palette.gold.withValues(alpha: 0.35), width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: SpacingTokens.xs, horizontal: SpacingTokens.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(EsploraStriscia.titolo,
                      // La famiglia si dichiara: Esplora vive nel builder e non
                      // eredita il tema tipografico delle schermate. Senza,
                      // usciva col font di ripiego, che in cattura sono blocchi
                      // neri e sul telefono sarebbe una lettera diversa da
                      // tutte le altre.
                      style: TextStyle(
                          fontFamily: TypographyTokens.displayFamily,
                          color: palette.goldSoft,
                          fontSize: 13,
                          letterSpacing: 0.6)),
                  const SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_up,
                      size: 18, color: palette.goldSoft),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Aperta extends StatelessWidget {
  const _Aperta({required this.palette, required this.onChiudi});

  final MaestroPalette palette;
  final VoidCallback onChiudi;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('esplora_aperta'),
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.96),
        border: Border(
            top: BorderSide(
                color: palette.gold.withValues(alpha: 0.35), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: SpacingTokens.sm, horizontal: SpacingTokens.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Via(
                key: const Key('esplora_cerchio'),
                etichetta: 'Il Cerchio',
                icona: Icons.brightness_3,
                palette: palette,
                onTap: () => EsploraNavigazione.alCerchio(context),
              ),
              for (final m in Maestro.fixedOrder)
                _Via(
                  key: Key('esplora_${m.id}'),
                  etichetta: m.displayName,
                  icona: m.icon,
                  palette: palette,
                  onTap: () => EsploraNavigazione.alDominio(context, m),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Via extends StatelessWidget {
  const _Via({
    super.key,
    required this.etichetta,
    required this.icona,
    required this.palette,
    required this.onTap,
  });

  final String etichetta;
  final IconData icona;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icona, size: 20, color: palette.goldSoft),
          const SizedBox(height: 2),
          Text(etichetta,
              style: TextStyle(
                  fontFamily: TypographyTokens.displayFamily,
                  color: palette.goldSoft,
                  fontSize: 11)),
        ],
      ),
    );
  }
}

/// LE VIE DI ESPLORA, CON LA REGOLA CONTRO IL DOPPIONE.
///
/// **Il tasto indietro non salta alla home e non schiaccia la pila:** torna
/// alla schermata precedente, come si aspetta chiunque e come fa il tasto
/// indietro di sistema. Si evita soltanto che la STESSA schermata finisca due
/// volte nella pila: se dal Consiglio si torna da un Maestro la cui chat e'
/// gia' aperta piu' in basso, ci si TORNA invece di aprirne una seconda. Con
/// questa sola regola la catena chat, Consiglio, chat non cresce oltre tre
/// schermate.
class EsploraNavigazione {
  const EsploraNavigazione._();

  /// L'osservatore che tiene la pila. Lo monta `app.dart` insieme allo scope:
  /// e' un dato solo, non due.
  static EsploraObservatore? osservatore;

  /// Torna al Cerchio senza aggiungere nulla alla pila: il Cerchio e' la rotta
  /// piu' in fondo, quindi si sfilano quelle sopra.
  static void alCerchio(BuildContext context) {
    context.read<NavigationController>().goToSantuario();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  /// Apre il dominio di un Maestro, oppure ci TORNA se e' gia' nella pila.
  static void alDominio(BuildContext context, Maestro maestro) {
    context.read<MaestroController>().selectMaestro(maestro);
    final servizi = context.read<AppServices>();
    apriUnaVoltaSola(
      context,
      tipo: 'DomainScreen',
      costruisci: () =>
          DomainScreen.route(maestro: maestro, services: servizi),
    );
  }

  /// Spinge la rotta solo se una schermata dello stesso tipo non e' gia' viva
  /// piu' in basso; in quel caso ci si torna.
  ///
  /// Il confronto e' sul TIPO della schermata, lo stesso criterio con cui
  /// `esplora_schermate.dart` la classifica: cosi' non serve dare un nome a
  /// ogni rotta, e non c'e' un secondo elenco da tenere allineato.
  static void apriUnaVoltaSola(
    BuildContext context, {
    required String tipo,
    required Route<void> Function() costruisci,
  }) {
    final oss = osservatore;
    if (oss != null) {
      for (var i = oss.pila.length - 1; i >= 0; i--) {
        if (tipoDellaRotta(oss.pila[i]) == tipo) {
          Navigator.of(context).popUntil((r) => identical(r, oss.pila[i]));
          return;
        }
      }
    }
    Navigator.of(context).push(costruisci());
  }

  /// Il tipo di schermata che una rotta mostra, letto dall'albero costruito.
  ///
  /// Torna null finche' la rotta non ha un sottoalbero, cioe' finche' non e'
  /// stata disegnata almeno una volta: e' un limite dichiarato, non un ripiego
  /// muto, e non morde perche' la regola serve su rotte gia' viste.
  static String? tipoDellaRotta(Route<dynamic> rotta) {
    if (rotta is! ModalRoute) return null;
    String? trovato;
    void visita(Element e) {
      final nome = e.widget.runtimeType.toString();
      if (presenzaPerSchermata.containsKey(nome)) trovato ??= nome;
      if (trovato == null) e.visitChildren(visita);
    }

    final ctx = rotta.subtreeContext;
    if (ctx is Element) ctx.visitChildren(visita);
    return trovato;
  }
}
