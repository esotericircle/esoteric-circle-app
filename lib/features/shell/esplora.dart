import 'dart:math' as math;

import 'package:flutter/material.dart';
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
import 'vie_del_cerchio.dart';
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
  /// QUANTO E' RITRATTA, IN PUNTI, e non se e' aperta o chiusa.
  ///
  /// **Regola di Mauro del 6 agosto 2026, che sostituisce quella dei due
  /// stati.** Va da zero, tutte le vie in vista, a `EsploraStriscia.corsa`,
  /// vie rientrate dietro la linguetta. Un valore continuo e non un booleano:
  /// un booleano commutato da `UserScrollNotification` produce uno scatto, e
  /// uno scatto non si puo' seguire col dito.
  double _ritiro = 0;

  /// Vero quando il valore e' cambiato per un TOCCO e non per il dito che
  /// scorre: solo allora il cambio si anima, perche' il dito non c'e' e non
  /// c'e' niente da seguire.
  bool _perUnTocco = false;

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

  /// La schermata in cima alla pila.
  ///
  /// **Si chiede alla PILA, non si visita l'albero.** Visitare l'albero intero
  /// dentro un post frame callback aveva due difetti, ed erano tutti e due
  /// veri: costava una passata su tutto l'albero a ogni push e a ogni pop, e
  /// soprattutto guardava un albero in cui la rotta USCENTE e' ancora montata.
  /// Dopo un pop dal dominio trovava `DomainScreen`, decideva presente, e
  /// nessun altro evento arrivava piu' a correggerla: nel Santuario restavano
  /// due barre, quella del guscio e Esplora sopra. Misurato il 6 agosto 2026.
  ///
  /// L'osservatore invece toglie la rotta dalla pila in `didPop`, subito:
  /// `pila.last` e' gia' quella giusta quando l'evento arriva.
  void _aggiornaSchermata() {
    final pila = widget.observatore.pila;
    _schermata = pila.isEmpty
        ? null
        : EsploraNavigazione.tipoDellaRotta(pila.last);
  }

  @override
  Widget build(BuildContext context) {
    // La primissima apertura si legge appena l'onboarding ha risolto, poi il
    // valore resta fermo.
    final onboarding = context.watch<OnboardingController>();
    if (_primissimaApertura == null && onboarding.resolved) {
      _primissimaApertura = onboarding.needsOnboarding;
      // Alla primissima apertura si presenta aperta; a ogni altro ritorno
      // parte ritratta, che e' il fondo corsa.
      _ritiro = _primissimaApertura! ? 0 : EsploraStriscia.corsa;
    }

    final presenza = presenzaPerSchermata[_schermata];
    final siVede = presenza == PresenzaEsplora.presente;
    final senzaMoto = MediaQuery.of(context).disableAnimations;

    // LE SI FA POSTO, non le si mette sopra il contenuto.
    //
    // Esplora e' un `Positioned` sopra tutto: senza questo, in chat copriva
    // meta' del campo di scrittura e il pulsante di invio, e li rendeva anche
    // INTOCCABILI, perche' i tocchi finivano su di lei. Si aggiunge la sua
    // altezza al padding basso, che e' il canale da cui ogni `SafeArea` gia'
    // esistente prende le sue distanze: cosi' la correzione sta qui, in un
    // posto solo, e non dentro le schermate.
    // **LO SPAZIO CHE SI FA CAMBIA A SOGLIA, non a ogni pixel.** Il movimento
    // della striscia e' continuo, ma lo spazio riservato al contenuto non puo'
    // esserlo: cambiare il `MediaQuery` a ogni pixel di scorrimento vorrebbe
    // dire ricostruire il Navigator INTERO a ogni fotogramma del gesto, cioe'
    // pagare la fluidita' della striscia con quella di tutto il resto. Tenerlo
    // fermo all'altezza piena sprecherebbe invece cinquantasei punti ogni volta
    // che le vie sono rientrate. Passa quindi una volta sola per gesto, quando
    // il ritiro attraversa la meta' della corsa.
    final mq = MediaQuery.of(context);
    final quantoOccupa = !siVede
        ? 0.0
        : (_ritiro > EsploraStriscia.corsa / 2
            ? EsploraStriscia.altezzaLinguetta
            : EsploraStriscia.altezzaAperta);

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
        NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (!siVede) return false;
            // **SI GUARDA IL DITO, non l'avanzamento nella lista.** Il segno
            // dello scorrimento dipende da come la lista e' orientata: la chat
            // e' ROVESCIATA, quindi lo stesso gesto del dito produceva li' il
            // verso opposto rispetto a ogni altra schermata, e la striscia si
            // apriva leggendo invece di ritrarsi. Il dito invece e' la sola
            // cosa che la persona conosce, ed e' uguale ovunque.
            //
            // Fuori dal trascinamento, cioe' durante l'inerzia, il dito non
            // c'e': la striscia resta dov'e'. Segue il dito, e l'inerzia non e'
            // il dito.
            //
            // **Anche l'OLTRECORSA porta il dito**, e senza di lei la striscia
            // restava ferma proprio dove serve di piu': a lista finita, o in
            // una conversazione corta, il contenuto non ha piu' niente da
            // scorrere, quindi nessun aggiornamento di scorrimento nasce, e il
            // gesto per riaprire non arrivava. Una prova gia' esistente lo ha
            // preso subito.
            final dito = switch (n) {
              ScrollUpdateNotification u => u.dragDetails?.delta.dy,
              OverscrollNotification o => o.dragDetails?.delta.dy,
              _ => null,
            };
            if (dito == null || dito == 0) return false;
            setState(() {
              _perUnTocco = false;
              if (senzaMoto) {
                // Con Riduci Movimento non si segue niente: si commuta, che e'
                // esattamente cio' che quell'impostazione chiede.
                _ritiro = dito < 0 ? EsploraStriscia.corsa : 0;
              } else {
                // Dito verso l'alto, cioe' si legge: la striscia si ritrae di
                // altrettanto. Dito verso il basso: risale di altrettanto.
                _ritiro =
                    (_ritiro - dito).clamp(0.0, EsploraStriscia.corsa);
              }
            });
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
              ritiro: _ritiro,
              animato: _perUnTocco && !senzaMoto,
              onLinguetta: () => setState(() {
                _perUnTocco = true;
                _ritiro = 0;
              }),
              onChiudi: () => setState(() {
                _perUnTocco = true;
                _ritiro = EsploraStriscia.corsa;
              }),
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
    required this.ritiro,
    required this.onLinguetta,
    required this.onChiudi,
    this.animato = false,
  });

  /// Quanto e' rientrata, in punti, fra zero e [corsa]. E' un valore continuo
  /// perche' segue il dito: si veda `test/esplora_segue_il_dito_test.dart`.
  final double ritiro;

  /// Vero solo quando il cambio viene da un tocco: allora la striscia ci
  /// arriva in una transizione, perche' non c'e' nessun dito da seguire.
  final bool animato;

  final VoidCallback onLinguetta;
  final VoidCallback onChiudi;

  /// QUANTO SPAZIO SI PRENDE, in punti logici.
  ///
  /// Serve a farle posto invece che a coprirci sotto: `EsploraScope` aggiunge
  /// questi punti al padding basso, cosi' ogni `SafeArea` gia' esistente ne
  /// tiene conto da sola e nessuna schermata deve saperlo.
  ///
  /// **Sono numeri che descrivono una resa, quindi scadono se la striscia
  /// cambia forma.** Li sorveglia `test/esplora_si_comporta_test.dart`, che
  /// disegna la striscia davvero e confronta l'altezza vera con questi valori:
  /// senza quella prova sarebbero costanti che dichiarano il falso, ed e' gia'
  /// successo su questo progetto.
  static const double altezzaLinguetta = 35;

  /// LA CORSA: quanto il blocco delle vie puo' rientrare, cioe' la sua stessa
  /// altezza. E' la grandezza del movimento continuo: scorrendo di meta' corsa
  /// la striscia scende di meta' corsa.
  ///
  /// Misurata sulla resa vera, non stimata sui padding: cinquantasei punti.
  static const double corsa = 56;

  static const double altezzaAperta = altezzaLinguetta + corsa;

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
    // La transizione esiste solo per il tocco: mentre il dito scorre la
    // striscia e' gia' esattamente dove il dito l'ha messa, e interpolare
    // vorrebbe dire farla arrivare in ritardo.
    final durata =
        animato ? const Duration(milliseconds: 220) : Duration.zero;

    // UN MATERIAL TRASPARENTE, IN UN POSTO SOLO.
    //
    // Verificata l'ipotesi e regge: il testo della linguetta usciva con
    // `TextDecoration.underline`, mentre le voci della barra del guscio, che un
    // Material antenato ce l'hanno, uscivano con `none`. E' la firma di un
    // `Text` senza Material, e Esplora vive nello `Stack` del builder, fuori da
    // qualunque Scaffold. La correzione non e' `TextDecoration.none` sui
    // quattro stili, che curerebbe il sintomo in quattro punti: e' dare alla
    // striscia l'antenato che le manca, qui, una volta.
    // UN BLOCCO SOLO CHE SCORRE DIETRO UNA LINGUETTA CHE RESTA.
    //
    // Non ci sono piu' due contenuti che si sostituiscono: c'e' il blocco delle
    // vie, che scende di quanto il dito ha scorso, e sotto la linguetta, che
    // non si muove mai e lo copre man mano che rientra. Cosi' il movimento e'
    // una traduzione sola, continua, senza niente che compaia o sparisca, e la
    // linguetta resta sempre a vista: mai un vicolo cieco.
    //
    // Lo spazio in alto lasciato libero dalle vie che rientrano resta vuoto e
    // non intercetta i tocchi, perche' il blocco che li riceve si e' spostato
    // con loro.
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nessuna misura forzata sul blocco: si lascia che sia alto quanto il
          // suo contenuto e si dichiara quel numero in `corsa`, che una prova
          // confronta con la resa vera. Imporgli un'altezza lo farebbe
          // traboccare in silenzio il giorno in cui una via cambia disegno.
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: ritiro, end: ritiro),
            duration: durata,
            curve: Curves.easeOut,
            builder: (context, quanto, figlio) => Transform.translate(
              offset: Offset(0, quanto),
              child: figlio,
            ),
            child: _Vie(palette: palette),
          ),
          _Linguetta(
            palette: palette,
            // La linguetta e' la sola cosa toccabile che resta sempre: apre
            // quando le vie sono rientrate, richiude quando sono in vista.
            // **E' qui che `onChiudi` ha smesso di essere un parametro che
            // nessuno usava:** finche' la striscia aperta sostituiva la
            // linguetta, non c'era piu' niente da toccare per richiuderla.
            onTap: ritiro > corsa / 2 ? onLinguetta : onChiudi,
            // La freccia gira col movimento invece di scattare: e' lo stesso
            // valore continuo, letto da un'altra parte.
            versoIlBasso: 1 - (ritiro / corsa).clamp(0.0, 1.0),
          ),
        ],
      ),
    );
  }
}

