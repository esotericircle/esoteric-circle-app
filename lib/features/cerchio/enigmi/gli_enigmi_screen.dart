import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/astro/zodiac.dart';
import '../../../core/cerchio/gli_enigmi_del_cerchio.dart';
import '../../../core/cerchio/i_tempi_dei_giochi.dart';
import '../../../core/cerchio/il_cerchio_sociale.dart';
import '../../../core/cerchio/la_prova.dart';
import '../../../core/entitlement/listino_degli_eos.dart';
import '../../../core/entitlement/question_allowance.dart';
import '../../../design_system/components/icona_degli_eos.dart';
import '../../../design_system/components/la_conferma_della_spesa.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../design_system/transizioni/velo_del_cerchio.dart';
import '../widgets/disegni_del_cerchio.dart';
import 'i_mattoni_degli_enigmi.dart';
import 'il_ritratto_screen.dart';
import 'l_indovinello_screen.dart';
import 'la_prova_screen.dart';

/// **GLI ENIGMI DEL CERCHIO.** Ordine FF, 8 ottobre 2026.
///
/// La casa dei giochi: Chi del Cerchio, chi ti ha indovinato, la Prova della
/// settimana con le scommesse e le sfide a due, il Pellegrinaggio verso la
/// luna piena, la classifica di chi conosce il Cerchio. Senza Ritratto
/// compilato nessun gioco si apre (voce FF.02.6 a). Ogni gioco aperto dice
/// quanto tempo gli resta (voce FF.07).
class GliEnigmiScreen extends StatefulWidget {
  const GliEnigmiScreen({super.key, this.vista, this.adesso});

  /// La vista gia' pronta, per le prove e le anteprime.
  final VistaDegliEnigmi? vista;
  final DateTime? adesso;

  static Route<void> route() => PassaggioDelCerchio.rotta<void>(
      (_) => const MaestroScope(neutro: true, child: GliEnigmiScreen()));

  @override
  State<GliEnigmiScreen> createState() => _GliEnigmiScreenState();
}

