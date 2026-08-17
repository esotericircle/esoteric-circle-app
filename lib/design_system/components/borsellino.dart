import 'dart:ui' as ui;

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
  const SegnoDelBorsellino({super.key, this.veste = VesteDellaPillola.velo});

  /// La veste della pillola, fra le due in attesa degli occhi di Mauro.
  final VesteDellaPillola veste;

  @override
  State<SegnoDelBorsellino> createState() => _SegnoDelBorsellinoState();
}

class _SegnoDelBorsellinoState extends State<SegnoDelBorsellino> {
  /// LA CHIAVE CON CUI IL VOLO SA DOVE ARRIVARE, ordine S voce 07.
  final GlobalKey _dove = GlobalKey();

  /// L'ULTIMO NUMERO GIA' MOSTRATO, da cui il conto parte quando cambia.
  int? _mostrato;

  @override
  void initState() {
    super.initState();
    DoveStaIlBorsellino.registra(_dove);
    ArrivoDegliEos.annunci.addListener(_ricominciaIlConto);
  }

  @override
  void dispose() {
    ArrivoDegliEos.annunci.removeListener(_ricominciaIlConto);
    DoveStaIlBorsellino.dimentica(_dove);
    super.dispose();
  }

  /// GLI EOS STANNO ARRIVANDO: il conto riparte da prima del premio.
  void _ricominciaIlConto() {
    if (!mounted) return;
    final borsa = context.read<QuestionAllowance?>();
    if (borsa == null) return;
    setState(() => _mostrato = borsa.saldoEos - ArrivoDegliEos.quanti);
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
    final stile = TypographyTokens.etichetta().copyWith(
      color: widget.veste == VesteDellaPillola.oro
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
    final veste0 = widget.veste == VesteDellaPillola.velo;
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
        onTap: () => PortafoglioDelCerchio.apri(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            color: palette.deepest.withValues(alpha: veste0 ? 0.38 : 0.55),
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
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: 5,
          ),
          child: Row(
            key: _dove,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconaDegliEos(
                  misura: 14,
                  colore:
                      veste0 ? palette.goldSoft : palette.gold),
              const SizedBox(width: 5),
              // IL NUMERO SALE CONTANDO, ordine S voce 07, e dura quanto il volo
              // delle scintille. **Con Riduci Movimento il volo non parte e il
              // conto resta**: si toglie la scintilla, non la notizia. La cifra
              // sta in uno spazio fisso allineato a destra, cosi' il conto non
              // fa respirare la pillola.
              SizedBox(
                width: larghezzaCifre,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                      begin: partenza.toDouble(), end: saldo.toDouble()),
                  duration: VoloDegliEos.durata,
                  curve: Curves.easeOutCubic,
                  builder: (context, valore, _) => Text(
                    cifraDegliEos(valore.round()),
                    key: const Key('saldo_eos_numero'),
                    textAlign: TextAlign.right,
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
    final limite = borsa.dailyLimit(tier);
    final gesti = limite == null
        ? 'Le domande ai Maestri non hanno un tetto giornaliero nel tuo piano.'
        : '${QuestionAllowance.comeSiDiceIlResiduo(borsa.remaining(tier), limite)} '
            'domande ai Maestri. Domani tornano intere.';
    final bonus = PlanCatalog.eosOgniMese(tier);
    final mensile = bonus == null
        ? 'Il tuo piano non porta Eos ogni mese: questi li guadagni tu, '
            'accendendo i Sigilli del cammino.'
        : 'Il tuo piano porta Eos bonus ogni mese, oltre a quelli che '
            'guadagni accendendo i Sigilli.';
    return '$gesti $mensile';
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
                        movimento.perche,
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: SpacingTokens.lg),
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
