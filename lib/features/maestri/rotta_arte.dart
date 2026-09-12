import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/arts/arti_preferite.dart';
import '../../core/misura/misura_del_ritorno.dart';
import '../../core/misura/registro_del_ritorno.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// La soglia di un'arte: il suo colore e il suo cuore, in un punto unico.
///
/// Le due cose che ogni arte deve avere stavano sparse. Il colore lo metteva la
/// tessera che apriva l'arte, quindi valeva per una strada sola; il cuore per
/// metterla fra le proprie non esisteva affatto. Qui stanno insieme, e chi
/// aggiunge un'arte domani le ottiene entrambe con una riga, senza doverselo
/// ricordare.
///
/// Prende il posto del MaestroScope nelle rotte delle arti: fa la stessa cosa,
/// piu' il cuore.
class SogliaArte extends StatefulWidget {
  const SogliaArte({
    super.key,
    required this.id,
    required this.maestro,
    required this.child,
  });

  /// L'identificativo dell'arte nel catalogo, quello che lo scaffale personale
  /// usa per ricordarsela.
  final String id;

  /// Il proprietario, che decide il colore dal primo frame.
  final Maestro maestro;

  final Widget child;

  @override
  State<SogliaArte> createState() => _SogliaArteState();
}

class _SogliaArteState extends State<SogliaArte> {
  /// **IL RECLAMO DEL CUORE VIVE QUANTO L'ARTE, non quanto un fotogramma.**
  /// Ordine DD voce 07, 10 settembre 2026.
  ///
  /// **Il fatto del fondatore**: nell'Oroscopo si vedono due cuoricini.
  /// Fotografato sul telefono 767f596c: appena aperto ce n'e' **uno**, premuto
  /// *Interroga il cielo* ce ne sono **due**, affiancati in alto a destra.
  ///
  /// **Qui stava un `ValueNotifier<bool>(false)` costruito DENTRO `build`**, e
  /// quella riga e' il difetto per intero. Ogni ricomposizione di un antenato
  /// ne fabbricava uno nuovo, spento: il cuore sovrapposto lo guardava e
  /// tornava a disegnarsi, il cuore della barra rialzava il reclamo **ma solo
  /// nel giro dopo la fine del fotogramma**. Il fotogramma in mezzo veniva
  /// disegnato con due cuori, e quando le ricomposizioni si susseguono quel
  /// fotogramma e' quello che si guarda.
  ///
  /// **REGOLA C, e i padri sono due.** La riga nasce il 30 luglio 2026 col
  /// commit `b49ab6fd`, l'ordine AL voce 08 che creo' [BarraArte]: allora era
  /// **latente**, perche' nelle schermate senza barra nessuno reclamava niente
  /// e il cuore sovrapposto era l'unico. **L'ordine DC voce 15, 10 settembre
  /// 2026, l'ha resa visibile** dando un cuore anche ad [AngoloDellaBarra]:
  /// da quel momento nell'Oroscopo i cuori sono due, e uno dei due si spegne
  /// un fotogramma troppo tardi.
  ///
  /// **Adesso e' un campo dello Stato**: nasce una volta con l'arte, non lo
  /// tocca nessuna ricomposizione, e si spegne quando l'arte si chiude.
  final ReclamoDelCuore _reclamato = ReclamoDelCuore();

  @override
  void dispose() {
    _reclamato.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // **IL RITO COMINCIATO SI SEGNA QUI. Ordine CC voce 09.**
    //
    // Questa e' la soglia di OGNI arte: ventidue schermate ci passano, e
    // nessun'altra riga dell'app le vede tutte. Il contesto e'
    // l'identificativo dell'arte nel catalogo, che e' un elenco chiuso
    // scritto da noi: non e' testo di nessuno.
    //
    // **Sta in initState e non in build**, perche' un'arte si ricostruisce
    // decine di volte mentre la si usa e il rito comincia una volta sola.
    RegistroDelRitorno.segnalo(EventoDelRitorno.ritoCominciato,
        contesto: widget.id);
  }

  @override
  Widget build(BuildContext context) => MaestroScope(
        maestro: widget.maestro,
        child: ArteCorrente(
          id: widget.id,
          reclamato: _reclamato,
          child: ConCuore(id: widget.id, child: widget.child),
        ),
      );
}

