import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../account/account_screen.dart';
import '../calendario/calendario_degli_eventi_screen.dart';
import '../maestri/domain_screen.dart';
import '../../services/app_services.dart';
import 'dove_si_vede_la_barra.dart';
import 'navigation_controller.dart';
import '../../design_system/theme/maestro_scope.dart';
import 'santuario_bottom_bar.dart';
import 'vie_del_cerchio.dart';

/// LA BARRA DEL CERCHIO, UNA SOLA IN TUTTA L'APP.
///
/// **Decisione di Mauro del 6 agosto 2026.** Prima erano due: la barra storica
/// dentro `AppShell`, che si vedeva nel Santuario e nel Passport perche' quelle
/// sono le due viste del guscio, ed Esplora sopra il Navigator, che si vedeva
/// dove la prima non arrivava. Due superfici per le stesse cinque destinazioni
/// erano una di troppo. Esplora e' stata tolta e la barra storica si e'
/// spostata qui, cioe' sopra il Navigator, che e' il solo punto da cui si vedono
/// anche le rotte spinte sopra il guscio: le chat e i domini hanno un proprio
/// Scaffold, e dentro `AppShell` non li si raggiungeva.
///
/// **Cosa si e' salvato di Esplora**, perche' era lavoro misurato e serviva
/// identico: il governo del movimento continuo, che legge il DITO e non
/// l'avanzamento nella lista, e il `MediaQuery` che fa posto al contenuto
/// invece di coprirlo.
class BarraDelCerchio extends StatefulWidget {
  const BarraDelCerchio({
    super.key,
    required this.observatore,
    required this.child,
  });

  final OsservatoreDellaPila observatore;
  final Widget child;

  /// L'ALTEZZA CHE SI PRENDE, in punti logici.
  ///
  /// Serve a farle posto invece che a coprirci sotto: si aggiungono questi
  /// punti al padding basso, cosi' ogni `SafeArea` gia' esistente ne tiene
  /// conto da sola e nessuna schermata deve saperlo. **E' una misura che
  /// descrive una resa**, quindi una prova la confronta con l'altezza vera:
  /// centoventitre punti, misurati e non stimati, col titolo compreso.
  /// Il numero vive in [SantuarioBottomBar.altezzaResa], che ne ha bisogno
  /// per il fondo dietro il titolo: UNA porta, riletta da qui.
  static const double altezza = SantuarioBottomBar.altezzaResa;

  /// LA CORSA: quanto la barra puo' scendere prima di sparire del tutto.
  ///
  /// E' l'altezza intera, perche' qui non resta nessuna linguetta: la barra
  /// scompare e ricompare seguendo il dito. Scorrendo di meta' corsa scende di
  /// meta' corsa.
  static const double corsa = altezza;

  @override
  State<BarraDelCerchio> createState() => _BarraDelCerchioState();
}

class _BarraDelCerchioState extends State<BarraDelCerchio> {
  /// QUANTO E' SCESA, IN PUNTI, e non se e' aperta o chiusa.
  ///
  /// Un valore continuo e non un booleano: un booleano commutato da
  /// `UserScrollNotification` produce uno scatto, e uno scatto non si puo'
  /// seguire col dito.
  double _discesa = 0;

  /// Vero quando il valore e' cambiato per un TOCCO e non per il dito che
  /// scorre: solo allora il cambio si anima, perche' il dito non c'e' e non
  /// c'e' niente da seguire.
  bool _perUnTocco = false;

  String? _schermata;

  /// Di chi e' la schermata in cima, quando e' di un Maestro.
  ///
  /// Si legge QUI e non dentro il build della barra: durante il build l'albero
  /// della rotta appena spinta non e' ancora percorribile e la ricerca torna
  /// nulla, che a video vuol dire Il Cerchio acceso dentro la chat di Medora.
  /// Nel post frame callback la rotta e' montata, ed e' lo stesso momento in
  /// cui si legge il nome della schermata.
  Maestro? _maestro;

