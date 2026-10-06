import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../core/entitlement/budget_del_giorno.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/synastry/cielo_della_sinastria.dart';
import '../../core/synastry/gemello_astrale.dart';
import '../../core/synastry/synastry_report.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../design_system/components/riga_del_residuo.dart';
import '../../design_system/components/vip_frame.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../core/maestro/maestro.dart';
import '../ricordi/azioni_del_responso.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'sinastria_vip_screen.dart';
import '../../core/synastry/perche_proprio_lui.dart';
import 'podio_del_gemello.dart';
import 'sinastria_share_card.dart';

/// LA SCHERMATA DEL GEMELLO ASTRALE. Ordine CF voce 14, rifatta dall'ordine
/// ER voce 06.
///
/// **Rilievo del fondatore, verbatim**: "la funzione di trova il tuo gemello
/// astrale non e' assolutamente appagante: serve animazione e responso simile
/// a quello della sinastria, sempre in stile goliardico."
///
/// **Cosa c'era, misurato.** Il Gemello viveva DENTRO la galleria di scelta e
/// non aveva una schermata sua: una sfilata di volti di 1600 millesimi, una
/// miniatura da 120 punti, e **una frase sola** in due varianti, che diceva il
/// nome, il punteggio e il distacco dal secondo. Il metro che il fondatore ha
/// indicato e' la Sinastria VIP: una schermata propria, la riflessione con le
/// due carte, e un responso lungo.
///
/// **LE TRE SCELTE CHE HO PRESO, e perche'.**
///
/// **1. Il responso NON si riscrive: e' quello della Sinastria.** Il Gemello
/// e' la stessa sinastria chiesta a tutti e cinquanta invece che a uno, quindi
/// il suo responso e' il responso di quella coppia. Scriverne uno nuovo
/// vorrebbe dire un secondo corpus che dice le stesse cose con altre parole, e
/// il corpus e' materia dell'Architetto e del fondatore. **Cosi' lo stile
/// goliardico e' garantito per costruzione**, e la regola sull'attualita' dei
/// personaggi vale gia' dentro quel corpus, senza doverla rifare qui.
///
/// **2. Un'animazione e' una successione di momenti**, e con un momento solo
/// non c'e' niente da guardare: prima il movimento, poi la grafica, poi il
/// nome, poi il responso.
///
/// **3. Non consuma niente, quindi non chiede niente.** Trovare il gemello e'
/// un calcolo su cinquanta cieli e non tocca nessun budget. **Il gesto che
/// consuma e' aprire la sinastria intera**, e li' la riga del residuo si
/// dichiara PRIMA, come vuole la voce CF.11.
///
/// **ORDINE ER VOCE 06, 27 settembre 2026: UNA SCHERMATA SOLA.** Parole del
/// fondatore: *"quando lo apro calcola immediatamente il gemello Vip, ma sopra
/// mostra "scegli il tuo vip" e sotto c'è l'elenco delle carte del vip che in
/// questa funzione non hanno senso. [...] non si capisce e non è intuitivo o
/// automatico che devo cliccare sulla carta per ottenere il responso"*.
///
/// **Prima** la porta apriva la galleria dei VIP (titolo, ricerca, categoria,
/// elenco), che calcolava il gemello e lo mostrava come una carta da toccare;
/// solo il tocco apriva questa schermata. **Adesso la porta apre questa
/// schermata e basta**, che vive in tre momenti:
///
/// 1. **L'attesa.** Un nastro di carte dei VIP in orizzontale, poco
///    sovrapposte, e sotto il pulsante "Cerca il tuo gemello VIP".
/// 2. **La corsa.** Al tocco il nastro parte veloce e rallenta, e si ferma
///    con le tre carte dei gemelli in fila: il secondo a sinistra, il gemello
///    al centro, il terzo a destra. Il nastro non si ferma dove capita: le
///    tre carte sono messe nel punto dove la frenata finisce, cosi' la corsa
///    e il risultato sono lo stesso gesto. Le altre carte si spengono.
/// 3. **La rivelazione.** Le tre carte salgono sul podio con le loro
///    percentuali, il cerchio si riempie, arrivano il nome e il titolo, poi il
///    responso intero con le barre: nella stessa schermata, senza un tocco in
///    piu'.
///
/// **La forma e' mia, e la dichiaro**: il fondatore ha lasciato aperta una
/// soluzione piu' elegante. Ho scelto che le tre carte che escono dalla corsa
/// siano le stesse che salgono sul podio, nello stesso ordine: il podio c'era
/// gia' (voce CF.14, "come in Formula uno") e il fondatore l'aveva chiesto,
/// quindi l'estrazione finisce DENTRO di lui invece di mettergli accanto un
/// secondo modo di dire la stessa classifica.
class SchermataDelGemello extends StatefulWidget {
  const SchermataDelGemello({
    super.key,
    required this.tuoCielo,
    required this.tuoSegno,
    this.gemello,
    this.adesso,
    this.cercaSubito = false,
    this.userName,
    this.userBirth,
  });

