import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/synastry_evolutiva/cielo_evolutivo.dart';
import '../../design_system/components/interruttore_del_cerchio.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'la_tua_nascita_per_una_lettura.dart';

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
/// `BirthIdentity`, vedi `CieloEvolutivo.perNascita`), e la schermata
/// che mostra la lettura sa che l'ora non e' nota.
///
/// **LA LETTURA A DUE TELEFONI**, la seconda strada di FT.03: chi ti sta
/// accanto apre "La tua nascita" (`LaTuaNascitaPerUnaLettura`), da' il
/// consenso e ti detta il codice; qui lo scrivi e la sua nascita arriva dal
/// server, una volta sola. Il server dice anche se il legame amore si apre
/// (`amoreDalServer`, il secondo controllo dell'eta' di FT.04). Senza rete o
/// con la porta non ancora pubblicata la riga lo dice, e la strada a mano
/// resta sotto: mai un vicolo cieco.
///
/// **LO STESSO GESTO PER L'ORACOLO DEGLI ANGELI**, ordine FU voce FU.09: con
/// `perLOracolo` resta la sola strada del codice, perche' per la domanda di
/// un amico la sua nascita passa solo col suo consenso esplicito; il codice
/// si legge solo se e' stato dato per l'Oracolo, e porta il minuto locale
/// della nascita ([minutoLocale]) per l'Angelo dell'Intelletto.
///
/// **LO STESSO GESTO PER "TROVA IL GIORNO INSIEME"**, ordine FV voce FV.10:
/// con `perLoLunario` vale la stessa regola, e il codice si legge solo se
/// e' stato dato per il Lunario. [NascitaLetta] porta anche [nascitaUtc] e
/// [giornoDiNascita], grezzi: il Calendario Lunare costruisce la sua
/// `BirthIdentity` da li', perche' `CieloEvolutivo` (pensato per la
/// Sinastria) non la contiene.
typedef NascitaLetta = ({
  String nome,
  CieloEvolutivo cielo,
  bool? amoreDalServer,
  int? minutoLocale,
  DateTime nascitaUtc,
  DateTime giornoDiNascita,
});

class LaNascitaDellAltraPersona extends StatefulWidget {
  const LaNascitaDellAltraPersona(
      {super.key,
      required this.palette,
      this.nomeIniziale,
      this.perLOracolo = false,
      this.perLoLunario = false});

  final MaestroPalette palette;

  /// Vero per la domanda all'Oracolo degli Angeli per un amico: solo il
  /// codice, mai la nascita scritta a mano (ordine FU voce FU.09).
  final bool perLOracolo;

  /// Vero per "Trova il giorno insieme" del Calendario Lunare: solo il
  /// codice, mai la nascita scritta a mano (ordine FV voce FV.10).
  final bool perLoLunario;

  /// Il nome gia' noto (l'amico del segno 15 o del confronto del cielo):
  /// riempie solo il campo del nome, mai la nascita.
  final String? nomeIniziale;

