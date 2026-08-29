/// IL TUTORIAL DI PRIMO APPRODO, CINQUE FUMETTI. Ordine CB voce 02.
///
/// **Parole del fondatore, 29 agosto 2026:** "facciamo una via di mezzo, da 5
/// fumetti tutorial da leggere in 1 minuto", e dal 28 agosto: "un brevissimo
/// tuttorial (disattivabile, skip) solo appena l'utente approda per la prima
/// volta nella Home il cerchio [...] poche righe ben leggibili per ogni popup
/// (fumetto con freccia)".
///
/// **I cinque testi sono dell'Architetto e si usano come sono scritti.** Due
/// frasi del quinto sono state corrette perche' dicevano il falso sul
/// borsellino, e la correzione e' dichiarata nel manifesto dell'ordine: la
/// regola e' che se un testo mente si corregge il testo, mai la funzione.
///
/// **Perche' i bersagli si registrano invece di essere cercati.** Un
/// `GlobalKey` piantato dentro la barra o dentro la striscia dei doni sarebbe
/// unico in tutto l'albero: due Santuari montati insieme, cosa che le prove
/// fanno, e l'app cade con un errore di chiave duplicata. Qui ogni bersaglio
/// si iscrive con un nome, l'ultimo montato vince, e chi sparisce si cancella.
/// E' la stessa famiglia di guasti del provider preteso, gia' pagata una volta
/// da questo progetto.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';


/// Dove sta il fumetto rispetto al suo bersaglio.
enum LatoDelFumetto {
  /// Il fumetto scende sotto il bersaglio, e la freccia punta in su.
  sotto,

  /// Il fumetto sale sopra il bersaglio, e la freccia punta in giu'.
  sopra,

  /// Nessun bersaglio, nessuna freccia: il fumetto sta al centro.
  soglia,
}

/// Un fumetto: cosa dice, cosa indica e da che parte sta.
class FumettoDelPrimoApprodo {
  const FumettoDelPrimoApprodo({
    required this.titolo,
    required this.testo,
    required this.lato,
    this.ancora,
  });

  final String titolo;
  final String testo;
  final LatoDelFumetto lato;

  /// Il nome del bersaglio, come lo dichiara l'[AncoraDelPrimoApprodo] che lo
  /// veste. Nullo sulla soglia, che non punta niente.
  final String? ancora;
}

/// I NOMI DEI BERSAGLI, in un punto solo.
///
/// **Sono quattro e non cinque**, perche' il primo fumetto e' la soglia e non
/// punta niente: lo dice l'ordine, "Benvenuto. Nessuna freccia".
abstract final class BersagliDelPrimoApprodo {
  static const trio = 'trio_dei_maestri';
  static const esplora = 'barra_esplora';
  static const doni = 'striscia_dei_doni';
  static const identita = 'barra_dell_identita';
}

