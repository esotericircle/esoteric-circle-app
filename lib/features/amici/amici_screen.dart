import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/amici/amici_offline.dart';
import '../../core/astro/city_catalog.dart';
import '../../core/astro/ricerca_del_luogo.dart';
import '../../core/astro/zodiac.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/lang/euphonic.dart';
import '../../core/entitlement/listino_degli_eos.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/entitlement/tier.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/porta_della_spesa.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../pricing/upgrade_invite.dart';
import 'l_oroscopo_dell_amico_screen.dart';

/// **GLI AMICI OFFLINE, ordine ES voce 12.**
///
/// Il fondatore: *"l'utente premium potrà inserire data e ora di nascita
/// dell'amico, scegliere la tipologia di oroscopo, scoprire il segno
/// corrispondete e creare l'oroscopo e con la condivisione inviarlo
/// all'amico"*; *"l'utente free non può fare orsocopo per amici, lo vede e se
/// fa click, viene invitato a sottoscrivere abbonamento"*.
class AmiciScreen extends StatefulWidget {
  const AmiciScreen({super.key, this.amici, this.perScegliere = false});

  /// Il contenitore, per le prove; nell'app se ne crea uno e si carica.
  final AmiciOffline? amici;

  /// **PER SCEGLIERE**, ordine EU voce 05: aperta dal selettore "Oroscopo
  /// per", il tocco su un amico torna all'Oroscopo con l'amico scelto,
  /// invece di aprire da qui la sua lettura.
  final bool perScegliere;

  /// **VESTITA DA MEDORA**, come il Calendario: l'oroscopo e' suo, e lo
  /// scope neutro sopra il Navigator e' solo il pavimento. Senza, l'invito
  /// al piano e la porta della spesa prenderebbero il viola del Cerchio.
  ///
  /// **DAL PASSAGGIO DEL CERCHIO**, come ogni schermata (ordine CC voce 04):
  /// la prima stesura costruiva la rotta da se', e la suite l'ha presa.
  static Route<Amico?> route({bool perScegliere = false}) =>
      PassaggioDelCerchio.rotta<Amico?>((_) => MaestroScope(
          maestro: Maestro.medora,
          child: AmiciScreen(perScegliere: perScegliere)));

  @override
  State<AmiciScreen> createState() => _AmiciScreenState();
}