/// **IL RECLAMO DEL CUORE SI CONTA, non si accende e si spegne.** Ordine DD
/// voce 07, 10 settembre 2026.
///
/// **Il fatto del fondatore**: nell'Oroscopo si vedono due cuoricini.
/// Fotografato sul telefono 767f596c, e la fotografia dice quando: appena
/// aperto ce n'e' **uno**, premuto *Interroga il cielo* ce ne sono **due**,
/// affiancati in alto a destra, e restano li'.
///
/// **QUI C'ERA UN BOOLEANO, E DUE MANI CHE LO TOCCAVANO.** Chi prende in
/// carico il cuore lo alza, e il cuore sovrapposto si toglie. Ma i
/// dichiaranti sono **due**, non uno:
///
/// - [CuoreNellaBarra], che vive quanto la schermata;
/// - la corsa dello zodiaco dell'Oroscopo, che copre tutto lo schermo mentre
///   il cielo si interroga e non vuole un cuore che le galleggi sopra.
///
/// La corsa arriva, alza il reclamo che era gia' alzato, e **quando se ne va
/// lo abbassa**. Il cuore della barra e' ancora li' e lo vuole ancora alzato,
/// ma nessuno glielo chiede piu': **l'ultimo che esce spegne la luce anche a
/// chi e' rimasto dentro**.
///
/// **REGOLA C, e i padri sono due.** Il booleano nasce il 30 luglio 2026 col
/// commit `b49ab6fd`, ordine AL voce 08, quando i dichiaranti erano uno solo e
/// contarli non serviva. Il secondo dichiarante arriva il 29 agosto 2026 con
/// **l'ordine CC voce 03**, la corsa dello zodiaco. Da allora il difetto
/// c'era e non si vedeva, perche' nell'Oroscopo il cuore sovrapposto era
/// l'unico: **l'ordine DC voce 15, 10 settembre 2026**, dando un cuore anche
/// ad [AngoloDellaBarra], ha reso visibile in due segni cio' che prima era
/// solo un segno che tornava.
///
/// **Adesso e' un contatore.** Ognuno prende e lascia il suo, e il cuore
/// sovrapposto si toglie finche' resta anche un solo dichiarante. Un booleano
/// condiviso da due e' sempre lo stesso difetto in agguato, e il contatore lo
/// rende **impossibile per costruzione** invece che corretto per attenzione.
class ReclamoDelCuore extends ValueNotifier<bool> {
  ReclamoDelCuore() : super(false);

  int _quanti = 0;

  /// **CHI LASCIA IL CARICO LO FA UN FOTOGRAMMA DOPO**, e in quel fotogramma
  /// l arte puo essere gia chiusa: senza questa memoria il rilascio in
  /// ritardo cade su un notificatore smontato e solleva *was used after being
  /// disposed*. Quando l arte se ne va, il carico non interessa piu' a
  /// nessuno.
  bool _spento = false;

  /// Quanti lo tengono in carico adesso. Serve alle guardie.
  int get quanti => _quanti;

  /// Un dichiarante in piu' prende in carico il cuore.
  void prendi() {
    if (_spento) return;
    _quanti++;
    value = _quanti > 0;
  }

  /// Un dichiarante se ne va. Sotto zero non si scende: un rilascio di
  /// troppo non deve poter spegnere il carico di un altro.
  void lascia() {
    if (_spento) return;
    if (_quanti > 0) _quanti--;
    value = _quanti > 0;
  }

  @override
  void dispose() {
    _spento = true;
    super.dispose();
  }
}

/// Nessuno la ascolta davvero: serve solo quando il cuore vive fuori da un'arte.
final ReclamoDelCuore _mai = ReclamoDelCuore();

/// LA BARRA IN ALTO DELLE SCHERMATE D'ARTE: un solo posto dove si dichiarano le
/// azioni, e le azioni non si sovrappongono per costruzione.
///
/// **La segnalazione.** Il cuore dorato pieno era disegnato SOPRA il cerchietto
/// della "i", di cui restava visibile solo la meta' destra. Tre schermate, Test
/// Archetipo, Estrazione Rune e Costellazione del Viso, e non dipendeva dalla
/// larghezza: i due elementi occupavano lo stesso posto, quindi si
/// sovrapponevano a qualunque misura. Il cuore dei preferiti era stato montato
/// dove c'era gia' qualcosa.
///
/// **Perche' non ho corretto le tre schermate una per una.** Il difetto non era
/// in nessuna delle tre: era che non esisteva un posto solo dove le azioni della
/// barra si dichiarano, quindi due autori diversi hanno messo due cose nello
/// stesso angolo senza potersi accorgere l'uno dell'altro. Correggerle a mano
/// avrebbe lasciato la quarta schermata libera di rifare lo stesso.
///
/// Qui le azioni stanno in una riga: il cuore e' l'ultima, dopo quelle della
/// schermata, e due elementi di una riga non possono sovrapporsi.
class BarraArte extends StatefulWidget implements PreferredSizeWidget {
  const BarraArte({
    super.key,
    required this.titolo,
    this.azioni = const [],
    this.leading,
  });