/// I CINQUE FUMETTI, nell'ordine che il fondatore ha elencato.
///
/// **L'ordine non si riordina** ed e' scritto nell'ordine CB: benvenuto, i
/// Maestri, Esplora in basso, i Doni del Giorno, la barra in alto.
const List<FumettoDelPrimoApprodo> cinqueFumetti = [
  // **I TESTI SONO DEL FONDATORE, ordine CC voce 01.** La prima stesura era
  // dell'Architetto; il fondatore li ha riscritti di suo pugno la sera del 29
  // agosto 2026. Si usano come sono scritti: nessuna riformulazione, nessun
  // sinonimo, nessun accorciamento, e i maiuscoli sono i suoi.
  FumettoDelPrimoApprodo(
    titolo: 'IL CERCHIO TI ACCOGLIE',
    testo: 'Qui trovi le risposte alle domande che non fai a nessuno. '
        'Universo, Oracoli, Simboli, Energia e Spiritualità con un solo '
        'click. Nulla di inventato: solo arti, pratiche e tradizioni '
        'accreditate.',
    lato: LatoDelFumetto.soglia,
  ),
  // **IL SECONDO E' STATO DECISO DAL FONDATORE IL 29 AGOSTO 2026.**
  //
  // La prima stesura nominava domini che l'app non usava da nessuna parte,
  // "Divinazione", "Runologia, Simbologia, Ritualistica", "Energia,
  // Meditazione, Equilibrio", e io avevo misurato che non coincidevano con
  // `Maestro.domainArts`. **Adesso coincidono, tutte e nove le parole**, e
  // non perche' io abbia riscritto il testo: il fondatore ha allineato le sue
  // parole all'app per Medora e per Aura, e ha allineato l'app alle sue per
  // Caligo, dove la macro categoria Cabala e' diventata Numerologia.
  //
  // **La coincidenza non e' lasciata alla buona volonta'**: una prova pretende
  // che questo testo contenga, carattere per carattere, il dominio che ogni
  // Maestro dichiara di se'. Se domani uno dei due cambia senza l'altro, cade.
  //
  // **LA FORMA A ELENCO E' SUA, del 30 agosto 2026.** Prima i tre domini
  // stavano in fila dentro un periodo unico, e a video erano un muretto di
  // testo; adesso ognuno ha la sua riga, col nome in maiuscolo. I capoversi
  // sono nel testo, il `Text` li disegna e il `TextPainter` che misura
  // l'ingombro prima di posare la carta li conta: le due cose leggono la
  // stessa stringa, quindi non possono divergere.
  FumettoDelPrimoApprodo(
    titolo: 'I TRE MAESTRI',
    testo: 'Tre Voci, Tre Mondi, Tre Personalità\n'
        '- MEDORA: Astrologia, Cartomanzia, Destino\n'
        '- CALIGO: Rune, Rituali, Numerologia\n'
        '- AURA: Chakra, Energia, Archetipi\n'
        'Tocca un volto ed entra nel suo dominio',
    lato: LatoDelFumetto.sotto,
    ancora: BersagliDelPrimoApprodo.trio,
  ),
  FumettoDelPrimoApprodo(
    titolo: 'IL CERCHIO A UN CLICK',
    testo: 'Raggiungi immediatamente, ovunque tu sia, il dominio e le arti '
        'di ogni maestro con un tap del dito.',
    lato: LatoDelFumetto.sopra,
    ancora: BersagliDelPrimoApprodo.esplora,
  ),
  // **QUESTO TESTO ASPETTA IL LAVORO SUI DONI. Ordine CC voce 01, decisione
  // del fondatore del 29 agosto 2026.**
  //
  // Il testo nuovo dice "cinque doni a cinque ore diverse, creati incrociando
  // il Cielo di oggi e la tua Carta natale". Misurato: **due doni su cinque
  // nascono davvero da quell'incrocio**, l'Alba e il Soffio. L'Arcano del
  // giorno non nasce da nessuno dei due, e' lo stesso per tutti e dipende solo
  // dalla data (`ArcanoDelGiorno.di(DateTime giorno)`); la Runa del tramonto e
  // il Sigillo del sogno guardano il cielo ma non la carta natale.
  //
  // **Il fondatore ha deciso di tenere la sua frase e di costruire l'incrocio
  // nei doni che oggi non ce l'hanno**, in un ordine suo. Fino ad allora a
  // video resta questo testo, perche' mettere quella frase oggi sarebbe una
  // promessa falsa. Non e' piu' una voce ferma in attesa di una decisione: la
  // decisione c'e', ed e' che il testo aspetta il lavoro.
  FumettoDelPrimoApprodo(
    titolo: 'I Doni del Giorno',
    testo: 'Il Cerchio ti lascia qualcosa ogni giorno, a ore diverse. Non si '
        // **LA VIRGOLA E' CADUTA, LE PAROLE NO. Regola della lingua di
        // questo progetto**: mai una proposizione dopo la virgola con
        // "e". L'ordine chiede di usare i testi dell'Architetto come
        // sono scritti, e qui le due regole si toccavano: si e' tolta la
        // virgola e non una parola. Stesso precedente dell'ordine CA,
        // dove trentasei frasi del corpus hanno perso la virgola.
        'cercano: si ricevono e chi torna li trova.',
    lato: LatoDelFumetto.sotto,
    ancora: BersagliDelPrimoApprodo.doni,
  ),
  // **IL QUINTO E' STATO CORRETTO IN DUE PUNTI, e la voce lo chiedeva.**
  //
  // L'ordine impone di misurare che le vie di guadagno e di spesa nominate
  // siano vere, e di correggere il TESTO se non lo sono. Non lo erano:
  //
  // 1. "ogni responso che condividi" prometteva un premio senza fine. Il
  //    server ne paga al massimo TRE al giorno, `TETTO_CONDIVISIONI_PREMIATE`,
  //    e dal quarto in poi la condivisione non vale un Eos. Adesso il testo
  //    dice "i primi responsi che condividi".
  // 2. "per aprire cio' che ancora dorme" prometteva di sbloccare le funzioni
  //    in arrivo. Gli Eos non aprono niente di dormiente: comprano una
  //    domanda in piu' o una lettura in piu' quando il giorno e' finito,
  //    `PREZZI_DEL_RISCATTO`. Adesso il testo dice quello.
  //
  // E' stata aggiunta la via di guadagno piu' frequente di tutte, che il testo
  // non nominava: l'accredito di ogni giorno.
  // **IL QUINTO E' STATO DECISO DAL FONDATORE IL 29 AGOSTO 2026.**
  //
  // Il testo che aspettava prometteva di comprare "nuove esperienze e arti".
  // Misurato due volte sul listino del server, `PREZZI_DEL_RISCATTO`: gli Eos
  // comprano cinque cose, tutte una dose in piu' di un'arte che la persona ha
  // gia' (una domanda 80, un approfondimento 60, una gettata 60, un confronto
  // 150, una stesa completa 250). **Nessuna arte dormiente si apre con gli
  // Eos**: quelle le accendono i feature flag, non il borsellino.
  //
  // **Il fondatore ha fatto cadere la parola "arti" e ha tenuto il resto.**
  // I maiuscoli sono suoi e non si normalizzano: IL TUO BORSELLINO ed EOS
  // stanno in maiuscolo perche' li ha scritti cosi'.
  FumettoDelPrimoApprodo(
    titolo: 'IL CAMMINO E GLI EOS',
    testo: 'Qui in alto: il tuo profilo, gli eventi cosmici speciali e IL TUO '
        'BORSELLINO: guadagna e spendi EOS ogni giorno per acquistare nuove '
        'esperienze.',
    lato: LatoDelFumetto.sotto,
    ancora: BersagliDelPrimoApprodo.identita,
  ),
];

