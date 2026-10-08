import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/archetypes/archetype_history.dart';
import '../../../core/astro/natal_chart_controller.dart';
import '../../../core/astro/zodiac.dart';
import '../../../core/cerchio/il_cerchio_sociale.dart';
import '../../../core/cerchio/il_ritratto.dart';
import '../../../core/cerchio/il_ritratto_del_corpus.g.dart';
import '../../../core/cerchio/il_testo_degli_enigmi.dart';
import '../../../core/chat/la_marca_del_genere.dart';
import '../../../core/identity/profile_controller.dart';
import '../../../core/rituals/guide_animal_derivation.dart';
import '../../../core/viaggio/il_nome_si_puo_dire.dart';
import '../../../design_system/components/interruttore_del_cerchio.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../widgets/disegni_del_cerchio.dart';
import 'i_mattoni_degli_enigmi.dart';

/// **IL RITRATTO.** Ordine FF voce 02, 8 ottobre 2026.
///
/// Si compila alla prima entrata in un gioco del Cerchio, mai
/// nell'onboarding: chi entra trova otto caselle gia' segnate dalla carta
/// natale, sceglie le altre dodici e gioca. Le otto si cambiano tutte. Dal
/// profilo si cambia quando si vuole; un gioco cominciato continua col
/// Ritratto di quando e' cominciato (la fotografia la tiene il server).
///
/// Il Ritratto intero lo vede solo chi lo possiede: questa e' l'unica
/// schermata che lo mostra, e mostra solo il proprio.
class IlRitrattoScreen extends StatefulWidget {
  const IlRitrattoScreen({super.key, this.tratti, this.proposte});

  /// Il Ritratto di partenza, per le prove e le anteprime; nullo vuol dire
  /// chiederlo al server.
  final List<int>? tratti;

  /// Le proposte della carta, per le prove e le anteprime.
  final List<int>? proposte;

  static Route<bool> route() => PassaggioDelCerchio.rotta<bool>(
      (_) => const MaestroScope(neutro: true, child: IlRitrattoScreen()));

  @override
  State<IlRitrattoScreen> createState() => _IlRitrattoScreenState();
}

class _IlRitrattoScreenState extends State<IlRitrattoScreen> {
  List<int> _scelte = [];
  Set<int> _proposte = {};
  bool _pronto = false;
  bool _scrivo = false;
  bool _fuoriDaiGiochi = false;
  String? _archetipo;
  String? _animale;
  String? _riga;

  @override
  void initState() {
    super.initState();
    if (widget.tratti != null) {
      _scelte = [...widget.tratti!];
      _proposte = (widget.proposte ?? _leProposte()).toSet();
      _pronto = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _carica());
  }

  /// Le otto proposte dalla carta natale; nessuna senza la data di nascita.
  List<int> _leProposte() {
    try {
      final identita = context.read<ProfileController>().identity;
      final sole = identita.sunSign;
      if (sole == null) return const [];
      Zodiac? luna;
      Zodiac? ascendente;
      try {
        final carta = context.read<NatalChartController>().chart;
        luna = carta?.moonSign;
        ascendente = carta?.ascendant;
      } catch (senzaLaCarta) {
        // Senza la carta intera restano il Sole e il ripiego del corpus.
      }
      return IlRitratto.proposteDallaCarta(
          sole: sole,
          luna: luna,
          ascendente: ascendente,
          giornoDiNascita: identita.birthMoment.day);
    } catch (senzaIlProfilo) {
      return const [];
    }
  }

  Future<void> _carica() async {
    final esito = await context.read<IlCerchioSociale>().ilMioRitratto();
    if (!mounted) return;
    final dal = esito.dati;
    final tratti = [
      for (final t
          in (dal['tratti'] is List ? dal['tratti'] as List : const []))
        if (t is num) t.toInt(),
    ];
    final proposte = _leProposte();
    setState(() {
      _proposte = proposte.toSet();
      _scelte = tratti.isNotEmpty ? tratti : [...proposte];
      _fuoriDaiGiochi = dal['fuoriDaiGiochi'] == true;
      _archetipo = dal['archetipo'] as String?;
      _animale = dal['animale'] as String?;
      _pronto = true;
      if (!esito.ok && tratti.isEmpty && esito.riga != null) {
        _riga = esito.riga;
      }
    });
  }