  final Widget titolo;

  /// Le azioni della schermata. Il cuore NON va messo qui: lo aggiunge la barra.
  final List<Widget> azioni;

  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<BarraArte> createState() => _BarraArteState();
}

class _BarraArteState extends State<BarraArte> {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppBar(
      backgroundColor: palette.deepest.withValues(alpha: 0.35),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: palette.goldSoft),
      automaticallyImplyLeading: false,
      // **IL CUORE STA IN ALTO A DESTRA, ordine CQ voce 1.02, 3 settembre
      // 2026, e la decisione e' del fondatore.**
      //
      // **Da dove veniva.** L'ordine AL voce 08 lo aveva messo al capo
      // SINISTRO, accanto alla freccia Indietro, quando l'angolo destro
      // apparteneva alla capsula dell'identita'. La capsula se n'e' andata
      // con l'ordine AM voce 03 e il cuore e' rimasto li'. **L'ordine CO
      // voce 20 ha poi spostato ANCHE il cuore sovrapposto a sinistra**, per
      // allinearlo a questo: la richiesta del fondatore era un'altra, e sono
      // parole sue, "IO AVEVO CHIESTO SOLO DI CENTRARLA VERTICALMENTE".
      //
      // Il risultato sul telefono: nelle Rune il cuore stava attaccato alla
      // freccia, e nella Stesa e nell'Oroscopo i due si vedevano FUSI in un
      // segno solo, con la freccia che non si poteva piu' premere.
      //
      // **Perche' dentro `actions` e non sovrapposto.** In una Row due
      // elementi non si possono sovrapporre per costruzione: e' il modo di
      // rendere impossibile il difetto invece di misurarlo ogni volta. Il
      // cuore va PRIMA delle altre azioni, cosi' il punto interrogativo
      // resta all'estremo destro, dove chi cerca aiuto lo cerca.
      leading: widget.leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Indietro',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
      title: widget.titolo,
      actions: [const CuoreNellaBarra(), ...widget.azioni],
    );
  }
}

/// L'ANGOLO DESTRO DI UNA BARRA, che dall'ordine AL voce 08 e' lo SPAZIO
/// DELLA CAPSULA.
///
/// **La storia, che resta vera.** Il cuore delle arti preferite ha due case:
/// nella barra per chi ha una barra, sovrapposto per chi non ne ha; quando il
/// borsellino arrivo' in tutte le schermate, cuore e saldo si trovarono nello
/// stesso angolo e nacque questo widget, l'angolo dichiarato in un posto
/// solo. Con la capsula dell'identita' l'angolo destro appartiene a LEI, che
/// fluttua sopra il Navigator: la pillola e' uscita dalle barre, il cuore
/// vive in [CuoreNellaBarra] al capo sinistro e qui resta la riserva di
/// spazio, cosi' nessuna azione finisce mai sotto la capsula.
class AngoloDellaBarra extends StatelessWidget {
  const AngoloDellaBarra({super.key});

  /// **E DA OGGI QUI STA IL CUORE, PER CHI NON HA UNA [BarraArte].**
  /// Ordine DC voce 15, 10 settembre 2026.
  ///
  /// **Il fatto del fondatore**: su Meditazione, Stesa di Tarocchi e Oroscopo
  /// la "i" del tooltip finisce sotto il bordo del cuore.
  ///
  /// **La causa, e spiega perche' proprio quelle tre.** `BarraArte` mette il
  /// cuore **dentro `actions`**, in fila con le altre azioni, e in una Row due
  /// elementi non si possono sovrapporre per costruzione. Quelle tre
  /// schermate pero' **non usano `BarraArte`: costruiscono una `AppBar` a
  /// mano**. Li' il cuore restava quello **sovrapposto**, disegnato in uno
  /// Stack sopra la scena nello stesso angolo delle azioni.
  ///
  /// Era lo stesso difetto gia' curato una volta, tornato dalla porta di
  /// servizio delle schermate che non passano dalla barra comune.
  ///
  /// **Perche' la cura sta QUI e non nelle tre schermate.** Tutte e sedici le
  /// schermate con una barra propria montano gia' questo widget, che finora
  /// era uno spazio vuoto. Diventando il posto del cuore, **il difetto si
  /// chiude in un punto solo** e non puo' tornare in una quarta schermata:
  /// chiunque monti una barra ottiene il cuore in fila.
  @override
  Widget build(BuildContext context) => const CuoreNellaBarra();
}