  @override
  void initState() {
    super.initState();
    widget.observatore.cambi.addListener(_pilaCambiata);
    // LA PRIMA PASSATA VA FATTA A MANO. La rotta iniziale viene spinta prima
    // che questo scope si monti, quindi l'osservatore non la annuncia mai:
    // senza questa riga la barra non comparirebbe affatto sulla home.
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
      if (mounted) {
        setState(() {
          _schermata = widget.observatore.schermataInCima();
          _maestro = NavigazioneDellaBarra.maestroCorrente;
          // Cambiando schermata la barra torna in vista: lo scorrimento di
          // prima apparteneva a un'altra lettura.
          _discesa = 0;
          _perUnTocco = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final siVede = barraSiVede(_schermata);
    final senzaMoto = MediaQuery.of(context).disableAnimations;

    // **LA BARRA SCIVOLA SOPRA IL CONTENUTO, E IL CONTENUTO NON SI MUOVE.**
    // Regola di Mauro del 6 agosto 2026, e chiude un difetto grave.
    //
    // Lo spazio riservato al contenuto e' COSTANTE, pari all'altezza della
    // barra, e non segue il movimento. Prima commutava fra zero e l'altezza
    // piena quando il ritiro passava la meta' della corsa, e commutare uno
    // spazio vuol dire RILAYARE cio' che ci sta dentro: misurato sull'app
    // montata, la carta del Maestro centrale cresceva di 66,42 punti e saliva
    // di 80,36 in un fotogramma solo, e in chat il campo di scrittura saltava
    // di 123. Non era il contenuto che scorreva: era il contenuto che veniva
    // ricomposto.
    //
    // **Il compromesso, dichiarato:** quando la barra e' nascosta resta una
    // fascia vuota alta quanto lei. E' il prezzo della fluidita', ed e' quello
    // che fanno i siti in cui la barra si ritrae. Se non piacera' si decidera'
    // guardandola, ma non si torna a uno spazio che commuta: quello e' lo
    // scatto.
    final mq = MediaQuery.of(context);
    final quantoOccupa = siVede ? BarraDelCerchio.altezza : 0.0;

    return Stack(
      children: [
        // LO SCORRIMENTO GOVERNA LA BARRA, e nient'altro. Nessun timer: una
        // barra che si abbassa da sola mentre il dito ci sta andando manda il
        // tocco a vuoto oppure colpisce cio' che sta sotto.
        NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (!siVede) return false;
            // **SI GUARDA IL DITO, non l'avanzamento nella lista.** Il segno
            // dello scorrimento dipende da come la lista e' orientata: la chat
            // e' ROVESCIATA, quindi lo stesso gesto del dito produceva li' il
            // verso opposto rispetto a ogni altra schermata. Il dito invece e'
            // la sola cosa che la persona conosce, ed e' uguale ovunque.
            //
            // **Anche l'OLTRECORSA porta il dito**, e senza di lei la barra
            // resterebbe ferma proprio dove serve di piu': a lista finita, o in
            // una conversazione corta, il contenuto non ha piu' niente da
            // scorrere, quindi nessun aggiornamento di scorrimento nasce.
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
                _discesa = dito < 0 ? BarraDelCerchio.corsa : 0;
              } else {
                // Dito verso l'alto, cioe' si legge: la barra scende di
                // altrettanto. Dito verso il basso: risale di altrettanto.
                _discesa =
                    (_discesa - dito).clamp(0.0, BarraDelCerchio.corsa);
              }
            });
            return false;
          },
          child: MediaQuery(
            data: mq.copyWith(
              padding:
                  mq.padding.copyWith(bottom: mq.padding.bottom + quantoOccupa),
              viewPadding: mq.viewPadding
                  .copyWith(bottom: mq.viewPadding.bottom + quantoOccupa),
            ),
            child: widget.child,
          ),
        ),
        if (siVede)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: _discesa, end: _discesa),
              duration: _perUnTocco && !senzaMoto
                  ? const Duration(milliseconds: 220)
                  : Duration.zero,
              curve: Curves.easeOut,
              builder: (context, quanto, figlio) => Transform.translate(
                offset: Offset(0, quanto),
                child: figlio,
              ),
              // LA BARRA E' QUELLA STORICA, non ridisegnata: stesse cinque
              // voci, stesse icone, stessa gerarchia fra accesa e smorzate.
              child: _LaBarra(maestro: _maestro, schermata: _schermata),
            ),
          ),
      ],
    );
  }
}