  void _tocca(int numero) {
    setState(() {
      if (_scelte.contains(numero)) {
        _scelte.remove(numero);
      } else if (_scelte.length < IlRitratto.quante) {
        _scelte.add(numero);
      }
    });
  }

  Future<void> _chiudi() async {
    setState(() => _scrivo = true);
    final esito =
        await context.read<IlCerchioSociale>().ilMioRitratto(tratti: _scelte);
    if (!mounted) return;
    setState(() => _scrivo = false);
    if (esito.ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _riga = esito.riga ?? EsitoDelGesto.silenzio.riga);
    }
  }

  Future<void> _scegli(
      {bool? fuori, String? archetipo, String? animale}) async {
    final sociale = context.read<IlCerchioSociale>();
    final esito = await sociale.ilMioRitratto(
      fuoriDaiGiochi: fuori,
      archetipo: archetipo,
      togliArchetipo: archetipo == null && fuori == null && animale == null,
      animale: animale,
    );
    if (!mounted || !esito.ok) return;
    setState(() {
      _fuoriDaiGiochi = esito.dati['fuoriDaiGiochi'] == true;
      _archetipo = esito.dati['archetipo'] as String?;
      _animale = esito.dati['animale'] as String?;
    });
  }

  /// L'archetipo del tuo ultimo Test, se l'hai fatto.
  String? _ilTuoArchetipo() {
    try {
      return context.read<ArchetypeHistory>().ultimo?.dominante.name;
    } catch (senzaLoStorico) {
      return null;
    }
  }

  /// L'animale guida, **solo se l'hai gia' nominato** dopo le quattro
  /// discese (`IlNomeSiPuoDire`): prima e' velato anche qui.
  String? _ilTuoAnimale() {
    try {
      final sole = context.read<ProfileController>().identity.sunSign;
      if (sole == null) return null;
      final animale = GuideAnimalDerivation.forSign(sole);
      return IlNomeSiPuoDire.dalCioCheSiSaGia(animale.name)
          ? animale.name.toLowerCase()
          : null;
    } catch (senzaIlProfilo) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final forma = LaMarcaDelGenere.formaCorrente;
    final mancano = IlRitratto.quante - _scelte.length;
    final archetipo = _ilTuoArchetipo();
    final animale = _ilTuoAnimale();
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            title: Text('Il tuo Ritratto',
                style: TypographyTokens.titoloDiSchermata()
                    .copyWith(color: palette.goldSoft)),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.md,
                  SpacingTokens.sm, SpacingTokens.md, SpacingTokens.md),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                    mancano > 0
                        ? 'Ne hai scelte ${_scelte.length} di 20: ne mancano $mancano.'
                        : 'Hai scelto le tue venti caratteristiche.',
                    key: const Key('ritratto_contatore'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary)),
                const SizedBox(height: SpacingTokens.xs),
                PulsanteDegliEnigmi(
                  key: const Key('ritratto_chiudi'),
                  etichetta: _scrivo ? 'Un momento...' : 'Chiudi il Ritratto',
                  onPressed:
                      IlRitratto.siChiude(_scelte) && !_scrivo ? _chiudi : null,
                ),
              ]),
            ),
          ),
          body: !_pronto
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  key: const Key('il_ritratto'),
                  padding: const EdgeInsets.fromLTRB(
                      SpacingTokens.md, 0, SpacingTokens.md, SpacingTokens.xl),
                  children: [
                    Text(
                        'Venti caratteristiche che dicono come sei fatto. '
                        'Lo vedi intero solo tu: agli altri ne arriva una '
                        'per volta, come indizio nei giochi del Cerchio.',
                        style: TypographyTokens.corpo().copyWith(
                            color: ColorTokens.textSecondary, height: 1.4)),
                    if (_proposte.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: SpacingTokens.xs),
                        child: Text(
                            'Otto le abbiamo segnate dalla tua carta natale: '
                            'puoi cambiarle tutte.',
                            key: const Key('ritratto_proposte'),
                            style: TypographyTokens.didascalia()
                                .copyWith(color: palette.goldSoft)),
                      ),
                    if (_riga != null)
                      Text(_riga!,
                          style: TypographyTokens.didascalia()
                              .copyWith(color: palette.goldSoft)),
                    // **LE TUE SCELTE, in cima**: chi apre vede subito cio'
                    // che e' gia' segnato, le otto della carta comprese, e
                    // lo toglie con un tocco.
                    if (_scelte.isNotEmpty) ...[
                      const _Sezione('Le tue scelte'),
                      for (final n in _scelte)
                        _RigaDelTratto(
                          key: Key('scelto_$n'),
                          testo: IlTestoDegliEnigmi.perChiCompila(
                              IlRitratto.tratto(n)!.testoMarcato, forma),
                          scelto: true,
                          proposto: _proposte.contains(n),
                          spento: false,
                          onTap: () => _tocca(n),
                        ),
                      const _Sezione('Tutte le caratteristiche'),
                    ],
                    for (var s = 0; s < sezioniDelRitratto.length; s++) ...[
                      _Sezione(sezioniDelRitratto[s]),
                      for (final t in IlRitratto.tutti)
                        if (t.sezione == s)
                          _RigaDelTratto(
                            key: Key('tratto_${t.numero}'),
                            testo: IlTestoDegliEnigmi.perChiCompila(
                                t.testoMarcato, forma),
                            scelto: _scelte.contains(t.numero),
                            proposto: _proposte.contains(t.numero),
                            spento: !_scelte.contains(t.numero) && mancano == 0,
                            onTap: () => _tocca(t.numero),
                          ),
                    ],
                    const _Sezione('Nei giochi degli altri'),
                    InterruttoreDelCerchio(
                      key: const Key('ritratto_fuori_dai_giochi'),
                      acceso: _fuoriDaiGiochi,
                      onCambia: (v) => _scegli(fuori: v),
                      titolo: 'Non comparire nei giochi degli altri',
                      sottotitolo: _fuoriDaiGiochi
                          ? 'Nessuno può indovinarti. Tu continui a giocare sugli altri.'
                          : 'Puoi comparire fra i quattro volti di un indovinello.',
                    ),
                    if (archetipo != null)
                      InterruttoreDelCerchio(
                        key: const Key('ritratto_archetipo'),
                        acceso: _archetipo != null,
                        onCambia: (v) =>
                            _scegli(archetipo: v ? archetipo : null),
                        titolo: 'Il tuo archetipo nei giochi',
                        sottotitolo: _archetipo != null
                            ? 'Il risultato del tuo Test può essere una risposta.'
                            : 'Il risultato del tuo Test resta tuo.',
                      ),
                    if (animale != null)
                      InterruttoreDelCerchio(
                        key: const Key('ritratto_animale'),
                        acceso: _animale != null,
                        onCambia: (v) => _scegli(animale: v ? animale : null),
                        titolo: 'Il tuo animale guida nei giochi',
                        sottotitolo: _animale != null
                            ? 'Chi gioca può cercarti dal tuo animale.'
                            : 'Il tuo animale resta tuo.',
                      ),
                  ],
                ),
        ));
  }
}

class _Sezione extends StatelessWidget {
  const _Sezione(this.titolo);
  final String titolo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            top: SpacingTokens.lg, bottom: SpacingTokens.xs),
        child: Text(titolo.toUpperCase(),
            style: TypographyTokens.etichetta().copyWith(
                color: MaestroPalette.neutral.goldSoft, letterSpacing: 1.4)),
      );
}

class _RigaDelTratto extends StatelessWidget {
  const _RigaDelTratto({
    super.key,
    required this.testo,
    required this.scelto,
    required this.proposto,
    required this.spento,
    required this.onTap,
  });

  final String testo;
  final bool scelto;
  final bool proposto;
  final bool spento;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const oro = MaestroPalette.neutral;
    return InkWell(
      onTap: spento ? null : onTap,
      enableFeedback: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(
              scelto
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 22,
              color: scelto ? oro.goldSoft : ColorTokens.textSecondary),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(testo,
                    style: TypographyTokens.corpo().copyWith(
                        color: spento
                            ? ColorTokens.textSecondary
                            : ColorTokens.textPrimary,
                        height: 1.3)),
                if (proposto)
                  Text('Dalla tua carta',
                      style: TypographyTokens.didascalia()
                          .copyWith(color: oro.goldSoft)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
