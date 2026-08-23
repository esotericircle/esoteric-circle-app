import '../../core/sigilli/traguardo.dart';
import 'dart:ui' as ui;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/registro_degli_eos.dart';
import '../../core/entitlement/tier.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'icona_degli_eos.dart';
import 'volo_degli_eos.dart';
import '../../features/pricing/pricing_screen.dart';

/// IL BORSELLINO, SEMPRE NELLO STESSO ANGOLO. Ordine S voce 06.
///
/// **Il difetto.** Il saldo compariva in UNA schermata sola, il sentiero dei
/// Sigilli, e la riga era disegnata dentro quella schermata: da ogni altra
/// parte gli Eos non esistevano. Un numero che appare e scompare non si impara,
/// e chi non lo vede non sa nemmeno di averne.
///
/// **Una forma sola, un posto solo.** Questo widget e' l'unico segno del
/// borsellino dell'app: l'icona degli Eos, il numero, la parola, in coda alle
/// azioni della barra e prima del cuore. Chi lo vuole non lo ridisegna, lo
/// monta. Se ogni schermata se lo disegnasse, in due mesi avremmo cinque
/// borsellini diversi in cinque angoli diversi, che e' la famiglia delle due
/// porte applicata al denaro. Dall'ordine AI voce 01 il segno veste la
/// PILLOLA qui sotto.

/// LE DUE VESTI DELLA PILLOLA, ordine AI voce 01: stessa meccanica, due pesi
/// visivi. Decide Mauro guardando le anteprime; finche' non decide si monta
/// il velo, che e' la piu' discreta.
enum VesteDellaPillola {
  /// Vetro leggero: fondo velato e bordo tenue.
  velo,

  /// Vetro inciso: fondo piu' pieno, bordo d'oro e un alone breve.
  oro,
}

class SegnoDelBorsellino extends StatefulWidget {
  const SegnoDelBorsellino({
    super.key,
    this.veste = VesteDellaPillola.velo,
    this.compatta = false,
    this.monetaDOro = false,
    this.contestoDelFoglio,
    this.verticale = false,
    this.senzaVeste = false,
    this.suTocco,
  });

  /// La veste di riposo della pillola. Dalla coda all'ordine AI la veste
  /// resa puo' accendersi d'oro all'atterraggio degli Eos e poi tornare qui.
  final VesteDellaPillola veste;

  /// **LA FORMA COMPATTA, per la barra delle arti.** La larghezza resta
  /// RISERVATA (cinque cifre tabellari), ma l'aria attorno si stringe:
  /// nella barra dei sentieri il titolo lungo scendeva a corpo 13 contro il
  /// minimo di 14, misurato dalla guardia del titolo, e quei punti erano
  /// margine della pillola, non contenuto. Le cinque schermate principali
  /// restano con la forma piena.
  final bool compatta;

  /// **LA MONETA D'ORO DI MAURO, ordine AL voce 08.** Nella capsula l'icona
  /// del saldo e' la moneta consegnata da Mauro (assets/brand/moneta_eos):
  /// la scritta incisa si perde sotto i 18 punti ed e' dichiarato, a queste
  /// misure resta una moneta d'oro e basta. Fuori dalla capsula resta
  /// l'icona storica degli Eos.
  final bool monetaDOro;

  /// **IL CONTESTO CON CUI APRIRE IL FOGLIO, per chi vive SOPRA il
  /// Navigator.** La capsula sta nel builder dell'app, antenata del
  /// Navigator: il suo contesto non puo' aprire un foglio, e questa porta
  /// consegna quello giusto. Nulla per chi vive dentro una schermata.
  final BuildContext Function()? contestoDelFoglio;

  /// **SENZA LA SUA VESTE, ordine AM voce 04.** Dentro la barra sottile il
  /// saldo non porta la propria pillola: la fascia e' gia' la sua superficie,
  /// e una pillola dentro una barra sarebbe un bordo dentro un bordo. La
  /// veste mista, il conto che sale e il bersaglio del volo restano.
  final bool senzaVeste;

  /// Il tocco, quando chi ospita ne vuole uno suo: nella barra chiusa il
  /// tocco APRE la barra invece di aprire il foglio, cosi' il primo tocco
  /// non porta via da dove si sta.
  final VoidCallback? suTocco;

