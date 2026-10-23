import 'package:flutter/material.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/lunario/il_giorno_lunare.dart';
import '../../core/lunario/il_segno_del_giorno_tuo.dart';
import '../../core/lunario/le_attivita_del_lunario.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../cerchio/scegli_dalla_rubrica_screen.dart';
import '../synastry/la_nascita_dell_altra_persona.dart';
import 'la_luna_nel_castone.dart';

/// **TROVA IL GIORNO INSIEME.** Ordine FV voce FV.10, 15 ottobre 2026. Fonte:
/// proposta dell'Architetto del 15 ottobre 2026, voce 5; Linee Guida V13
/// sezione 27; P7.
///
/// La persona sceglie uno o piu' amici veri del Cerchio e un'attivita' fra
/// le undici categorie di FV.06 (viaggio e trasloco ci stanno gia' dentro,
/// `viaggi` e `traslochi`: il rapporto dell'ordine dice perche' "cena" non
/// e' entrata come AttivitaDelLunario nuova). Il mese accende i giorni
/// buoni per tutti con le regole di FV.06 (uguali per chiunque, non
/// dipendono dalla nascita) e, per chi ha dato la sua nascita col consenso
/// di [P7], anche i suoi giorni tuoi di FV.07.
///
/// Apre il foglio e aspetta che la persona lo chiuda (manda la proposta o
/// torna indietro).
Future<void> apriTrovaIlGiornoInsieme(
  BuildContext context, {
  required MaestroPalette palette,
  required IlCerchioSociale sociale,
  required BirthIdentity identitaMia,
  required int anno,
  required int mese,
  required List<GiornoLunare> giorni,
  required bool ruota,
  required ValutaIlGiorno valuta,
  required IGiorniTuoiDelMese? giorniTuoi,
  VoidCallback? onPropostaMandata,
}) {
  return foglioDelCerchio<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => FoglioTrovaIlGiornoInsieme(
      palette: palette,
      sociale: sociale,
      identitaMia: identitaMia,
      anno: anno,
      mese: mese,
      giorni: giorni,
      ruota: ruota,
      valuta: valuta,
      giorniTuoi: giorniTuoi,
      onPropostaMandata: onPropostaMandata,
    ),
  );
}

class FoglioTrovaIlGiornoInsieme extends StatefulWidget {
  const FoglioTrovaIlGiornoInsieme({
    super.key,
    required this.palette,
    required this.sociale,
    required this.identitaMia,
    required this.anno,
    required this.mese,
    required this.giorni,
    required this.ruota,
    required this.valuta,
    required this.giorniTuoi,
    this.onPropostaMandata,
  });

  final MaestroPalette palette;
  final IlCerchioSociale sociale;
  final BirthIdentity identitaMia;
  final int anno;
  final int mese;
  final List<GiornoLunare> giorni;
  final bool ruota;
  final ValutaIlGiorno valuta;
  final IGiorniTuoiDelMese? giorniTuoi;

  /// Chiamato una volta mandata una proposta, cosi' chi ha aperto il foglio
  /// con un credito a Eos (FV.12) lo puo' consumare solo adesso.
  final VoidCallback? onPropostaMandata;

  @override
  State<FoglioTrovaIlGiornoInsieme> createState() =>
      _FoglioTrovaIlGiornoInsiemeState();
}

