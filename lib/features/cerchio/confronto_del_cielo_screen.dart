import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/zodiac.dart';
import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/cerchio/il_confronto_del_cielo.dart';
import '../../core/chat/user_profile.dart';
import '../../core/entitlement/listino_degli_eos.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/horoscope/horoscope.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/synastry/synastry_report.dart';
import '../../design_system/components/borsellino.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../services/app_services.dart';
import '../synastry/podio_del_gemello.dart';
import '../synastry/sinastria_share_card.dart';
import 'widgets/disegni_del_cerchio.dart';

/// **IL CONFRONTO DEL CIELO, ordine EY voce 13.** Il colpo d'occhio prima
/// del testo: le due icone affiancate, il cerchio dell'affinita' del giorno
/// con la percentuale che sale, le quattro barre che si riempiono. Sotto, il
/// titolo del tuo oroscopo di oggi e quello del suo, e in mezzo la riga che
/// dice come stanno insieme i due cieli. E' la stessa famiglia visiva della
/// Sinastria VIP: il cerchio e le barre sono i suoi componenti.
///
/// **Il tetto lo tiene il server** (budget `cieli`): un confronto con lo
/// stesso amico nello stesso giorno si conta una volta sola, perche'
/// l'identificativo del consumo e' il giorno piu' l'amico.
class ConfrontoDelCieloScreen extends StatefulWidget {
  const ConfrontoDelCieloScreen(
      {super.key, required this.amico, this.oggi, this.mioSegno});

  final PersonaDelCerchio amico;

  /// Per le prove: il giorno e il segno di chi guarda.
  final DateTime? oggi;
  final Zodiac? mioSegno;

  static Route<void> route(PersonaDelCerchio amico) =>
      PassaggioDelCerchio.rotta<void>(
          (_) => ConfrontoDelCieloScreen(amico: amico));

  @override
  State<ConfrontoDelCieloScreen> createState() =>
      _ConfrontoDelCieloScreenState();
}

enum _Stato { chiedo, aperto, finiti, silenzio }

class _ConfrontoDelCieloScreenState extends State<ConfrontoDelCieloScreen> {
  _Stato _stato = _Stato.chiedo;

  DateTime get _oggi => widget.oggi ?? DateTime.now();

  String get _idDelConsumo {
    final g = _oggi;
    return 'cieli-${g.year}-${g.month}-${g.day}-${widget.amico.uid}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _conta());
  }

  Future<void> _conta() async {
    final porta = context.read<AppServices>().porta;
    final esito =
        await porta.consuma(budget: 'cieli', idMovimento: _idDelConsumo);
    if (!mounted) return;
    setState(() {
      if (esito == null) {
        // **IL RIPIEGO, DICHIARATO A SCHERMO**: senza la risposta del server
        // il confronto non si apre, perche' il conto e' suo.
        _stato = _Stato.silenzio;
      } else {
        _stato = esito.concesso ? _Stato.aperto : _Stato.finiti;
      }
    });
  }

  Future<void> _unoInPiu() async {
    final borsa = context.read<QuestionAllowance>();
    if (borsa.saldoEos < ListinoDegliEos.confrontoDelCieloInPiu.costo) {
      await PortafoglioDelCerchio.apri(context);
      return;
    }
    final pagato = await borsa.riscatta('cieli');
    if (!mounted) return;
    if (pagato == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Non si è potuto spendere adesso. '
              'Non ti è stato tolto niente.')));
      return;
    }
    setState(() => _stato = _Stato.chiedo);
    await _conta();
  }

  Zodiac? _ilMioSegno() {
    if (widget.mioSegno != null) return widget.mioSegno;
    try {
      final id = context.read<ProfileController>().identity;
      return id.isExample ? null : id.sunSign;
    } catch (senzaQuelDato) {
      // Il dato e' facoltativo: senza, si va avanti col ripiego.
      return null;
    }
  }

  String _titoloDi(Zodiac segno, {DateTime? nascita}) {
    final prima = LaMarcaDelGenere.formaCorrente;
    if (nascita == null) LaMarcaDelGenere.formaCorrente = CourtesyForm.unknown;
    try {
      return Horoscope.forSign(
        sign: segno,
        dayOfYear: Horoscope.dayOfYear(_oggi),
        year: _oggi.year,
        nascita: nascita,
      ).first.title;
    } finally {
      LaMarcaDelGenere.formaCorrente = prima;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = paletteDi(widget.amico.maestro);
    final mio = _ilMioSegno();
    final suo = widget.amico.segno;
    final profilo = context.watch<IlCerchioSociale>().profilo;
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: palette.deepest,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            title: Text('I vostri cieli di oggi',
                style: TypographyTokens.titoloDiSchermata()
                    .copyWith(color: palette.goldSoft)),
          ),
          body: switch (_stato) {
            _Stato.chiedo => const Center(child: CircularProgressIndicator()),
            _Stato.silenzio => _Riga(
                'Il Cerchio non risponde adesso: il confronto si apre appena '
                'torna la rete.',
                palette: palette),
            _Stato.finiti =>
              _IConfrontiFiniti(palette: palette, onPiu: _unoInPiu),
            _Stato.aperto => (mio == null || suo == null)
                ? _Riga(
                    'Per confrontare i cieli servono i due segni: '
                    '${mio == null ? 'il tuo nasce dalla tua data di nascita' : 'il suo arriva quando lo dice il suo profilo'}.',
                    palette: palette)
                : _IlConfronto(
                    confronto: IlConfrontoDelCielo.fra(mio, suo, _oggi),
                    mio: mio,
                    suo: suo,
                    iconaMia: profilo?.icona ?? 'segno:${mio.index}',
                    iconaSua: widget.amico.icona,
                    nomeSuo: widget.amico.nome,
                    titoloMio: _titoloDi(mio, nascita: _miaNascita(context)),
                    titoloSuo: _titoloDi(suo),
                    palette: palette,
                  ),
          },
        ));
  }

  DateTime? _miaNascita(BuildContext context) {
    try {
      final id = context.read<ProfileController>().identity;
      return id.isExample ? null : id.birthDate;
    } catch (senzaQuelDato) {
      // Il dato e' facoltativo: senza, si va avanti col ripiego.
      return null;
    }
  }
}