  /// **LA FORMA VERTICALE, per la capsula dell'ordine AL voce 08.** Icona
  /// sopra e cifra sotto: la capsula resta stretta e le barre delle arti,
  /// che le riservano lo spazio, non rubano al titolo i punti che la
  /// guardia tipografica difende. La larghezza della cifra resta RISERVATA
  /// come in ogni altra forma.
  final bool verticale;

  @override
  State<SegnoDelBorsellino> createState() => _SegnoDelBorsellinoState();
}

class _SegnoDelBorsellinoState extends State<SegnoDelBorsellino> {
  /// LA CHIAVE CON CUI IL VOLO SA DOVE ARRIVARE, ordine S voce 07.
  final GlobalKey _dove = GlobalKey();

  /// L'ULTIMO NUMERO GIA' MOSTRATO, da cui il conto parte quando cambia.
  int? _mostrato;

  /// **LA VESTE MISTA, decisione di Mauro del 17 agosto (coda all'ordine
  /// AI).** La pillola vive col velo di riposo; quando il volo degli Eos le
  /// atterra dentro si accende d'ORO e poi torna velo: il guadagno si
  /// celebra da solo.
  bool _accesa = false;
  Timer? _spegnimento;

  /// Quanto resta d'oro dopo l'atterraggio: il volo e il conto durano 900
  /// millesimi l'uno, e la doratura li copre entrambi e resta un respiro in
  /// piu', abbastanza da vedersi, mai un lampeggio.
  static const Duration quantoRestaAccesa = Duration(milliseconds: 2600);

  /// Quanto dura il passaggio fra le due vesti, nei due sensi.
  static const Duration transizione = Duration(milliseconds: 420);

  @override
  void initState() {
    super.initState();
    DoveStaIlBorsellino.registra(_dove);
    ArrivoDegliEos.annunci.addListener(_ricominciaIlConto);
  }

  @override
  void dispose() {
    _spegnimento?.cancel();
    ArrivoDegliEos.annunci.removeListener(_ricominciaIlConto);
    DoveStaIlBorsellino.dimentica(_dove);
    super.dispose();
  }

