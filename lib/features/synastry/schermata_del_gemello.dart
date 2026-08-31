import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../core/entitlement/budget_del_giorno.dart';
import '../../core/synastry/cielo_della_sinastria.dart';
import '../../core/synastry/gemello_astrale.dart';
import '../../core/synastry/synastry_report.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../design_system/components/riga_del_residuo.dart';
import '../../design_system/components/vip_frame.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'rivelazione_del_gemello.dart';
import 'sinastria_vip_screen.dart';
import '../../core/synastry/perche_proprio_lui.dart';
import 'podio_del_gemello.dart';
import 'sinastria_share_card.dart';

/// LA SCHERMATA DEL GEMELLO ASTRALE. Ordine CF voce 14.
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
/// **2. La sfilata dura il doppio e non e' piu' una sola.** Milleseicento
/// millesimi passano prima che l'occhio si accorga che sta succedendo
/// qualcosa. Qui la sfilata sta in una cornice grande, alla forma vera
/// dell'artwork, e ci si aggiungono due momenti che prima non c'erano: il
/// nome che arriva DOPO il volto, e il responso che arriva dopo il nome.
/// **Un'animazione e' una successione di momenti**, e con un momento solo non
/// c'e' niente da guardare.
///
/// **3. Non consuma niente, quindi non chiede niente.** Trovare il gemello e'
/// un calcolo su cinquanta cieli e non tocca nessun budget. **Il gesto che
/// consuma e' aprire la sinastria intera**, e li' la riga del residuo si
/// dichiara PRIMA, come vuole la voce CF.11.
class SchermataDelGemello extends StatefulWidget {
  const SchermataDelGemello({
    super.key,
    required this.gemello,
    required this.tuoCielo,
    required this.tuoSegno,
    this.adesso,
  });

  final GemelloAstrale gemello;
  final CieloDiSinastria tuoCielo;
  final Zodiac tuoSegno;

  /// L'istante, per le prove: il responso lo usa per l'attualita'.
  final DateTime? adesso;

  static Route<void> route({
    required GemelloAstrale gemello,
    required CieloDiSinastria tuoCielo,
    required Zodiac tuoSegno,
    DateTime? adesso,
  }) =>
      PassaggioDelCerchio.rotta<void>((_) => SchermataDelGemello(
            gemello: gemello,
            tuoCielo: tuoCielo,
            tuoSegno: tuoSegno,
            adesso: adesso,
          ));

  /// Quanto dura la sfilata dei volti, ordine CF voce 14: il doppio di prima.
  static const Duration sfilata = Duration(milliseconds: 3200);

  /// Quando arriva il nome, dopo il volto.
  static const Duration ilNome = Duration(milliseconds: 3800);

  /// **QUANDO SALE IL PODIO E SI RIEMPIE IL CERCHIO.** Richiesta del
  /// fondatore del 31 agosto 2026: la parte grafica viene prima del testo,
  /// quindi arriva prima del responso e non dopo.
  static const Duration laGrafica = Duration(milliseconds: 4400);

  /// Quanto ci mettono i gradini a salire e l'arco a chiudersi.
  static const Duration corsaDellaGrafica = Duration(milliseconds: 900);

  /// Quando arriva il responso, per ultimo.
  static const Duration ilResponso = Duration(milliseconds: 5600);

  @override
  State<SchermataDelGemello> createState() => _SchermataDelGemelloState();
}

