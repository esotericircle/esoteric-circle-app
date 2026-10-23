import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/maestro/la_scena_del_maestro.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../scene/la_scena_in_video.dart';
import '../shell/vie_del_cerchio.dart';
import 'il_dono_nel_palmo.dart';
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
  const DomainScreen(
      {super.key, required this.maestro, this.fabbricaDellaScena, this.adesso});

  final Maestro maestro;

  /// La finta del lettore video, per le prove headless.
  final FabbricaDiScena? fabbricaDellaScena;

  /// L'ora da cui si legge il dono del giorno nel palmo (la runa del
  /// tramonto di Caligo, GD.02). Nulla vuol dire adesso; la fissano le prove.
  final DateTime? adesso;

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

  // **LA TESTA SALE VERSO LA BARRA, ordine FW, 15 ottobre 2026.** Il
  // fondatore: *"Tutti i video dei domini di ogni maestro devono salire
  // verso l'alto altrimenti il video non si vede e lo scopo cade. Porta il
  // video in alto finche' la testa dei maestri sia a 30 pixel dalla barra
  // del titolo"*, e poi, vista un primo tentativo con uno zoom: *"Perche'
  // hai ingrandito i video? I video non vanno ingranditi, vanno solo
  // spostati in alto"*. Niente scala: solo uno spostamento verticale puro
  // (`Transform.translate`), alla stessa grandezza di sempre. I tre video
  // non hanno il viso alla stessa altezza (misurato sui fermi veri,
  // docs/collaudo/FW/*_dominio_ultimo_dopo.png, riga per riga su un
  // righello sovrapposto): la testa di Medora comincia al 28 per cento
  // dell'immagine, quella di Caligo al 22, quella di Aura al 18. Spostando
  // la scena verso l'alto di quel tanto che serve, sotto resta uno spazio
  // vuoto (l'immagine non arriva piu' al bordo basso): coperto da un fondo
  // pieno del colore profondo della palette, lo stesso in cui il velo gia'
  // sfuma, cosi' il taglio non si vede.
  static const Map<String, double> _frazioneTestaNelFotogramma = {
    'medora': 0.28,
    'caligo': 0.22,
    'aura': 0.18,
  };

  /// **DI QUANTO SI SPOSTA LA SCENA VERSO L'ALTO**, in punti schermo.
  /// Positivo quando la testa, alla sua altezza naturale, sta piu' in
  /// basso del bersaglio (barra piu' 30 punti): si sposta su di tanto.
  /// Se e' gia' piu' in alto del bersaglio (come capita ad Aura) non si
  /// sposta affatto: la richiesta e' che la testa salga, non che scenda.
  double _spostamentoVersoLAlto(BuildContext context) {
    final frazioneTesta = _frazioneTestaNelFotogramma[widget.maestro.id] ?? 0;
    final altezzaSchermo = MediaQuery.sizeOf(context).height;
    final posizioneAttuale = frazioneTesta * altezzaSchermo;
    final appBarBasso = MediaQuery.paddingOf(context).top + 88;
    final bersaglio = appBarBasso + 30;
    return (posizioneAttuale - bersaglio).clamp(0.0, altezzaSchermo);
  }

  // **IL MEZZOBUSTO INTERO, FINO AL TAVOLO.** Il fondatore, non ancora
  // soddisfatto di un margine fisso: *"VOGLIO VEDERE TUTTO IL MEZZOBUSTO DI
  // OGNI MAESTRO E SENZA ZOOM, dal tavolo parte la sfumatura verso il basso
  // scura o velo e le icone delle arti"*. Un numero solo (37 per cento piu'
  // 30 punti) non poteva reggere per tutti e tre: ogni scena ha il suo
  // tavolo a un'altezza diversa (misurato sugli stessi fermi veri, lo
  // stesso righello della testa). Il tavolo di Medora e' al 77 per cento
  // dell'immagine, quello di Caligo al 65 (il piano del suo leggio, piu' in
  // alto perche' lui e' inquadrato piu' vicino), quello di Aura al 74 (il
  // bordo del suo altare di marmo).
  static const Map<String, double> _frazioneTavoloNelFotogramma = {
    'medora': 0.77,
    'caligo': 0.65,
    'aura': 0.74,
  };

  /// **DOVE FINISCE LA SCENA E COMINCIA IL CONTENUTO**, in punti schermo,
  /// contati dal bordo basso della barra (lo stesso zero da cui parte
  /// `spazioScena` dentro `MaestroScreen`). E' il tavolo, nella sua
  /// posizione VERA dopo lo spostamento verso l'alto: se la scena sale di
  /// `spostamento` punti, il tavolo sale della stessa misura, e il velo lo
  /// segue invece di restare fermo a un numero scritto a mano.
  double _fineDellaScena(BuildContext context, double spostamento) {
    final frazioneTavolo =
        _frazioneTavoloNelFotogramma[widget.maestro.id] ?? 0.7;
    final altezzaSchermo = MediaQuery.sizeOf(context).height;
    final appBarBasso = MediaQuery.paddingOf(context).top + 88;
    final posizioneDelTavolo = frazioneTavolo * altezzaSchermo - spostamento;
    return (posizioneDelTavolo - appBarBasso).clamp(0.0, altezzaSchermo);
  }

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
    final spostamento = _spostamentoVersoLAlto(context);
    final altezzaSchermo = MediaQuery.sizeOf(context).height;
    final fineScena = _fineDellaScena(context, spostamento);
    // **IL VELO PARTE DAL TAVOLO, NON DAL BUSTO.** Il velo e' steso su tutto
    // lo schermo, dal bordo alto; `fineScena` invece e' contata dal bordo
    // basso della barra. Usata cosi' com'era, la forza piena cadeva circa
    // 125 punti sopra il tavolo e la sfumatura cominciava altri 145 punti
    // piu' su, sul busto del Maestro: il fondatore, sulla build 2312 del 16
    // ottobre 2026, "Il velo nero semitrasparente dal basso è troppo esteso
    // e copre il maestro" (padre FW.03, commit ca288d84). Adesso il velo
    // arriva a forza piena dove il contenuto comincia davvero sullo schermo
    // (il tavolo: la barra piu' `fineScena`), e sale per soli 0,06 di
    // schermo sopra di lui, quanto basta perche' il titolo delle arti non
    // stia su una linea dura.
    final appBarBasso = MediaQuery.paddingOf(context).top + 88;
    final veloFine =
        ((appBarBasso + fineScena) / altezzaSchermo).clamp(0.0, 1.0);
    final veloInizio = (veloFine - 0.06).clamp(0.0, veloFine);
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
            // **IL FONDO SOTTO LO SPOSTAMENTO.** Spostando la scena verso
            // l'alto, sotto di lei non resta piu' niente (l'immagine non
            // tocca piu' il bordo basso dello schermo): questo colore pieno
            // sta dietro a tutto, cosi' il vuoto non si vede, nello stesso
            // colore profondo in cui il velo piu' sotto gia' sfuma.
            Positioned.fill(child: ColoredBox(color: palette.deepest)),
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, -spostamento),
                child: Image.asset(
                  ferma ? scena.ultimoFotogramma : scena.primoFotogramma,
                  key: const Key('dominio_fotogramma'),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) =>
                      ColoredBox(color: palette.deepest),
                ),
              ),
            ),
            // IL VIDEO SI TOGLIE QUANDO FINISCE, come nel Calendario Lunare:
            // l'ultimo fotogramma dipinto sta gia' sotto. Saltato, sfuma e
            // poi non dipinge piu'.
            if (_regia.filmatoInScena && (!ferma || _regia.saltata))
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, -spostamento),
                  child: IlFilmatoCheSfuma(
                    key: const Key('dominio_filmato'),
                    saltato: _regia.saltata,
                    child: _regia.disegna(),
                  ),
                ),
              ),
            // **IL DONO NEL PALMO, ordine GD voci GD.01 e GD.02**: il segno
            // di Medora, la runa del tramonto di Caligo. Sopra il video e
            // dentro lo stesso spostamento verso l'alto del fotogramma, cosi'
            // resta sul palmo dipinto; compare solo a scena ferma, come il
            // resto (`IlDonoSulPalmo` usa `IlRestoDopoLaScena`).
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, -spostamento),
                child: IlDonoSulPalmo(
                  maestro: widget.maestro,
                  scenaFerma: ferma,
                  subito: !_regia.filmatoInScena && !_regia.saltata,
                  adesso: widget.adesso,
                ),
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
            // dopo: i fermi non sono piu' numeri scritti a mano, sono
            // calcolati da `fineScena` (`veloInizio`, `veloFine`), lo stesso
            // punto dato a `spazioScena` qui sotto: il velo e il contenuto
            // restano uniti anche se `fineScena` cambia. La forza piena e'
            // 0,80 (misurata la prima volta sulla cattura di Aura, dove le
            // lanterne del tempio sono chiare proprio li': contrasto 5,53 e
            // 5,22, sopra 4,5, docs/collaudo/FW/fw03_contrasto_sulla_cattura.py).
            //
            // **SOPRA IL VIDEO SOLO IL VIDEO**, ordine FX voce FXA.08: il
            // velo e il contenuto del dominio (le arti, le schede) stavano
            // sopra la meta' bassa del video mentre girava. Adesso aspettano
            // la scena ferma e compaiono in dissolvenza; il velo serve alla
            // lettura del contenuto, e arriva con lui.
            Positioned.fill(
              child: IlRestoDopoLaScena(
                scenaFerma: ferma,
                subito: !_regia.filmatoInScena && !_regia.saltata,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, veloInizio, veloFine],
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
            ),
            IlRestoDopoLaScena(
              scenaFerma: ferma,
              subito: !_regia.filmatoInScena && !_regia.saltata,
              child: MaestroScreen(
                maestro: widget.maestro,
                // **DOVE COMINCIA IL CONTENUTO**, calcolato da `_fineDellaScena`
                // qui sopra: il tavolo di ogni scena, nella sua posizione vera
                // dopo lo spostamento verso l'alto. Il Maestro intero, fino al
                // tavolo, e' visibile sopra; attenzione se si tocca questo
                // numero: la scheda "Consulta" (la prima azione del dominio)
                // puo' cadere dove la barra Esplora, sempre in vista sul
                // dominio, si sovrappone (ordine EJ, 112 punti). Non e' un
                // difetto, e' la regola permanente della barra: scorrendo lei
                // si ritira e la scheda torna libera, come verifica
                // `test/il_maestro_non_resta_muto_test.dart` scorrendo prima
                // di toccare.
                spazioScena: fineScena,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