/// IL BERSAGLIO SI ISCRIVE DA SE'.
///
/// Veste un pezzo di scena e ne dichiara il nome. Il tutorial gli chiede dove
/// sta, quando gli serve. Se quel pezzo non e' montato in questo momento,
/// nessuno risponde e il fumetto resta senza freccia: e' la scelta dichiarata
/// per le zone non visibili.
class AncoraDelPrimoApprodo extends StatefulWidget {
  const AncoraDelPrimoApprodo({
    super.key,
    required this.nome,
    required this.child,
  });

  final String nome;
  final Widget child;

  /// Il rettangolo del bersaglio in coordinate di schermo, o null se quel
  /// pezzo non e' montato.
  ///
  /// **Si misura con la matrice, non con `localToGlobal` piu' `size`.** Le due
  /// barre si ingrandiscono quando la persona le tocca, e sotto una scala il
  /// secondo metodo restituisce il rettangolo NON scalato: la freccia
  /// punterebbe accanto alla cosa. E' un difetto che questo progetto ha gia'
  /// misurato una volta.
  static Rect? dove(String nome) {
    final stato = _iscritte[nome];
    final box = stato?.context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return null;
    return MatrixUtils.transformRect(
        box.getTransformTo(null), Offset.zero & box.size);
  }

  static final Map<String, State<AncoraDelPrimoApprodo>> _iscritte = {};

  @override
  State<AncoraDelPrimoApprodo> createState() => _AncoraDelPrimoApprodoState();
}