/// IL CUORE DELLE ARTI PREFERITE dentro una barra, col ritiro del cuore
/// sovrapposto: chi lo monta prende in carico il cuore e quello che fluttua
/// sulla scena si toglie da se'. Chi non e' dentro un'arte non mostra niente,
/// e non deve saperlo.
class CuoreNellaBarra extends StatefulWidget {
  const CuoreNellaBarra({super.key});

  @override
  State<CuoreNellaBarra> createState() => _CuoreNellaBarraState();
}

class _CuoreNellaBarraState extends State<CuoreNellaBarra> {
  ReclamoDelCuore? _reclamato;

  /// Se il carico e' stato davvero preso: si lascia una volta sola, e solo
  /// se lo si era preso. Contare male in un verso e' come non contare.
  bool _preso = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dice al cuore sovrapposto di togliersi: da qui in poi ce ne occupiamo noi.
    final arte = ArteCorrente.of(context);
    if (arte?.reclamato != _reclamato) {
      _lascia();
      _reclamato = arte?.reclamato;
      final mio = _reclamato;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || mio == null || _reclamato != mio) return;
        _preso = true;
        mio.prendi();
      });
    }
  }

  /// **IL CARICO SI LASCIA DOPO IL FOTOGRAMMA, non dentro il dispose.**
  /// Scrivere sul notificatore mentre l'albero si smonta fa cadere l'app con
  /// *widget tree was locked*: chi ascolta non puo' ricostruirsi adesso. Il
  /// reclamo appartiene alla soglia dell'arte, che vive piu' a lungo di
  /// questa barra.
  void _lascia() {
    if (!_preso) return;
    _preso = false;
    final mio = _reclamato;
    if (mio == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => mio.lascia());
  }

  @override
  void dispose() {
    _lascia();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arte = ArteCorrente.of(context);
    if (arte == null) return const SizedBox.shrink();
    return CuorePreferita(id: arte.id);
  }
}

/// Quale arte si sta guardando, e se qualcuno ha gia' preso in carico il cuore.
///
/// **Perche' esiste.** Il cuore dorato era disegnato in uno Stack sopra tutta
/// l'arte, in alto a destra, e le schermate d'arte hanno una barra le cui azioni
/// stanno nello stesso angolo: il cuore copriva il tasto informazioni, di cui
/// restava visibile la meta' destra. Non dipendeva dalla larghezza, i due
/// elementi occupavano lo stesso posto e si sovrapponevano a qualunque misura.
///
/// Adesso la barra dichiara le azioni in un posto solo, `BarraArte`, e il cuore
/// e' una di quelle: sta in fila con le altre e non ci si puo' sovrapporre per
/// costruzione. Chi non ha una barra tiene il cuore sovrapposto, che li' non
/// copre niente.
class ArteCorrente extends InheritedWidget {
  const ArteCorrente({
    super.key,
    required this.id,
    required this.reclamato,
    required super.child,
  });

  final String id;

  /// Preso in carico da chi disegna il cuore lui, cosi' il sovrapposto si
  /// toglie di mezzo invece di raddoppiarlo.
  ///
  /// **E' un contatore, non un interruttore**: vedi [ReclamoDelCuore] per la
  /// ragione, che e' un difetto visto due volte a schermo.
  final ReclamoDelCuore reclamato;

  static ArteCorrente? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ArteCorrente>();

  @override
  bool updateShouldNotify(ArteCorrente old) =>
      id != old.id || reclamato != old.reclamato;
}