class _Linguetta extends StatelessWidget {
  const _Linguetta({
    required this.palette,
    required this.onTap,
    required this.versoIlBasso,
  });

  final MaestroPalette palette;
  final VoidCallback onTap;

  /// Da zero, vie rientrate e freccia in su, a uno, vie in vista e freccia in
  /// giu'. Continuo come tutto il resto del movimento.
  final double versoIlBasso;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: versoIlBasso > 0.5
          ? '${EsploraStriscia.titolo}, richiudi le vie'
          : '${EsploraStriscia.titolo}, apri le vie',
      child: GestureDetector(
        key: const Key('esplora_linguetta'),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            // OPACA, e da oggi deve esserlo: e' lei a coprire le vie mentre
            // rientrano. A 0,92 le si vedeva trasparire attraverso la
            // linguetta per tutta la corsa, misurato sull'anteprima a meta'
            // strada. Non e' un dettaglio di gusto: due strati di testo
            // sovrapposti rendono illeggibili tutti e due.
            color: palette.deepest,
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
                  Transform.rotate(
                    angle: versoIlBasso * math.pi,
                    child: Icon(Icons.keyboard_arrow_up,
                        size: 18, color: palette.goldSoft),
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

/// IL BLOCCO DELLE VIE, l'unica parte che si muove.
class _Vie extends StatelessWidget {
  const _Vie({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('esplora_vie'),
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.96),
        border: Border(
            top: BorderSide(
                color: palette.gold.withValues(alpha: 0.35), width: 1)),
      ),
      // NESSUNA SAFE AREA QUI: il blocco non tocca piu' il bordo dello schermo,
      // perche' sotto di lui c'e' sempre la linguetta, che la sua distanza dal
      // bordo se la prende gia'. Tenerla avrebbe aggiunto una fascia vuota in
      // mezzo alla striscia sui telefoni con la barra dei gesti.
      child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: SpacingTokens.xs, horizontal: SpacingTokens.sm),
          // LE VIE VENGONO DALL'ELENCO UNICO, non da qui.
          //
          // Sono le stesse destinazioni della barra del guscio, viste da dove
          // quella barra non c'e'. Finche' le due liste sono state scritte a
          // mano hanno divergiuto: qui mancava il Passport e la voce del
          // Cerchio portava una mezzaluna di sistema invece del segno vero.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final via in ViaDelCerchio.tutte)
                _Via(
                  key: Key('esplora_${via.id}'),
                  via: via,
                  palette: palette,
                  onTap: () => EsploraNavigazione.vaiA(context, via),
                ),
            ],
          ),
        ),
    );
  }
}