class _AncoraDelPrimoApprodoState extends State<AncoraDelPrimoApprodo> {
  @override
  void initState() {
    super.initState();
    AncoraDelPrimoApprodo._iscritte[widget.nome] = this;
  }

  @override
  void didUpdateWidget(AncoraDelPrimoApprodo vecchio) {
    super.didUpdateWidget(vecchio);
    if (vecchio.nome != widget.nome) {
      if (AncoraDelPrimoApprodo._iscritte[vecchio.nome] == this) {
        AncoraDelPrimoApprodo._iscritte.remove(vecchio.nome);
      }
      AncoraDelPrimoApprodo._iscritte[widget.nome] = this;
    }
  }

  @override
  void dispose() {
    if (AncoraDelPrimoApprodo._iscritte[widget.nome] == this) {
      AncoraDelPrimoApprodo._iscritte.remove(widget.nome);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// LA MEMORIA DEL PRIMO APPRODO.
///
/// **La chiave sta sotto `avvisi.`**, che e' un prefisso che la cancellazione
/// gia' porta via: chi cancella tutto e torna rivede il tutorial, che e'
/// giusto, perche' per l'app e' una persona nuova.
abstract final class MemoriaDelPrimoApprodo {
  /// **LA CHIAVE CHE ARMA, e non e' la stessa che ricorda.**
  ///
  /// Il tutorial non nasce acceso: si accende quando qualcuno lo ARMA. Lo arma
  /// l'onboarding quando finisce, che e' esattamente il momento del primo
  /// approdo, e lo arma il menu' utente quando la persona chiede di rivederlo.
  ///
  /// **Un tutorial che nascesse acceso si accenderebbe anche nelle prove e
  /// nelle anteprime**, dove il disco e' vuoto e "mai visto" e "appena
  /// arrivato" sono la stessa cosa: centinaia di scene monterebbero con un
  /// velo sopra, e nessuna di quelle prove parla del tutorial. E' la famiglia
  /// di guasti che questo progetto ha gia' pagato col provider preteso.
  static const chiaveArmata = 'avvisi.primoApprodo.armato';

  /// Quello che il tutorial scrive quando e' finito o saltato: chi l'ha visto
  /// non lo rivede da solo, nemmeno se qualcuno riarma per sbaglio.
  static const chiave = 'avvisi.primoApprodo.visto';

  /// **ARMA IL PRIMO APPRODO**, cioe' dice che la prossima volta che si vede
  /// il Cerchio il tutorial deve partire. Non lo fa partire adesso: il
  /// Cerchio potrebbe non essere ancora a video.
  static Future<void> arma() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(chiaveArmata, true);
  }

  /// Vero solo se qualcuno ha armato E la persona non l'ha ancora visto.
  static Future<bool> daMostrare() async {
    final p = await SharedPreferences.getInstance();
    if (!(p.getBool(chiaveArmata) ?? false)) return false;
    return !(p.getBool(chiave) ?? false);
  }

  /// **VERO SE IL TUTORIAL E' GIA' STATO VISTO.** Ordine CC voce 09.
  ///
  /// Non e' [daMostrare] al contrario: quella e' falsa anche per chi non
  /// e' mai stato armato, cioe' per chi il tutorial non l'ha ancora avuto.
  /// Qui serve sapere se il Cerchio e' gia' stato spiegato a qualcuno.
  static Future<bool> visto() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(chiave) ?? false;
    } catch (errore) {
      return false;
    }
  }

  static Future<void> segnaVisto() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(chiave, true);
    await p.remove(chiaveArmata);
  }

  /// La via del menu' utente: si dimentica di averlo visto e si riarma.
  static Future<void> rivedi() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(chiave);
    await p.setBool(chiaveArmata, true);
  }
}

/// **LA RICHIESTA DI RIVEDERLO, dal menu' utente.** Il menu' vive dentro una
/// rotta spinta sopra il guscio, quindi non puo' accendere il tutorial da
/// solo: alza questa bandierina, torna al Cerchio, e il tutorial la vede.
final ValueNotifier<int> rivediIlPrimoApprodo = ValueNotifier<int>(0);