class _LaBarra extends StatelessWidget {
  const _LaBarra({required this.maestro, required this.schermata});

  /// Di chi e' la schermata in cima, letto quando la rotta e' montata.
  final Maestro? maestro;

  /// Il nome della schermata in cima, per riconoscere il Consiglio.
  final String? schermata;

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    // **LO SCOPE SE LO PORTA DIETRO, E IL COLORE VIENE DALLA ROTTA.**
    // Ordine 2163, voce 6: nella chat di Medora il fondo della barra
    // restava rosso perche' lo scope senza maestro seguiva il controller,
    // cioe' l'ultimo Maestro toccato altrove. Adesso: se la rotta ha un
    // proprietario, il suo colore; se la rotta e' il Consiglio, che non e'
    // di nessuno, il neutro; solo dentro il guscio si segue il Maestro
    // attivo, perche' li' "dove sei" lo dice la vista.
    // Fuori dal guscio = una rotta spinta sopra: dominio, chat, Consiglio.
    final fuoriDalGuscio = schermata != null &&
        schermata != 'SantuarioScreen' &&
        schermata != 'CosmicPassport';
    return MaestroScope(
      maestro: maestro,
      neutro: schermata == 'AskMaestriScreen',
      child: SantuarioBottomBar(
        view: nav.view,
        // DOVE SEI, ACCESA. Dentro il guscio lo dice la vista; fuori dal guscio
      // lo dice il Maestro di cui si sta guardando il dominio o la chat, che e'
      // lo stesso dato da cui la palette prende il colore.
        maestroCorrente: maestro,
        fuoriDalGuscio: fuoriDalGuscio,
        onSantuario: () => NavigazioneDellaBarra.alCerchio(context),
        onMaestro: (m) => NavigazioneDellaBarra.alDominio(context, m),
        onPassport: () => NavigazioneDellaBarra.alPassport(context),
      ),
    );
  }
}

/// L'OSSERVATORE DELLA PILA, che dice quale schermata sta in cima.
///
/// **Si chiede alla PILA, non si visita l'albero.** Visitare l'albero intero
/// dentro un post frame callback aveva due difetti, ed erano tutti e due veri:
/// costava una passata su tutto l'albero a ogni push e a ogni pop, e soprattutto
/// guardava un albero in cui la rotta USCENTE e' ancora montata. Dopo un pop dal
/// dominio trovava `DomainScreen`, decideva presente, e nessun altro evento
/// arrivava piu' a correggerla: nel Santuario restavano due barre. Misurato il 6
/// agosto 2026.
class OsservatoreDellaPila extends NavigatorObserver {
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

  /// Il nome di classe della schermata in cima alla pila.
  String? schermataInCima() =>
      pila.isEmpty ? null : tipoDellaRotta(pila.last);

