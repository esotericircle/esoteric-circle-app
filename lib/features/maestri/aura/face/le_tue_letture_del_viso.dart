import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/face/face_history.dart';
import '../../../../core/face/ritratti_del_viso.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/transizioni/velo_del_cerchio.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../rotta_arte.dart';

/// **LE LETTURE PASSATE, CON IL VOLTO CHE LE HA FATTE.**
/// Ordine CX voce 04, 8 settembre 2026.
///
/// **Parole del fondatore**: *"quando andro' a vedere le scorse scansioni e
/// risultati vorro' vedere la foto del viso e non del muro, che dovrebbe
/// essere vietato"*, e poi: *"puoi tenerle memorizzate solo sul telefono e
/// dare l'opportunita' all'utente di gestirle?"*.
///
/// **Prima di oggi questa schermata non esisteva**, e nemmeno le fotografie:
/// lo storico teneva la data e i tratti, che sono testo, e l'immagine viveva
/// quanto la schermata del responso. La foto del muro non si vedeva nelle
/// scorse letture perche' non si vedeva niente.
///
/// **Il muro non ci arriva piu' per una ragione che sta a monte**: dall'ordine
/// CX la fotografia viene giudicata prima di essere conservata, e uno scatto
/// senza un volto dentro non produce ne' responso ne' ricordo. Qui dentro
/// finiscono solo scatti in cui un volto c'era.
///
/// **Gestire vuol dire poter togliere.** Ogni lettura si cancella da sola, col
/// suo ritratto, e in fondo c'e' la via per portarle via tutte: senza quella,
/// conservare sarebbe una decisione presa al posto della persona.
class LeTueLettureDelViso extends StatefulWidget {
  const LeTueLettureDelViso({super.key, this.storico});

  /// Lo storico da mostrare. Si puo' passare dall'esterno perche' una prova
  /// possa montarlo con dei dati suoi senza toccare il disco.
  final FaceHistory? storico;

  @override
  State<LeTueLettureDelViso> createState() => _LeTueLettureDelVisoState();
}

class _LeTueLettureDelVisoState extends State<LeTueLettureDelViso> {
  late final FaceHistory _storico = widget.storico ?? FaceHistory();
  bool _pronto = false;

  @override
  void initState() {
    super.initState();
    if (widget.storico != null) {
      _pronto = true;
    } else {
      _storico.carica().then((_) {
        if (mounted) setState(() => _pronto = true);
      });
    }
  }

  @override
  void dispose() {
    if (widget.storico == null) _storico.dispose();
    super.dispose();
  }

  Future<void> _cancellaUna(FaceEsito quale) async {
    final conferma = await _chiedi(
      titolo: 'Cancellare questa lettura?',
      testo: 'Sparisce dal telefono con la sua fotografia. Non si torna '
          'indietro.',
    );
    if (conferma != true) return;
    await _storico.dimentica(quale);
    if (mounted) setState(() {});
  }

  Future<void> _cancellaTutte() async {
    final conferma = await _chiedi(
      titolo: 'Cancellare tutte le letture?',
      testo: 'Spariscono dal telefono tutte le letture e tutte le '
          'fotografie. Non si torna indietro.',
    );
    if (conferma != true) return;
    await _storico.dimenticaTutto();
    if (mounted) setState(() {});
  }

