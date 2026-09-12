import 'package:flutter/material.dart';

import '../../core/misura/misura_del_ritorno.dart';
import '../../core/misura/registro_del_ritorno.dart';
import '../../design_system/theme/maestro_palette.dart';
import 'riga_interruttore.dart';

/// L'INTERRUTTORE DELLA MISURA DEL RITORNO. Ordine CC voce 09, spostato
/// dall'ordine CE voce 03.
///
/// **Dove sta adesso, e perche'.** Il consenso si da' una volta sola dentro il
/// percorso della registrazione, voce CE.01: qui non si chiede niente, si
/// REVOCA o si concede di nuovo. Il fondatore ha deciso che l'interruttore
/// resta come via per cambiare idea e che si sposta nel sotto menu' dedicato.
///
/// **Perche' una classe sua e non una riga nuda.** Le altre righe delle
/// Impostazioni leggono da `SettingsController`, che e' gia' in memoria; il
/// consenso alla misura vive nelle preferenze e si legge dal disco, quindi
/// serve qualcuno che aspetti quella lettura senza far comparire un
/// interruttore acceso per un istante prima di sapere com'e'.
class InterruttoreDellaMisura extends StatefulWidget {
  const InterruttoreDellaMisura({super.key, required this.palette});

  final MaestroPalette palette;

  @override
  State<InterruttoreDellaMisura> createState() =>
      _InterruttoreDellaMisuraState();
}

class _InterruttoreDellaMisuraState extends State<InterruttoreDellaMisura> {
  ConsensoAllaMisura? _risposta;

  @override
  void initState() {
    super.initState();
    _leggi();
  }

  Future<void> _leggi() async {
    final letto = await ConsensoDellaMisura.letto();
    if (mounted) setState(() => _risposta = letto);
  }

  Future<void> _cambia(bool acceso) async {
    setState(() => _risposta =
        acceso ? ConsensoAllaMisura.concesso : ConsensoAllaMisura.negato);
    await ConsensoDellaMisura.segna(acceso);
    // Il registro tiene il consenso in memoria per non leggere il disco a ogni
    // gesto: se cambia qui, deve rileggerlo, o la scelta varrebbe dal prossimo
    // avvio.
    await RegistroDelRitorno.corrente?.rileggiIlConsenso();
  }

  @override
  Widget build(BuildContext context) {
    final r = _risposta;
    // **Finche' non si sa, non si mostra niente.** Un interruttore che sbatte
    // da spento ad acceso mentre la schermata si apre dice due cose diverse in
    // mezzo secondo, e chi guarda non sa quale delle due e' la sua.
    if (r == null) return const SizedBox(height: 72);
    return RigaInterruttore(
      itemKey: const Key('settings_misura'),
      icon: Icons.insights_outlined,
      title: 'Conta i gesti, non te',
      subtitle: 'Aperture, riti cominciati e finiti, ritorni da una notifica '
          'e responsi condivisi. Numeri per giorno, senza nome. Spegnilo e '
          'l\'app resta identica.',
      value: r == ConsensoAllaMisura.concesso,
      onChanged: _cambia,
      palette: widget.palette,
    );
  }
}