class _SchermataDelGemelloState extends State<SchermataDelGemello>
    with SingleTickerProviderStateMixin {
  late final AnimationController _corsa;

  @override
  void initState() {
    super.initState();
    _corsa = AnimationController(
      vsync: this,
      duration: SchermataDelGemello.ilResponso,
    )..forward();
  }

  @override
  void dispose() {
    _corsa.dispose();
    super.dispose();
  }

  /// A che punto del racconto siamo, in millesimi.
  int get _quando =>
      (_corsa.value * SchermataDelGemello.ilResponso.inMilliseconds).round();

  bool get _voltoFermo => _quando >= SchermataDelGemello.sfilata.inMilliseconds;
  bool get _nomeArrivato => _quando >= SchermataDelGemello.ilNome.inMilliseconds;
  bool get _graficaArrivata =>
      _quando >= SchermataDelGemello.laGrafica.inMilliseconds;
  bool get _responsoArrivato =>
      _quando >= SchermataDelGemello.ilResponso.inMilliseconds;

  /// Da zero a uno: quanto il podio e' salito e il cerchio si e' riempito.
  double get _quantoDellaGrafica {
    if (!_graficaArrivata) return 0;
    final passati =
        _quando - SchermataDelGemello.laGrafica.inMilliseconds;
    return (passati /
            SchermataDelGemello.corsaDellaGrafica.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.medora;
    final vip = widget.gemello.vip;
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
      widget.gemello,
      widget.tuoCielo,
      rapporto,
    );
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        // **"Il tuo gemello" e non "Il tuo gemello astrale"**: guardata
        // l'anteprima, il titolo lungo finiva troncato con tre puntini a
        // 360 punti. Il resto lo dice la schermata intera.
        title: Text('Il tuo gemello',
            style: TypographyTokens.titoloDiSchermata()),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _corsa,
          builder: (context, _) {
            final volto = _voltoFermo
                ? vip
                : RivelazioneDelGemello.voltoDellaSfilata(
                    widget.gemello,
                    _quando / SchermataDelGemello.sfilata.inMilliseconds,
                  );
            return ListView(
              key: const Key('gemello_schermata'),
              padding: const EdgeInsets.all(SpacingTokens.lg),
              children: [
                Center(
                  child: SizedBox(
                    key: const Key('gemello_cornice'),
                    width: 220,
                    // Il rapporto dell'artwork, ordine CF voce 12.
                    height: 220 / VipFrame.aspect,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(SpacingTokens.radiusLg),
                        border: Border.all(
                          color: palette.gold
                              .withValues(alpha: _voltoFermo ? 0.95 : 0.3),
                          width: _voltoFermo ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(SpacingTokens.radiusLg),
                        // **I CARTIGLI SI SCRIVONO A RUNTIME, e montare
                        // l'arte nuda li lascia bianchi.** Rilievo del
                        // fondatore del 31 agosto 2026, guardando questa
                        // anteprima: "perche' i cartigli delle carte sono
                        // vuoti?"
                        //
                        // **E' lo stesso difetto che l'ordine CC voce 06i
                        // aveva gia' curato sulla carta ingrandita**, e l'ho
                        // rifatto qui: gli artwork dei VIP hanno i cartigli
                        // VUOTI di proposito, perche' il nome e la data si
                        // posano in Flutter e cosi' un set solo di immagini
                        // vale per tutte le lingue. `Image.asset` nudo e'
                        // l'arte senza chi la posa: `VipFramedPortrait` e' il
                        // componente che quei due testi li scrive, ed e' lo
                        // stesso che la Sinastria e la card da condividere
                        // usano gia'.
                        child: VipFramedPortrait(
                          palette: palette,
                          name: volto.name,
                          date: volto.note,
                          sign: volto.sign.symbol,
                          vipAsset: volto.hasImage
                              ? (_voltoFermo
                                  ? volto.fullPath
                                  : volto.thumbPath)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                // **IL NOME ARRIVA DOPO IL VOLTO**, ed e' il secondo momento:
                // prima si vede chi e', poi si legge chi e'.
                if (_nomeArrivato)
                  Text(volto.name,
                      key: const Key('gemello_nome'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.cerimoniale()
                          .copyWith(color: palette.goldSoft)),
                if (_nomeArrivato) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  // **IL TITOLO CHE SI CONDIVIDE.** Richiesta del fondatore
                  // del 31 agosto 2026: "un titolo accattivante e anche un
                  // po' meme, che spinga alla condivisione, qualcosa di
                  // memorabile". Nasce dai due elementi e dal punteggio,
                  // quindi due persone leggono due titoli diversi, ed e'
                  // quello che rende una cosa condivisibile.
                  // **Testo provvisorio**: le parole le approva lui.
                  Text(parole.titolo,
                      key: const Key('gemello_titolo_meme'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.cerimoniale()
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.xs),
                  // **DAL PARAGRAFO E NON DA UN `Text` NUDO.** Nel ruolo
                  // lettura la porta e' una sola, e una prova la sorveglia:
                  // da un `Text` diretto torna il muro di testo.
                  ParagrafiDiLettura(
                      key: const Key('gemello_annuncio'),
                      testo: widget.gemello.annuncio,
                      textAlign: TextAlign.center,
                      stile: TypographyTokens.lettura()
                          .copyWith(color: ColorTokens.textSecondary)),
                ],
                // **LA GRAFICA PRIMA DEL TESTO, ed e' la regola del
                // progetto.** Richiesta del fondatore del 31 agosto 2026: "la
                // parte grafica o infografica e' prioritaria". Il cerchio dice
                // il punteggio senza farlo leggere, e il podio dice in un
                // istante se il gemello e' netto o se sono tre quasi pari:
                // "stacca il secondo di dieci punti" e' un fatto, tre gradini
                // di altezza diversa lo fanno VEDERE.
                if (_graficaArrivata) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Center(
                    child: CerchioDellaPercentuale(
                      percento: rapporto.overall,
                      palette: palette,
                      avanzamento: _quantoDellaGrafica,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text('IL PODIO DEI TRE PIÙ VICINI',
                      textAlign: TextAlign.center,
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.6)),
                  const SizedBox(height: SpacingTokens.sm),
                  PodioDelGemello(
                    gemello: widget.gemello,
                    palette: palette,
                    avanzamento: _quantoDellaGrafica,
                  ),
                ],
                // **IL RESPONSO ARRIVA PER ULTIMO, ed e' quello della
                // Sinastria**: le stesse parole, lo stesso corpus, lo stesso
                // stile goliardico. Un secondo corpus direbbe le stesse cose
                // con altre parole, e le parole sono del fondatore.
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
                        // **PERCHE' PROPRIO LUI: due risposte e non una.**
                        // Richiesta del fondatore del 31 agosto 2026: "vorra'
                        // una risposta tecnica che riguarda le stelle, ma
                        // soprattutto una risposta evocativa legata alla
                        // personalita'". La tecnica dice cos'e' successo nel
                        // cielo, l'evocativa cosa vuol dire: la prima da sola
                        // sembra un referto, la seconda da sola un oroscopo
                        // da rivista.
                        Text('Perché proprio lui',
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
                              style: TypographyTokens.didascalia().copyWith(
                                  color: ColorTokens.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // **LE BARRE DELLA PERSONALITA', le stesse della
                  // Sinastria.** Richiesta del fondatore del 31 agosto 2026:
                  // "inserirei delle barre di personalita' (come nel responso
                  // di una sinastria vip) per rafforzare il gemellaggio col
                  // vip". Sono le stesse per costruzione: `report.bars` e'
                  // l'unico posto dove quelle dimensioni vivono, e una
                  // seconda copia direbbe numeri diversi per la stessa
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
                  // **IL RESIDUO PRIMA DEL GESTO, voce CF.11.** Trovare il
                  // gemello non consuma niente; aprire la sinastria intera si.
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
                      onPressed: () => Navigator.of(context)
                          .push(SinastriaVipScreen.route(vip: vip)),
                      child: Text('Guarda il vostro cielo',
                          style: TypographyTokens.etichetta()
                              .copyWith(color: palette.deepest)),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
