import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/amici/amici_offline.dart';
import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/entitlement/tier.dart';
import '../../core/synastry_evolutiva/cielo_evolutivo.dart';
import '../../core/synastry_evolutiva/la_lunga_della_sinastria.dart';
import '../../core/synastry_evolutiva/legame_e_eta.dart';
import '../../design_system/components/interruttore_del_cerchio.dart';
import '../../design_system/components/riquadro_in_evidenza.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../cerchio/invita_nel_cerchio_screen.dart';
import '../pricing/upgrade_invite.dart';
import '../respiro_della_luna/i_comandi_dipinti.dart';
import 'il_ritratto_della_coppia.dart' show immagineDellaSinastria;
import '../tarot/tarot_selectors.dart';
import 'la_nascita_dell_altra_persona.dart';

/// Cio' che la tendina restituisce: la persona, il suo cielo, il legame e la
/// profondita'. Nulla, chi legge ci ha ripensato.
class SceltaDellaSinastria {
  const SceltaDellaSinastria({
    required this.nome,
    required this.cielo,
    required this.legame,
    this.profondita = ProfonditaDellaSinastria.breve,
    this.amoreDalServer,
    this.uidDelCerchio,
  });

  final String nome;
  final CieloEvolutivo cielo;
  final Legame legame;
  final ProfonditaDellaSinastria profondita;

  /// Il parere del server sull'amore, nella lettura a due telefoni (FT.04);
  /// nullo con la nascita scritta a mano.
  final bool? amoreDalServer;

  /// L'amico del Cerchio scelto dall'elenco online (GD.14): il responso
  /// arriva anche a lui (GD.21). Nullo per chi non e' nel Cerchio.
  final String? uidDelCerchio;

  bool get lunga => profondita == ProfonditaDellaSinastria.lunga;
}

enum _Passo { scelta, online, offline, modulo }

/// **LA TENDINA DELLA SINASTRIA EVOLUTIVA.** Ordine GD voci GD.14, GD.15,
/// GD.16 e GD.17, 23 ottobre 2026.
///
/// Il fondatore, GD.14: *"Quando l'utente fa click sul pulsante in basso, si
/// apre verso l'alto una tendina in semitrasparenza con la scelta guidata,
/// uno alla volta, tra on-line e offline. Se sceglie online comparirà
/// l'elenco degli amici del cerchio e se non ne ha verrà informato che non
/// ha amci nel cerchio e se vorrà invitalri. In quest'ultimo caso passerà
/// alle schermate di invito nel cerchio della funzionalità Social, ma potrà
/// tornare indietro, Senza uscire, con la freccetta indietro. Se sceglierà
/// offline, comparirà l'elenco degli amici che ha già creato offline (la
/// stessa lista dell'oroscopo, per intenderci) oppure potrà inserirne uno
/// nuovo"*.
///
/// GD.15: *"Dopo la selezione comparirà il modulo inserimento dati
/// graficamente elegante per inserire nome, data e orario di nascita"*. Il
/// modulo usa i ruoli tipografici del responso dei Tarocchi
/// ([TypographyTokens.titoloScheda], [TypographyTokens.etichetta],
/// [TypographyTokens.lettura], [TypographyTokens.didascalia]) e i riquadri
/// della casa ([RiquadroInEvidenza]); la prova ne fa il censimento.
///
/// GD.16: la tipologia del legame si sceglie con le quattro icone dipinte,
/// una sola alla volta; l'Amore resta chiuso sotto i sedici anni di una
/// delle due persone (FT.04, [SbarramentoDEta]).
///
/// GD.17: Breve o Lunga, la Lunga dai piani a pagamento, col lucchetto e
/// l'invito per chi non li ha ([RigaDelPiano.sinastriaLunga]).
///
/// **GLI AMICI OFFLINE DA UNA PORTA SOLA** (GD.20): l'elenco e' quello di
/// [AmiciOffline], lo stesso dell'Oroscopo e la persona nuova scritta qui
/// entra in quella lista (se il piano la tiene): nessuna seconda lista.
///
/// **LA LETTURA A DUE TELEFONI RESTA** (FT.03 e per la Sinastria resta,
/// FY.14): nel modulo, "Hai un codice dal suo telefono?" apre la nascita
/// letta col consenso e la nascita non si mostra (arriva per una lettura).
class LaTendinaDellaSinastria extends StatefulWidget {
  const LaTendinaDellaSinastria({
    super.key,
    required this.palette,
    required this.tier,
    required this.cieloTuo,
    required this.oggi,
    this.nomeSuggerito,
    this.amici,
  });