class _GliEnigmiScreenState extends State<GliEnigmiScreen> {
  VistaDegliEnigmi? _vista;
  bool _silenzio = false;
  late final DateTime _adesso = widget.adesso ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _vista = widget.vista;
    if (_vista == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _carica());
    }
  }

  Future<void> _carica() async {
    final luna = ITempiDeiGiochi.eIlTempoDelPellegrinaggio(_adesso)
        ? ITempiDeiGiochi.prossimaLunaPiena(_adesso)
        : null;
    final vista =
        await context.read<IlCerchioSociale>().gliEnigmi(lunaPiena: luna);
    if (!mounted) return;
    setState(() {
      _vista = vista ?? _vista;
      _silenzio = vista == null;
    });
  }

  Future<void> _apri(Route<Object?> rotta) async {
    await Navigator.of(context).push(rotta);
    if (mounted) await _carica();
  }

  Future<void> _scopri(VoceDelRitorno voce) async {
    final consenso = await LaConfermaDellaSpesa.degliEos(context,
        costo: ListinoDegliEos.segnoDiChiTiHaIndovinato.costo);
    if (consenso == null || !mounted) return;
    final esito = await context
        .read<IlCerchioSociale>()
        .scopriUnSegno(voce.chiave, consenso: consenso);
    if (!mounted) return;
    final saldo = esito.dati['saldo'];
    if (saldo is num) {
      try {
        await context.read<QuestionAllowance>().applicaSaldo(saldo.toInt());
      } catch (senzaIlBorsellino) {
        // Senza il borsellino montato il saldo si riallinea al ritorno.
      }
    }
    if (!mounted) return;
    if (esito.motivo == 'eos') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Mancano ${esito.dati['manca']} Eos per scoprire '
              'un segno.')));
    }
    await _carica();
  }

  /// **IL FOGLIO DELLE QUATTRO NATURE**: il presagio su un amico, la
  /// lettura a due, la risposta alla lettura. Il fondatore, 8 ottobre 2026:
  /// *"Non possiamo parlare di gioco o sfide o punteggi nella nostra app."*
  /// Si sceglie una natura, mai un numero. Torna la posizione (0-3).
  Future<int?> _unaNatura(String titolo, String spiega) {
    return foglioDelCerchio<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => fondoDelFoglio(
        c,
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(titolo,
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: ColorTokens.textPrimary)),
            const SizedBox(height: SpacingTokens.xs),
            RigaDegliEnigmi(spiega),
            const SizedBox(height: SpacingTokens.md),
            for (final n in NaturaDellaProva.values)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                child: OutlinedButton(
                  key: Key('enigmi_natura_${n.index}'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: MaestroPalette.neutral.goldSoft,
                    side: BorderSide(
                        color:
                            MaestroPalette.neutral.gold.withValues(alpha: 0.5)),
                  ),
                  onPressed: () => Navigator.of(c).pop(n.index),
                  child: Text('${n.nome}, ${n.temperamento}'),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  /// La natura di un amico dalla sua Prova di questa settimana.
  NaturaDellaProva? _naturaDi(TemaDellaProva tema, int? punteggio) =>
      punteggio == null ? null : LaProva.natura(tema, punteggio);

  Future<void> _gesto(Future<EsitoDelGesto> Function() fai) async {
    final esito = await fai();
    if (!mounted) return;
    final perche = esito.motivo;
    final riga = switch (perche) {
      'tardi' => 'Ha già fatto la Prova: adesso si vede la sua natura.',
      'limite' => 'Hai usato i presagi di oggi.',
      'piano' => 'La lettura a due si apre dall’Iniziato in su.',
      'prova' => 'Prima fai la Prova della settimana, poi chiedi la lettura.',
      'scaduta' => 'La lettura a due è chiusa.',
      'sfidaAperta' => 'Con questa persona hai già una lettura a due aperta.',
      _ => esito.ok ? null : esito.rigaPerLaPersona,
    };
    if (riga != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(riga)));
    }
    await _carica();
  }

  /// Il nome di un amico della Prova, dal suo identificativo.
  String _nomeDi(VistaDegliEnigmi v, String uid) {
    for (final a in v.amici) {
      if (a.uid == uid) return a.nome;
    }
    return 'un amico';
  }

  String _nomeDelSegno(String id) =>
      Zodiac.fromId(id)?.italianName ?? 'un segno sconosciuto';

  String _giornoEMese(DateTime d) {
    const mesi = [
      'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
      'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
    ];
    return '${d.day} ${mesi[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final v = _vista;
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            title: const TitoloDegliEnigmi('Gli Enigmi del Cerchio'),
          ),
          body: v == null
              ? Center(
                  child: _silenzio
                      ? const Padding(
                          padding: EdgeInsets.all(SpacingTokens.lg),
                          child: RigaDegliEnigmi(
                              'Il Cerchio non risponde adesso: gli Enigmi '
                              'tornano appena c’è la rete.'),
                        )
                      : const CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _carica,
                  child: ListView(
                    key: const Key('gli_enigmi'),
                    padding: const EdgeInsets.fromLTRB(SpacingTokens.md, 0,
                        SpacingTokens.md, SpacingTokens.xl),
                    children: _sezioni(v),
                  ),
                ),
        ));
  }

  List<Widget> _sezioni(VistaDegliEnigmi v) {
    final tema =
        v.tema != null ? LaProva.temi[v.tema! - 1] : LaProva.temaDi(_adesso);
    final scadeLaProva =
        ITempiDeiGiochi.scadenza(GiocoDelCerchio.prova, _adesso)!;
    final tuaNatura = v.provaFatta ? _naturaDi(tema, v.punteggio) : null;
    return [
      if (!v.ritrattoCompilato) ...[
        const SezioneDegliEnigmi('Il tuo Ritratto'),
        const RigaDegliEnigmi(
            'Per entrare negli Enigmi serve il tuo Ritratto: venti '
            'caratteristiche, otto già pronte dalla tua carta natale. Lo vedi '
            'intero solo tu.'),
        const SizedBox(height: SpacingTokens.sm),
        PulsanteDegliEnigmi(
          key: const Key('enigmi_compila_ritratto'),
          etichetta: 'Compila il Ritratto',
          icona: Icons.portrait_rounded,
          onPressed: () => _apri(IlRitrattoScreen.route()),
        ),
      ],
      const SezioneDegliEnigmi('Chi del Cerchio'),
      RigaDegliEnigmi(v.indovinelliRimasti == 1
          ? 'Ti resta un enigma oggi.'
          : 'Ti restano ${v.indovinelliRimasti} enigmi oggi.'),
      const SizedBox(height: SpacingTokens.sm),
      PulsanteDegliEnigmi(
        key: const Key('enigmi_gioca'),
        etichetta: 'Apri Chi del Cerchio',
        icona: Icons.groups_2_rounded,
        onPressed: v.ritrattoCompilato && v.indovinelliRimasti > 0
            ? () => _apri(LIndovinelloScreen.route())
            : null,
      ),
      if (v.ritorno.isNotEmpty) ...[
        const SezioneDegliEnigmi('Chi ti ha riconosciuto'),
        for (final r in v.ritorno) ...[
          Text(r.frase,
              key: Key('enigmi_ritorno_${r.chiave}'),
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
          if (r.segni.isNotEmpty)
            RigaDegliEnigmi(
                'Segni scoperti: ${r.segni.map(_nomeDelSegno).join(', ')}.'),
          if (r.daScoprire > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: Key('enigmi_scopri_${r.chiave}'),
                style: TextButton.styleFrom(
                    foregroundColor: MaestroPalette.neutral.goldSoft),
                onPressed: () => _scopri(r),
                icon: IconaDegliEos(colore: MaestroPalette.neutral.goldSoft),
                label: Text('Scopri il segno di chi ti ha riconosciuto, '
                    '${ListinoDegliEos.segnoDiChiTiHaIndovinato.costo} Eos'),
              ),
            ),
        ],
      ],
      const SezioneDegliEnigmi('La Prova della settimana'),
      Text(tema.nome,
          style: TypographyTokens.titoloDiRiga()
              .copyWith(color: MaestroPalette.neutral.goldSoft)),
      RigaDegliEnigmi(
          'Finisce fra ${ilTempoCheResta(ITempiDeiGiochi.resta(scadeLaProva, _adesso))}.'),
      if (tuaNatura != null)
        Text(
            'La tua natura: ${tuaNatura.nomeInFrase}, il temperamento '
            '${tuaNatura.temperamento}.',
            key: const Key('enigmi_tua_natura'),
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary)),
      if (!v.provaFatta) ...[
        const SizedBox(height: SpacingTokens.sm),
        PulsanteDegliEnigmi(
          key: const Key('enigmi_fai_la_prova'),
          etichetta: 'Fai la Prova',
          icona: Icons.auto_awesome_rounded,
          onPressed: v.ritrattoCompilato
              ? () => _apri(LaProvaScreen.route(temaFissato: v.tema))
              : null,
        ),
      ],
      for (final a in v.amici)
        Padding(
          padding: const EdgeInsets.only(top: SpacingTokens.sm),
          child: Row(children: [
            Expanded(
              child: Text(
                  a.fatta
                      ? '${a.nome}: ${_naturaDi(tema, a.punteggio)?.nomeInFrase ?? 'la Prova fatta'}'
                      : a.scommessa != null
                          ? '${a.nome}: hai presagito '
                              '${NaturaDellaProva.diIndice(a.scommessa)?.nomeInFrase ?? 'la sua natura'}'
                          : '${a.nome}: non l’ha ancora fatta',
                  key: Key('enigmi_amico_${a.uid}'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary)),
            ),
            if (!a.fatta &&
                a.scommessa == null &&
                v.scommesse < v.scommesseAlGiorno)
              TextButton(
                key: Key('enigmi_presagio_${a.uid}'),
                style: TextButton.styleFrom(
                    foregroundColor: MaestroPalette.neutral.goldSoft),
                onPressed: () async {
                  final n = await _unaNatura(
                      'Che natura senti in ${a.nome}?',
                      'Prima che faccia la Prova, presagisci con quale dei '
                          'quattro elementi vivrà la domanda del cielo.');
                  if (n != null && mounted) {
                    await _gesto(() =>
                        context.read<IlCerchioSociale>().scommetti(a.uid, n));
                  }
                },
                child: const Text('Presagio'),
              ),
            if (!a.fatta &&
                v.provaFatta &&
                v.puoiSfidare &&
                !v.sfide.any((s) => s.da == a.uid || s.a == a.uid))
              TextButton(
                key: Key('enigmi_lettura_${a.uid}'),
                style: TextButton.styleFrom(
                    foregroundColor: MaestroPalette.neutral.goldSoft),
                onPressed: () async {
                  final n = await _unaNatura(
                      'Lettura a due con ${a.nome}',
                      'Ciascuno presagisce la natura dell’altro nella Prova '
                          'di questa settimana. Ventiquattro ore.');
                  if (n != null && mounted) {
                    await _gesto(
                        () => context.read<IlCerchioSociale>().sfida(a.uid, n));
                  }
                },
                child: const Text('Lettura a due'),
              ),
          ]),
        ),
      if (v.sfide.isNotEmpty) ...[
        const SezioneDegliEnigmi('Le letture a due aperte'),
        for (final s in v.sfide)
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
            child: Row(children: [
              Expanded(
                child: Text(
                    '${s.tua ? 'La tua lettura con ${_nomeDi(v, s.a)}' : 'La lettura di ${_nomeDi(v, s.da)}'}: '
                    'finisce fra ${ilTempoCheResta(ITempiDeiGiochi.resta(s.scade, _adesso))}.',
                    key: Key('enigmi_lettura_aperta_${s.id}'),
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textPrimary)),
              ),
              if (!s.tua && !s.haiStimato)
                TextButton(
                  key: Key('enigmi_rispondi_${s.id}'),
                  style: TextButton.styleFrom(
                      foregroundColor: MaestroPalette.neutral.goldSoft),
                  onPressed: () async {
                    final n = await _unaNatura(
                        'Che natura senti in ${_nomeDi(v, s.da)}?',
                        'Ti ha chiesto una lettura a due: presagisci la sua '
                            'natura nella Prova di questa settimana.');
                    if (n != null && mounted) {
                      await _gesto(() => context
                          .read<IlCerchioSociale>()
                          .rispondiAllaSfida(s.id, s.da, n));
                    }
                  },
                  child: const Text('Rispondi'),
                ),
            ]),
          ),
      ],
      const SezioneDegliEnigmi('Il Pellegrinaggio'),
      ..._ilPellegrinaggio(v.pellegrinaggio),
      if (v.classifica.length > 1) ...[
        const SezioneDegliEnigmi('Chi legge il Cerchio'),
        for (var i = 0; i < v.classifica.length; i++)
          Text(
              '${i + 1}. ${v.classifica[i].tu ? 'Tu' : v.classifica[i].nome}: '
              '${v.classifica[i].quanti == 1 ? 'un riconoscimento' : '${v.classifica[i].quanti} riconoscimenti'}',
              key: Key('enigmi_chi_legge_$i'),
              style: TypographyTokens.corpo().copyWith(
                  color: v.classifica[i].tu
                      ? MaestroPalette.neutral.goldSoft
                      : ColorTokens.textPrimary)),
      ],
    ];
  }

  List<Widget> _ilPellegrinaggio(IlPellegrinaggio? p) {
    if (p == null) {
      final luna = ITempiDeiGiochi.prossimaLunaPiena(_adesso);
      return [
        RigaDegliEnigmi(luna == null
            ? 'Il prossimo Pellegrinaggio si apre nella settimana della luna piena.'
            : 'Si apre nella settimana che porta alla luna piena del '
                '${_giornoEMese(luna)}: ogni rito che fai porta il Cerchio '
                'avanti di un passo.'),
      ];
    }
    final scade = ITempiDeiGiochi.scadenza(
        GiocoDelCerchio.pellegrinaggio, _adesso,
        lunaPiena: p.luna)!;
    return [
      RigaDegliEnigmi(
          'Verso la luna piena del ${_giornoEMese(p.luna)}: ${p.totale} passi '
          'di ${p.meta}. Finisce fra '
          '${ilTempoCheResta(ITempiDeiGiochi.resta(scade, _adesso))}.'),
      const SizedBox(height: SpacingTokens.sm),
      ClipRRect(
        key: const Key('enigmi_barra_pellegrinaggio'),
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 12,
          child: Row(children: [
            for (final passo in p.passi)
              if (passo.quanti > 0)
                Expanded(
                  flex: passo.quanti,
                  child: Container(
                    margin: const EdgeInsets.only(right: 1),
                    color: passo.tu
                        ? MaestroPalette.neutral.goldSoft
                        : MaestroPalette.neutral.gold.withValues(alpha: 0.6),
                  ),
                ),
            if (p.meta > p.totale)
              Expanded(
                flex: p.meta - p.totale,
                // La strada che manca: l'oro spento, non un grigio di testo.
                child: Container(
                    color: MaestroPalette.neutral.gold.withValues(alpha: 0.18)),
              ),
          ]),
        ),
      ),
      const SizedBox(height: SpacingTokens.xs),
      if (p.arrivato)
        const RigaDegliEnigmi('Il Cerchio è arrivato: nessuno resta indietro.',
            oro: true),
      for (final passo in p.passi)
        Text(
            '${passo.tu ? 'Tu' : passo.nome}: '
            '${passo.quanti == 1 ? 'un passo' : '${passo.quanti} passi'}',
            style: TypographyTokens.didascalia().copyWith(
                color: passo.tu
                    ? MaestroPalette.neutral.goldSoft
                    : ColorTokens.textSecondary)),
    ];
  }
}