  /// GLI EOS STANNO ARRIVANDO: il conto riparte da prima del premio.
  void _ricominciaIlConto() {
    if (!mounted) return;
    final borsa = context.read<QuestionAllowance?>();
    if (borsa == null) return;
    setState(() {
      _mostrato = borsa.saldoEos - ArrivoDegliEos.quanti;
      // L'ATTERRAGGIO ACCENDE L'ORO: stessa porta del conto, perche' il
      // volo annuncia una volta sola e i due si muovono insieme.
      _accesa = true;
    });
    _spegnimento?.cancel();
    _spegnimento = Timer(quantoRestaAccesa, () {
      if (mounted) setState(() => _accesa = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // **LA PALETTE SI CHIEDE DALLA PORTA CHE AMMETTE IL NULLA.** Il segno vive
    // dentro barre che non sempre hanno uno `MaestroScope` sopra: la barra delle
    // arti ce l'ha, una AppBar propria montata in una prova puo' non averlo.
    // Chiedere `context.palette` faceva esplodere un assert DENTRO la schermata
    // che stava solo mostrando un numero, e ha fatto cadere quattro prove del
    // Tramonto che non c'entravano niente. E' la stessa porta che usa la festa,
    // per la stessa ragione.
    final palette = MaestroScope.forse(context);
    if (palette == null) return const SizedBox.shrink();
    // IL SALDO LO LEGGE, NON LO SCRIVE: il numero e' del server, e questo e'
    // solo il posto in cui si vede.
    //
    // **E SE L'ALBERO NON PORTA LA BORSA, non si dipinge e non si casca.** Nel
    // guscio dell'app il contatore c'e' sempre, ma le prove montano una scena
    // d'arte da sola: pretendere il provider vorrebbe dire far cadere una
    // schermata intera per un numero in un angolo. E' la stessa scelta della
    // coda delle feste e del registro dei movimenti. Che il segno ci sia in
    // tutte le schermate della pratica non lo garantisce questo `if`, lo
    // garantisce l'enumerazione della prova.
    final borsa = context.watch<QuestionAllowance?>();
    if (borsa == null) return const SizedBox.shrink();
    final saldo = borsa.saldoEos;
    // **DA DOVE PARTE IL CONTO.** Al primo montaggio si parte dal numero stesso,
    // cosi' aprendo una schermata il saldo non conta da zero come se lo avessi
    // appena guadagnato: il conto e' il racconto di un CAMBIAMENTO, e alla prima
    // apertura non e' cambiato niente.
    final partenza = _mostrato ?? saldo;
    _mostrato = saldo;
    // **LA PILLOLA, ordine AI voce 01.** Il saldo era icona e testo nudi, e
    // con mille Eos la riga cresceva fin dentro i sottotitoli. Adesso e' una
    // pillola di vetro a LARGHEZZA RISERVATA: lo spazio e' quello di cinque
    // cifre coi numeri tabellari, misurato qui sotto sul campione piu' largo,
    // quindi 0 e 10.000 occupano lo stesso posto e niente si sposta mai.
    // **Senza sfocature**: il vetro e' un velo di colore, perche' il filtro di
    // sfocatura e' la stessa tecnica sospettata di non comparire sul telefono.
    //
    // **La parola "Eos" esce dalla pillola**, e non e' un ripensamento
    // dell'ordine S voce 05 fatto in silenzio: la' il numero nudo con la
    // scintilla di serie si leggeva "stelle"; qui la moneta e' la NOSTRA
    // icona, il tocco apre il borsellino che la nomina per esteso e la voce
    // per chi ascolta dice "Borsellino, N Eos". Cinque cifre piu' la parola
    // non starebbero in nessuna testata.
    // La veste RESA: quella di riposo del montaggio, oppure l'oro
    // dell'atterraggio finche' la doratura non si spegne.
    final vesteResa =
        _accesa ? VesteDellaPillola.oro : widget.veste;
    final stile = TypographyTokens.etichetta().copyWith(
      color: vesteResa == VesteDellaPillola.oro
          ? palette.gold
          : palette.goldSoft,
      fontFeatures: const [ui.FontFeature.tabularFigures()],
    );
    final metro = TextPainter(
      text: TextSpan(text: '88.888', style: stile),
      textDirection: TextDirection.ltr,
    )..layout();
    final larghezzaCifre = metro.width;
    metro.dispose();
    final veste0 = vesteResa == VesteDellaPillola.velo;
    // Sotto Riduci Movimento il passaggio fra le vesti e' un cambio secco:
    // si toglie il movimento, non la doratura.
    final durataTransizione = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : transizione;
    return Semantics(
      button: true,
      label: 'Borsellino, $saldo Eos',
      // Il Material sta NEL componente: una prova che monta la schermata da
      // sola non ne ha uno sopra, e la pillola non deve farla cadere.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
        key: const Key('borsellino'),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        onTap: widget.suTocco ??
            () => PortafoglioDelCerchio.apri(
                widget.contestoDelFoglio?.call() ?? context),
        child: AnimatedContainer(
          duration: durataTransizione,
          curve: Curves.easeOut,
          decoration: widget.senzaVeste
              ? const BoxDecoration()
              : BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            // Il velo si e' scurito da 0,38 a 0,62 con l'ordine AK voce 03: senza
            // la rotellina accanto, sul Passaporto la pillola e' finita
            // sopra un fondo chiaro e il contrasto della cifra scendeva a
            // 2,9 contro il 4,5 che l'ordine AI pretende su OGNI fondo. Il
            // velo resta velo: cambia il fondo della pillola, non il bordo.
            color: palette.deepest.withValues(alpha: veste0 ? 0.62 : 0.72),
            border: Border.all(
              color: veste0
                  ? palette.goldSoft.withValues(alpha: 0.35)
                  : palette.gold.withValues(alpha: 0.65),
            ),
            boxShadow: veste0
                ? null
                : [
                    BoxShadow(
                      color: palette.glow.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: -3,
                    ),
                  ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compatta ? SpacingTokens.xs : SpacingTokens.sm,
            vertical: widget.compatta ? 3 : 5,
          ),
          child: Flex(
            key: _dove,
            // La stessa pillola in due forme: in fila nelle barre, in
            // colonna dentro la capsula. Il contenuto e' identico.
            direction: widget.verticale ? Axis.vertical : Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.monetaDOro)
                Image.asset(
                  'assets/brand/moneta_eos.webp',
                  key: const Key('moneta_eos'),
                  width: widget.compatta ? 14 : 16,
                  height: widget.compatta ? 14 : 16,
                  filterQuality: FilterQuality.medium,
                )
              else
                IconaDegliEos(
                    misura: widget.compatta ? 12 : 14,
                    colore: veste0 ? palette.goldSoft : palette.gold),
              SizedBox.square(dimension: widget.compatta ? 3 : 5),
              // IL NUMERO SALE CONTANDO, ordine S voce 07, e dura quanto il volo
              // delle scintille. **Con Riduci Movimento il volo non parte e il
              // conto resta**: si toglie la scintilla, non la notizia. La cifra
              // sta in uno spazio fisso allineato a destra, cosi' il conto non
              // fa respirare la pillola; in colonna sta al centro sotto la
              // moneta.
              SizedBox(
                // **LA LARGHEZZA RISERVATA NON VALE DENTRO LA BARRA.**
                // Nelle testate teneva fermo il vicino di banco mentre il
                // numero cresceva; nella barra sottile il vicino e' uno
                // spazio elastico, e il posto per cinque cifre apriva un
                // vuoto fra la moneta e lo zero. Guardato sull'anteprima.
                width: widget.senzaVeste ? null : larghezzaCifre,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                      begin: partenza.toDouble(), end: saldo.toDouble()),
                  duration: VoloDegliEos.durata,
                  curve: Curves.easeOutCubic,
                  builder: (context, valore, _) => Text(
                    cifraDegliEos(valore.round()),
                    key: const Key('saldo_eos_numero'),
                    textAlign: widget.verticale
                        ? TextAlign.center
                        : TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: stile,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

/// La cifra col punto delle migliaia, all'italiana: 10000 diventa "10.000".
/// Una porta sola per il formato, cosi' pillola e prove leggono lo stesso.
String cifraDegliEos(int saldo) {
  final crudo = saldo.toString();
  final testo = StringBuffer();
  for (var i = 0; i < crudo.length; i++) {
    if (i > 0 && (crudo.length - i) % 3 == 0) testo.write('.');
    testo.write(crudo[i]);
  }
  return testo.toString();
}


/// L'ANNUNCIO CHE GLI EOS STANNO ARRIVANDO. Ordine S voce 07.
///
/// **Perche' non basta guardare il saldo.** Il numero in barra sale da se' quando
/// il saldo cambia, ma il saldo cambia appena il server risponde, cioe' MENTRE la
/// celebrazione a schermo pieno copre la barra: il conto avviene dietro la festa,
/// e chi chiude la festa trova un numero gia' cresciuto, senza aver visto niente
/// crescere. Il volo annuncia l'arrivo alla chiusura della festa, e il segno
/// ricomincia il conto da dove stava prima del premio.
///
/// Non e' un secondo saldo: il numero di arrivo resta quello del server, e questo
/// dice soltanto DA DOVE far partire il conto.
class ArrivoDegliEos {
  const ArrivoDegliEos._();

  static final ValueNotifier<int> _annunci = ValueNotifier<int>(0);
  static int _quanti = 0;

  /// Quanti Eos sono appena arrivati, secondo l'ultimo annuncio.
  static int get quanti => _quanti;

  static Listenable get annunci => _annunci;

  static void annuncia(int quanti) {
    if (quanti <= 0) return;
    _quanti = quanti;
    // Un seme sempre nuovo: due premi identici di seguito devono restare due
    // annunci, e un valore uguale non sveglierebbe nessuno.
    _annunci.value = _annunci.value + 1;
  }
}

/// DOVE STA IL BORSELLINO, per chi deve farci arrivare qualcosa.
///
/// **Non e' una comodita', e' l'alternativa a due numeri da tenere d'accordo.**
/// Il volo degli Eos ha bisogno di un punto d'arrivo: scriverlo dentro il volo
/// vorrebbe dire avere l'angolo del borsellino in due posti, e al primo cambio
/// della barra le scintille arriverebbero dove il borsellino non e' piu'. Qui il
/// segno DICHIARA se stesso, e chi deve arrivarci lo chiede.
///
/// Si tiene una lista e non una chiave sola perche' una rotta spinta lascia
/// montata quella sotto: vale l'ULTIMA che ha davvero una scatola a schermo.
class DoveStaIlBorsellino {
  const DoveStaIlBorsellino._();

  static final List<GlobalKey> _segni = [];

  static void registra(GlobalKey chiave) => _segni.add(chiave);

  static void dimentica(GlobalKey chiave) => _segni.remove(chiave);

  /// La scatola del borsellino a schermo, oppure nulla se non ce n'e' nessuno.
  static Rect? scatola() {
    for (final chiave in _segni.reversed) {
      final scatola = chiave.currentContext?.findRenderObject();
      if (scatola is RenderBox && scatola.hasSize && scatola.attached) {
        return scatola.localToGlobal(Offset.zero) & scatola.size;
      }
    }
    return null;
  }
}

/// IL PORTAFOGLIO: quanti Eos hai, quando tornano i gesti del giorno, e da dove
/// sono arrivati gli ultimi.
///
/// **Le tre cose sono tre perche' rispondono a tre domande diverse.** Quanto ho
/// e' il saldo. Quando ne avro' di piu' e' la ricarica. Da dove vengono e' la
/// fiducia: un numero che sale senza una ragione accanto e' indistinguibile da
/// un numero che sale per caso.
class PortafoglioDelCerchio {
  const PortafoglioDelCerchio._();

  /// COSA TORNA, E QUANDO. E' una funzione a se' perche' la prova la interroga
  /// senza montare il foglio, e perche' qui si decide di NON inventare niente.
  ///
  /// **Gli Eos non si ricaricano da soli, e dirlo e' meglio che promettere una
  /// data che non esiste.** Cio' che torna ogni giorno sono i gesti del giorno,
  /// e il giorno lo dice il server. Il bonus mensile esiste solo per chi ha un
  /// piano che lo porta, e la matrice lo promette senza un numero: qui non se ne
  /// scrive uno, perche' una cifra inventata nel portafoglio e' peggio di una
  /// cifra assente.
  static String quandoTornano(QuestionAllowance borsa, Tier tier) {
    final bonus = PlanCatalog.eosOgniMese(tier);
    final mensile = bonus == null
        ? 'Il tuo piano non porta Eos ogni mese: questi li guadagni tu, '
            'accendendo i Sigilli del cammino.'
        : 'Il tuo piano porta Eos bonus ogni mese, oltre a quelli che '
            'guadagni accendendo i Sigilli.';
    return mensile;
  }

  /// **TUTTI I LIMITI DEL PIANO, NON UNO SOLO.** Ordine BB voce 02.
  ///
  /// **Il fondatore ha aperto il borsellino e ha trovato una riga sola**: "Oggi
  /// te ne restano 3 su 3 domande ai Maestri". Parole sue: "perche' dare solo
  /// questa informazione? E le altre limitate dal piano free?"
  ///
  /// **Aveva ragione al numero: i budget sono QUATTRO**, contati nel codice
  /// che li conta, cioe' `QuestionAllowance`: domande ai Maestri,
  /// approfondimenti, confronti di sinastria e gettate di rune. Il foglio ne
  /// mostrava uno.
  ///
  /// **Si enumera dal codice dei permessi e non a memoria**: ogni riga esce da
  /// `PlanCatalog`, che e' la matrice dei piani, e da `QuestionAllowance`, che
  /// tiene il conto speso. Se domani il piano gratuito guadagnasse un quinto
  /// limite, **questa funzione resterebbe indietro e la guardia lo direbbe**:
  /// vedi `test/il_borsellino_dice_tutti_i_limiti_test.dart`.
  static List<String> tuttiILimiti(QuestionAllowance borsa, Tier tier) {
    final righe = <String>[];
    // **OGNI COSA PORTA IL SUO SINGOLARE E IL SUO PLURALE**, e il genere: e'
    // l'unico modo di scrivere quattro righe che si leggono tutte bene. Vedi
    // il commento su `residuoDiCosa`, dove la prima stesura ne prendeva uno
    // solo e produceva "nessun domanda" e "1 gettate".
    void aggiungi(
      int? limite,
      int resta, {
      required String uno,
      required String molti,
      bool femminile = false,
    }) {
      if (limite == null) {
        righe.add('${molti[0].toUpperCase()}${molti.substring(1)}: senza '
            'tetto nel tuo piano.');
        return;
      }
      final detto = QuestionAllowance.residuoDiCosa(resta, limite,
          uno: uno, molti: molti, femminile: femminile);
      righe.add('$detto. Domani torna intero.');
    }

    aggiungi(borsa.dailyLimit(tier), borsa.remaining(tier),
        uno: 'domanda ai Maestri',
        molti: 'domande ai Maestri',
        femminile: true);
    aggiungi(borsa.limiteApprofondimenti(tier),
        borsa.approfondimentiRimasti(tier),
        uno: 'approfondimento', molti: 'approfondimenti');
    aggiungi(borsa.limiteConfronti(tier), borsa.confrontiRimasti(tier),
        uno: 'confronto di sinastria', molti: 'confronti di sinastria');
    aggiungi(borsa.limiteGettate(tier), borsa.gettateRimaste(tier) ?? 0,
        uno: 'gettata di rune', molti: 'gettate di rune', femminile: true);
    return righe;
  }

  /// **L'INVITO AD ABBONARSI, e cosa porta davvero.** Ordine BB voce 02.
  ///
  /// **Una frase e un pulsante, non un cartellone**: e' quello che il
  /// fondatore ha chiesto, "un invito elegante". Chi sta guardando i propri
  /// Eos non va aggredito.
  ///
  /// **La dote si legge dal catalogo dei piani, non si scrive qui.** Il
  /// numero vive in `PlanCatalog.doteDellaSottoscrizione`, ed e' la stessa
  /// fonte che la pagina dei piani mostra: due copie dello stesso numero un
  /// giorno diventerebbero due numeri diversi.
  ///
  /// **Nessuna promessa che il prodotto non mantiene**: la dote si dichiara
  /// come valore del piano, e non si promette una data d'accredito, perche'
  /// gli abbonamenti non sono ancora acquistabili e **una data promessa e non
  /// mantenuta vale meno di un silenzio onesto**.
  static String? invitoAdAbbonarsi(Tier tier) {
    if (tier != Tier.free) return null;
    final doti = <String>[];
    for (final t in const [Tier.tier1, Tier.tier2, Tier.tier3]) {
      final dote = PlanCatalog.doteScritta(t);
      // **IL NOME DEL PIANO VIENE DALLE INTESTAZIONI DEL CATALOGO**, che
      // sono la fonte unica: scriverlo qui a mano sarebbe una seconda copia
      // che un giorno diverge da quella della pagina dei piani.
      const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
      final nome = PlanCatalog.columns[ordine.indexOf(t)];
      if (dote != null) doti.add('$nome $dote');
    }
    if (doti.isEmpty) return null;
    return 'Con un piano i tetti si allargano, e ogni piano porta una dote in '
        'Eos: ${doti.join(', ')}.';
  }

  static Future<void> apri(BuildContext context) {
    // **LA PALETTE SI PRENDE QUI, e non dentro il foglio.** Un foglio inferiore
    // vive nell'Overlay del Navigator, cioe' SOPRA la rotta che lo ha aperto: il
    // `MaestroScope` dell'arte sta dentro la rotta e da lassu' non si vede, e
    // chiederlo la' faceva cadere il montaggio con "MaestroScope non trovato".
    // E' la stessa scelta del foglio delle funzioni, `showFeatureSheet`.
    final palette = context.palette;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FoglioDelPortafoglio(palette: palette),
    );
  }
}

class _FoglioDelPortafoglio extends StatelessWidget {
  const _FoglioDelPortafoglio({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final borsa = context.watch<QuestionAllowance>();
    final tier = context.watch<EntitlementService>().tier;
    // IL REGISTRO PUO' NON ESSERCI: una prova che monta una scena da sola non
    // ha l'albero intero, e il portafoglio deve aprirsi comunque.
    final registro = context.watch<RegistroDegliEos?>();
    return Container(
      key: const Key('portafoglio'),
      padding: EdgeInsets.only(
        left: SpacingTokens.lg,
        right: SpacingTokens.lg,
        top: SpacingTokens.lg,
        bottom: SpacingTokens.xl + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpacingTokens.radiusXl),
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      // **IL FOGLIO SCORRE.** Ordine BB voce 02: con i quattro limiti e
      // l'invito il contenuto e' cresciuto, e su uno schermo corto sbordava
      // di sette pixel. **Un foglio che sborda non e' un foglio piu' lungo,
      // e' un foglio con un pezzo che nessuno vedra' mai**, e il pezzo tagliato
      // sarebbe proprio l'invito, che sta in fondo.
      //
      // `shrinkWrap` con `mainAxisSize.min` tiene il foglio alto quanto il suo
      // contenuto finche' ci sta, e lo lascia scorrere solo quando non ci sta
      // piu': chi ha uno schermo comodo non si accorge di niente.
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: palette.gold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // 1. IL SALDO, e il livello visivo prima del testo: l'alba grande, il
          //    numero grande, la parola accanto.
          Row(
            children: [
              IconaDegliEos(misura: 34, colore: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                '${borsa.saldoEos} Eos',
                key: const Key('portafoglio_saldo'),
                // IL RUOLO E NON UNA MISURA: `cerimoniale` e' il titolo di una
                // schermata cerimoniale, ed e' esattamente il peso che ha il
                // saldo quando si apre il portafoglio. Scrivere un numero qui
                // sarebbe debito tipografico, e il censimento lo conta.
                style: TypographyTokens.cerimoniale()
                    .copyWith(color: palette.goldSoft),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Il tuo saldo nel Cerchio.',
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // 2. LA PROSSIMA RICARICA.
          _Titoletto('La prossima ricarica', palette),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            PortafoglioDelCerchio.quandoTornano(borsa, tier),
            key: const Key('portafoglio_ricarica'),
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // **2 BIS. TUTTI I LIMITI DEL PIANO, e non uno solo.** Ordine BB
          // voce 02: il fondatore ha aperto il borsellino e ha trovato una
          // riga sola sulle domande ai Maestri. I budget sono quattro, e chi
          // guarda i propri Eos sta guardando proprio cosa puo' fare oggi.
          _Titoletto('Cosa puoi fare oggi', palette),
          const SizedBox(height: SpacingTokens.xs),
          for (final riga
              in PortafoglioDelCerchio.tuttiILimiti(borsa, tier)) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                riga,
                key: Key('portafoglio_limite_${PortafoglioDelCerchio.tuttiILimiti(borsa, tier).indexOf(riga)}'),
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.lg),
          // 3. DA DOVE SONO ARRIVATI GLI ULTIMI EOS.
          _Titoletto('Gli ultimi Eos', palette),
          const SizedBox(height: SpacingTokens.xs),
          if (registro == null || registro.vuoto)
            Text(
              'Ancora nessun movimento. Gli Eos arrivano quando accendi un '
              'Sigillo del cammino: non si comprano e non si ricaricano, li '
              'guadagni tu.',
              key: const Key('portafoglio_movimenti_vuoti'),
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary),
            )
          else
            for (final movimento in registro.ultimi)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                child: Row(
                  children: [
                    Text(
                      movimento.quanti > 0
                          ? '+${movimento.quanti}'
                          : '${movimento.quanti}',
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.goldSoft),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Text(
                        // **IL NOME COME SI LEGGE, non come sta nel dato.**
                        // Ordine BB voce 03, fatto del fondatore: nello stesso
                        // elenco si leggevano "LA PRIMA FIORITURA" e "Il tuo
                        // numero", "LA COSTELLAZIONE NASCENTE" e "La tua carta
                        // e' nata".
                        //
                        // **La causa sta nel corpus e NON si cura li'**: il
                        // maiuscolo integrale e' il modo in cui il corpus
                        // marca i traguardi grandi, ed e' un'informazione
                        // vera. Si normalizza alla lettura, con la stessa
                        // funzione che usa la scheda della festa: cosi' i due
                        // posti non possono divergere, e il dato resta
                        // intatto.
                        nomeInTondo(movimento.perche),
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: SpacingTokens.lg),
          // **4. L'INVITO, in fondo e in una frase.** Ordine BB voce 02, e il
          // fondatore ha chiesto che sia "elegante": una riga e un pulsante,
          // non un cartellone. Compare solo a chi e' sul piano gratuito: a chi
          // ha gia' un piano sarebbe un invito a comprare cio' che ha.
          if (PortafoglioDelCerchio.invitoAdAbbonarsi(tier) != null) ...[
            Text(
              PortafoglioDelCerchio.invitoAdAbbonarsi(tier)!,
              key: const Key('portafoglio_invito'),
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.4),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Center(
              child: FilledButton(
                key: const Key('portafoglio_vai_ai_piani'),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.surfaceElevated,
                  foregroundColor: palette.goldSoft,
                  side: BorderSide(color: palette.gold.withValues(alpha: 0.45)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(PricingScreen.route());
                },
                child: Text('Guarda i piani',
                    style: TypographyTokens.etichetta()),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
          ],
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Chiudi',
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textMuted),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

}

class _Titoletto extends StatelessWidget {
  const _Titoletto(this.testo, this.palette);

  final String testo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(
      testo,
      style: TypographyTokens.etichetta()
          .copyWith(color: palette.goldSoft, letterSpacing: 1.2),
    );
  }
}