/// IL TUTORIAL, sopra tutto il resto.
///
/// Sta fuori dalle due barre e dentro l'intro: cosi' copre anche le barre, che
/// sono due dei cinque bersagli, e non copre mai l'intro, che viene prima.
class PrimoApprodo extends StatefulWidget {
  const PrimoApprodo({
    super.key,
    required this.child,
    this.attivo = true,
  });

  final Widget child;

  /// Spento nelle prove e nelle anteprime che non lo riguardano, cosi' una
  /// scena qualunque non nasce con un velo sopra.
  final bool attivo;

  /// **L'INTERRUTTORE DELLE PROVE.** Quando e' vero il tutorial parte anche
  /// senza chiedere niente al disco, che nelle prove risponde troppo tardi.
  static bool sempreAllaProva = false;

  @override
  State<PrimoApprodo> createState() => _PrimoApprodoState();
}

class _PrimoApprodoState extends State<PrimoApprodo> {
  bool _inScena = false;
  int _passo = 0;

  @override
  void initState() {
    super.initState();
    rivediIlPrimoApprodo.addListener(_riapri);
    _forseApri();
  }

  @override
  void dispose() {
    rivediIlPrimoApprodo.removeListener(_riapri);
    super.dispose();
  }

  void _riapri() {
    if (!mounted) return;
    setState(() {
      _passo = 0;
      _inScena = true;
    });
  }

  Future<void> _forseApri() async {
    if (!widget.attivo) return;
    if (PrimoApprodo.sempreAllaProva) {
      if (mounted) setState(() => _inScena = true);
      return;
    }
    if (!await MemoriaDelPrimoApprodo.daMostrare()) return;
    if (!mounted) return;
    setState(() => _inScena = true);
  }

  Future<void> _chiudi() async {
    setState(() => _inScena = false);
    await MemoriaDelPrimoApprodo.segnaVisto();
  }

  void _avanti() {
    if (_passo + 1 >= cinqueFumetti.length) {
      _chiudi();
      return;
    }
    setState(() => _passo++);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_inScena)
          _VeloDelPrimoApprodo(
            fumetto: cinqueFumetti[_passo],
            passo: _passo,
            quanti: cinqueFumetti.length,
            avanti: _avanti,
            salta: _chiudi,
          ),
      ],
    );
  }
}

class _VeloDelPrimoApprodo extends StatelessWidget {
  const _VeloDelPrimoApprodo({
    required this.fumetto,
    required this.passo,
    required this.quanti,
    required this.avanti,
    required this.salta,
  });

  final FumettoDelPrimoApprodo fumetto;
  final int passo;
  final int quanti;
  final VoidCallback avanti;
  final VoidCallback salta;

  /// Quanto respiro fra il bersaglio e il fumetto, e quanto e' alta la freccia.
  static const double _aria = SpacingTokens.sm;
  /// **QUANTO E' ALTA LA FRECCIA. Ordine CC voce 02.**
  ///
  /// Era dodici punti, ed era la meta' del problema: dodici punti di triangolo
  /// scuro su un velo scuro non li vede nessuno. Sedici e' l'altezza a cui il
  /// triangolo regge il proprio colore anche sopra la parte piu' chiara di una
  /// scena, ed e' ancora un terzo dell'aria che lo circonda.
  static const double _freccia = 16;

  /// Quanto respiro resta fra il fumetto e il bordo dello schermo.
  static const double _orlo = SpacingTokens.md;

  /// I due pezzi fissi della carta: la riga del conto e il pulsante largo.
  /// Sono misure del tema, non numeri scelti qui, e stanno insieme perche'
  /// insieme entrano nel conto dell'ingombro.
  /// Alta come il tasto che porta, che e' il minimo di un dito: misurata
  /// sulla carta vera, quaranta punti la sottostimavano di otto.
  static const double _altezzaDellaRiga = 48;
  static const double _altezzaDelPulsante = 48;