class _AmiciScreenState extends State<AmiciScreen> {
  late final AmiciOffline _amici = widget.amici ?? AmiciOffline();

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
    super.dispose();
  }

  void _invita() {
    final piano = PlanCatalog.forTier(Tier.tier1).name;
    showUpgradeInvite(
      context,
      title: 'L\'oroscopo per gli amici si apre ${conPiano(piano)}',
      message: 'Inserisci il nome e la nascita di chi ti sta a cuore, scopri '
          'il suo segno nelle tre tradizioni e mandagli il suo oroscopo del '
          'giorno.',
    );
  }

  Future<void> _aggiungi(Tier tier) async {
    final nuovo = await foglioDelCerchio<Amico>(
      context: context,
      isScrollControlled: true,
      // Il fondo dichiarato, ordine AL voce 04: il foglio si veste di Medora.
      backgroundColor:
          MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)).deepest,
      builder: (_) => const _FoglioDellAmico(),
    );
    if (nuovo == null || !mounted) return;
    await _amici.aggiungi(nuovo, tier);
  }

  Future<void> _togli(Amico a) async {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final si = await dialogoDelCerchio<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('amici_togli_dialogo'),
        backgroundColor: palette.deepest,
        title: Text('Togliere ${a.nome}?',
            style: TypographyTokens.cerimoniale()
                .copyWith(color: palette.goldSoft)),
        content: Text('I suoi dati di nascita escono dal telefono.',
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('No', style: TextStyle(color: palette.goldSoft)),
          ),
          TextButton(
            key: const Key('amici_togli_si'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Togli', style: TextStyle(color: palette.goldSoft)),
          ),
        ],
      ),
    );
    if (si == true) await _amici.togli(a.id);
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final tier = context.watch<EntitlementService>().tier;
    final posti = _amici.posti(tier);
    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: Text('I tuoi amici',
            style: TypographyTokens.titoloDiSchermata()
                .copyWith(color: palette.goldSoft)),
      ),
      body: ListView(
        key: const Key('amici_lista'),
        padding: const EdgeInsets.all(SpacingTokens.lg),
        children: [
          Text(
              'Il nome e la nascita di chi ti sta a cuore: scopri il suo segno '
              'nelle tre tradizioni e mandagli il suo oroscopo del giorno. I '
              'dati restano sul tuo telefono.',
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
          const SizedBox(height: SpacingTokens.lg),
          if (tier == Tier.free) ...[
            _Bottone(
              chiave: const Key('amici_invito_al_piano'),
              etichetta: 'Aggiungi un amico',
              palette: palette,
              onTap: _invita,
            ),
          ] else ...[
            for (final a in _amici.tutti)
              Card(
                color: palette.surfaceElevated.withValues(alpha: 0.8),
                child: ListTile(
                  key: Key('amico_${a.id}'),
                  enableFeedback: false,
                  title: Text(a.nome,
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: palette.goldSoft)),
                  subtitle: Text(
                      '${Zodiac.fromDate(a.nascita).italianName}, nascita del '
                      '${a.nascita.day}/${a.nascita.month}/${a.nascita.year}',
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                  trailing: IconButton(
                    tooltip: 'Togli',
                    icon: Icon(Icons.delete_outline_rounded,
                        color: palette.goldSoft),
                    onPressed: () => _togli(a),
                  ),
                  onTap: () => widget.perScegliere
                      ? Navigator.of(context).pop(a)
                      : Navigator.of(context)
                          .push(LOroscopoDellAmicoScreen.route(a)),
                ),
              ),
            const SizedBox(height: SpacingTokens.md),
            Text(
                posti == null
                    ? 'Col tuo piano gli amici non hanno limite.'
                    : _amici.tutti.length > posti
                        // **CHI NE HA GIA' DI PIU' NON LE PERDE**, ordine EZ
                        // voce 06: cancellare i dati di una persona per un
                        // limite nuovo sarebbe un danno che nessun limite
                        // giustifica. Le tiene tutte e non ne aggiunge.
                        ? 'Hai ${_amici.tutti.length} amici, oltre i $posti '
                            'del tuo piano: restano tutti, ma non se ne '
                            'aggiungono altri.'
                        : 'Amici ${_amici.tutti.length} su $posti.',
                key: const Key('amici_posti'),
                textAlign: TextAlign.center,
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
            const SizedBox(height: SpacingTokens.sm),
            if (_amici.siPuoAggiungere(tier))
              _Bottone(
                chiave: const Key('amici_aggiungi'),
                etichetta: 'Aggiungi un amico',
                palette: palette,
                onTap: () => _aggiungi(tier),
              )
            // Oltre il numero del piano un posto comprato non basterebbe a
            // far entrare nessuno: niente spesa che non porta a niente.
            else if (posti == null || _amici.tutti.length <= posti)
              PortaDellaSpesa(
                voce: ListinoDegliEos.amicoInPiu,
                etichetta: 'Un posto in più',
                suSpesaFatta: () => unawaited(_amici.unPostoInPiu()),
              ),
          ],
        ],
      ),
    );
  }
}

class _Bottone extends StatelessWidget {
  const _Bottone(
      {required this.chiave,
      required this.etichetta,
      required this.palette,
      required this.onTap});

  final Key chiave;
  final String etichetta;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: chiave,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
      ),
      onPressed: onTap,
      icon: Icon(Icons.person_add_alt_1_rounded, color: palette.goldSoft),
      label: Text(etichetta,
          style: TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
    );
  }
}

/// Il foglio per aggiungere un amico: nome e data sempre, ora e luogo se si
/// sanno.
class _FoglioDellAmico extends StatefulWidget {
  const _FoglioDellAmico();

  @override
  State<_FoglioDellAmico> createState() => _FoglioDellAmicoState();
}