  final MaestroPalette palette;
  final Tier tier;
  final CieloEvolutivo cieloTuo;
  final DateTime oggi;
  final String? nomeSuggerito;

  /// La porta degli amici offline, per le prove; nell'app se ne crea una e
  /// si carica dal telefono.
  final AmiciOffline? amici;

  /// Il velo della tendina: semitrasparente, la scena si vede dietro.
  static const double velo = 0.82;

  /// Apre la tendina dal basso e aspetta la scelta.
  static Future<SceltaDellaSinastria?> apri(
    BuildContext context, {
    required MaestroPalette palette,
    required Tier tier,
    required CieloEvolutivo cieloTuo,
    required DateTime oggi,
    String? nomeSuggerito,
    AmiciOffline? amici,
  }) {
    return foglioDelCerchio<SceltaDellaSinastria>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.deepest.withValues(alpha: velo),
      builder: (_) => LaTendinaDellaSinastria(
        palette: palette,
        tier: tier,
        cieloTuo: cieloTuo,
        oggi: oggi,
        nomeSuggerito: nomeSuggerito,
        amici: amici,
      ),
    );
  }

  @override
  State<LaTendinaDellaSinastria> createState() =>
      _LaTendinaDellaSinastriaState();
}

class _LaTendinaDellaSinastriaState extends State<LaTendinaDellaSinastria> {
  _Passo _passo = _Passo.scelta;
  late final AmiciOffline _amici = widget.amici ?? AmiciOffline();
  bool _caricandoIlCerchio = false;

  // Il modulo.
  late final TextEditingController _nome =
      TextEditingController(text: widget.nomeSuggerito ?? '');
  DateTime? _data;
  TimeOfDay? _ora;
  bool _oraNonNota = false;
  Legame? _legame;
  ProfonditaDellaSinastria _profondita = ProfonditaDellaSinastria.breve;
  NascitaLetta? _dalCodice;
  String? _uidDelCerchio;

  /// Vero se la persona del modulo e' nuova, dall'elenco offline: alla
  /// scoperta entra fra gli amici offline (GD.20).
  bool _nuovaOffline = false;

  /// Il passo da cui si e' arrivati al modulo, per la freccia indietro.
  _Passo _primaDelModulo = _Passo.scelta;

  MaestroPalette get _p => widget.palette;

  @override
  void initState() {
    super.initState();
    if (!_amici.caricati) unawaited(_amici.carica());
    _amici.addListener(_aggiorna);
  }

