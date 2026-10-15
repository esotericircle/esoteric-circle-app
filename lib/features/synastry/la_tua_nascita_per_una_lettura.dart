import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/identity/profile_controller.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';

/// **LA TUA NASCITA PER UNA LETTURA.** Ordine FT voce FT.03, 14 ottobre
/// 2026: "Nella lettura a due telefoni la nascita passa solo col consenso
/// esplicito di chi la condivide, una volta per lettura. Non entra mai nel
/// profilo pubblico."
///
/// Il consenso e' il pulsante, e si preme sapendo che cosa succede: la riga
/// sopra lo dice prima. Solo dopo il gesto il telefono manda la nascita al
/// server (`IlCerchioSociale.condividiLaNascita`) e mostra il codice, che
/// vale cinque minuti e una lettura sola. Senza la nascita data, senza rete
/// o con la porta non ancora pubblicata, la schermata lo dice: chi legge
/// puo' sempre inserire la nascita a mano.
///
/// **LO STESSO GESTO PER L'ORACOLO DEGLI ANGELI**, ordine FU voce FU.09: con
/// [perLOracolo] la riga del consenso dice che la nascita serve ai tuoi tre
/// angeli per la domanda di un amico, e il consenso vale solo per quello.
class LaTuaNascitaPerUnaLettura extends StatefulWidget {
  const LaTuaNascitaPerUnaLettura(
      {super.key, required this.palette, this.perLOracolo = false});

  final MaestroPalette palette;

  /// Vero quando la nascita si presta all'Oracolo degli Angeli.
  final bool perLOracolo;

  static Route<void> route(MaestroPalette palette,
          {bool perLOracolo = false}) =>
      PassaggioDelCerchio.rotta((_) => LaTuaNascitaPerUnaLettura(
          palette: palette, perLOracolo: perLOracolo));

  /// La riga del consenso per l'Oracolo: si legge prima del gesto.
  static const String rigaDellOracolo =
      'Chi ti è accanto può chiedere all\'Oracolo degli Angeli una risposta '
      'per te: rispondono i tuoi tre angeli, che vengono dalla tua nascita '
      'vera. Il codice la presta per una lettura sola, per cinque minuti. Nel '
      'tuo profilo del Cerchio non entra.';

  /// Quanto vale il codice: lo stesso del server
  /// (`DURATA_DEL_CONSENSO_MS` in `functions/src/sinastria_evolutiva.ts`).
  static const Duration durata = Duration(minutes: 5);

  @override
  State<LaTuaNascitaPerUnaLettura> createState() =>
      _LaTuaNascitaPerUnaLetturaState();
}

class _LaTuaNascitaPerUnaLetturaState extends State<LaTuaNascitaPerUnaLettura> {
  bool _inCorso = false;
  String? _codice;
  DateTime? _scade;
  String? _riga;
  Timer? _orologio;

  @override
  void dispose() {
    _orologio?.cancel();
    super.dispose();
  }

  T? _forse<T>() {
    try {
      return context.read<T>();
    } catch (senzaProvider) {
      debugPrint('La tua nascita: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }

  Future<void> _condividi() async {
    final identita = _forse<ProfileController>()?.identity;
    if (identita == null || identita.isExample) {
      setState(() => _riga = 'Prima scrivi la tua nascita nel profilo: '
          'senza, non c\'è niente da condividere.');
      return;
    }
    final sociale = _forse<IlCerchioSociale>();
    if (sociale == null) {
      setState(() => _riga = EsitoDelGesto.silenzio.riga);
      return;
    }
    setState(() {
      _inCorso = true;
      _riga = null;
    });
    final m = identita.birthMoment;
    final luogo = identita.birthPlace;
    final utc = DateTime.utc(m.year, m.month, m.day, m.hour, m.minute)
        .subtract(Duration(minutes: luogo?.utcOffsetMinutes ?? 0));
    final nome = _forse<ProfileController>()?.profile.displayName ?? '';
    final esito = await sociale.condividiLaNascita(
      nascitaUtc: utc,
      giorno: DateTime(m.year, m.month, m.day),
      oraNota: identita.hasBirthTime,
      nome: nome.isEmpty ? 'Chi ti è accanto' : nome,
      perLOracolo: widget.perLOracolo,
      minutoLocale: m.hour * 60 + m.minute,
    );
    if (!mounted) return;
    final codice = esito.dati['codice'];
    final scade = esito.dati['scade'];
    setState(() {
      _inCorso = false;
      if (esito.ok && codice is String && scade is num) {
        _codice = codice;
        _scade = DateTime.fromMillisecondsSinceEpoch(scade.toInt());
        _orologio = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() {});
        });
      } else {
        _riga = esito.rigaPerLaPersona;
      }
    });
  }

  String get _quantoResta {
    final s = _scade;
    if (s == null) return '';
    final resta = s.difference(DateTime.now());
    if (resta.isNegative) return 'Il codice è scaduto: chiedine uno nuovo.';
    final minuti = resta.inMinutes;
    final secondi = (resta.inSeconds % 60).toString().padLeft(2, '0');
    return 'Vale ancora $minuti:$secondi, per una lettura sola.';
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final codice = _codice;
    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        backgroundColor: palette.deepest,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: TitoloCheNonSiRompe(
            chiaveDelTesto: const Key('la_tua_nascita_titolo'),
            testo: 'La tua nascita',
            righe: 1,
            stile: TypographyTokens.titoloSezione()
                .copyWith(color: palette.goldSoft)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          children: [
            ParagrafiDiLettura(
              key: const Key('la_tua_nascita_perche'),
              testo: widget.perLOracolo
                  ? LaTuaNascitaPerUnaLettura.rigaDellOracolo
                  : 'Chi ti è accanto può leggere la vostra Sinastria '
                      'evolutiva con la tua nascita vera. Il codice la presta '
                      'per una lettura sola, per cinque minuti. Nel tuo '
                      'profilo del Cerchio non entra.',
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
            const SizedBox(height: SpacingTokens.xl),
            if (codice == null)
              Center(
                child: FilledButton(
                  key: const Key('la_tua_nascita_consenso'),
                  onPressed: _inCorso ? null : _condividi,
                  // L'etichetta ha il suo colore: senza, sull'oro usciva
                  // chiara e quasi illeggibile (anteprima ft03, 14 ottobre
                  // 2026).
                  style: FilledButton.styleFrom(
                      backgroundColor: palette.goldSoft,
                      foregroundColor: palette.deepest,
                      padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.lg,
                          vertical: SpacingTokens.sm)),
                  child: Text(
                      _inCorso ? 'Un momento' : 'Condivido la mia nascita'),
                ),
              )
            else ...[
              Center(
                child: SelectableText(
                  codice,
                  key: const Key('la_tua_nascita_codice'),
                  style: TypographyTokens.titoloSezione().copyWith(
                      color: palette.goldSoft,
                      fontSize: SpacingTokens.xxl,
                      letterSpacing: SpacingTokens.xs),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(_quantoResta,
                  key: const Key('la_tua_nascita_scadenza'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
            if (_riga != null) ...[
              const SizedBox(height: SpacingTokens.md),
              Text(_riga!,
                  key: const Key('la_tua_nascita_riga'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}