class _Riga extends StatelessWidget {
  const _Riga(this.testo, {required this.palette});
  final String testo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Text(testo,
              key: const Key('confronto_riga'),
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.45)),
        ),
      );
}

class _IConfrontiFiniti extends StatelessWidget {
  const _IConfrontiFiniti({required this.palette, required this.onPiu});
  final MaestroPalette palette;
  final VoidCallback onPiu;

  @override
  Widget build(BuildContext context) {
    const voce = ListinoDegliEos.confrontoDelCieloInPiu;
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('I confronti del cielo di oggi sono finiti.',
              key: const Key('confronti_finiti'),
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text('${voce.nome}, ${ListinoDegliEos.prezzo(voce.costo)}.',
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary)),
          const SizedBox(height: SpacingTokens.md),
          FilledButton(
            key: const Key('confronto_in_piu'),
            onPressed: onPiu,
            style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.onPrimary,
                minimumSize: const Size.fromHeight(48)),
            child: const Text('Confronta ancora'),
          ),
        ],
      ),
    );
  }
}

class _IlConfronto extends StatelessWidget {
  const _IlConfronto({
    required this.confronto,
    required this.mio,
    required this.suo,
    required this.iconaMia,
    required this.iconaSua,
    required this.nomeSuo,
    required this.titoloMio,
    required this.titoloSuo,
    required this.palette,
  });

  final IlConfrontoDelCielo confronto;
  final Zodiac mio;
  final Zodiac suo;
  final String iconaMia;
  final String iconaSua;
  final String nomeSuo;
  final String titoloMio;
  final String titoloSuo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
          ? Duration.zero
          : const Duration(milliseconds: 1600),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => ListView(
        key: const Key('confronto_del_cielo'),
        padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md, 0, SpacingTokens.md, SpacingTokens.xl),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconaTonda(icona: iconaMia, lato: 72),
              const SizedBox(width: SpacingTokens.lg),
              IconaTonda(icona: iconaSua, lato: 72),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Center(
            child: CerchioDellaPercentuale(
              key: const Key('confronto_percentuale'),
              percento: confronto.affinita,
              palette: palette,
              avanzamento: t,
              misura: 150,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          for (final (nome, valore) in confronto.barre)
            SynastryBarRow(
              bar: SynastryBar(label: nome, value: valore),
              palette: palette,
              progress: t,
            ),
          const SizedBox(height: SpacingTokens.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Colonna('Tu', mio, titoloMio, palette)),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(child: _Colonna(nomeSuo, suo, titoloSuo, palette)),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Center(
            key: const Key('confronto_riga_del_giorno'),
            child: ParagrafiDiLettura(
              testo: confronto.rigaDelGiorno(mio, suo),
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.45),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(IlConfrontoDelCielo.sulSegno,
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary)),
          ExpansionTile(
            key: const Key('confronto_fonti_e_metodo'),
            collapsedIconColor: palette.goldSoft,
            iconColor: palette.goldSoft,
            title: Text('Fonti e metodo',
                style: TypographyTokens.titoloDiRiga()
                    .copyWith(color: palette.goldSoft)),
            children: [
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                child: Text(IlConfrontoDelCielo.fontiEMetodo,
                    style: TypographyTokens.corpo().copyWith(
                        color: ColorTokens.textPrimary, height: 1.45)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Colonna extends StatelessWidget {
  const _Colonna(this.chi, this.segno, this.titolo, this.palette);
  final String chi;
  final Zodiac segno;
  final String titolo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(SpacingTokens.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          color: palette.surfaceElevated.withValues(alpha: 0.75),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text('$chi · ${segno.italianName}',
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: ColorTokens.textSecondary)),
            const SizedBox(height: SpacingTokens.xxs),
            Text(titolo,
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloDiRiga()
                    .copyWith(color: palette.goldSoft)),
          ],
        ),
      );
}