class _FoglioTrovaIlGiornoInsiemeState
    extends State<FoglioTrovaIlGiornoInsieme> {
  final Set<String> _amiciScelti = {};

  /// Le nascite prestate per gli amici che hanno dato il consenso (FV.10):
  /// solo chi e' in questa mappa porta i suoi giorni tuoi sul mese comune.
  final Map<String, BirthIdentity> _nasciteAmici = {};

  CategoriaDelLunario? _categoria;
  AttivitaDelLunario? _attivita;
  DateTime? _giornoScelto;
  bool _inviando = false;
  String? _rigaEsito;

  List<PersonaDelCerchio> get _amici => widget.sociale.cerchio.amici;

  /// **LE REGOLE DI FV.06 SONO UGUALI PER TUTTI**: `valuta` non dipende
  /// dalla nascita di nessuno, quindi il giorno buono per l'attivita' scelta
  /// e' lo stesso giorno buono per ogni amico della proposta. Questa e' la
  /// base comune, prima di aggiungere i giorni tuoi di chi ha dato la sua
  /// nascita.
  Map<int, EsitoDelGiorno> get _esitiComuni {
    final a = _attivita;
    if (a == null) return const {};
    return {for (final g in widget.giorni) g.giorno.day: widget.valuta(a, g)};
  }

  /// I giorni tuoi di ogni persona che ha dato la sua nascita (io compreso,
  /// quando la mia non e' quella d'esempio), per giorno del mese: il nome,
  /// per la frase sotto il giorno scelto, e il sigillo dipinto del tipo
  /// (R9), per il segno piccolo sulla casella del giorno.
  Map<int, List<(String nome, String sigillo)>> get _giorniTuoiComuni {
    final porta = widget.giorniTuoi;
    if (porta == null) return const {};
    final risultato = <int, List<(String, String)>>{};
    void aggiungi(String nome, BirthIdentity nascita) {
      if (nascita.isExample) return;
      for (final s in porta(nascita, widget.anno, widget.mese)) {
        if (nascita.hasBirthTime || !s.tipo.dipendeDallOra) {
          (risultato[s.giorno.day] ??= []).add((nome, s.sigillo));
        }
      }
    }

    aggiungi('te', widget.identitaMia);
    for (final uid in _amiciScelti) {
      final nascita = _nasciteAmici[uid];
      if (nascita == null) continue;
      final nome = _amici
          .firstWhere((p) => p.uid == uid,
              orElse: () => const PersonaDelCerchio(
                  uid: '', nome: 'il tuo amico', icona: ''))
          .nome;
      aggiungi(nome, nascita);
    }
    return risultato;
  }

  void _scegliCategoria(CategoriaDelLunario c) {
    setState(() {
      if (_categoria == c) {
        _categoria = null;
        _attivita = null;
      } else {
        _categoria = c;
        _attivita = c.attivita.length == 1 ? c.attivita.first : null;
      }
      _giornoScelto = null;
    });
  }

  void _scegliAmico(String uid) {
    setState(() {
      if (_amiciScelti.contains(uid)) {
        _amiciScelti.remove(uid);
        _nasciteAmici.remove(uid);
      } else {
        _amiciScelti.add(uid);
      }
    });
  }

  Future<void> _prestaLaNascitaDi(String uid) async {
    final letta = await LaNascitaDellAltraPersona.chiedi(
        context, widget.palette,
        perLoLunario: true);
    if (letta == null || !mounted) return;
    final oraNota = letta.minutoLocale != null;
    final minuti = letta.minutoLocale ?? 12 * 60;
    final g = letta.giornoDiNascita;
    setState(() {
      _nasciteAmici[uid] = BirthIdentity(
        birthMoment:
            DateTime(g.year, g.month, g.day, minuti ~/ 60, minuti % 60),
        hasBirthTime: oraNota,
      );
    });
  }

  Future<void> _manda() async {
    final attivita = _attivita;
    final giorno = _giornoScelto;
    if (attivita == null || giorno == null || _amiciScelti.isEmpty) return;
    setState(() {
      _inviando = true;
      _rigaEsito = null;
    });
    final esito = await widget.sociale.proponiGiornoInsieme(
      amici: _amiciScelti.toList(),
      attivita: attivita.name,
      giorno: giorno,
    );
    if (!mounted) return;
    setState(() {
      _inviando = false;
      _rigaEsito = esito.ok
          ? 'Proposta mandata. I tuoi amici la trovano nel Cerchio.'
          : esito.rigaPerLaPersona;
    });
    if (esito.ok) widget.onPropostaMandata?.call();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final esiti = _esitiComuni;
    final giorniTuoi = _giorniTuoiComuni;
    final attivita = _attivita;
    final pronto =
        attivita != null && _giornoScelto != null && _amiciScelti.isNotEmpty;
    return Container(
      key: const Key('lunario_foglio_insieme'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusXl)),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                SpacingTokens.md, SpacingTokens.lg, SpacingTokens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Trova il giorno insieme',
                    key: const Key('lunario_insieme_titolo'),
                    style: TypographyTokens.titoloSezione()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                    'Scegli gli amici e che cosa volete fare: il mese si '
                    'accende sui giorni buoni per tutti.',
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textSecondary)),
                const SizedBox(height: SpacingTokens.md),
                Text('Chi viene con te',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft)),
                if (_amici.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.xxs),
                    child: Text(
                        'Non hai ancora amici nel Cerchio: invitane uno per '
                        'trovare un giorno insieme.',
                        key: const Key('lunario_insieme_senza_amici'),
                        style: TypographyTokens.didascalia()
                            .copyWith(color: ColorTokens.textSecondary)),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.xxs),
                    child: Wrap(
                      spacing: SpacingTokens.xs,
                      runSpacing: SpacingTokens.xs,
                      children: [
                        for (final a in _amici)
                          _ChipAmico(
                            persona: a,
                            scelto: _amiciScelti.contains(a.uid),
                            conNascita: _nasciteAmici.containsKey(a.uid),
                            palette: palette,
                            onTap: () => _scegliAmico(a.uid),
                            onPresta: () => _prestaLaNascitaDi(a.uid),
                          ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const Key('lunario_insieme_invita'),
                    style: TextButton.styleFrom(
                        foregroundColor: palette.goldSoft,
                        padding: EdgeInsets.zero),
                    onPressed: () => Navigator.of(context)
                        .push(ScegliDallaRubricaScreen.route()),
                    child: const Text('Invita chi non è nel Cerchio'),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Text('Che cosa volete fare',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xxs),
                SizedBox(
                  height: 56,
                  child: ListView(
                    key: const Key('lunario_insieme_emblemi'),
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final c in CategoriaDelLunario.values)
                        GestureDetector(
                          key: Key('lunario_insieme_emblema_${c.name}'),
                          onTap: () => _scegliCategoria(c),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Image.asset(c.emblema,
                                width: _categoria == c ? 54 : 44,
                                height: _categoria == c ? 54 : 44,
                                opacity: AlwaysStoppedAnimation(
                                    _categoria != null && _categoria != c
                                        ? 0.45
                                        : 1),
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox(width: 44)),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_categoria != null && _categoria!.attivita.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.xxs),
                    child: Wrap(
                      spacing: SpacingTokens.xxs,
                      children: [
                        for (final a in _categoria!.attivita)
                          ChoiceChip(
                            key: Key('lunario_insieme_attivita_${a.name}'),
                            label: Text(a.nome),
                            showCheckmark: false,
                            selected: _attivita == a,
                            onSelected: (_) => setState(() {
                              _attivita = a;
                              _giornoScelto = null;
                            }),
                          ),
                      ],
                    ),
                  ),
                if (attivita != null) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Text('I giorni buoni per tutti',
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.xxs),
                  SizedBox(
                    height: 72,
                    child: ListView(
                      key: const Key('lunario_insieme_giorni'),
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final g in widget.giorni)
                          _GiornoInsieme(
                            giorno: g,
                            ruota: widget.ruota,
                            oro: esiti[g.giorno.day]?.grado ==
                                GradoDelGiorno.oro,
                            sigilliDiChiHaGiornoTuo: <String>{
                              for (final coppia in giorniTuoi[g.giorno.day] ??
                                  const <(String, String)>[])
                                coppia.$2,
                            }.toList(),
                            scelto: _giornoScelto?.day == g.giorno.day,
                            palette: palette,
                            onTap: () =>
                                setState(() => _giornoScelto = g.giorno),
                          ),
                      ],
                    ),
                  ),
                  if (_giornoScelto != null) ...[
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                        [
                          ...esiti[_giornoScelto!.day]?.perche ?? const [],
                          if ((giorniTuoi[_giornoScelto!.day] ?? const [])
                              .isNotEmpty)
                            'È anche il giorno tuo di '
                                '${(giorniTuoi[_giornoScelto!.day] ?? const []).map((e) => e.$1).join(", ")}.',
                        ].join(' '),
                        key: const Key('lunario_insieme_perche'),
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textPrimary)),
                  ],
                ],
                const SizedBox(height: SpacingTokens.lg),
                Center(
                  child: OutlinedButton(
                    key: const Key('lunario_insieme_manda'),
                    onPressed: pronto && !_inviando ? _manda : null,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: palette.goldSoft,
                        side: BorderSide(color: palette.goldSoft)),
                    child: Text(_inviando ? 'Un momento' : 'Manda la proposta'),
                  ),
                ),
                if (_rigaEsito != null) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  Text(_rigaEsito!,
                      key: const Key('lunario_insieme_esito'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipAmico extends StatelessWidget {
  const _ChipAmico({
    required this.persona,
    required this.scelto,
    required this.conNascita,
    required this.palette,
    required this.onTap,
    required this.onPresta,
  });

  final PersonaDelCerchio persona;
  final bool scelto;
  final bool conNascita;
  final MaestroPalette palette;
  final VoidCallback onTap;
  final VoidCallback onPresta;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scelto
          ? palette.goldSoft.withValues(alpha: 0.22)
          : palette.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      child: InkWell(
        key: Key('lunario_insieme_amico_${persona.uid}'),
        enableFeedback: false,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                  scelto
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.xxs),
              Text(persona.nome,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary)),
              if (scelto) ...[
                const SizedBox(width: SpacingTokens.xxs),
                GestureDetector(
                  key: Key('lunario_insieme_presta_${persona.uid}'),
                  onTap: onPresta,
                  child: Icon(
                      conNascita ? Icons.key_rounded : Icons.key_off_rounded,
                      size: 16,
                      color: palette.goldSoft),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GiornoInsieme extends StatelessWidget {
  const _GiornoInsieme({
    required this.giorno,
    required this.ruota,
    required this.oro,
    required this.sigilliDiChiHaGiornoTuo,
    required this.scelto,
    required this.palette,
    required this.onTap,
  });

  final GiornoLunare giorno;
  final bool ruota;
  final bool oro;

  /// I sigilli dipinti (P2) dei tipi di giorno tuo che qualcuno del gruppo
  /// ha su questo giorno, mai piu' di una stella disegnata (R9).
  final List<String> sigilliDiChiHaGiornoTuo;
  final bool scelto;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colore = oro ? palette.goldSoft : ColorTokens.textSecondary;
    return GestureDetector(
      key: Key('lunario_insieme_giorno_${giorno.giorno.day}'),
      onTap: onTap,
      child: Container(
        width: 52,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
          border: Border.all(
              color: scelto ? palette.goldSoft : Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${giorno.giorno.day}',
                style: TypographyTokens.etichetta().copyWith(color: colore)),
            LaLunaNelCastone(
                elongazione: giorno.elongazione, ruota: ruota, lato: 36),
            if (sigilliDiChiHaGiornoTuo.isNotEmpty)
              SizedBox(
                height: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final s in sigilliDiChiHaGiornoTuo.take(3))
                      Image.asset(s,
                          width: 12,
                          height: 12,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox(width: 12)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