  void _aggiorna() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _amici.removeListener(_aggiorna);
    _nome.dispose();
    super.dispose();
  }

  IlCerchioSociale? get _sociale {
    try {
      return Provider.of<IlCerchioSociale>(context, listen: false);
    } on ProviderNotFoundException catch (senzaCerchio) {
      debugPrint('La tendina della Sinastria: nessun Cerchio. $senzaCerchio');
      return null;
    }
  }

  Future<void> _vaiOnline() async {
    setState(() => _passo = _Passo.online);
    final s = _sociale;
    if (s == null || !s.vivo || s.chiusoPerEta || s.cerchio.amici.isNotEmpty) {
      return;
    }
    setState(() => _caricandoIlCerchio = true);
    await s.caricaIlCerchio();
    if (mounted) setState(() => _caricandoIlCerchio = false);
  }

  void _alModulo({
    required _Passo da,
    String nome = '',
    DateTime? data,
    TimeOfDay? ora,
    String? uid,
    bool nuova = false,
  }) {
    setState(() {
      _primaDelModulo = da;
      _passo = _Passo.modulo;
      _nome.text = nome.isEmpty ? (widget.nomeSuggerito ?? '') : nome;
      _data = data;
      _ora = ora;
      _oraNonNota = data != null && ora == null;
      _uidDelCerchio = uid;
      _nuovaOffline = nuova;
      _dalCodice = null;
      _legame = null;
    });
  }

  void _indietro() {
    setState(() {
      _passo = switch (_passo) {
        _Passo.modulo => _primaDelModulo,
        _ => _Passo.scelta,
      };
    });
  }

  // --- Il modulo ---------------------------------------------------------

  DateTime? get _giornoSuo {
    final c = _dalCodice;
    if (c != null) return c.giornoDiNascita;
    return _data;
  }

  /// L'amore si apre se tutte e due hanno sedici anni (FT.04) e il server,
  /// quando ha visto la nascita, non ha detto di no.
  bool get _amoreApribile {
    if (_dalCodice?.amoreDalServer == false) return false;
    final suo = _giornoSuo;
    if (suo == null) return true;
    return SbarramentoDEta.legameApribile(
        Legame.amore, widget.cieloTuo.giornoDiNascita, suo,
        adesso: widget.oggi);
  }

  bool get _datiCompleti {
    if (_nome.text.trim().isEmpty) return false;
    if (_dalCodice != null) return true;
    return _data != null && (_oraNonNota || _ora != null);
  }

  bool get _pronto =>
      _datiCompleti &&
      _legame != null &&
      (_legame != Legame.amore || _amoreApribile);

  bool get _lungaAperta =>
      PlanCatalog.apre(RigaDelPiano.sinastriaLunga, widget.tier);

  Future<void> _scegliData() async {
    final scelta = await showDatePicker(
      context: context,
      initialDate: _data ?? DateTime(widget.oggi.year - 25),
      firstDate: DateTime(1900),
      lastDate: widget.oggi,
    );
    if (scelta == null || !mounted) return;
    setState(() {
      _data = scelta;
      // Una data che chiude l'amore toglie la scelta dell'amore.
      if (_legame == Legame.amore && !_amoreApribile) _legame = null;
    });
  }

  Future<void> _scegliOra() async {
    final scelta = await showTimePicker(
      context: context,
      initialTime: _ora ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (scelta != null && mounted) setState(() => _ora = scelta);
  }

  Future<void> _leggiIlCodice() async {
    final letta = await LaNascitaDellAltraPersona.chiedi(context, _p,
        nomeIniziale: _nome.text.trim().isEmpty ? null : _nome.text.trim());
    if (letta == null || !mounted) return;
    setState(() {
      _dalCodice = letta;
      if (_nome.text.trim().isEmpty) _nome.text = letta.nome;
      if (_legame == Legame.amore && !_amoreApribile) _legame = null;
    });
  }

  void _scegliIlLegame(Legame l) {
    setState(() => _legame = l);
  }

  Future<void> _invitaAllaLunga() {
    final dal = PlanCatalog.dalPiano(
            (t) => PlanCatalog.apre(RigaDelPiano.sinastriaLunga, t)) ??
        'Dal piano superiore';
    return showUpgradeInvite(
      context,
      title: 'La lettura Lunga si apre ${dal[0].toLowerCase()}'
          '${dal.substring(1)}',
      message: 'Con la Lunga il primo capitolo della vostra sinastria porta '
          'due paragrafi in più: il contatto che lo approfondisce e il filo '
          'del vostro cielo comune.',
    );
  }

  CieloEvolutivo _cielo() {
    final c = _dalCodice;
    if (c != null) return c.cielo;
    final data = _data!;
    final oraNota = !_oraNonNota && _ora != null;
    // La stessa convenzione del modulo "La sua nascita" (FT.03): l'ora
    // scritta come istante universale, mezzogiorno se non si sa.
    return CieloEvolutivo.perNascita(
      momentoUtc: DateTime.utc(data.year, data.month, data.day,
          oraNota ? _ora!.hour : 12, oraNota ? _ora!.minute : 0),
      oraNota: oraNota,
      nome: _nome.text.trim(),
      giornoDiNascita: DateTime(data.year, data.month, data.day),
    );
  }

  Future<void> _scopri() async {
    if (!_pronto) return;
    final nome = _nome.text.trim();
    final navigatore = Navigator.of(context);
    if (_nuovaOffline && _dalCodice == null && _data != null) {
      // **LA PERSONA NUOVA ENTRA NELLA LISTA DI TUTTI** (GD.20): la stessa
      // dell'Oroscopo, se il piano la tiene; se no la lettura si fa lo
      // stesso e la riga nel modulo l'ha detto prima.
      await _amici.aggiungi(
          Amico(
            id: 'a${DateTime.now().microsecondsSinceEpoch}',
            nome: nome,
            nascita: _data!,
            ora: _oraNonNota || _ora == null
                ? null
                : '${_ora!.hour.toString().padLeft(2, '0')}:'
                    '${_ora!.minute.toString().padLeft(2, '0')}',
          ),
          widget.tier);
    }
    navigatore.pop(SceltaDellaSinastria(
      nome: nome,
      cielo: _cielo(),
      legame: _legame!,
      profondita: _profondita,
      amoreDalServer: _dalCodice?.amoreDalServer,
      uidDelCerchio: _uidDelCerchio,
    ));
  }

  // --- Le parti ------------------------------------------------------------

  TextStyle get _titolo =>
      TypographyTokens.titoloScheda().copyWith(color: _p.goldSoft);
  TextStyle get _etichetta => TypographyTokens.etichetta()
      .copyWith(color: _p.goldSoft, letterSpacing: 1.6);
  TextStyle get _valore =>
      TypographyTokens.lettura().copyWith(color: ColorTokens.textPrimary);
  TextStyle get _nota =>
      TypographyTokens.didascalia().copyWith(color: ColorTokens.textSecondary);

  Widget _testata(String titolo, {bool indietro = true}) {
    return Row(
      children: [
        if (indietro)
          IconButton(
            key: const Key('sinastria_tendina_indietro'),
            tooltip: 'Indietro',
            icon: Icon(Icons.arrow_back_rounded, color: _p.goldSoft),
            onPressed: _indietro,
          )
        else
          const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Text(titolo,
              key: const Key('sinastria_tendina_titolo'),
              style: _titolo,
              textAlign: indietro ? TextAlign.start : TextAlign.center),
        ),
        if (!indietro) const SizedBox(width: SpacingTokens.sm),
      ],
    );
  }

  Widget _voce({
    required Key chiave,
    required String titolo,
    required String sotto,
    required IconData icona,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: chiave,
          enableFeedback: false,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          onTap: onTap,
          child: RiquadroInEvidenza(
            palette: _p,
            child: Row(
              children: [
                Icon(icona, color: _p.goldSoft, size: 28),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titolo, style: _titolo),
                      const SizedBox(height: SpacingTokens.xxs),
                      Text(sotto, style: _nota),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _p.goldSoft),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _laScelta() {
    return Column(
      key: const Key('sinastria_tendina_scelta'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _testata('Dove trovi la persona?', indietro: false),
        const SizedBox(height: SpacingTokens.xs),
        Text(
            'Scegli una strada: poi scrivi o controlli la sua nascita e '
            'Medora legge i vostri due cieli.',
            textAlign: TextAlign.center,
            style: _nota),
        const SizedBox(height: SpacingTokens.md),
        _voce(
          chiave: const Key('sinastria_tendina_online'),
          titolo: 'Online',
          sotto: 'Un amico del tuo Cerchio su Esoteric Circle.',
          icona: Icons.people_alt_rounded,
          onTap: () => unawaited(_vaiOnline()),
        ),
        _voce(
          chiave: const Key('sinastria_tendina_offline'),
          titolo: 'Offline',
          sotto: 'Un amico che hai già salvato, o una persona nuova.',
          icona: Icons.person_rounded,
          onTap: () => setState(() => _passo = _Passo.offline),
        ),
      ],
    );
  }

  Widget _online() {
    final s = _sociale;
    final amici = s?.cerchio.amici ?? const <PersonaDelCerchio>[];
    final chiuso = s?.chiusoPerEta ?? false;
    return Column(
      key: const Key('sinastria_tendina_elenco_online'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _testata('I tuoi amici del Cerchio'),
        const SizedBox(height: SpacingTokens.sm),
        if (_caricandoIlCerchio)
          Text('Un momento, apro il tuo Cerchio.', style: _nota)
        else if (chiuso)
          Text(IlCerchioSociale.rigaDeiQuattordici,
              key: const Key('sinastria_tendina_cerchio_chiuso'), style: _nota)
        else if (amici.isEmpty) ...[
          Text('Non hai ancora amici nel Cerchio.',
              key: const Key('sinastria_tendina_online_vuoto'), style: _valore),
          const SizedBox(height: SpacingTokens.xxs),
          Text(
              'Vuoi invitarli? Quando entrano nel tuo Cerchio li trovi qui: '
              'la vostra lettura arriva anche a loro.',
              style: _nota),
          const SizedBox(height: SpacingTokens.md),
          PulsanteDipinto(
            key: const Key('sinastria_tendina_invita'),
            testo: 'Invita nel Cerchio',
            larghezzaPiena: true,
            // La freccia indietro dell'invito riporta qui, nella tendina:
            // la rotta si apre sopra di lei e non la chiude (GD.14).
            onTap: () =>
                Navigator.of(context).push(InvitaNelCerchioScreen.route()),
          ),
        ] else
          for (final a in amici)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: Key('sinastria_tendina_amico_${a.uid}'),
                  enableFeedback: false,
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                  onTap: () =>
                      _alModulo(da: _Passo.online, nome: a.nome, uid: a.uid),
                  child: RiquadroInEvidenza(
                    palette: _p,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.nome, style: _titolo),
                              if (a.segno != null)
                                Text(a.segno!.italianName, style: _nota),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: _p.goldSoft),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _offline() {
    final amici = _amici.tutti;
    return Column(
      key: const Key('sinastria_tendina_elenco_offline'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _testata('I tuoi amici offline'),
        const SizedBox(height: SpacingTokens.xs),
        Text(
            amici.isEmpty
                ? 'Non hai ancora salvato nessun amico. Scrivi la nascita di '
                    'una persona nuova.'
                : 'Gli stessi amici dell\'Oroscopo: tocca un nome, oppure '
                    'scrivi una persona nuova.',
            style: _nota),
        const SizedBox(height: SpacingTokens.sm),
        for (final a in amici)
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: Key('sinastria_tendina_offline_${a.id}'),
                enableFeedback: false,
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                onTap: () => _alModulo(
                  da: _Passo.offline,
                  nome: a.nome,
                  data: a.nascita,
                  ora: a.ora == null
                      ? null
                      : TimeOfDay(
                          hour: int.parse(a.ora!.split(':')[0]),
                          minute: int.parse(a.ora!.split(':')[1])),
                ),
                child: RiquadroInEvidenza(
                  palette: _p,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.nome, style: _titolo),
                            Text(a.segno.italianName, style: _nota),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: _p.goldSoft),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: SpacingTokens.xs),
        PulsanteDipinto(
          key: const Key('sinastria_tendina_nuovo'),
          testo: 'Una persona nuova',
          larghezzaPiena: true,
          onTap: () => _alModulo(da: _Passo.offline, nuova: true),
        ),
      ],
    );
  }

  String _laData(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _campo({
    required Key chiave,
    required String etichetta,
    required String valore,
    required bool vuoto,
    required IconData icona,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: chiave,
        enableFeedback: false,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        onTap: onTap,
        child: RiquadroInEvidenza(
          palette: _p,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(etichetta.toUpperCase(), style: _etichetta),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(valore,
                        style: vuoto
                            ? _valore.copyWith(
                                color: ColorTokens.textSecondary,
                                fontStyle: FontStyle.italic)
                            : _valore),
                  ],
                ),
              ),
              Icon(icona, color: _p.goldSoft),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iLegami() {
    return Row(
      key: const Key('sinastria_modulo_legami'),
      children: [
        for (final l in Legame.values)
          Expanded(
            child: Semantics(
              button: true,
              selected: l == _legame,
              label: l.nome,
              child: GestureDetector(
                key: Key('sinastria_legame_${l.name}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => _scegliIlLegame(l),
                child: Opacity(
                  opacity: l == Legame.amore && !_amoreApribile ? 0.4 : 1,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color:
                                  l == _legame ? _p.gold : Colors.transparent,
                              width: 3),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                              immagineDellaSinastria('legame_${l.name}_v1'),
                              width: 60,
                              height: 60),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xxs),
                      Text(l.nome,
                          style: _etichetta.copyWith(
                              letterSpacing: 0.4,
                              color: l == _legame
                                  ? _p.goldSoft
                                  : ColorTokens.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _ilModulo() {
    final codice = _dalCodice;
    final nuovaFuoriLista =
        _nuovaOffline && codice == null && !_amici.siPuoAggiungere(widget.tier);
    return Column(
      key: const Key('sinastria_modulo'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _testata('La sua nascita'),
        const SizedBox(height: SpacingTokens.xs),
        Text(
            'Medora legge il tuo cielo e il suo: scrivi chi è e quando è '
            'nato, poi scegli il vostro legame.',
            style: _nota),
        const SizedBox(height: SpacingTokens.md),
        RiquadroInEvidenza(
          palette: _p,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('IL SUO NOME', style: _etichetta),
              TextField(
                key: const Key('sinastria_modulo_nome'),
                controller: _nome,
                style: _valore,
                textCapitalization: TextCapitalization.words,
                cursorColor: _p.goldSoft,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Come si chiama',
                  hintStyle: _valore.copyWith(
                      color: ColorTokens.textSecondary,
                      fontStyle: FontStyle.italic),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        if (codice != null)
          RiquadroInEvidenza(
            palette: _p,
            child: Text(
                'La nascita di ${codice.nome.isEmpty ? 'questa persona' : codice.nome} '
                'è arrivata dal suo telefono, per questa lettura.',
                key: const Key('sinastria_modulo_dal_codice'),
                style: _valore),
          )
        else ...[
          _campo(
            chiave: const Key('sinastria_modulo_data'),
            etichetta: 'Data di nascita',
            valore: _data == null ? 'Tocca per sceglierla' : _laData(_data!),
            vuoto: _data == null,
            icona: Icons.calendar_today_rounded,
            onTap: _scegliData,
          ),
          const SizedBox(height: SpacingTokens.sm),
          Opacity(
            opacity: _oraNonNota ? 0.45 : 1,
            child: _campo(
              chiave: const Key('sinastria_modulo_ora'),
              etichetta: 'Ora di nascita',
              valore: _oraNonNota
                  ? 'Non la conosci: la Luna tace'
                  : _ora == null
                      ? 'Tocca per sceglierla'
                      : '${_ora!.hour.toString().padLeft(2, '0')}:'
                          '${_ora!.minute.toString().padLeft(2, '0')}',
              vuoto: _ora == null || _oraNonNota,
              icona: Icons.access_time_rounded,
              onTap: _oraNonNota ? null : _scegliOra,
            ),
          ),
          InterruttoreDelCerchio(
            key: const Key('sinastria_modulo_ora_non_nota'),
            titolo: 'Non conosco l\'ora di nascita',
            acceso: _oraNonNota,
            onCambia: (v) => setState(() => _oraNonNota = v),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('sinastria_modulo_codice'),
              style: TextButton.styleFrom(
                  foregroundColor: _p.goldSoft, padding: EdgeInsets.zero),
              onPressed: _leggiIlCodice,
              child: Text('Hai un codice dal suo telefono?',
                  style: _nota.copyWith(color: _p.goldSoft)),
            ),
          ),
        ],
        if (nuovaFuoriLista)
          Text(
              'Col tuo piano questa persona non resta fra i tuoi amici: la '
              'lettura si fa lo stesso.',
              key: const Key('sinastria_modulo_fuori_lista'),
              style: _nota),
        const SizedBox(height: SpacingTokens.md),
        Text('IL VOSTRO LEGAME', style: _etichetta),
        const SizedBox(height: SpacingTokens.xxs),
        Text('Uno solo: per un altro legame si fa una sinastria nuova.',
            style: _nota),
        const SizedBox(height: SpacingTokens.sm),
        _iLegami(),
        if (!_amoreApribile) ...[
          const SizedBox(height: SpacingTokens.xs),
          // **UNA RIGA SOBRIA, senza spiegazioni sull'eta' dell'altra
          // persona** (FT.04).
          Text('Il legame amore si apre dai sedici anni.',
              key: const Key('sinastria_amore_chiuso'),
              textAlign: TextAlign.center,
              style: _nota),
        ],
        const SizedBox(height: SpacingTokens.md),
        TendinaSelettore<ProfonditaDellaSinastria>(
          chiave: const Key('sinastria_profondita'),
          titolo: 'Profondità della lettura',
          corrente: _profondita,
          voci: ProfonditaDellaSinastria.values,
          palette: _p,
          etichetta: (d) => d.etichetta,
          bloccata: (d) => d == ProfonditaDellaSinastria.lunga && !_lungaAperta,
          perche: (d) =>
              PlanCatalog.dalPiano(
                  (t) => PlanCatalog.apre(RigaDelPiano.sinastriaLunga, t)) ??
              'Coming soon',
          onSelect: (d) => setState(() => _profondita = d),
          onLocked: (_) => unawaited(_invitaAllaLunga()),
        ),
        const SizedBox(height: SpacingTokens.lg),
        PulsanteDipinto(
          key: const Key('sinastria_scopri'),
          testo: 'Scopri la compatibilità',
          larghezzaPiena: true,
          onTap: _pronto ? () => unawaited(_scopri()) : null,
        ),
        if (!_pronto) ...[
          const SizedBox(height: SpacingTokens.xs),
          Text(
              !_datiCompleti
                  ? 'Scrivi il nome, la data e l\'ora di nascita per accendere '
                      'il pulsante.'
                  : 'Scegli il vostro legame per accendere il pulsante.',
              key: const Key('sinastria_scopri_spento'),
              textAlign: TextAlign.center,
              style: _nota),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final alta = MediaQuery.sizeOf(context).height * 0.86;
    final Widget passo = switch (_passo) {
      _Passo.scelta => _laScelta(),
      _Passo.online => _online(),
      _Passo.offline => _offline(),
      _Passo.modulo => _ilModulo(),
    };
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: alta),
      child: SingleChildScrollView(
        key: const Key('sinastria_tendina'),
        padding: EdgeInsets.fromLTRB(
            SpacingTokens.lg,
            SpacingTokens.md,
            SpacingTokens.lg,
            MediaQuery.viewInsetsOf(context).bottom + SpacingTokens.lg),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(key: ValueKey(_passo), child: passo),
        ),
      ),
    );
  }
}