  /// Il gemello, se chi apre la schermata l'ha gia' calcolato. Nulla: lo
  /// calcola lei dal cielo della persona.
  final GemelloAstrale? gemello;
  final CieloDiSinastria tuoCielo;
  final Zodiac tuoSegno;

  /// L'istante, per le prove: il responso lo usa per l'attualita'.
  final DateTime? adesso;

  /// Parte senza aspettare il pulsante: per le anteprime e le prove che
  /// misurano il racconto. L'app apre sempre sull'attesa.
  final bool cercaSubito;

  /// Il nome e la nascita della persona, per la sinastria intera che si apre
  /// alla fine.
  final String? userName;
  final DateTime? userBirth;

  static Route<void> route({
    GemelloAstrale? gemello,
    required CieloDiSinastria tuoCielo,
    required Zodiac tuoSegno,
    DateTime? adesso,
    bool cercaSubito = false,
    String? userName,
    DateTime? userBirth,
  }) =>
      PassaggioDelCerchio.rotta<void>((_) => SchermataDelGemello(
            gemello: gemello,
            tuoCielo: tuoCielo,
            tuoSegno: tuoSegno,
            adesso: adesso,
            cercaSubito: cercaSubito,
            userName: userName,
            userBirth: userBirth,
          ));

  /// **IL CIELO DA CUI NASCE IL GEMELLO**, in un posto solo. La nascita a
  /// mezzogiorno, senza luogo e senza ora: e' il conto che la galleria faceva
  /// dall'ordine BO voce 10, spostato qui con la ricerca.
  static CieloDiSinastria cieloPer({Zodiac? segno, DateTime? nascita}) {
    final n = nascita ?? BirthIdentity.example.birthMoment;
    return CieloDiSinastria.perNascita(
      momentoUtc: DateTime.utc(n.year, n.month, n.day, 12),
      oraNota: false,
      latitudine: null,
      longitudineDelLuogo: null,
      segnoDichiarato: segno,
    );
  }

  /// La rotta che la porta della Sinastria apre, dal segno e dalla nascita
  /// della persona.
  static Route<void> perLaPersona({
    Zodiac? userSign,
    String? userName,
    DateTime? userBirth,
  }) {
    final cielo = cieloPer(segno: userSign, nascita: userBirth);
    return route(
      tuoCielo: cielo,
      tuoSegno: cielo.segnoSolare,
      userName: userName,
      userBirth: userBirth,
    );
  }

  /// **QUANTO CORRE IL NASTRO**, dal tocco alla frenata.
  static const Duration corsaDelNastro = Duration(milliseconds: 3400);

  /// Quanto ci mettono le altre carte a spegnersi, a nastro fermo.
  static const Duration sfumaturaDegliAltri = Duration(milliseconds: 300);

  /// **QUANDO SALE IL PODIO E SI RIEMPIE IL CERCHIO.** Richiesta del
  /// fondatore del 31 agosto 2026: la parte grafica viene prima del testo,
  /// quindi arriva prima del nome e del responso.
  static const Duration laGrafica = Duration(milliseconds: 3700);

  /// Quanto ci mettono i gradini a salire e l'arco a chiudersi.
  static const Duration corsaDellaGrafica = Duration(milliseconds: 900);

  /// Quando arriva il nome, dopo la grafica.
  static const Duration ilNome = Duration(milliseconds: 4300);

  /// Quando arriva il responso, per ultimo.
  static const Duration ilResponso = Duration(milliseconds: 5000);

  /// Quante carte passano sotto gli occhi durante la corsa.
  static const int carteDellaCorsa = 44;

  /// La carta del nastro che sta al centro prima della corsa.
  static const int cartaDiPartenza = 2;

  /// La carta del nastro dove la corsa si ferma: il gemello. Il secondo le
  /// sta a sinistra, il terzo a destra.
  static const int cartaDellArrivo = cartaDiPartenza + carteDellaCorsa;

  @override
  State<SchermataDelGemello> createState() => _SchermataDelGemelloState();
}