  @override
  Widget build(BuildContext context) {
    // **NIENTE SCOPE PRETESO, e qui non ci sarebbe.** Il velo sta FUORI dal
    // `MaestroScope`, che vive dentro la barra del Cerchio: `MaestroScope.of`
    // lancia sull'assert, e in release lancia sul nullo. Si chiede col forse e
    // si ripiega sul neutro, come fa gia' la barra dell'identita'.
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    final schermo = MediaQuery.sizeOf(context);
    final bersaglio = fumetto.ancora == null
        ? null
        : AncoraDelPrimoApprodo.dove(fumetto.ancora!);

    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        container: true,
        label: 'Primo approdo, passo ${passo + 1} di $quanti',
        child: Stack(
          children: [
            // **IL VELO NON SI CHIUDE AL TOCCO.** Un velo che si chiude
            // toccandolo farebbe sparire il tutorial al primo dito appoggiato,
            // e la persona non saprebbe cosa ha fatto: si esce dal tasto che
            // lo dice.
            Positioned.fill(
              child: CustomPaint(
                painter: _VeloForato(
                  buco: bersaglio,
                  colore: palette.deepest,
                  oro: palette.gold,
                ),
              ),
            ),
            _fumetto(context, palette, schermo, bersaglio),
          ],
        ),
      ),
    );
  }

  Widget _fumetto(BuildContext context, MaestroPalette palette, Size schermo,
      Rect? bersaglio) {
    final larghezza = schermo.width - SpacingTokens.lg * 2;
    final carta = _Carta(
      fumetto: fumetto,
      passo: passo,
      quanti: quanti,
      avanti: avanti,
      salta: salta,
      palette: palette,
      larghezza: larghezza,
    );

    // **SENZA BERSAGLIO IL FUMETTO STA AL CENTRO, senza freccia.** E' la
    // scelta dichiarata per la soglia e per la zona non visibile: puntare una
    // freccia verso il nulla sarebbe peggio che non puntarla.
    if (bersaglio == null || fumetto.lato == LatoDelFumetto.soglia) {
      return Center(child: carta);
    }

    // **L'INGOMBRO SI MISURA PRIMA DI POSARE IL FUMETTO.**
    //
    // Guardando l'anteprima a 360 punti: il fumetto dei Maestri, appeso sotto
    // il carosello che e' alto mezzo schermo, usciva dal fondo e il tasto
    // Avanti non si vedeva. Nemmeno il tocco lo trovava, e il registro delle
    // anteprime lo diceva con un avviso che nessuna prova leggeva.
    //
    // Adesso si misura quanto e' alta la carta con un `TextPainter`, cioe'
    // con lo stesso motore che poi la disegna, e si sceglie: il lato che il
    // corpus chiede se ci sta, l'altro lato se ci sta quello, il centro senza
    // freccia se non ci sta nessuno dei due. Meglio un fumetto al centro che
    // un fumetto mezzo fuori.
    final alta = _quantoEAlta(carta, larghezza) + _freccia;
    final sottoLibero = schermo.height - bersaglio.bottom - _aria - _orlo;
    final sopraLibero = bersaglio.top - _aria - _orlo;
    final volutoSotto = fumetto.lato == LatoDelFumetto.sotto;
    // Il lato voluto se ci sta, l'altro se ci sta l'altro, e se non ci sta
    // nessuno dei due quello che ha piu' spazio.
    // **QUANDO NON CI STA DA NESSUNA PARTE, VINCE IL LATO CHE IL CORPUS
    // CHIEDE, non quello con piu' spazio.**
    //
    // **Il fatto del fondatore, il 30 agosto 2026**: "la bolla taglia la testa
    // ai Maestri che stanno sotto e visivamente sta proprio male". Vero, e
    // guardato: il fumetto dei Maestri tagliava tutti e tre al collo.
    //
    // La causa era qui. Il corpus chiede il fumetto SOTTO il carosello, con la
    // freccia in su. A 360 punti non ci sta ne' sotto ne' sopra, e la vecchia
    // regola sceglieva **il lato con piu' spazio**, cioe' sopra: la carta
    // scendeva sulla parte alta delle tre carte dei Maestri, che e' dove
    // stanno le facce.
    //
    // **Un ritratto si riconosce dalla faccia.** Se la carta deve sovrapporsi
    // per forza, che si sovrapponga dove il bersaglio dice meno: sotto, cioe'
    // sulle vesti e sui piedi. Il lato voluto dal corpus e' una scelta di chi
    // ha scritto quel fumetto, e regge anche qui.
    final sotto = volutoSotto
        ? (alta <= sottoLibero
            ? true
            : (alta <= sopraLibero ? false : true))
        : (alta <= sopraLibero
            ? false
            : (alta <= sottoLibero ? true : false));

    // **E QUANDO NON CI STA, SI TIENE DENTRO LO SCHERMO, non al centro.**
    // Al centro il fumetto copriva per intero i tre Maestri di cui parla: il
    // velo apriva il buco sulla cosa e la carta ci si sedeva sopra. Meglio
    // sfiorarne il bordo che nasconderla tutta. Il caso vero e' uno solo, il
    // carosello dei Maestri, che a 360 punti e' alto 274 su 797: sotto ne
    // restano 203, sopra 264, e la carta ne chiede 285.
    final voluto =
        sotto ? bersaglio.bottom + _aria : bersaglio.top - _aria - alta;
    final quota = voluto.clamp(_orlo, schermo.height - alta - _orlo);

    return Positioned(
      left: SpacingTokens.lg,
      top: quota,
      width: larghezza,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sotto) _puntaVerso(bersaglio, palette, versoIlBasso: false),
          carta,
          if (!sotto) _puntaVerso(bersaglio, palette, versoIlBasso: true),
        ],
      ),
    );
  }

  /// Quanto e' alta la carta a quella larghezza, misurata e non stimata.
  ///
  /// Le due altezze che non vengono dal testo sono quelle dei pezzi fissi:
  /// il bordo e i due riempimenti, la riga del conto e il pulsante largo.
  static double _quantoEAlta(_Carta carta, double larghezza) {
    final dentro = larghezza - SpacingTokens.md * 2;
    double riga(String testo, TextStyle stile) {
      final p = TextPainter(
        text: TextSpan(text: testo, style: stile),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: dentro);
      return p.height;
    }

    return SpacingTokens.md * 2 +
        riga(carta.fumetto.titolo, TypographyTokens.titoloScheda()) +
        SpacingTokens.xs +
        riga(carta.fumetto.testo,
            TypographyTokens.corpo().copyWith(height: 1.45)) +
        SpacingTokens.md +
        _altezzaDellaRiga +
        SpacingTokens.xs +
        _altezzaDelPulsante;
  }

  Widget _puntaVerso(Rect bersaglio, MaestroPalette palette,
      {required bool versoIlBasso}) {
    // La freccia sta sotto il centro del bersaglio, ma non esce mai dalla
    // carta: su un bersaglio a filo di schermo finirebbe fuori dal fumetto.
    final centro = bersaglio.center.dx - SpacingTokens.lg;
    return Padding(
      padding: EdgeInsets.only(left: centro.clamp(SpacingTokens.md, 1000)),
      child: CustomPaint(
        size: const Size(_freccia * 1.9, _freccia),
        painter: _Freccia(
          colore: palette.gold,
          bordo: palette.deepest,
          versoIlBasso: versoIlBasso,
        ),
      ),
    );
  }
}

