import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/tier.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/sentieri.dart';
import '../../core/sigilli/stato_del_sigillo.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../maestri/rotta_arte.dart';
import '../pricing/upgrade_invite.dart';
import 'celebrazione.dart';
import 'disegno_del_sentiero.dart';
import 'le_tre_righe_del_sentiero.dart';
import '../../design_system/components/icona_degli_eos.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import 'la_mappa_del_sentiero.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// IL SENTIERO DEI SIGILLI: Albero, Costellazione o Loto.
///
/// **Il disegno sta in alto ed e' la prima cosa che si vede, ordine P voce
/// 33.** Prima di questa voce la schermata era un elenco di righe con le icone
/// di serie del framework, e i tre sentieri differivano per la sola palette:
/// la sezione 13 del Briefing non era costruita. Adesso ogni sentiero ha il
/// suo disegno, `DisegnoDelSentiero`, e l'elenco resta come SECONDA LETTURA,
/// scorrendo. Il disegno e l'elenco si parlano nei due versi: toccando un
/// punto si va al suo traguardo, e toccando un traguardo si evidenzia il suo
/// punto.
///
/// **ALL'APERTURA SI RESTA SUL DISEGNO, FERMI. Ordine S voce 01, e supera la
/// voce P.36.** Erano due regole dello stesso ordine P che si combattevano: la
/// discesa automatica al punto raggiunto e "il disegno e' la prima cosa che si
/// vede". Vinceva la discesa, quindi chi apriva il sentiero atterrava
/// sull'elenco e il disegno non lo vedeva mai. Adesso la discesa non parte da
/// se': **il codice della misura non si e' buttato, si e' spostato sul TOCCO**,
/// il comando "Vai al punto in cui sei" sotto il disegno.
///
/// Il disegno non e' piu' un quadrato: prende almeno il
/// [quotaDelDisegno] dell'altezza utile, e all'apertura ci sta dentro tutto.
class SentieroScreen extends StatefulWidget {
  const SentieroScreen({super.key, required this.sentiero, this.senzaVolo = false});

  final Sentiero sentiero;

  /// Per le prove e le anteprime: niente scorrimento animato, la scena si
  /// monta gia' ferma sul punto raggiunto.
  final bool senzaVolo;

  // **NIENTE SOGLIA D'ARTE, coda dell'ordine BF.** Il sentiero stava dentro
  // una `SogliaArte`, che e' la soglia delle arti del catalogo e porta con
  // se' il cuore dei preferiti: cosi' sulla barra compariva un cuore che
  // salvava un id (`sigilli_...`) che nessuno scaffale conosce. Parola del
  // fondatore: "non sono funzionalita' che possono e devono finire tra i
  // preferiti in home". Del guscio serviva solo il colore del Maestro, e
  // resta solo quello.
  static Route<void> route(Sentiero sentiero) => PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
          maestro: sentiero.maestro,
          child: SentieroScreen(sentiero: sentiero),
        ));

  @override
  State<SentieroScreen> createState() => _SentieroScreenState();
}

class _SentieroScreenState extends State<SentieroScreen> {
  final ScrollController _scorrimento = ScrollController();

