import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/maestro/la_scena_del_maestro.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../scene/la_scena_in_video.dart';
import '../shell/vie_del_cerchio.dart';
import 'maestro_screen.dart';
import 'widgets/domain_pillars.dart';
import 'rotta_arte.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// Il dominio di un Maestro, come route spinta sopra il Santuario.
///
/// E' l'hub minimo: l'ingresso Parla con il Maestro verso la chat, piu' le
/// funzioni del dominio nei loro stati. Ha la sua freccia Indietro che torna al
/// Santuario, nessuna bottom bar, cosi' resta superficie immersiva. Dalla chat,
/// Indietro torna qui; da qui, Indietro torna al Santuario.
///
/// **LA SCENA IN VIDEO, ordine FW voce FW.03, 15 ottobre 2026.** Il
/// fondatore: *"per coerenza"*, sul video di scena per la home del dominio di
/// ogni Maestro, come gia' per la Stesa, la Sinastria e l'Oracolo. All'
/// apertura parte il video del Maestro (`LaScenaDelMaestro.delDominio`);
/// fermo o finito, il suo ultimo fotogramma resta come fondo, al posto di
/// `CosmosBackground`. Un tocco lo salta (`IlToccoCheSalta`, lo stesso punto
/// delle altre scene).
///
/// **UNA REGIA PER SCHERMATA, COME LE ALTRE SCENE.** Questa classe e'
/// diventata `StatefulWidget` perche' la regia (`RegiaDellaScena`) vive
/// quanto la schermata: nasce in `initState`, si chiude in `dispose`. Spinto
/// come route ogni volta che si entra nel dominio, un ritorno con
/// `Navigator.pop` (da un'arte o dalla chat) **non** crea una nuova istanza:
/// e' la stessa schermata gia' nello stack, la regia resta quella di prima e
/// il video non riparte. Solo una nuova apertura del dominio (per esempio
/// tornando al Santuario e rientrando) lo fa ripartire: e' il comportamento
/// naturale di push e pop, voluto uguale per i tre Maestri perche' nessuno
/// dei tre ha un motivo per comportarsi diversamente (scelta di Code, FW.03).
class DomainScreen extends StatefulWidget {
  const DomainScreen({super.key, required this.maestro, this.fabbricaDellaScena});

  final Maestro maestro;

  /// La finta del lettore video, per le prove headless.
  final FabbricaDiScena? fabbricaDellaScena;

  static Route<void> route({
    required Maestro maestro,
    required AppServices services,
  }) {
    return PassaggioDelCerchio.rotta<void>(
        // LA ROTTA DICHIARA LA PROPRIA DESTINAZIONE, rotta piu' argomento.
        //
        // E' il dato su cui la barra decide se TORNARE a una stanza gia' aperta
        // o aprirne una nuova. Sta QUI, nella fabbrica, e non in chi spinge:
        // cosi' ogni porta che apre un dominio, barra, Santuario o guscio, la
        // dichiara senza doverlo sapere. Il perche' un nome o un tipo non
        // bastano sta scritto su DestinazioneDominio.

        // LA ROTTA DICHIARA ANCHE IL PROPRIETARIO, ordine 2163 voce 6: senza
        // `maestro:` lo scope seguiva il controller, e la barra dentro il
        // dominio non sapeva di chi fosse la stanza (voce spenta, colore
        // della provenienza). E' la stessa dichiarazione che la chat fa gia'.
        (_) => MaestroScope(
            maestro: maestro, child: DomainScreen(maestro: maestro)),
        settings: RouteSettings(arguments: DestinazioneDominio(maestro)));
  }

  @override
  State<DomainScreen> createState() => _DomainScreenState();
}

class _DomainScreenState extends State<DomainScreen> {
  late final RegiaDellaScena _regia;

  @override
  void initState() {
    super.initState();
    final scena = LaScenaDelMaestro.delDominio(widget.maestro);
    _regia = RegiaDellaScena(
        widget.fabbricaDellaScena ?? () => LettoreDiScena.vero(scena.video))
      ..addListener(_quandoLaScenaCambia);
  }