  /// Apre la schermata e aspetta il nome e il cielo, o nullo se annullato.
  static Future<NascitaLetta?> chiedi(
      BuildContext context, MaestroPalette palette,
      {String? nomeIniziale,
      bool perLOracolo = false,
      bool perLoLunario = false}) {
    return Navigator.of(context).push<NascitaLetta>(
      PassaggioDelCerchio.rotta(
        (_) => LaNascitaDellAltraPersona(
            palette: palette,
            nomeIniziale: nomeIniziale,
            perLOracolo: perLOracolo,
            perLoLunario: perLoLunario),
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

  final _codice = TextEditingController();
  bool _leggendo = false;
  String? _rigaDelCodice;

  @override
  void dispose() {
    _nome.dispose();
    _codice.dispose();
    super.dispose();
  }

  T? _forse<T>() {
    try {
      return context.read<T>();
    } catch (senzaProvider) {
      debugPrint('La sua nascita: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }

  Future<void> _leggiIlCodice() async {
    final codice = _codice.text.trim();
    if (codice.isEmpty) return;
    final sociale = _forse<IlCerchioSociale>();
    final mia = _forse<ProfileController>()?.identity;
    if (sociale == null || mia == null) {
      setState(() => _rigaDelCodice = EsitoDelGesto.silenzio.riga);
      return;
    }
    setState(() {
      _leggendo = true;
      _rigaDelCodice = null;
    });
    final esito = await sociale.leggiLaNascita(codice,
        giornoMio: DateTime(
            mia.birthMoment.year, mia.birthMoment.month, mia.birthMoment.day),
        perLOracolo: widget.perLOracolo,
        perLoLunario: widget.perLoLunario);
    if (!mounted) return;
    final d = esito.dati;
    final nascita = DateTime.tryParse('${d['nascita']}');
    final giorno = DateTime.tryParse('${d['giorno']}');
    if (!esito.ok || nascita == null || giorno == null) {
      setState(() {
        _leggendo = false;
        _rigaDelCodice =
            esito.ok ? EsitoDelGesto.silenzio.riga : esito.rigaPerLaPersona;
      });
      return;
    }
    final nomeDato = _nome.text.trim();
    final nome = nomeDato.isNotEmpty ? nomeDato : '${d['nome'] ?? ''}'.trim();
    final cielo = CieloEvolutivo.perNascita(
      momentoUtc: nascita.toUtc(),
      oraNota: d['oraNota'] == true,
      nome: nome,
      giornoDiNascita: DateTime(giorno.year, giorno.month, giorno.day),
    );
    final minuto = d['minutoLocale'];
    Navigator.of(context).pop((
      nome: nome,
      cielo: cielo,
      amoreDalServer: d['amoreApribile'] == true,
      minutoLocale:
          minuto is num && d['oraNota'] == true ? minuto.toInt() : null,
      nascitaUtc: nascita.toUtc(),
      giornoDiNascita: DateTime(giorno.year, giorno.month, giorno.day),
    ));
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
    final cielo = CieloEvolutivo.perNascita(
      momentoUtc: momento,
      oraNota: oraNota,
      nome: _nome.text.trim(),
      giornoDiNascita: DateTime(data.year, data.month, data.day),
    );
    Navigator.of(context).pop((
      nome: _nome.text.trim(),
      cielo: cielo,
      amoreDalServer: null,
      minutoLocale: null,
      nascitaUtc: momento,
      giornoDiNascita: DateTime(data.year, data.month, data.day),
    ));
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                children: [
                  Text('Hai un codice?',
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.xxs),
                  Text(
                      'Chi ti è accanto apre «La tua nascita» sul suo telefono e ti '
                      'detta il codice: la sua nascita vera arriva qui, per una '
                      'lettura sola.',
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('nascita_altra_codice'),
                          controller: _codice,
                          textCapitalization: TextCapitalization.characters,
                          decoration:
                              const InputDecoration(labelText: 'Il codice'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      TextButton(
                        key: const Key('nascita_altra_leggi'),
                        style: TextButton.styleFrom(
                            foregroundColor: palette.goldSoft),
                        onPressed: _leggendo || _codice.text.trim().isEmpty
                            ? null
                            : _leggiIlCodice,
                        child: Text(_leggendo ? 'Un momento' : 'Leggi'),
                      ),
                    ],
                  ),
                  if (_rigaDelCodice != null) ...[
                    const SizedBox(height: SpacingTokens.xs),
                    Text(_rigaDelCodice!,
                        key: const Key('nascita_altra_riga_del_codice'),
                        style: TypographyTokens.didascalia()
                            .copyWith(color: ColorTokens.textSecondary)),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const Key('nascita_altra_condividi_la_mia'),
                      style: TextButton.styleFrom(
                          foregroundColor: palette.goldSoft,
                          padding: EdgeInsets.zero),
                      onPressed: () => Navigator.of(context).push(
                          LaTuaNascitaPerUnaLettura.route(palette,
                              perLOracolo: widget.perLOracolo,
                              perLoLunario: widget.perLoLunario)),
                      child: const Text('Fai leggere la tua nascita'),
                    ),
                  ),
                  // Per l'Oracolo e per il Lunario la nascita passa solo col
                  // consenso: la strada a mano qui non c'e' (ordine FU voce
                  // FU.09, ordine FV voce FV.10).
                  if (!widget.perLOracolo && !widget.perLoLunario) ...[
                    const Divider(height: SpacingTokens.xl),
                    Text('Oppure scrivila tu',
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: palette.goldSoft)),
                    TextField(
                      key: const Key('nascita_altra_nome'),
                      controller: _nome,
                      decoration:
                          const InputDecoration(labelText: 'Il suo nome'),
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
                    InterruttoreDelCerchio(
                      key: const Key('nascita_altra_ora_non_nota'),
                      titolo: 'Non conosco l\'ora di nascita',
                      acceso: _oraNonNota,
                      onCambia: (v) => setState(() => _oraNonNota = v),
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
                  ],
                ],
              ),
            ),
            if (!widget.perLOracolo && !widget.perLoLunario)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.lg),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    key: const Key('nascita_altra_conferma'),
                    onPressed: _pronto ? _conferma : null,
                    style: FilledButton.styleFrom(
                        backgroundColor: palette.goldSoft),
                    child: const Text('Continua'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