  @override
  void initState() {
    super.initState();
    // **LA MAPPA AL PRIMO INGRESSO, ordine AU voce 13.** Una volta sola per
    // sentiero, e poi solo se la si chiede col punto interrogativo: e' la
    // differenza fra un aiuto e un'interruzione.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!await LaMappaDelSentiero.eIlPrimoIngresso(widget.sentiero)) return;
      await LaMappaDelSentiero.segnaLIngresso(widget.sentiero);
      if (!mounted) return;
      await LaMappaDelSentiero.mostra(context, widget.sentiero);
    });
  }

  /// Le chiavi dei gradini: servono a MISURARE dove sta una riga invece di
  /// dedurlo da un'altezza scritta a mano, ordine P voce 36.
  final Map<String, GlobalKey> _chiaviDeiGradini = {};

  /// Il traguardo che il disegno deve evidenziare.
  String? _evidenziato;

  /// QUANTA ALTEZZA UTILE PRENDE IL DISEGNO.
  ///
  /// L'ordine S voce 01 chiede almeno il 55 per cento, misurato sulla resa: qui
  /// c'e' 0,58, che lo supera e lascia il resto per il comando del tocco piu'
  /// l'inizio dell'elenco, cosi' si capisce che sotto c'e' altro da leggere.
  /// **Non e' un quadrato**, e il disegno non ne soffre: i tre pittori pongono i
  /// punti su coordinate normalizzate e prendono i raggi dal lato corto, quindi
  /// una scatola piu' alta che larga li allarga senza deformare i cerchi.
  static const double quotaDelDisegno = 0.58;

  // NESSUN initState CHE SCORRE. Prima qui c'era un post frame callback che
  // chiamava `_scendiAlPunto`, e quello era il difetto della voce S.01: il
  // disegno esisteva e nessuno lo vedeva.

  @override
  void dispose() {
    _scorrimento.dispose();
    super.dispose();
  }

  /// Il traguardo su cui il cammino si e' fermato: il primo NON ancora acceso.
  Traguardo _dovePuntare(int accesi) {
    final mini = Sentieri.miniDi(widget.sentiero);
    return mini[accesi.clamp(0, mini.length - 1)];
  }

  /// LA DISCESA AL PUNTO RAGGIUNTO, **e adesso la chiede un TOCCO**.
  ///
  /// Ordine S voce 01: all'apertura non parte piu' da se'. La misura resta
  /// identica, perche' era giusta ed era costata una voce intera.
  ///
  /// **Il conto era rovesciato, ordine P voce 36.** Qui c'era
  /// `(50 - gradini) * altezzaDelGradino` con `gradini = (50 - accesi)`, cioe',
  /// sostituendo, `accesi * 92`. La lista e' rovesciata, quindi in cima c'e' il
  /// 50 e in fondo l'1: con due traguardi accesi lo scorrimento si fermava a
  /// 184 punti, due righe, ed e' il motivo per cui non si muoveva niente. Con
  /// zero accesi non si muoveva affatto.
  ///
  /// **E sotto quel difetto ce n'era un secondo**: `altezzaDelGradino` era
  /// fissata a 92 mentre le righe hanno titoli e frasi di lunghezza diversa,
  /// quindi anche col conto giusto il punto di arrivo sarebbe scivolato. Per
  /// questo qui non si calcola piu' niente: si MISURA la riga vera sulla resa,
  /// col viewport che la ospita. Una misura non puo' scivolare.
  Future<void> _scendiAlPunto() async {
    if (!mounted) return;
    final diario = context.read<DiarioDelCammino>();
    final accesi = diario.quantiAccesiDi(widget.sentiero);
    final dove = offsetDelTraguardo(_dovePuntare(accesi).id);
    if (dove == null || !_scorrimento.hasClients) return;
    final meta = dove.clamp(0.0, _scorrimento.position.maxScrollExtent);
    // CON RIDUCI MOVIMENTO LA DISCESA E' IMMEDIATA MA IL PUNTO DI ARRIVO E'
    // LO STESSO: si toglie il volo, non la destinazione.
    final fermo = widget.senzaVolo ||
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    if (fermo) {
      _scorrimento.jumpTo(meta);
      return;
    }
    await _scorrimento.animateTo(
      meta,
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
    );
  }

  /// Dove sta una riga dentro cio' che scorre, MISURATO sulla resa.
  ///
  /// Restituisce null finche' la riga non e' stata disposta: con le righe
  /// costruite tutte insieme (sono cinquanta) succede solo prima del primo
  /// fotogramma.
  double? offsetDelTraguardo(String id) {
    final contesto = _chiaviDeiGradini[id]?.currentContext;
    final scatola = contesto?.findRenderObject();
    if (scatola is! RenderBox || !scatola.hasSize || !scatola.attached) {
      return null;
    }
    return RenderAbstractViewport.of(scatola)
        .getOffsetToReveal(scatola, 0)
        .offset;
  }

  void _vaiAlTraguardo(Traguardo traguardo) {
    setState(() => _evidenziato = traguardo.id);
    final dove = offsetDelTraguardo(traguardo.id);
    if (dove == null || !_scorrimento.hasClients) return;
    final meta = dove.clamp(0.0, _scorrimento.position.maxScrollExtent);
    if (MediaQuery.maybeOf(context)?.disableAnimations == true) {
      _scorrimento.jumpTo(meta);
      return;
    }
    _scorrimento.animateTo(meta,
        duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final diario = context.watch<DiarioDelCammino>();
    final piano = context.watch<EntitlementService>().tier;
    // **L'ELENCO PORTA TUTTI E CINQUANTACINQUE, GRANDI COMPRESI.** Ordine AV
    // voce 04.
    //
    // **Il fatto del fondatore**: "le perle grandi di ogni sentiero non
    // funzionano: se faccio click si illuminano di piu' ma non portano a
    // nessun traguardo nell'elenco piu' sotto".
    //
    // **La causa, e la misura la conferma al numero.** Qui c'era
    // `Sentieri.miniDi(...)`, cioe' i CINQUANTA mini: i cinque grandi non
    // avevano una riga, quindi non avevano una chiave in
    // `_chiaviDeiGradini`, quindi `offsetDelTraguardo` non trovava niente e lo
    // scorrimento non partiva. La perla si illuminava lo stesso, perche'
    // quello lo fa `_evidenziato`, ed e' esattamente cio' che si vedeva.
    // Enumerate tutte e centosessantacinque le perle dei tre sentieri:
    // **scollegate cinque per sentiero, e sono precisamente i cinque grandi**.
    //
    // I traguardi si mostrano dal 55 al 1: l'apertura viene dall'alto, e i
    // grandi stanno al loro posto nel cammino, alle posizioni 11, 22, 33, 44 e
    // 55, invece che in fondo o in un elenco a parte.
    final mini = (Sentieri.di(widget.sentiero).toList()
          ..sort((a, b) => Sentieri.ordineNelCammino(a)
              .compareTo(Sentieri.ordineNelCammino(b))))
        .reversed
        .toList();
    final accesi = {
      for (final t in Sentieri.di(widget.sentiero))
        if (diario.eAcceso(t.id)) t.id,
    };

    return CosmosBackground(
      seed: 19,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // LA BARRA UNICA DELLE ARTI, non una AppBar montata a mano: e' la
        // regola che tiene insieme il cuore delle arti preferite e le azioni
        // di ogni schermata, e una barra fatta in casa e' il modo in cui il
        // difetto era nato la prima volta.
        appBar: BarraArte(
          // IL TITOLO INTERO, e non tagliato: "Costellazione pers..." era
          // quello che si leggeva nell'anteprima, e un titolo troncato dice
          // che la schermata non e' finita.
          // **IL TITOLO VA A CAPO FRA LE PAROLE, MAI DENTRO UNA PAROLA.** Con
          // un `Text` normale "Costellazione personale" si spezzava in
          // "Costellazio / ne persona..." appena la riga delle azioni cresceva:
          // il nome non si accorcia, perche' vive anche nel briefing e nel
          // Passport, quindi si adatta la misura del testo e non il testo.
          titolo: TitoloCheNonSiRompe(
            testo: widget.sentiero.titolo,
            stile: TypographyTokens.titoloScheda()
                .copyWith(color: palette.goldSoft),
          ),
          // **IL PUNTO INTERROGATIVO, ordine AU voce 13.** La mappa del
          // sentiero non si impone: dopo il primo ingresso la si chiede da
          // qui, e da qui e' sempre raggiungibile.
          azioni: [
            IconButton(
              key: const Key('sentiero_apri_la_mappa'),
              tooltip: 'Dove sono in questo sentiero',
              icon: Icon(Icons.help_outline_rounded, color: palette.goldSoft),
              onPressed: () =>
                  LaMappaDelSentiero.mostra(context, widget.sentiero),
            ),
          ],
          // **IL SALDO NON STA PIU' QUI, ordine S voce 06.** Era disegnato
          // dentro questa schermata, e per questo esisteva soltanto in questa
          // schermata: adesso e' `SegnoDelBorsellino` e lo monta la barra, in
          // ogni arte e sempre nello stesso angolo. Lasciarne una copia qui
          // sarebbe il secondo borsellino, cioe' due numeri da tenere
          // d'accordo per sempre.
        ),
        // TUTTO DENTRO UN SOLO SCORRIMENTO: il disegno in alto e' la prima
        // cosa che si vede, l'elenco arriva scorrendo. Le cinquanta righe si
        // costruiscono tutte, non a domanda: sono cinquanta, e servono
        // disposte perche' la discesa possa MISURARE dove si ferma.
        // **L'ALTEZZA UTILE SI MISURA QUI**, dove il viewport la dichiara. Dentro
        // uno sliver il vincolo verticale e' infinito, quindi chiederla la'
        // vorrebbe dire dedurla dallo schermo e sottrarre a mano barra e
        // intestazione: due conti che divergono al primo cambiamento.
        body: LayoutBuilder(builder: (context, vincoli) {
          final altezzaDelDisegno = vincoli.maxHeight * quotaDelDisegno;
          return CustomScrollView(
          key: const Key('sentiero_scorrimento'),
          controller: _scorrimento,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(SpacingTokens.md,
                    SpacingTokens.sm, SpacingTokens.md, SpacingTokens.sm),
                child: SizedBox(
                  key: const Key('sentiero_disegno'),
                  height: altezzaDelDisegno,
                  child: DisegnoDelSentiero(
                    sentiero: widget.sentiero,
                    accesi: accesi,
                    evidenziato: _evidenziato,
                    suTocco: _vaiAlTraguardo,
                  ),
                ),
              ),
            ),
            // LE TRE RIGHE, sotto il disegno: dove sei, cosa vedi, cosa
            // guadagni. Ordine S voce 03.
            SliverToBoxAdapter(
              child: LeTreRigheDelSentiero(
                sentiero: widget.sentiero,
                accesi: accesi.length,
                palette: palette,
              ),
            ),
            // IL COMANDO DISCRETO, che fa quello che prima si faceva da se'.
            SliverToBoxAdapter(
              child: Center(
                child: TextButton.icon(
                  key: const Key('sentiero_vai_al_punto'),
                  onPressed: _scendiAlPunto,
                  style: TextButton.styleFrom(
                      foregroundColor: palette.goldSoft,
                      textStyle: TypographyTokens.didascalia()),
                  icon: const Icon(Icons.south_rounded, size: 15),
                  label: const Text('Vai al punto in cui sei'),
                ),
              ),
            ),
            // LA FASCIA DEI CINQUE GRANDI NON C'E' PIU'. Ordine S voce 02,
            // punto 7, ed e' la strada che l'Architetto raccomandava.
            //
            // Erano cinque anelli grigi coi numeri 10, 20, 30, 40 e 50: una
            // tessera punti di sistema appoggiata sopra un cielo, che con la
            // gerarchia nuova diceva una cosa che il disegno dice meglio. Le
            // cinque stelle principali stanno dentro la figura e si vedono
            // SPENTE in anticipo: e' quella la tessera punti, ed e' fatta della
            // materia del sentiero invece che di cerchi di sistema. Tenerla
            // avrebbe voluto dire due tessere per lo stesso conto, e una delle
            // due con le icone di serie dentro.
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
              // UNA COLONNA E NON UNA LISTA PIGRA, ed e' una scelta della
              // voce 36. Una lista pigra dispone soltanto le righe dentro il
              // viewport: le altre non hanno una posizione, quindi la discesa
              // non potrebbe MISURARE dove si ferma e tornerebbe a stimarla
              // da un'altezza scritta a mano, che e' il difetto di partenza.
              // Le righe sono cinquanta: costruirle tutte non costa niente e
              // rende la misura possibile.
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    for (final traguardo in mini)
                      GradinoDelSentiero(
                        key: _chiaviDeiGradini.putIfAbsent(
                            traguardo.id, GlobalKey.new),
                        traguardo: traguardo,
                        sentiero: widget.sentiero,
                        diario: diario,
                        piano: piano,
                        evidenziato: _evidenziato == traguardo.id,
                        suTocco: () =>
                            setState(() => _evidenziato = traguardo.id),
                      ),
                  ],
                ),
              ),
            ),
          ],
          );
        }),
      ),
    );
  }
}