class _SchermataDelGemelloState extends State<SchermataDelGemello>
    with SingleTickerProviderStateMixin {
  late final AnimationController _corsa;
  late final GemelloAstrale? _gemello =
      widget.gemello ?? GemelloAstrale.per(widget.tuoCielo);
  bool _cercato = false;

  @override
  void initState() {
    super.initState();
    _corsa = AnimationController(
      vsync: this,
      duration: SchermataDelGemello.ilResponso,
    );
    if (widget.cercaSubito) _cerca();
  }

  @override
  void dispose() {
    _corsa.dispose();
    super.dispose();
  }

  void _cerca() {
    if (_cercato || _gemello == null) return;
    setState(() => _cercato = true);
    _corsa.forward(from: 0);
  }

  /// A che punto del racconto siamo, in millesimi dal tocco.
  int get _quando => _cercato
      ? (_corsa.value * SchermataDelGemello.ilResponso.inMilliseconds).round()
      : 0;

  bool _passato(Duration d) => _cercato && _quando >= d.inMilliseconds;

  /// Da zero a uno, fra [da] e [da] piu' [durata].
  double _fra(Duration da, Duration durata) {
    if (!_cercato) return 0;
    return ((_quando - da.inMilliseconds) / durata.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  bool get _nomeArrivato => _passato(SchermataDelGemello.ilNome);
  bool get _graficaArrivata => _passato(SchermataDelGemello.laGrafica);
  bool get _responsoArrivato => _passato(SchermataDelGemello.ilResponso);

  /// Da zero a uno: quanto il podio e' salito e il cerchio si e' riempito.
  double get _quantoDellaGrafica => _fra(
      SchermataDelGemello.laGrafica, SchermataDelGemello.corsaDellaGrafica);

  /// **LA FRENATA.** Veloce all'inizio, piano alla fine: la curva quartica
  /// parte a quattro volte la velocita' media e arriva a zero, ed e' la
  /// sensazione di una ruota che gira e si ferma.
  double get _quantoDellaCorsa => Curves.easeOutQuart
      .transform(_fra(Duration.zero, SchermataDelGemello.corsaDelNastro));

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.medora;
    // **IL GEMELLO SUL CIELO, NON SUL NERO.** Il fondatore, guardando la
    // build 2285 (ordine ER): "La schermata del nastro delle carte ha sfondo
    // nero, perche'? Dovrebbe essere cosmico". Il fondo nero era nato con la
    // schermata, ordine CF voce 14, e la voce ER.06 lo aveva ereditato; la
    // porta della sinastria e i responsi stanno sul cielo.
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        // **"Il tuo gemello" e non "Il tuo gemello astrale"**: guardata
        // l'anteprima, il titolo lungo finiva troncato con tre puntini a
        // 360 punti. Il resto lo dice la schermata intera.
        title:
            Text('Il tuo gemello', style: TypographyTokens.titoloDiSchermata()),
      ),
      body: CosmosBackground(
        key: const Key('gemello_cielo'),
        seed: 29,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _corsa,
            builder: (context, _) => ListView(
              key: const Key('gemello_schermata'),
              padding: const EdgeInsets.all(SpacingTokens.lg),
              children: [
                _ilPalco(palette),
                if (!_cercato) ...[
                  const SizedBox(height: SpacingTokens.lg),
                  Center(
                    child: FilledButton.icon(
                      key: const Key('gemello_cerca'),
                      onPressed: _gemello == null ? null : _cerca,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.gold,
                        foregroundColor: palette.deepest,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusLg),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: Text('Cerca il tuo gemello VIP',
                          style: TypographyTokens.titoloScheda()),
                    ),
                  ),
                ],
                ..._ilRacconto(palette),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **IL PALCO**: prima il nastro, poi il podio, nello stesso posto e alla
  /// stessa altezza, cosi' che le tre carte che la corsa lascia in fila siano
  /// le stesse che salgono sui gradini, senza che la pagina salti.
  Widget _ilPalco(MaestroPalette palette) {
    final gemello = _gemello;
    final podio = gemello == null || !_graficaArrivata
        ? 0.0
        : _fra(SchermataDelGemello.laGrafica,
            SchermataDelGemello.sfumaturaDegliAltri);
    return SizedBox(
      key: const Key('gemello_palco'),
      // Il palco cresce quanto cresce il nome sul podio: i 262 punti erano
      // pensati per un nome alto 34, e col nome in due righe vere del
      // carattere (build 2285, ordine ER) il podio non ci stava.
      height: _NastroDeiVolti.altezzaDelPalco -
          _NastroDeiVolti.nomeDelProgetto +
          NomeSulPodio.altezza(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (podio < 1)
            Positioned(
              left: -SpacingTokens.lg,
              right: -SpacingTokens.lg,
              top: _NastroDeiVolti.cimaDelNastro,
              height: _NastroDeiVolti.altezza,
              child: Opacity(
                opacity: 1 - podio,
                child: _NastroDeiVolti(
                  gemello: gemello,
                  palette: palette,
                  corsa: _quantoDellaCorsa,
                  sfumaGliAltri: _fra(SchermataDelGemello.corsaDelNastro,
                      SchermataDelGemello.sfumaturaDegliAltri),
                ),
              ),
            ),
          if (gemello != null && podio > 0)
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: podio,
                child: PodioDelGemello(
                  gemello: gemello,
                  palette: palette,
                  avanzamento: _quantoDellaGrafica,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _ilRacconto(MaestroPalette palette) {
    final gemello = _gemello;
    if (gemello == null || !_graficaArrivata) return const [];
    final vip = gemello.vip;
    // **IL RESPONSO NON SI RICOSTRUISCE: il rapporto lo porta gia'.**
    // `SynastryReport` chiama lui stesso il corpus e tiene il titolo, il
    // corpo e la nota. Chiamare il corpus una seconda volta da qui
    // vorrebbe dire due strade verso lo stesso testo, e il giorno che una
    // cambia le due direbbero cose diverse per la stessa coppia.
    final rapporto = SynastryReport.perCieli(
      tuo: widget.tuoCielo,
      vip: vip,
      quando: widget.adesso,
    );
    final parole = PercheProprioLui.perIlGemello(
      gemello,
      widget.tuoCielo,
      rapporto,
    );
    return [
      // **IL GEMELLO ENTRA NEL DIARIO DA SE'. Ordine FE voce 22.6**, quando
      // il nome e' arrivato, cioe' quando la persona ha il responso intero.
      if (_nomeArrivato)
        IlResponsoNelDiario(
          maestro: Maestro.medora,
          responso: ResponsoDaCustodire(
            arte: 'gemello',
            titolo: 'Il tuo gemello del cielo: ${vip.name}',
            testo: '${rapporto.overall}%. ${rapporto.reading}',
            dati: {'vip': vip.name, 'punteggio': '${rapporto.overall}'},
          ),
        ),
      // **LA GRAFICA PRIMA DEL TESTO, ed e' la regola del progetto.**
      // Richiesta del fondatore del 31 agosto 2026: "la parte grafica o
      // infografica e' prioritaria". Il cerchio dice il punteggio senza farlo
      // leggere, e il podio qui sopra dice in un istante se il gemello e'
      // netto o se sono tre quasi pari.
      const SizedBox(height: SpacingTokens.md),
      Center(
        child: CerchioDellaPercentuale(
          percento: rapporto.overall,
          palette: palette,
          avanzamento: _quantoDellaGrafica,
        ),
      ),
      // **IL NOME ARRIVA DOPO LA GRAFICA**: prima si vede chi e', poi si
      // legge chi e'.
      if (_nomeArrivato) ...[
        const SizedBox(height: SpacingTokens.md),
        Text(vip.name,
            key: const Key('gemello_nome'),
            textAlign: TextAlign.center,
            style: TypographyTokens.cerimoniale()
                .copyWith(color: palette.goldSoft)),
        const SizedBox(height: SpacingTokens.xs),
        // **IL TITOLO CHE SI CONDIVIDE.** Richiesta del fondatore del 31
        // agosto 2026: "un titolo accattivante e anche un po' meme, che
        // spinga alla condivisione, qualcosa di memorabile". Nasce dai due
        // elementi e dal punteggio, quindi due persone leggono due titoli
        // diversi, ed e' quello che rende una cosa condivisibile.
        // **Testo provvisorio**: le parole le approva lui.
        Text(parole.titolo,
            key: const Key('gemello_titolo_meme'),
            textAlign: TextAlign.center,
            style: TypographyTokens.cerimoniale()
                .copyWith(color: palette.goldSoft)),
        const SizedBox(height: SpacingTokens.xs),
        // **DAL PARAGRAFO E NON DA UN `Text` NUDO.** Nel ruolo lettura la
        // porta e' una sola, e una prova la sorveglia: da un `Text` diretto
        // torna il muro di testo.
        ParagrafiDiLettura(
            key: const Key('gemello_annuncio'),
            testo: gemello.annuncio,
            textAlign: TextAlign.center,
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textSecondary)),
      ],
      // **IL RESPONSO ARRIVA PER ULTIMO, ed e' quello della Sinastria**: le
      // stesse parole, lo stesso corpus, lo stesso stile goliardico. Un
      // secondo corpus direbbe le stesse cose con altre parole, e le parole
      // sono del fondatore.
      if (_responsoArrivato) ...[
        const SizedBox(height: SpacingTokens.md),
        DepthCard(
          raised: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rapporto.titoloDellaBolla,
                  key: const Key('gemello_titolo_responso'),
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              // **PERCHE' PROPRIO LUI: due risposte e non una.** Richiesta
              // del fondatore del 31 agosto 2026: "vorra' una risposta
              // tecnica che riguarda le stelle, ma soprattutto una risposta
              // evocativa legata alla personalita'". La tecnica dice cos'e'
              // successo nel cielo, l'evocativa cosa vuol dire: la prima da
              // sola sembra un referto, la seconda da sola un oroscopo da
              // rivista.
              Text('Perché proprio ${vip.luiOLei}',
                  key: const Key('gemello_perche_titolo'),
                  style: TypographyTokens.titoloDiRiga()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.xs),
              ParagrafiDiLettura(
                  key: const Key('gemello_perche_tecnica'),
                  testo: parole.tecnica,
                  stile: TypographyTokens.lettura()
                      .copyWith(color: ColorTokens.textPrimary)),
              const SizedBox(height: SpacingTokens.sm),
              ParagrafiDiLettura(
                  key: const Key('gemello_perche_evocativa'),
                  testo: parole.evocativa,
                  stile: TypographyTokens.lettura()
                      .copyWith(color: ColorTokens.textPrimary)),
              const SizedBox(height: SpacingTokens.md),
              ParagrafiDiLettura(
                key: const Key('gemello_responso'),
                testo: rapporto.reading,
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary),
              ),
              if (rapporto.nota.isNotEmpty) ...[
                const SizedBox(height: SpacingTokens.sm),
                Text(rapporto.nota,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary)),
              ],
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        // **LE BARRE DELLA PERSONALITA', le stesse della Sinastria.**
        // Richiesta del fondatore del 31 agosto 2026: "inserirei delle barre
        // di personalita' (come nel responso di una sinastria vip) per
        // rafforzare il gemellaggio col vip". Sono le stesse per
        // costruzione: `report.bars` e' l'unico posto dove quelle dimensioni
        // vivono, e una seconda copia direbbe numeri diversi per la stessa
        // coppia.
        DepthCard(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            key: const Key('gemello_barre'),
            children: [
              for (final bar in rapporto.bars) ...[
                SynastryBarRow(
                  bar: bar,
                  palette: palette,
                  progress: 1,
                  meetingReport: rapporto,
                ),
                if (bar != rapporto.bars.last)
                  const SizedBox(height: SpacingTokens.sm),
              ],
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        // **IL RESIDUO PRIMA DEL GESTO, voce CF.11.** Trovare il gemello non
        // consuma niente; aprire la sinastria intera si.
        const RigaDelResiduo(
          budget: BudgetDelGiorno.sinastrie,
          allineamento: MainAxisAlignment.center,
        ),
        Center(
          child: FilledButton(
            key: const Key('gemello_apri_sinastria'),
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.deepest,
            ),
            // Il segno, il nome e la nascita della persona vanno con lei:
            // senza, il polo del responso scriveva "Tu" e prendeva il segno
            // dalla persona d'esempio.
            onPressed: () =>
                Navigator.of(context).push(SinastriaVipScreen.route(
              vip: vip,
              userSign: widget.tuoSegno,
              userName: widget.userName,
              userBirth: widget.userBirth,
            )),
            child: Text('Guarda il vostro cielo',
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.deepest)),
          ),
        ),
      ],
    ];
  }
}

/// **IL NASTRO DEI VOLTI.** Le carte dei VIP in orizzontale, poco
/// sovrapposte, la piu' vicina al centro davanti alle altre e un poco piu'
/// grande: e' la prima cosa che si vede, ed e' la stessa che corre.
///
/// Il nastro e' infinito e si legge a indici: la carta numero `i` e' il VIP
/// `i` del catalogo, tranne le tre carte dove la corsa si ferma, che sono i
/// tre gemelli. **Le tre carte sono messe dove la frenata finisce**, non
/// cercate dove capita, e intorno a loro il nastro non ripete i loro volti.
class _NastroDeiVolti extends StatelessWidget {
  const _NastroDeiVolti({
    required this.gemello,
    required this.palette,
    required this.corsa,
    required this.sfumaGliAltri,
  });

  final GemelloAstrale? gemello;
  final MaestroPalette palette;

  /// Da zero a uno: quanta strada il nastro ha fatto.
  final double corsa;

  /// Da zero a uno: quanto le carte che non sono gemelli si sono spente.
  final double sfumaGliAltri;

  /// La carta in mezzo, a riposo.
  static const double larghezza = 84;
  static const double altezza = larghezza / VipFrame.aspect;

  /// **POCO SOVRAPPOSTE**: ogni carta copre un quarto scarso della vicina.
  static const double passo = 64;

  /// Il palco e' alto quanto il podio cresciuto tutto, e il nastro sta dove
  /// le carte del podio stanno prima di salire: cosi' la sostituzione non si
  /// vede come un salto.
  static const double altezzaDelPalco = 262;

  /// L'altezza del nome sul podio per cui i 262 punti erano stati fatti.
  static const double nomeDelProgetto = 34;
  static const double cimaDelNastro = 79;

  static const int partenza = SchermataDelGemello.cartaDiPartenza;
  static const int arrivo = SchermataDelGemello.cartaDellArrivo;

  Vip _allIndice(int i) {
    const vips = VipCatalog.vips;
    final g = gemello;
    if (g != null) {
      if (i == arrivo - 1) return g.secondo;
      if (i == arrivo) return g.vip;
      if (i == arrivo + 1) return g.terzo;
    }
    var v = vips[i % vips.length];
    if (g != null && (i - arrivo).abs() <= 5) {
      // Intorno alle tre carte il nastro non ripete i loro volti.
      final tre = {g.vip.name, g.secondo.name, g.terzo.name};
      var salto = vips.length ~/ 2;
      while (tre.contains(v.name)) {
        v = vips[(i + salto) % vips.length];
        salto++;
      }
    }
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, vincoli) {
      final largo = vincoli.maxWidth;
      const strada = (arrivo - partenza) * passo;
      final spostamento = partenza * passo + strada * corsa;
      final primo = ((spostamento - largo / 2) / passo).floor() - 1;
      final ultimo = ((spostamento + largo / 2) / passo).ceil() + 1;
      final carte = <({int i, double dx})>[
        for (var i = primo; i <= ultimo; i++)
          (i: i, dx: i * passo - spostamento),
      ]
        // Le lontane sotto, la piu' vicina al centro sopra.
        ..sort((a, b) => b.dx.abs().compareTo(a.dx.abs()));
      return ClipRect(
        child: Stack(
          key: const Key('gemello_nastro'),
          clipBehavior: Clip.none,
          children: [
            for (final c in carte) _unaCarta(context, c.i, c.dx, largo),
          ],
        ),
      );
    });
  }

  Widget _unaCarta(BuildContext context, int i, double dx, double largo) {
    final vip = _allIndice(i);
    final vicinanza = (1 - (dx.abs() / (passo * 2))).clamp(0.0, 1.0);
    final scala = 0.84 + 0.16 * vicinanza;
    final unGemello = gemello != null && (i - arrivo).abs() <= 1;
    final luce = unGemello ? 1.0 : 1 - sfumaGliAltri;
    return Positioned(
      key: Key('gemello_nastro_carta_$i'),
      left: largo / 2 + dx - larghezza / 2,
      top: 0,
      width: larghezza,
      // Il rapporto dell'artwork, ordine CF voce 12.
      height: larghezza / VipFrame.aspect,
      child: Opacity(
        opacity: (0.55 + 0.45 * vicinanza) * luce,
        child: Transform.scale(
          scale: scala,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
              border: Border.all(
                color: palette.gold.withValues(alpha: 0.3 + 0.5 * vicinanza),
                width: vicinanza > 0.9 ? 1.6 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: Offset(math.min(6, dx / 40), 4),
                ),
              ],
            ),
            // **I CARTIGLI SI SCRIVONO A RUNTIME**: gli artwork dei VIP li
            // hanno vuoti di proposito, e `VipFramedPortrait` e' il
            // componente che ci posa il nome e la data (ordine CF voce 14).
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
              child: VipFramedPortrait(
                palette: palette,
                name: vip.name,
                date: vip.note,
                sign: vip.sign.symbol,
                vipAsset: vip.hasImage ? vip.thumbPath : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