  void _quandoLaScenaCambia() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_regia.avvia(context));
  }

  @override
  void dispose() {
    _regia
      ..removeListener(_quandoLaScenaCambia)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scena = LaScenaDelMaestro.delDominio(widget.maestro);
    final ferma = _regia.ferma;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        // Il nome del Maestro e, come seconda riga, i tre pilastri del suo
        // dominio: si sa di che cosa e' fatto prima ancora di scorrere.
        //
        // **LA TESTATA HA DUE CAPI E UN CENTRO PROTETTO, ordine AI voce 02.**
        // Qui c'era uno Stack col titolo centrato sull'intera larghezza e il
        // saldo sovrapposto a destra: con mille Eos il numero entrava nei
        // sottotitoli, ed e' il difetto fotografato da Mauro. Adesso e' una
        // AppBar normale: la freccia e la porta dell'account al capo
        // sinistro, la pillola al capo destro, e il titolo VINCOLATO dallo
        // spazio fra i due per costruzione, quindi non puo' toccare nessuno
        // dei capi. La centratura perfetta sull'intera larghezza si perde di
        // pochi punti, uguali nei tre domini: la protezione vale la deriva.
        toolbarHeight: 88,
        titleSpacing: 0,
        centerTitle: true,
        // **LA PORTA NON VIVE PIU' QUI, ordine AL voce 08**: il volto sta
        // nella capsula dell'identita', sopra il Navigator.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.maestro.nomeAVideo,
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloDiSchermata()),
            const SizedBox(height: 2),
            DomainPillars(maestro: widget.maestro),
          ],
        ),
        // IL BORSELLINO, ordine S voce 06, oggi PILLOLA dell'ordine AI: al
        // capo destro, fra le azioni come in ogni altra testata.
        actions: const [AngoloDellaBarra()],
      ),
      body: IlToccoCheSalta(
        inCorso: _regia.inCorso,
        onSalta: _regia.salta,
        child: Stack(
          key: const Key('dominio_scena'),
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: Image.asset(
                ferma ? scena.ultimoFotogramma : scena.primoFotogramma,
                key: const Key('dominio_fotogramma'),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) =>
                    ColoredBox(color: palette.deepest),
              ),
            ),
            // IL VIDEO SI TOGLIE QUANDO FINISCE, come nel Calendario Lunare:
            // l'ultimo fotogramma dipinto sta gia' sotto. Saltato, sfuma e
            // poi non dipinge piu'.
            if (_regia.filmatoInScena && (!ferma || _regia.saltata))
              Positioned.fill(
                child: IlFilmatoCheSfuma(
                  key: const Key('dominio_filmato'),
                  saltato: _regia.saltata,
                  child: _regia.disegna(),
                ),
              ),
            // **IL VELO IN BASSO, FW.03**: il contenuto del dominio (i
            // pilastri sono gia' nella barra, leggibili per conto loro)
            // scorre sopra la scena a partire da meta' schermo: una
            // sfumatura verso il colore profondo della palette aiuta la
            // lettura delle prime schede senza coprire il viso del Maestro,
            // che resta nella meta' alta.
            // **IL VELO NON DIPINGEVA NIENTE**: senza `Positioned.fill` un
            // figlio non posizionato di uno Stack, senza una sua misura
            // intrinseca, collassa a dimensione zero: il velo era scritto
            // ma non e' mai stato a schermo, su nessuno dei tre domini, da
            // quando esiste. Scoperto cosi': guardando la cattura vera
            // dell'anteprima (`docs/preview/FW/fw06_aura_dominio_ferma_dopo.png`,
            // R6, mai dalla sola lettura del codice), su Aura il titolo e la
            // riga sotto cadevano su lanterne chiare senza nessuna
            // sfumatura a coprirle: contrasto misurato 1,35 e 1,43, molto
            // sotto 4,5 (docs/collaudo/FW/fw03_contrasto_sulla_cattura.py).
            // Su Medora e Caligo il difetto non si vedeva perche' la scena a
            // quell'altezza e' gia' scura per conto suo: la stessa assenza
            // di velo, ma senza conseguenze visibili, quindi senza misura
            // non si sarebbe mai saputo che i tre domini vivevano dello
            // stesso difetto con fortuna diversa.
            // **IL VELO FINISCE DI SALIRE DOVE COMINCIA IL TESTO**, non
            // dopo: i vecchi fermi (0,42 e 0,62) arrivavano a piena forza
            // dopo il 46 per cento dove comincia il contenuto
            // (`spazioScena`); ora salgono da 0,28 a 0,46, pronti per il
            // testo e non dopo, e la forza piena passa da 0,72 a 0,80 per un
            // margine piu' largo sopra soglia. Misurato di nuovo dopo
            // entrambe le correzioni (il `Positioned.fill` e i nuovi fermi)
            // sulla stessa cattura: 5,53 (titolo) e 5,22 (riga), sopra 4,5
            // anche nel punto piu' chiaro della scena di Aura.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.28, 0.46],
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        palette.deepest.withValues(alpha: 0.80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            MaestroScreen(
              maestro: widget.maestro,
              // **IL VISO NON SI COPRE, FW.03**: misurato sui tre ultimi
              // fotogrammi (docs/preview/FW/), il viso dei tre Maestri sta
              // tutto entro il 40 per cento alto dell'immagine 1080x1920. Lo
              // spazio libero e' il 46 per cento dell'altezza dello schermo,
              // uguale per i tre: il contenuto del dominio comincia sotto le
              // spalle, mai sopra il mento.
              spazioScena: MediaQuery.sizeOf(context).height * 0.46,
            ),
          ],
        ),
      ),
    );
  }
}