class _FoglioDellAmicoState extends State<_FoglioDellAmico> {
  final _nome = TextEditingController();
  final _dove = TextEditingController();
  DateTime? _data;
  TimeOfDay? _ora;
  City? _citta;
  List<City> _risultati = const [];

  /// **TUTTO IL MONDO ANCHE PER L'AMICO**, il fondatore il 1 ottobre 2026:
  /// *"il campo di ricerca del luogo di nascita funziona male e non ci sono
  /// tutte le città, paesi, villaggi, borgo del mondo"*. Qui la ricerca si
  /// fermava al catalogo offline: adesso chiede al mondo (OpenStreetMap, dal
  /// server) come il rito dell'accoglienza e i dati di nascita.
  final RicercaNelMondo _nelMondo = RicercaNelMondo();

  @override
  void dispose() {
    _nelMondo.chiudi();
    _nome.dispose();
    _dove.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final pronto = _nome.text.trim().isNotEmpty && _data != null;
    final stile = TypographyTokens.corpo()
        .copyWith(color: ColorTokens.textPrimary, height: 1.3);
    return Padding(
      padding: EdgeInsets.only(
          left: SpacingTokens.lg,
          right: SpacingTokens.lg,
          top: SpacingTokens.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + SpacingTokens.lg),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Un amico',
                style: TypographyTokens.cerimoniale()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.md),
            TextField(
              key: const Key('amico_nome'),
              controller: _nome,
              style: stile,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Come si chiama'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SpacingTokens.sm),
            OutlinedButton(
              key: const Key('amico_data'),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990, 1, 1),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _data = d);
              },
              child: Text(
                  _data == null
                      ? 'La data di nascita'
                      : 'Nascita del ${_data!.day}/${_data!.month}/${_data!.year}',
                  style: stile),
            ),
            const SizedBox(height: SpacingTokens.sm),
            OutlinedButton(
              key: const Key('amico_ora'),
              onPressed: () async {
                final o = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 12, minute: 0));
                if (o != null) setState(() => _ora = o);
              },
              child: Text(
                  _ora == null
                      ? 'L\'ora di nascita, se la sai'
                      : 'Alle ${_ora!.hour.toString().padLeft(2, '0')}:'
                          '${_ora!.minute.toString().padLeft(2, '0')}',
                  style: stile),
            ),
            const SizedBox(height: SpacingTokens.sm),
            TextField(
              key: const Key('amico_luogo'),
              controller: _dove,
              style: stile,
              decoration: const InputDecoration(
                  labelText: 'Il luogo di nascita, se lo sai'),
              onChanged: (q) {
                final r = RicercaDelLuogo.per(q);
                setState(() {
                  _risultati = r.risultati.take(5).toList();
                  _citta = r.scelta;
                });
                _nelMondo.chiedi(
                  q,
                  gia: r.risultati,
                  quando: (trovati) {
                    if (!mounted || trovati.isEmpty) return;
                    setState(() => _risultati = RicercaNelMondo.unisci(
                            r.risultati.take(5).toList(), trovati)
                        .take(8)
                        .toList());
                  },
                );
              },
            ),
            for (final c in _risultati)
              ListTile(
                enableFeedback: false,
                dense: true,
                title: Text(c.label, style: stile),
                onTap: () => setState(() {
                  _citta = c;
                  _dove.text = c.label;
                  _risultati = const [];
                }),
              ),
            const SizedBox(height: SpacingTokens.md),
            FilledButton(
              key: const Key('amico_salva'),
              onPressed: !pronto
                  ? null
                  : () => Navigator.of(context).pop(Amico(
                        id: 'a${DateTime.now().microsecondsSinceEpoch}',
                        nome: _nome.text.trim(),
                        nascita: _data!,
                        ora: _ora == null
                            ? null
                            : '${_ora!.hour.toString().padLeft(2, '0')}:'
                                '${_ora!.minute.toString().padLeft(2, '0')}',
                        luogo: _citta?.label,
                        lat: _citta?.latitude,
                        lon: _citta?.longitude,
                        fuso: _citta?.timeZoneId,
                      )),
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }
}
