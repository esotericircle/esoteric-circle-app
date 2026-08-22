import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/aspetti_di_oggi.dart';
import '../../core/astro/lingua_degli_eventi.dart';
import '../../core/astro/natal_chart.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/astro/prossimi_eventi.dart';
import '../../core/astro/zodiac.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../account/dati_di_nascita_screen.dart';
import '../shell/vie_del_cerchio.dart';

/// IL CALENDARIO DEGLI EVENTI. Ordine AN voce 03.
///
/// Si apre dal centro della barra. Elenca in ordine cronologico cio' che il
/// cielo fara' nei prossimi mesi, distinguendo a colpo d'occhio gli eventi
/// DI TUTTI (fasi, solstizi, equinozi, retrogradi e ritorni diretti) dagli
/// appuntamenti TUOI (la Luna nel tuo segno, il ritorno solare, i transiti
/// sulla tua carta).
///
/// **Le date vengono dal motore unico** della voce AN.01, che le calcola in
/// locale dalle stesse fonti del cielo di oggi: nessuna rete, nessuna
/// seconda porta dell'astronomia, e un evento senza data calcolata non
/// compare affatto.
///
/// **Senza identita' non c'e' un vicolo cieco**: restano gli eventi di
/// tutti, che valgono per chiunque, piu' un invito con un pulsante vero a
/// completare il profilo, perche' i tuoi appuntamenti li puo' calcolare solo
/// chi sa quando sei nato.
class CalendarioDegliEventiScreen extends StatelessWidget {
  const CalendarioDegliEventiScreen({super.key, this.adesso});

  /// L'istante da cui guardare avanti, iniettabile per le prove.
  final DateTime? adesso;

  /// L'ORIZZONTE DEL CALENDARIO, dichiarato: tre mesi di cielo comune, e i
  /// grandi appuntamenti personali anche oltre, perche' il ritorno solare e
  /// la Luna piena nel tuo segno capitano una volta l'anno e sparire da un
  /// calendario che guarda novanta giorni li renderebbe invisibili.
  static const int orizzonteComune = 90;

  static const Set<String> _grandiPersonali = {
    'ritorno_solare',
    'luna_piena_nel_tuo_segno',
    'luna_nuova_nel_tuo_segno',
  };

  static Route<void> route({DateTime? adesso}) => MaterialPageRoute<void>(
        settings: const RouteSettings(arguments: PortaDelCerchio.calendario),
        builder: (_) => MaestroScope(
          maestro: Maestro.medora,
          child: CalendarioDegliEventiScreen(adesso: adesso),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final quando = adesso ?? DateTime.now();
    Zodiac? segno;
    NatalChart? carta;
    try {
      // **SI CHIEDE IL TIPO VERO, non quello nullabile.** Provider cerca
      // il tipo esatto: `watch<ZodiacController?>()` e' un tipo DIVERSO da
      // quello registrato e non lo trova mai, quindi il segno arrivava
      // sempre nullo e gli appuntamenti personali non comparivano. Il
      // ripiego per chi non ha il provider resta il catch qui sotto.
      segno = context.watch<ZodiacController>().sunSign;
    } catch (errore) {
      segno = null;
    }
    try {
      carta = context.watch<NatalChartController>().chart;
    } catch (errore) {
      carta = null;
    }

    // **QUANTO SI SA DI QUESTA PERSONA, chiesto alla porta unica.** La prima
    // stesura decideva l'invito con una condizione scritta qui, e sarebbe
    // stata la seconda verita' sui dati di nascita: il giorno che il Cerchio
    // cambia idea su cosa serve per un appuntamento personale, questa
    // schermata resterebbe indietro da sola. Il livello lo dice
    // `AspettiDiOggi`, che e' la porta, e qui si legge soltanto.
    final livello = AspettiDiOggi.livello(carta);
    final nullaDiTuo =
        livello == LivelloPersonalizzazione.soloSegno && segno == null;

    final tutti =
        ProssimiEventi.da(adesso: quando, carta: carta, segno: segno);
    final elenco = [
      for (final evento in tutti)
        if (evento.fraQuantiGiorni <= orizzonteComune ||
            _grandiPersonali.contains(evento.evento))
          evento,
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: Text('Il cielo che viene',
            style: TypographyTokens.display(size: 20)),
      ),
      body: CosmosBackground(
        seed: 23,
        child: SafeArea(
          child: ListView(
            key: const Key('calendario_degli_eventi'),
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                SpacingTokens.md, SpacingTokens.lg, SpacingTokens.xxxl),
            children: [
              Text(
                'Le date che il cielo ha già deciso, calcolate sul tuo '
                'fuso orario.',
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.lg),
              if (nullaDiTuo)
                _InvitoACompletare(palette: palette),
              for (final evento in elenco) ...[
                _VoceDelCalendario(evento: evento),
                const SizedBox(height: SpacingTokens.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Una voce del calendario: il colpo d'occhio prima del testo, come chiede
/// l'anatomia del responso.
class _VoceDelCalendario extends StatelessWidget {
  const _VoceDelCalendario({required this.evento});

  final EventoInArrivo evento;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // GLI APPUNTAMENTI TUOI SI RICONOSCONO A COLPO D'OCCHIO: bordo d'oro e
    // il segno del Cerchio accanto, contro il velo neutro degli eventi che
    // valgono per tutti.
    final tuo = evento.personale;
    return DepthCard(
      key: Key('evento_${evento.evento}'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            tuo ? Icons.auto_awesome : Icons.public_rounded,
            color: tuo ? palette.gold : ColorTokens.textSecondary,
            size: 22,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LinguaDegliEventi.nomeDi(evento.evento),
                        style: TypographyTokens.titoloScheda().copyWith(
                            color: tuo
                                ? palette.goldSoft
                                : ColorTokens.textPrimary),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.xs),
                    Text(
                      evento.eOggi
                          ? 'oggi'
                          : LinguaDegliEventi.dataBreve(evento.quando),
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.goldSoft),
                    ),
                  ],
                ),
                // IL CONTO ALLA ROVESCIA SOLO SE DICE QUALCOSA IN PIU':
                // guardando l'anteprima, per un evento di oggi si leggeva
                // "oggi" due volte, a destra e sotto.
                if (!evento.eOggi) ...[
                  const SizedBox(height: 2),
                  Text(
                    LinguaDegliEventi.fraQuanto(evento.fraQuantiGiorni),
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textMuted),
                  ),
                ],
                if (LinguaDegliEventi.significatoDi(evento.evento) != null) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    LinguaDegliEventi.significatoDi(evento.evento)!,
                    style: TypographyTokens.didascalia().copyWith(
                        color: ColorTokens.textSecondary, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// L'invito a completare il profilo, con un pulsante vero: mai un vicolo
/// cieco, e mai un elenco vuoto con la colpa addosso a chi guarda.
class _InvitoACompletare extends StatelessWidget {
  const _InvitoACompletare({required this.palette});

  final dynamic palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
      child: DepthCard(
        key: const Key('calendario_invito_al_profilo'),
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Qui sotto c\'è il cielo di tutti',
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              'I tuoi appuntamenti, il ritorno solare e i transiti sulla tua '
              'carta, si calcolano solo con giorno, ora e luogo di nascita.',
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.4),
            ),
            const SizedBox(height: SpacingTokens.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('calendario_completa_il_profilo'),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.gold,
                  foregroundColor: palette.deepest,
                ),
                onPressed: () => Navigator.of(context)
                    .push(DatiDiNascitaScreen.route()),
                child: Text('Dai al Cerchio la tua nascita',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.deepest)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
