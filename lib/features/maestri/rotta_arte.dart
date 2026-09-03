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
          reclamato: ValueNotifier<bool>(false),
          child: ConCuore(id: widget.id, child: widget.child),
        ),
      );
}

/// Nessuno la ascolta davvero: serve solo quando il cuore vive fuori da un'arte.
final ValueNotifier<bool> _mai = ValueNotifier<bool>(false);

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
      // **IL CUORE STA AL CAPO SINISTRO, ordine AL voce 08, e ci resta.**
      // Con la capsula sparita (ordine AM voce 03) l'angolo destro non ha
      // piu' un occupante che fluttua sopra, ma il cuore accanto alla
      // freccia si e' guardato ed e' giusto li': il titolo tiene i suoi
      // punti e la guardia tipografica resta intera.
      leadingWidth: 96,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.leading ??
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Indietro',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
          const CuoreNellaBarra(),
        ],
      ),
      title: widget.titolo,
      actions: widget.azioni,
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

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
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
  ValueNotifier<bool>? _reclamato;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dice al cuore sovrapposto di togliersi: da qui in poi ce ne occupiamo noi.
    final arte = ArteCorrente.of(context);
    if (arte?.reclamato != _reclamato) {
      _reclamato = arte?.reclamato;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reclamato?.value = true;
      });
    }
  }

  @override
  void dispose() {
    _reclamato?.value = false;
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

  /// Alzato dalla barra dell'arte quando il cuore lo mette lei, cosi' il
  /// sovrapposto si toglie di mezzo invece di raddoppiarlo.
  final ValueNotifier<bool> reclamato;

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
        // **LO STESSO ANGOLO DI QUANDO C'E' LA BARRA. Ordine CO voce 20**,
        // 3 settembre 2026. Parole del fondatore: il cuore dei preferiti
        // centrato, e verificato ovunque.
        //
        // **Verificato: non stava nello stesso posto.** Con una barra il
        // cuore vive in `CuoreNellaBarra`, al capo SINISTRO accanto alla
        // freccia Indietro, dove l'ordine AL voce 08 l'ha messo e dove la
        // voce AM voce 03 l'ha lasciato dopo che la capsula dell'identita'
        // se n'era andata. Senza barra viveva qui, in alto a DESTRA. Due
        // angoli diversi per la stessa cosa: chi passa da un'arte all'altra
        // deve cercarlo ogni volta, e cercare un comando che si e' gia'
        // imparato e' il modo piu' sicuro di smettere di usarlo.
        //
        // Si e' scelto il sinistro e non il destro perche' e' quello che una
        // decisione guardata ha gia' confermato: si sposta il cuore
        // sovrapposto, che di decisioni non ne aveva nessuna.
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: SpacingTokens.sm, left: SpacingTokens.sm),
              child: ValueListenableBuilder<bool>(
                valueListenable: arte?.reclamato ?? _mai,
                builder: (context, reclamato, _) => reclamato
                    ? const SizedBox.shrink()
                    : CuorePreferita(id: id),
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
