import 'package:flutter/material.dart';

import '../../core/tarot/i_mazzi_dei_tarocchi.dart';
import '../../core/tarot/i_mazzi_scaricati.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// **IL MAZZO DELLA STESA**, per chi disegna una carta sotto la schermata:
/// la faccia della carta lo legge da qui invece di riceverlo a mano da ogni
/// widget in mezzo. Senza, e' il Rider-Waite.
class IlMazzoDellaStesa extends InheritedWidget {
  const IlMazzoDellaStesa(
      {super.key, required this.mazzo, required super.child});

  final TarotDeckStyle mazzo;

  static TarotDeckStyle di(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<IlMazzoDellaStesa>()?.mazzo ??
      TarotDeckStyle.predefinito;

  @override
  bool updateShouldNotify(IlMazzoDellaStesa vecchio) => vecchio.mazzo != mazzo;
}

/// **IL MAZZO SI SCARICA QUANDO LO SCEGLI.** Ordine FJ voce 12.
///
/// Rende vero se il mazzo [d] si puo' usare: e' nel binario, era gia'
/// scaricato, oppure la persona l'ha appena scaricato. Il download si apre in
/// un dialogo con l'avanzamento in megabyte e il gesto che lo annulla. Se non
/// riesce, una riga sola lo dice e la stesa resta sul Rider-Waite: nessuna
/// schermata d'errore, e la stesa in corso non si tocca.
Future<bool> scegliIlMazzo(
  BuildContext context,
  TarotDeckStyle d,
  MaestroPalette palette, {
  IMazziScaricati? servizio,
}) async {
  final mazzi = servizio ?? IMazziScaricati.diCasa;
  await mazzi.leggiIInstallati();
  if (mazzi.installato(d)) return true;
  if (!context.mounted) return false;
  final messaggi = ScaffoldMessenger.maybeOf(context);
  final esito = await dialogoDelCerchio<EsitoDelDownload>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _IlDownload(mazzo: d, palette: palette, servizio: mazzi),
  );
  if (esito == EsitoDelDownload.installato) return true;
  if (esito == EsitoDelDownload.nonRiuscito) {
    messaggi?.showSnackBar(SnackBar(
      key: const Key('mazzo_non_scaricato'),
      content: Text('Il mazzo ${d.label} non si è scaricato: la stesa resta '
          'col ${TarotDeckStyle.predefinito.label}.'),
    ));
  }
  return false;
}

class _IlDownload extends StatefulWidget {
  const _IlDownload({
    required this.mazzo,
    required this.palette,
    required this.servizio,
  });

  final TarotDeckStyle mazzo;
  final MaestroPalette palette;
  final IMazziScaricati servizio;

  @override
  State<_IlDownload> createState() => _IlDownloadState();
}

class _IlDownloadState extends State<_IlDownload> {
  final _annulla = AnnullaDownload();
  int _fatti = 0;
  int _totali = 0;

  @override
  void initState() {
    super.initState();
    widget.servizio.scarica(widget.mazzo, annulla: _annulla,
        avanzamento: (f, t) {
      if (mounted) {
        setState(() {
          _fatti = f;
          _totali = t;
        });
      }
    }).then((esito) {
      if (mounted) Navigator.of(context).pop(esito);
    });
  }

  String _mb(int byte) => (byte / 1e6).toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final quota = _totali == 0 ? null : _fatti / _totali;
    return Dialog(
      key: const Key('mazzo_in_download'),
      backgroundColor: p.surfaceElevated,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Il mazzo ${widget.mazzo.label}',
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: p.textPrimary)),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              _totali == 0
                  ? 'Lo prendo dal Cerchio: dopo resta sul telefono e funziona '
                      'anche senza rete.'
                  : '${_mb(_fatti)} MB su ${_mb(_totali)}',
              key: const Key('mazzo_avanzamento'),
              style: TypographyTokens.corpo().copyWith(color: p.textSecondary),
            ),
            const SizedBox(height: SpacingTokens.md),
            LinearProgressIndicator(value: quota, color: p.gold),
            const SizedBox(height: SpacingTokens.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('mazzo_annulla'),
                onPressed: _annulla.annulla,
                child: Text('Annulla',
                    style: TypographyTokens.corpo(weight: 600)
                        .copyWith(color: p.gold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