class _Carta extends StatelessWidget {
  const _Carta({
    required this.fumetto,
    required this.passo,
    required this.quanti,
    required this.avanti,
    required this.salta,
    required this.palette,
    required this.larghezza,
  });

  final FumettoDelPrimoApprodo fumetto;
  final int passo;
  final int quanti;
  final VoidCallback avanti;
  final VoidCallback salta;
  final MaestroPalette palette;
  final double larghezza;

  @override
  Widget build(BuildContext context) {
    final ultimo = passo + 1 >= quanti;
    return Container(
      width: larghezza,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.gold.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: palette.deepest.withValues(alpha: 0.55),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            fumetto.titolo,
            key: Key('primo_approdo_titolo_$passo'),
            style: TypographyTokens.titoloScheda().copyWith(color: palette.gold),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            fumetto.testo,
            key: Key('primo_approdo_testo_$passo'),
            style: TypographyTokens.corpo()
                .copyWith(color: palette.textPrimary, height: 1.45),
          ),
          const SizedBox(height: SpacingTokens.md),
          // **IL CONTO E LO SKIP SOPRA, IL PASSO AVANTI SOTTO.** In fila su
          // una riga sola, a 360 punti logici, "5 di 5" piu' Salta piu'
          // "Entra nel Cerchio" sfondavano di 35 punti: misurato, non temuto.
          // Il pulsante che porta avanti prende tutta la riga, che a un dito
          // e' anche piu' facile da prendere.
          Row(
            children: [
              Text(
                '${passo + 1} di $quanti',
                key: const Key('primo_approdo_conta'),
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft),
              ),
              const Spacer(),
              // **LO SKIP C'E' SEMPRE, su tutti e cinque.** L'ordine lo
              // chiede per nome: "l'utente potra' cmq decidere in ogni momento
              // se proseguire o chiudere il tutorial".
              TextButton(
                key: const Key('primo_approdo_salta'),
                onPressed: salta,
                child: Text('Salta',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft)),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('primo_approdo_avanti'),
              onPressed: avanti,
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
              ),
              child: Text(ultimo ? 'Entra nel Cerchio' : 'Avanti',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.deepest)),
            ),
          ),
        ],
      ),
    );
  }
}