class SogliaDelLeggibile {
  const SogliaDelLeggibile._();

  /// L'unica opacita' dello stato spento. Non ne esiste una seconda che la
  /// moltiplichi: e' proprio il moltiplicarsi ad aver prodotto lo 0,273.
  static const double alfaDelloSpento = 0.80;

  /// Lo stato "e' il tuo prossimo": oro tenue, e a 0,70 misura 4,82 a 1 nel
  /// caso peggiore.
  static const double alfaDelProssimo = 0.70;

  /// La soglia della voce P.12 per il testo di lettura e di corpo.
  static const double contrastoMinimo = 4.5;
}

/// UN GRADINO: il Sigillo nei suoi CINQUE stati dichiarati.
class GradinoDelSentiero extends StatelessWidget {
  const GradinoDelSentiero({
    super.key,
    required this.traguardo,
    required this.sentiero,
    required this.diario,
    required this.piano,
    this.evidenziato = false,
    this.suTocco,
  });

  final Traguardo traguardo;
  final Sentiero sentiero;
  final DiarioDelCammino diario;
  final Tier piano;
  final bool evidenziato;
  final VoidCallback? suTocco;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // I CINQUE STATI, chiesti al dato invece di combinati a mente qui.
    //
    // **Ordine P voce 21.** Erano tre booleani, quindi otto combinazioni di cui
    // quattro senza senso, e nessuno poteva enumerarle per verificare che
    // nessuna lasciasse una casella grigia dopo un traguardo raggiunto. Adesso
    // lo stato e' un dato solo, e `test/il_sigillo_non_lascia_buchi_test.dart`
    // li attraversa tutti e cinque.
    final stato = StatoDeiSigilli.di(
      raggiunto: diario.eAcceso(traguardo.id),
      condiviso: diario.eStatoCondiviso(traguardo.id),
      bloccato: Sentieri.chiedeIlTier(traguardo) && piano == Tier.free,
      eIlProssimo: diario.prossimoDi(sentiero)?.id == traguardo.id,
    );
    final acceso = stato.acceso;
    final prossimo = stato == StatoDelSigillo.prossimo;
    final bloccato = stato == StatoDelSigillo.bloccato;