  Future<bool?> _chiedi({required String titolo, required String testo}) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    // **IL DIALOGO PASSA DAL VELO DEL CERCHIO**, ordine CF voce 09: un
    // `showDialog` diretto arriva su un fondo che non e' il nostro, e una
    // guardia lo pretende in un punto solo per tutta l'app.
    return dialogoDelCerchio<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: palette.surfaceElevated,
        title: Text(titolo,
            style: TypographyTokens.titoloScheda()
                .copyWith(color: palette.goldSoft)),
        content: ParagrafiDiLettura(
          testo: testo,
          stile: TypographyTokens.lettura()
              .copyWith(color: ColorTokens.textPrimary),
        ),
        actions: [
          TextButton(
            key: const Key('letture_annulla'),
            onPressed: () => Navigator.of(c).pop(false),
            child: Text('Lascia stare',
                style: TypographyTokens.etichetta()
                    .copyWith(color: ColorTokens.textSecondary)),
          ),
          TextButton(
            key: const Key('letture_conferma'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text('Cancella',
                style:
                    TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    final esiti = _storico.esiti;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: BarraArte(
        titolo: TitoloCheNonSiRompe(
            testo: 'Le tue letture', stile: TypographyTokens.titoloScheda()),
      ),
      body: CosmosBackground(
        child: SafeArea(
          child: !_pronto
              ? const Center(child: CircularProgressIndicator())
              : esiti.isEmpty
                  ? _IlVuoto(palette: palette)
                  : ListView.separated(
                      key: const Key('letture_elenco'),
                      padding: const EdgeInsets.all(SpacingTokens.lg),
                      itemCount: esiti.length + 1,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: SpacingTokens.md),
                      itemBuilder: (context, i) {
                        if (i == esiti.length) {
                          return _IlPulsanteDelVuoto(
                              palette: palette, onTutte: _cancellaTutte);
                        }
                        return _UnaLettura(
                          palette: palette,
                          esito: esiti[i],
                          onCancella: () => _cancellaUna(esiti[i]),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

/// Nessuna lettura: mai un vicolo cieco, si dice cosa fare.
class _IlVuoto extends StatelessWidget {
  const _IlVuoto({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) => Padding(
        key: const Key('letture_vuoto'),
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face_retouching_natural_outlined,
                size: 48, color: palette.goldSoft),
            const SizedBox(height: SpacingTokens.lg),
            ParagrafiDiLettura(
              testo: 'Qui restano le tue letture del viso, con la fotografia '
                  'di quel momento. Non ne hai ancora nessuna: la prima '
                  'nasce dalla Costellazione del Viso.',
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
          ],
        ),
      );
}

/// Una lettura passata: il ritratto, la data, il tratto e la via per toglierla.
class _UnaLettura extends StatelessWidget {
  const _UnaLettura({
    required this.palette,
    required this.esito,
    required this.onCancella,
  });

  final MaestroPalette palette;
  final FaceEsito esito;
  final VoidCallback onCancella;

  @override
  Widget build(BuildContext context) {
    final r = esito.ritratto;
    return DepthCard(
      palette: palette,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              child: SizedBox(
                width: 72,
                height: 72,
                // **IL RITRATTO, e la sagoma quando non c'e'.** Le letture
                // oltre la dodicesima tengono il testo e perdono la foto: al
                // suo posto non si lascia un buco, si dice perche'.
                child: r == null
                    ? _SenzaRitratto(palette: palette)
                    : Image.file(
                        File(r),
                        key: const Key('lettura_ritratto'),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _SenzaRitratto(palette: palette),
                      ),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_quando(esito.quando),
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.xs),
                  ParagrafiDiLettura(
                    testo: esito.reading.dominante.nome,
                    stile: TypographyTokens.lettura()
                        .copyWith(color: ColorTokens.textPrimary),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('lettura_cancella'),
              tooltip: 'Cancella questa lettura',
              onPressed: onCancella,
              icon: Icon(Icons.delete_outline_rounded,
                  size: 20, color: palette.goldSoft),
            ),
          ],
        ),
      ),
    );
  }

  static String _quando(DateTime d) {
    const mesi = [
      'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
      'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
    ];
    final mese = mesi[(d.month - 1).clamp(0, 11)];
    final ora = d.hour.toString().padLeft(2, '0');
    final minuti = d.minute.toString().padLeft(2, '0');
    return '${d.day} $mese ${d.year}, $ora:$minuti';
  }
}

class _SenzaRitratto extends StatelessWidget {
  const _SenzaRitratto({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: palette.surfaceElevated,
        child: Center(
          child: Icon(Icons.face_outlined, size: 28, color: palette.goldSoft),
        ),
      );
}

/// La via per portarle via tutte, in fondo e non in cima: si trova quando la
/// si cerca, e non si preme per sbaglio scorrendo.
class _IlPulsanteDelVuoto extends StatelessWidget {
  const _IlPulsanteDelVuoto({required this.palette, required this.onTutte});

  final MaestroPalette palette;
  final VoidCallback onTutte;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: SpacingTokens.lg),
        child: Column(
          children: [
            ParagrafiDiLettura(
              testo: 'Le fotografie restano su questo telefono e non vengono '
                  'inviate da nessuna parte. Si conservano per le ultime '
                  '${RitrattiDelViso.quanteNeTengono} letture.',
              // **UN TESTO DA LEGGERE PER INTERO PORTA LA MISURA DEL
              // RESPONSO**, e non quella della didascalia: lo pretende la
              // guardia delle descrizioni, e qui si tratta della promessa
              // sulla privacy delle fotografie, che va letta davvero.
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
            const SizedBox(height: SpacingTokens.md),
            OutlinedButton.icon(
              key: const Key('letture_cancella_tutte'),
              onPressed: onTutte,
              style: OutlinedButton.styleFrom(
                  foregroundColor: palette.goldSoft,
                  side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
                  minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text('Cancella tutte le letture',
                  style: TypographyTokens.etichetta()),
            ),
          ],
        ),
      );
}