/// IL VELO COL BUCO: scurisce tutto tranne la cosa di cui si parla.
class _VeloForato extends CustomPainter {
  const _VeloForato({
    required this.buco,
    required this.colore,
    required this.oro,
  });

  final Rect? buco;
  final Color colore;
  final Color oro;

  @override
  void paint(Canvas canvas, Size size) {
    final tutto = Offset.zero & size;
    final velo = Paint()..color = colore.withValues(alpha: 0.86);
    if (buco == null) {
      canvas.drawRect(tutto, velo);
      return;
    }
    final foro = RRect.fromRectAndRadius(
        buco!.inflate(4), const Radius.circular(14));
    canvas.saveLayer(tutto, Paint());
    canvas.drawRect(tutto, velo);
    canvas.drawRRect(foro, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
    canvas.drawRRect(
        foro,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = oro.withValues(alpha: 0.7));
  }

  @override
  bool shouldRepaint(_VeloForato vecchio) =>
      vecchio.buco != buco || vecchio.colore != colore;
}

/// LA FRECCIA DEL FUMETTO, un triangolo dello stesso colore della carta.
class _Freccia extends CustomPainter {
  const _Freccia({
    required this.colore,
    required this.bordo,
    required this.versoIlBasso,
  });

  final Color colore;
  final Color bordo;
  final bool versoIlBasso;

  @override
  void paint(Canvas canvas, Size size) {
    final via = Path();
    if (versoIlBasso) {
      via.moveTo(0, 0);
      via.lineTo(size.width, 0);
      via.lineTo(size.width / 2, size.height);
    } else {
      via.moveTo(0, size.height);
      via.lineTo(size.width, size.height);
      via.lineTo(size.width / 2, 0);
    }
    via.close();
    // **L'ALONE PRIMA, SOTTO IL TRIANGOLO. Ordine CC voce 02.** Rilievo del
    // fondatore: "la freccia delle bolle sono poco visibili". La freccia era
    // dipinta col colore della CARTA, cioe' un viola scuro, sopra un velo
    // quasi nero: due scuri uno sull'altro. Adesso e' oro pieno, che e' lo
    // stesso oro del bordo della carta, e l'alone la stacca anche quando sotto
    // passa la parte chiara di una scena illuminata.
    canvas.drawPath(
        via,
        Paint()
          ..color = bordo.withValues(alpha: 0.65)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(via, Paint()..color = colore);
  }

  @override
  bool shouldRepaint(_Freccia vecchio) =>
      vecchio.colore != colore || vecchio.versoIlBasso != versoIlBasso;
}