/// Aggiunge il cuore delle preferite sopra un'arte, in alto a destra.
///
/// Il cuore sta DENTRO l'arte, non solo sulla bolla che la apre: si decide che
/// un'arte ci piace mentre la si usa, non prima di averla vista.
///
/// Si fa da parte quando l'arte ha una `BarraArte`: li' il cuore e' un'azione
/// della barra, in fila con le altre.
class ConCuore extends StatelessWidget {
  const ConCuore({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final arte = ArteCorrente.of(context);
    return Stack(
      children: [
        child,
        // **IN ALTO A DESTRA, ordine CQ voce 1.02.** L'ordine CO voce 20 lo
        // aveva portato a sinistra per allinearlo alla barra, e a sinistra
        // c'e' la freccia Indietro: sul telefono del fondatore i due si sono
        // trovati addosso, fusi in un segno solo, e la freccia non si poteva
        // piu' premere.
        //
        // **I due angoli restano lo stesso angolo**, che era la ragione
        // buona dell'ordine CO: adesso e' il destro da tutte e due le parti,
        // perche' e' quello che il fondatore ha chiesto e perche' a sinistra
        // c'e' un comando che non si puo' coprire.
        Positioned(
          top: 0,
          right: 0,
          // **E ALLA STESSA QUOTA DEL CUORE DELLA BARRA. Ordine CQ voce
          // 6.07, 4 settembre 2026.**
          //
          // Parole del fondatore: *i cuoricini sono tornati a destra ma non
          // sono centrati verticalmente*. **L'angolo era giusto, la quota
          // no**: qui il cuore stava a `top: 0` piu' un'aria, mentre nella
          // barra sta al centro dei suoi cinquantasei punti, col centro a
          // ventotto esatti, misurato. Due cuori della stessa app a due
          // altezze diverse a seconda che la schermata abbia una barra o no.
          //
          // Adesso questo vive dentro una fascia alta come la barra, e
          // centrato dentro: **la quota e' la stessa numero per numero**, e
          // lo resta il giorno che la barra cambia altezza, perche' e' la
          // stessa costante a dirla.
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: SpacingTokens.sm),
              child: SizedBox(
                height: kToolbarHeight,
                child: Center(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: arte?.reclamato ?? _mai,
                    builder: (context, reclamato, _) => reclamato
                        ? const SizedBox.shrink()
                        : CuorePreferita(id: id),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Il cuore che mette o toglie un'arte dallo scaffale personale.
///
/// Nessun controllo di piano: i preferiti sono una comodita' di chi usa l'app,
/// non merce.
class CuorePreferita extends StatelessWidget {
  const CuorePreferita({super.key, required this.id, this.compatto = false});

  final String id;

  /// Compatto per stare sopra una bolla, pieno per stare dentro l'arte.
  final bool compatto;

  @override
  Widget build(BuildContext context) {
    final preferite = context.watch<ArtiPreferiteController?>();
    if (preferite == null) return const SizedBox.shrink();
    final dentro = preferite.contiene(id);
    final palette = MaestroScope.of(context);

    return Semantics(
      button: true,
      selected: dentro,
      label: dentro ? 'Togli dalle tue arti' : 'Aggiungi alle tue arti',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: IconButton(
          key: Key('cuore_$id'),
          tooltip: dentro ? 'Togli dalle tue arti' : 'Aggiungi alle tue arti',
          iconSize: compatto ? 18 : 24,
          visualDensity: compatto ? VisualDensity.compact : null,
          icon: Icon(
            dentro ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: dentro ? palette.gold : palette.goldSoft,
            shadows: const [
              // Un'ombra sotto: il cuore sta sopra sfondi di ogni colore.
              Shadow(color: Colors.black54, blurRadius: 6),
            ],
          ),
          onPressed: () => mostraEsito(context, preferite.cambia(id), palette),
        ),
      ),
    );
  }

  /// Dice cosa e' successo, invece di lasciare la persona a indovinare.
  static void mostraEsito(
      BuildContext context, EsitoPreferita esito, MaestroPalette palette) {
    final testo = switch (esito) {
      EsitoPreferita.aggiunta => 'Aggiunta alle tue arti.',
      EsitoPreferita.tolta => 'Tolta dalle tue arti.',
      EsitoPreferita.ripristinata =>
        'Era l\'ultima: le tue arti sono tornate come all\'inizio.',
      EsitoPreferita.pieno =>
        'Le tue arti sono ${ArtiPreferiteController.tetto}: togline una per '
            'fare posto.',
      EsitoPreferita.sconosciuta => 'Quest\'arte non è ancora viva.',
    };
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        key: const Key('esito_preferita'),
        duration: const Duration(seconds: 3),
        backgroundColor: palette.surfaceElevated,
        content: Text(testo,
            style:
                TypographyTokens.corpo().copyWith(color: palette.textPrimary)),
      ));
  }
}
