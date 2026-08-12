import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/arts/arti_preferite.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/borsellino.dart';
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
class SogliaArte extends StatelessWidget {
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
  Widget build(BuildContext context) => MaestroScope(
        maestro: maestro,
        child: ArteCorrente(
          id: id,
          reclamato: ValueNotifier<bool>(false),
          child: ConCuore(id: id, child: child),
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
      // Mai un vicolo cieco: la via d'uscita e' sempre la stessa e sempre li'.
      leading: widget.leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Indietro',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
      title: widget.titolo,
      actions: [
        ...widget.azioni,
        // L'ANGOLO DESTRO E' UNA PORTA SOLA: il borsellino e il cuore, in
        // quest'ordine, e il cuore sovrapposto si toglie da se'.
        const AngoloDellaBarra(),
      ],
    );
  }
}


/// L'ANGOLO DESTRO DI UNA BARRA: il borsellino e il cuore, in quest'ordine.
///
/// **Perche' esiste, e non e' una comodita'.** Il cuore delle arti preferite ha
/// due case: dentro la barra, per chi ha una barra, e SOVRAPPOSTO in alto a
/// destra per chi non ne ha. Quando il borsellino e' arrivato in tutte le
/// schermate della pratica, ordine S voce 06, quelle che avevano una AppBar
/// propria e il cuore sovrapposto si sono trovate le due cose nello stesso
/// angolo: nell'anteprima del rito e della meditazione il cuore dorato passava
/// SOPRA "0 Eos". E' la stessa famiglia del difetto che aveva fatto nascere
/// `BarraArte`, dove il cuore copriva il tasto delle fonti.
///
/// Adesso l'angolo e' un widget solo: chiunque lo monta ottiene il borsellino, il
/// cuore in fila accanto e il ritiro del cuore sovrapposto. Chi non e' dentro
/// un'arte ottiene il solo borsellino, e non deve saperlo.
class AngoloDellaBarra extends StatefulWidget {
  const AngoloDellaBarra({super.key});

  @override
  State<AngoloDellaBarra> createState() => _AngoloDellaBarraState();
}

class _AngoloDellaBarraState extends State<AngoloDellaBarra> {
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SegnoDelBorsellino(),
        if (arte != null) CuorePreferita(id: arte.id),
        const SizedBox(width: SpacingTokens.xs),
      ],
    );
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
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: SpacingTokens.sm, right: SpacingTokens.sm),
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
            style: TypographyTokens.corpo()
                .copyWith(color: palette.textPrimary)),
      ));
  }
}