    // Il Sigillo si accende al RAGGIUNGIMENTO, sempre: la condivisione governa
    // solo il bonus, e chi non condivide non vede buchi.
    //
    // UNA SOLA OPACITA', quella del colore. La riga non e' piu' avvolta in un
    // Opacity: era la seconda, e le due si moltiplicavano.
    final colore = acceso
        ? palette.goldSoft
        : prossimo
            ? palette.goldSoft
                .withValues(alpha: SogliaDelLeggibile.alfaDelProssimo)
            : ColorTokens.textSecondary
                .withValues(alpha: SogliaDelLeggibile.alfaDelloSpento);

    final sottotitolo = acceso
        ? traguardo.frase
        : bloccato
            ? 'Dal Tier 1 in su'
            // IL CONTO E' UNO SOLO e viene da `Sentieri`: qui c'era "di 50"
            // scritto a mano, che contava i soli mini e diceva alla persona che
            // i cinque grandi non fanno parte del cammino.
            : '${Sentieri.ordineNelCammino(traguardo)} di '
                '${Sentieri.quantiInTutto(sentiero)}';

    return InkWell(
      key: Key('gradino_${traguardo.id}'),
      // OGNI SIGILLO ACCESO E' TOCCABILE, voce 2e: riapre la sua card e la si
      // puo' condividere anche settimane dopo, incassando il bonus rimasto in
      // sospeso. Nessun traguardo raggiunto resta senza una via per
      // condividerlo. E ogni riga, in qualunque stato, evidenzia il suo punto
      // dentro il disegno: e' il verso di ritorno del legame di voce 33.
      onTap: () {
        suTocco?.call();
        if (acceso) {
          mostraLaCardDelTraguardo(context,
              traguardo: traguardo, sentiero: sentiero);
        } else if (bloccato) {
          showUpgradeInvite(
            context,
            title: 'Il cammino continua dal Tier 1',
            message: 'I primi venti traguardi di ogni sentiero sono di tutti. '
                'Dal ventunesimo il cammino prosegue con l\'Iniziato: gli Eos '
                'che hai già preso restano tuoi per sempre.',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: SpacingTokens.sm),
        decoration: evidenziato
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                border:
                    Border.all(color: palette.gold.withValues(alpha: 0.55)),
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IL LUCCHETTO SOLO DOVE C'E' DAVVERO UN BLOCCO: in Demo non ce
            // n'e' nessuno, e un sentiero pieno di lucchetti diceva "chiuso" a
            // chi poteva percorrerlo tutto. Visto sull'anteprima, non
            // ragionato.
            Padding(
              padding: const EdgeInsets.only(top: 2),
              // LA PULSAZIONE LENTA DEL SOSPESO, ordine P voce 21: il Sigillo
              // acceso che ha ancora un bonus da dare respira piano. Con Riduci
              // Movimento resta fermo e acceso, e la marcatura accanto al nome
              // continua a dire che c'e' qualcosa in attesa: il contenuto non
              // si toglie mai.
              child: _SigilloPulsante(
                pulsa: stato.pulsa &&
                    !MediaQuery.of(context).disableAnimations,
                child: Icon(
                  acceso
                      ? Icons.auto_awesome
                      : bloccato
                          ? Icons.lock_outline_rounded
                          : Icons.radio_button_unchecked,
                  color: colore,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(traguardo.nome,
                      key: Key('gradino_nome_${traguardo.id}'),
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: colore)),
                  // LA MARCATURA DEL SOSPESO: dice che il bonus c'e' ancora.
                  if (stato.marcatura != null)
                    Padding(
                      // I VUOTI PASSANO DAI TOKEN, anche i piccoli: il
                      // censimento degli spazi e' a cricchetto e puo' solo
                      // scendere, quindi una marcatura nuova non ha il diritto
                      // di portarsi dietro due misure scritte a mano.
                      padding: const EdgeInsets.only(top: SpacingTokens.xxs),
                      child: Container(
                        key: Key('gradino_sospeso_${traguardo.id}'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.xs,
                            vertical: SpacingTokens.xxs),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusPill),
                          border: Border.all(
                              color: palette.gold.withValues(alpha: 0.55)),
                        ),
                        child: Text(stato.marcatura!,
                            style: TypographyTokens.didascalia()
                                .copyWith(color: palette.goldSoft)),
                      ),
                    ),
                  const SizedBox(height: 2),
                  // NIENTE maxLines, ordine P voce 39. Sul gradino acceso si
                  // leggeva "Tre gettate di rune: le pietre hanno imparato il
                  // peso della" e finiva li': la frase era piu' lunga di due
                  // righe e veniva troncata senza puntini, a meta' di un
                  // gruppo di parole. Una frase tagliata a meta' e' una frase
                  // non scritta, e i puntini l'avrebbero solo nascosta: qui lo
                  // spazio si adatta alla frase.
                  Text(
                    sottotitolo,
                    key: Key('gradino_frase_${traguardo.id}'),
                    style: TypographyTokens.didascalia().copyWith(
                      color: ColorTokens.textSecondary.withValues(
                          alpha: acceso || prossimo
                              ? 1.0
                              : SogliaDelLeggibile.alfaDelloSpento),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              // IL PREMIO DELLA RIGA porta la sua icona, la stessa della barra:
              // un numero nudo in fondo a una riga non dice di cosa e' il
              // numero, e cinquantacinque righe con un numero nudo non lo
              // insegnano.
              child: Row(
                children: [
                  IconaDegliEos(misura: 12, colore: colore),
                  const SizedBox(width: 3),
                  Text('${traguardo.eos}',
                      style: TypographyTokens.etichetta()
                          .copyWith(color: colore)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// IL SIGILLO CHE RESPIRA, quando ha ancora un bonus da dare.
///
/// Ordine P voce 21. Una pulsazione lenta, tre secondi per giro: piu' veloce
/// sarebbe un avviso, e un avviso su cinquanta righe diventa un fastidio.
class _SigilloPulsante extends StatefulWidget {
  const _SigilloPulsante({required this.pulsa, required this.child});

  final bool pulsa;
  final Widget child;

  @override
  State<_SigilloPulsante> createState() => _SigilloPulsanteState();
}

class _SigilloPulsanteState extends State<_SigilloPulsante>
    with SingleTickerProviderStateMixin {
  AnimationController? _motore;

  @override
  void initState() {
    super.initState();
    if (widget.pulsa) {
      _motore = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _motore?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motore = _motore;
    if (motore == null) return widget.child;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.55, end: 1).animate(motore),
      child: widget.child,
    );
  }
}
