import 'package:flutter/material.dart';

import '../../core/synastry_approfondita/cielo_approfondito.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// **LA NASCITA DELL'ALTRA PERSONA, INSERITA A MANO.** Ordine FT voce
/// FT.03, 14 ottobre 2026: "la persona puo' inserire a mano la nascita
/// dell'altra". Questa e' la strada semplice, sempre disponibile: nessun
/// consenso da chiedere, perche' e' chi compila a dichiarare di conoscere
/// quella data (come gia' avviene per gli "amici offline",
/// `lib/core/amici/amici_offline.dart`, che il progetto gia' tratta come
/// schede senza consenso della persona descritta).
///
/// **L'ORA SCONOSCIUTA SI DICHIARA, non si indovina.** Con l'interruttore
/// spento il momento si ancora a mezzogiorno (stessa convenzione di
/// `BirthIdentity`, vedi `CieloApprofondito.perNascita`), e la schermata
/// che mostra la lettura sa che l'ora non e' nota.
class LaNascitaDellAltraPersona extends StatefulWidget {
  const LaNascitaDellAltraPersona(
      {super.key, required this.palette, this.nomeIniziale});

  final MaestroPalette palette;

  /// Il nome gia' noto (l'amico del segno 15 o del confronto del cielo):
  /// riempie solo il campo del nome, mai la nascita.
  final String? nomeIniziale;

  /// Apre la schermata e aspetta il nome e il cielo, o nullo se annullato.
  static Future<({String nome, CieloApprofondito cielo})?> chiedi(
      BuildContext context, MaestroPalette palette,
      {String? nomeIniziale}) {
    return Navigator.of(context).push<({String nome, CieloApprofondito cielo})>(
      PassaggioDelCerchio.rotta(
        (_) => LaNascitaDellAltraPersona(
            palette: palette, nomeIniziale: nomeIniziale),
      ),
    );
  }

  @override
  State<LaNascitaDellAltraPersona> createState() =>
      _LaNascitaDellAltraPersonaState();
}

class _LaNascitaDellAltraPersonaState extends State<LaNascitaDellAltraPersona> {
  late final _nome = TextEditingController(text: widget.nomeIniziale ?? '');
  DateTime? _data;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  TimeOfDay? _ora;
  bool _oraNonNota = false;

  bool get _pronto => _nome.text.trim().isNotEmpty && _data != null;

  Future<void> _scegliData() async {
    final adesso = DateTime.now();
    final scelta = await showDatePicker(
      context: context,
      initialDate: _data ?? DateTime(adesso.year - 25),
      firstDate: DateTime(1900),
      lastDate: adesso,
    );
    if (scelta != null) setState(() => _data = scelta);
  }

  Future<void> _scegliOra() async {
    final scelta = await showTimePicker(
      context: context,
      initialTime: _ora ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (scelta != null) setState(() => _ora = scelta);
  }

  void _conferma() {
    final data = _data;
    if (!_pronto || data == null) return;
    final oraNota = !_oraNonNota && _ora != null;
    final momento = DateTime.utc(
      data.year,
      data.month,
      data.day,
      oraNota ? _ora!.hour : 12,
      oraNota ? _ora!.minute : 0,
    );
    final cielo = CieloApprofondito.perNascita(
      momentoUtc: momento,
      oraNota: oraNota,
      nome: _nome.text.trim(),
      giornoDiNascita: DateTime(data.year, data.month, data.day),
    );
    Navigator.of(context).pop((nome: _nome.text.trim(), cielo: cielo));
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        backgroundColor: palette.deepest,
        iconTheme: IconThemeData(color: palette.goldSoft),
        // Il titolo lungo si troncava a 360 punti, e con la freccia
        // indietro ancora di piu' (anteprima ft03, 14 ottobre 2026).
        title: TitoloCheNonSiRompe(
            chiaveDelTesto: const Key('nascita_altra_titolo'),
            testo: 'La sua nascita',
            righe: 1,
            stile: TypographyTokens.titoloSezione()
                .copyWith(color: palette.goldSoft)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('nascita_altra_nome'),
              controller: _nome,
              decoration: const InputDecoration(labelText: 'Il suo nome'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SpacingTokens.lg),
            ListTile(
              key: const Key('nascita_altra_data'),
              contentPadding: EdgeInsets.zero,
              title: Text(_data == null
                  ? 'Scegli la data di nascita'
                  : '${_data!.day}/${_data!.month}/${_data!.year}'),
              trailing: const Icon(Icons.calendar_today_rounded),
              onTap: _scegliData,
            ),
            SwitchListTile(
              key: const Key('nascita_altra_ora_non_nota'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Non conosco l\'ora di nascita'),
              value: _oraNonNota,
              onChanged: (v) => setState(() => _oraNonNota = v),
            ),
            if (!_oraNonNota)
              ListTile(
                key: const Key('nascita_altra_ora'),
                contentPadding: EdgeInsets.zero,
                title: Text(_ora == null
                    ? 'Scegli l\'ora (se la conosci)'
                    : _ora!.format(context)),
                trailing: const Icon(Icons.access_time_rounded),
                onTap: _scegliOra,
              ),
            const Spacer(),
            FilledButton(
              key: const Key('nascita_altra_conferma'),
              onPressed: _pronto ? _conferma : null,
              style: FilledButton.styleFrom(backgroundColor: palette.goldSoft),
              child: const Text('Continua'),
            ),
          ],
        ),
      ),
    );
  }
}