class _Via extends StatelessWidget {
  const _Via({
    super.key,
    required this.via,
    required this.palette,
    required this.onTap,
  });

  final ViaDelCerchio via;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            via.icona(palette.goldSoft, 20),
            const SizedBox(height: 2),
            // IL NOME NON ALZA LA STRISCIA E NON SI SPEZZA.
            //
            // Con cinque vie invece di quattro lo spazio per ciascuna scende a
            // circa settanta punti, e "Il Cerchio" in Cinzel a undici ci sta
            // per un soffio. Andando a capo la striscia crescerebbe oltre i
            // sessantadue punti che dichiara, e `EsploraScope` userebbe un
            // numero falso per farle posto: si rimpicciolisce invece di
            // spezzarsi, come gia' fanno le tessere delle arti.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(via.etichetta,
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: TypographyTokens.displayFamily,
                      color: palette.goldSoft,
                      fontSize: 11)),
            ),
          ],
        ),
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

  /// IL NAVIGATOR SI CHIEDE ALL'OSSERVATORE, NON AL CONTESTO.
  ///
  /// **Misurato il 6 agosto 2026, ed era la terza delle tre cause possibili.**
  /// Nella chat i tocchi sulle voci non aprivano niente: il tocco arrivava
  /// benissimo, ma `Navigator.of(context)` sollevava "Navigator operation
  /// requested with a context that does not include a Navigator". Esplora vive
  /// nel `builder` di `MaterialApp`, che AVVOLGE il Navigator: il suo contesto
  /// ne e' antenato, non discendente, e `Navigator.of` cerca solo verso l'alto.
  /// La stessa cosa che le fa vedere le chat le impediva di aprirle.
  ///
  /// Non serve una `GlobalKey` nuova: un `NavigatorObserver` porta gia' lo
  /// stato del Navigator che osserva, e l'osservatore e' gia' il dato unico da
  /// cui si legge la pila. Una porta sola per tutte e due le cose.
  ///
  /// Se manca, **si dichiara invece di tacere**: una via che non porta da
  /// nessuna parte senza dire niente e' il difetto appena chiuso.
  static NavigatorState _navigatore() {
    final nav = osservatore?.navigator;
    if (nav == null) {
      throw StateError(
          'Esplora non ha un Navigator: EsploraNavigazione.osservatore deve '
          'essere lo stesso EsploraObservatore montato in navigatorObservers, '
          'e il Navigator deve essere gia\' costruito.');
    }
    return nav;
  }

  /// Dove porta una via, deciso dalla sua SPECIE e non da una riga scritta
  /// accanto a ciascuna voce: cosi' una via nuova nell'elenco non puo' restare
  /// senza destinazione, perche' il compilatore chiede cosa farne.
  static void vaiA(BuildContext context, ViaDelCerchio via) {
    switch (via.specie) {
      case SpecieDiVia.cerchio:
        alCerchio(context);
      case SpecieDiVia.maestro:
        alDominio(context, via.maestro!);
      case SpecieDiVia.passport:
        alPassport(context);
    }
  }

  /// Torna al Cerchio senza aggiungere nulla alla pila: il Cerchio e' la rotta
  /// piu' in fondo, quindi si sfilano quelle sopra.
  static void alCerchio(BuildContext context) {
    context.read<NavigationController>().goToSantuario();
    _navigatore().popUntil((r) => r.isFirst);
  }

  /// Il Cosmic Passport e' una VISTA del guscio, non una rotta: si dice al
  /// guscio quale vista mostrare e si sfilano le rotte sopra, esattamente come
  /// per il Cerchio. Spingere una rotta nuova avrebbe messo il Passport due
  /// volte nell'albero, una qui e una dentro il guscio.
  static void alPassport(BuildContext context) {
    context.read<NavigationController>().goToPassport();
    _navigatore().popUntil((r) => r.isFirst);
  }

  /// Apre il dominio di un Maestro, oppure ci TORNA se e' gia' nella pila.
  static void alDominio(BuildContext context, Maestro maestro) {
    context.read<MaestroController>().selectMaestro(maestro);
    final servizi = context.read<AppServices>();
    apriUnaVoltaSola(
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
  /// **Nessun `BuildContext` fra i parametri, e non e' una semplificazione:**
  /// il contesto di Esplora non vede il Navigator, quindi tenerlo qui sarebbe
  /// l'invito a rimetterci dentro `Navigator.of` e a riaprire il difetto del 6
  /// agosto 2026.
  static void apriUnaVoltaSola({
    required String tipo,
    required Route<void> Function() costruisci,
  }) {
    final oss = osservatore;
    if (oss != null) {
      for (var i = oss.pila.length - 1; i >= 0; i--) {
        if (tipoDellaRotta(oss.pila[i]) == tipo) {
          _navigatore().popUntil((r) => identical(r, oss.pila[i]));
          return;
        }
      }
    }
    _navigatore().push(costruisci());
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