  /// Il Maestro di cui parla la schermata in cima, quando ce n'e' uno.
  ///
  /// **Si chiede alla ROTTA e non al controller**, e la ragione e' misurata:
  /// il dominio chiama `selectMaestro`, quindi il controller lo sa, ma la chat
  /// no: dichiara il suo Maestro al `MaestroScope` che si monta addosso, ed e'
  /// giusto cosi', perche' quel colore appartiene alla rotta e non allo stato
  /// globale. Leggendo il solo controller la barra accendeva Il Cerchio dentro
  /// la chat di Medora, visto sull'anteprima.
  ///
  /// Si guarda quindi lo stesso posto in cui la schermata lo ha dichiarato.
  Maestro? maestroInCima() {
    if (pila.isEmpty) return null;
    final rotta = pila.last;
    if (rotta is! ModalRoute) return null;
    Maestro? trovato;
    void visita(Element e) {
      final w = e.widget;
      if (w is MaestroScope && w.maestro != null) {
        trovato ??= w.maestro;
      }
      if (trovato == null) e.visitChildren(visita);
    }

    final ctx = rotta.subtreeContext;
    if (ctx is Element) ctx.visitChildren(visita);
    return trovato;
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
      // **I NOMI CONOSCIUTI SONO DUE ELENCHI, ordine AQ voce 03.** Qui si
      // guardava solo la mappa della barra storica, quindi ogni scena del
      // rito rispondeva nulla, e per il nulla la barra sottile si vede: e'
      // il motivo per cui compariva sull'Animale Guida e sul Bentornato
      // benche' il Risveglio fosse gia' dichiarato fra le soglie.
      if (nomiDiSchermataConosciuti.contains(nome)) trovato ??= nome;
      if (trovato == null) e.visitChildren(visita);
    }

    final ctx = rotta.subtreeContext;
    if (ctx is Element) ctx.visitChildren(visita);
    return trovato;
  }
}

/// DOVE PORTANO LE VOCI DELLA BARRA, da sopra il Navigator.
class NavigazioneDellaBarra {
  const NavigazioneDellaBarra._();

  /// L'osservatore che tiene la pila. Lo monta `app.dart` insieme alla barra:
  /// e' un dato solo, non due.
  static OsservatoreDellaPila? osservatore;

  /// Il Maestro di cui si sta guardando il dominio, la chat o il Consiglio.
  ///
  /// Nullo dentro il guscio, dove "dove sei" lo dice gia' la vista.
  static Maestro? get maestroCorrente {
    final oss = osservatore;
    if (oss == null) return null;
    final cima = oss.schermataInCima();
    if (cima == null || cima == 'SantuarioScreen' || cima == 'CosmicPassport') {
      return null;
    }
    // IL CONSIGLIO NON E' DI NESSUNO DEI TRE, ordine 2163 voce 6: la
    // schermata porta lo scope del Maestro da cui la si e' aperta, ma quello
    // e' il colore della PROVENIENZA, non della stanza. Con questo ramo
    // assente la barra accendeva Caligo dentro il Consiglio, visto da Mauro.
    if (cima == 'AskMaestriScreen') return null;
    return oss.maestroInCima();
  }

  /// IL NAVIGATOR SI CHIEDE ALL'OSSERVATORE, NON AL CONTESTO.
  ///
  /// La barra vive nel `builder` di `MaterialApp`, che AVVOLGE il Navigator: il
  /// suo contesto ne e' antenato, non discendente, e `Navigator.of` cerca solo
  /// verso l'alto, quindi solleverebbe. La stessa cosa che le fa vedere le chat
  /// le impedirebbe di aprirle. Un `NavigatorObserver` porta gia' lo stato del
  /// Navigator che osserva: una porta sola per tutte e due le cose.
  static NavigatorState _navigatore() {
    final nav = osservatore?.navigator;
    if (nav == null) {
      throw StateError(
          'La barra non ha un Navigator: NavigazioneDellaBarra.osservatore '
          'deve essere lo stesso montato in navigatorObservers.');
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

  /// IL CONTESTO DEL NAVIGATOR, per chi vive sopra di lui. Ordine AL voce
  /// 08: la capsula apre il foglio del borsellino, e un foglio ha bisogno di
  /// un contesto DENTRO il Navigator. Questo e' quello del Navigator stesso,
  /// che sta sotto il pavimento dello scope e sotto i provider dell'app.
  static BuildContext contestoDelNavigatore() => _navigatore().context;

  /// La via all'account da sopra il Navigator, per il volto della barra.
  static void allAccount() {
    _navigatore().push(AccountScreen.route());
  }

  /// La via al Calendario degli Eventi, dal centro della barra sottile.
  /// Ordine AN voce 02.
  static void alCalendario() {
    _navigatore().push(CalendarioDegliEventiScreen.route());
  }

  /// Torna al Cerchio senza aggiungere nulla alla pila: il Cerchio e' la rotta
  /// piu' in fondo, quindi si sfilano quelle sopra.
  static void alCerchio(BuildContext context) {
    context.read<NavigationController>().goToSantuario();
    _navigatore().popUntil((r) => r.isFirst);
  }

  /// Il Cosmic Passport e' una VISTA del guscio, non una rotta: si dice al
  /// guscio quale vista mostrare e si sfilano le rotte sopra, esattamente come
  /// per il Cerchio.
  static void alPassport(BuildContext context) {
    context.read<NavigationController>().goToPassport();
    _navigatore().popUntil((r) => r.isFirst);
  }

  /// Apre il dominio di un Maestro, oppure ci TORNA se e' gia' nella pila.
  ///
  /// **IL COLORE CAMBIA INSIEME ALLA ROTTA, MAI PRIMA.** La versione
  /// precedente chiamava `selectMaestro` PRIMA di decidere se muoversi: quando
  /// il confronto sbagliava stanza, il colore virava e la rotta restava, e a
  /// video il tema dichiarava un passaggio mai avvenuto. Visto sul telefono il
  /// 7 agosto 2026, dal dominio di Medora toccando Caligo. Un colore che
  /// cambia da solo e' peggio di un tocco a vuoto: mente. Qui il Maestro si
  /// seleziona dentro `apriUnaVoltaSola`, nel punto esatto in cui il movimento
  /// e' deciso, cosi' non esiste un cammino che cambia il colore senza
  /// cambiare la rotta.
  static void alDominio(BuildContext context, Maestro maestro) {
    final controller = context.read<MaestroController>();
    final servizi = context.read<AppServices>();
    apriUnaVoltaSola(
      destinazione: DestinazioneDominio(maestro),
      quandoCiSiMuove: () => controller.selectMaestro(maestro),
      costruisci: () =>
          DomainScreen.route(maestro: maestro, services: servizi),
    );
  }

  /// Spinge la rotta solo se la stessa DESTINAZIONE non e' gia' viva piu' in
  /// basso; in quel caso ci si torna.
  ///
  /// **Serve ancora, e non e' un residuo di Esplora.** La barra porta alle
  /// stesse cinque destinazioni da ogni schermata, quindi senza questa regola
  /// bastano due tocchi per avere due domini dello stesso Maestro impilati, e
  /// il tasto indietro ne chiederebbe due per uscire da una sola stanza.
  ///
  /// **Il confronto e' sulla DESTINAZIONE, non sul tipo ne' sul nome.** Il
  /// confronto sul nome di classe, `'DomainScreen'`, faceva di tre stanze una
  /// sola: dal dominio di Medora il tocco su Caligo TORNAVA da Medora invece
  /// di aprire Caligo, perche' una stanza di quel tipo c'era gia'. Un nome poi
  /// e' una stringa che chiunque puo' scrivere diversa, e un tipo veste tre
  /// stanze: la destinazione, rotta piu' argomento, la dichiara la fabbrica
  /// della rotta dentro `RouteSettings.arguments`, tipizzata, e qui la si
  /// confronta con `==`.
  ///
  /// [quandoCiSiMuove] corre nel punto esatto in cui il movimento e' deciso,
  /// sia che si torni sia che si apra: e' il posto dello stato che deve
  /// seguire la rotta, il colore del Maestro, e non puo' correre prima del
  /// confronto per la ragione scritta su [alDominio].
  static void apriUnaVoltaSola({
    required Object destinazione,
    required Route<void> Function() costruisci,
    VoidCallback? quandoCiSiMuove,
  }) {
    final oss = osservatore;
    if (oss != null) {
      for (var i = oss.pila.length - 1; i >= 0; i--) {
        if (oss.pila[i].settings.arguments == destinazione) {
          quandoCiSiMuove?.call();
          _navigatore().popUntil((r) => identical(r, oss.pila[i]));
          return;
        }
      }
    }
    quandoCiSiMuove?.call();
    _navigatore().push(costruisci());
  }
}
