import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../core/sensi/motore_audio.dart';
import '../../../core/sensi/wav_da_pcm.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../design_system/transizioni/velo_del_cerchio.dart';
import '../../../services/ai/registro_dei_guasti.dart';
import '../../../services/live/porta_del_live.dart';

/// **IL SELETTORE DELLE VOCI, riservato ai fondatori.** Ordine EJ voce 02,
/// 24 settembre 2026.
///
/// Il fondatore: *"le voci non mi convincono, ma non era previsto un
/// selettore in cui potevo sentire e scegliere la voce di ogni maestro?"*.
/// Per il Maestro del LIVE elenca le voci candidate; ognuna si ascolta sulla
/// **stessa frase**, per confrontarle, e quella scelta diventa la voce del
/// Maestro per tutti, dal server, senza una build nuova.
///
/// Lo apre la schermata LIVE solo quando il server dice che la persona e' un
/// fondatore: il telefono non decide chi puo' scegliere.
///
/// **L'ELENCO SCORRE.** Ordine EM voce 07, 25 settembre 2026. Il fondatore:
/// *"Non posso scorrere le voci, lo scorrimento non funziona."* Le candidate
/// stavano in una `Column` senza scorrimento dentro il foglio: le sedici voci
/// di Calìgo non entravano nello schermo e le ultime non si raggiungevano.
/// Padre: ordine EJ voce 02, che ha scritto l'elenco per le voci candidate di
/// allora, poche; l'ordine EK le ha portate a tutte quelle del genere del
/// Maestro. Adesso le voci stanno in una lista che scorre, dentro un foglio
/// alto al massimo l'ottantacinque per cento dello schermo; e con le voci
/// Chirp 3 HD dell'ordine EM voce 02 sono il doppio.
class IlSelettoreDelleVoci extends StatefulWidget {
  const IlSelettoreDelleVoci({super.key, required this.maestro});

  final Maestro maestro;

  static Future<void> apri(BuildContext context, Maestro maestro) =>
      foglioDelCerchio<void>(
        context: context,
        backgroundColor: ColorTokens.neutralDeep,
        isScrollControlled: true,
        builder: (_) => IlSelettoreDelleVoci(maestro: maestro),
      );

  @override
  State<IlSelettoreDelleVoci> createState() => _IlSelettoreDelleVociState();
}

class _IlSelettoreDelleVociState extends State<IlSelettoreDelleVoci> {
  LeVociDelMaestro? _voci;
  String? _scelta;
  String? _inAscolto;
  bool _guasto = false;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    try {
      final v = await PortaDelLive.leVoci(widget.maestro);
      if (!mounted) return;
      setState(() {
        _voci = v;
        _scelta = v.scelta;
      });
    } catch (errore) {
      annotaGuastoInnocuo('le voci del Maestro non arrivano', errore);
      if (mounted) setState(() => _guasto = true);
    }
  }

  Future<void> _ascolta(String voce) async {
    setState(() => _inAscolto = voce);
    try {
      final v = await PortaDelLive.ascoltaUnaVoce(widget.maestro, voce);
      await MotoreAudio.condiviso
          .tono(wavDaPcm(v.pcm, tasso: v.tasso), inCiclo: false);
    } catch (errore) {
      annotaGuastoInnocuo('la voce $voce non si ascolta', errore);
    } finally {
      if (mounted) setState(() => _inAscolto = null);
    }
  }

  Future<void> _scegli(String voce) async {
    final prima = _scelta;
    setState(() => _scelta = voce);
    try {
      await PortaDelLive.scegliLaVoce(widget.maestro, voce);
    } catch (errore) {
      annotaGuastoInnocuo('la voce $voce non si sceglie', errore);
      if (mounted) setState(() => _scelta = prima);
    }
  }

  @override
  Widget build(BuildContext context) {
    final voci = _voci;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Il timbro di ${widget.maestro.displayName}',
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: ColorTokens.goldLight),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                voci == null
                    ? (_guasto
                        ? 'Le voci non arrivano, stasera. Riprova fra poco.'
                        : 'Carico le voci.')
                    : 'Ogni timbro dice la stessa frase: «${voci.frase}»',
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.md),
              if (voci != null)
                Flexible(
                  child: ListView(
                    key: const Key('voci_elenco'),
                    shrinkWrap: true,
                    children: [
                      for (final c in voci.candidate)
                        ListTile(
                          key: Key('voce_${c.voce}'),
                          contentPadding: EdgeInsets.zero,
                          leading: IconButton(
                            key: Key('ascolta_${c.voce}'),
                            icon: Icon(
                              _inAscolto == c.voce
                                  ? Icons.graphic_eq
                                  : Icons.play_circle_outline,
                              color: ColorTokens.goldLight,
                            ),
                            onPressed: _inAscolto == null
                                ? () => _ascolta(c.voce)
                                : null,
                          ),
                          title: Text(
                            c.nome,
                            style: TypographyTokens.corpo()
                                .copyWith(color: ColorTokens.textPrimary),
                          ),
                          subtitle: Text(
                            // La famiglia dice da dove viene la voce: Gemini, o Chirp
                            // 3 HD dall'endpoint "eu". Ordine EM voce 02.
                            '${c.descrizione} · ${c.famiglia}',
                            style: TypographyTokens.didascalia()
                                .copyWith(color: ColorTokens.textSecondary),
                          ),
                          trailing: TextButton(
                            key: Key('scegli_${c.voce}'),
                            style: TextButton.styleFrom(
                                foregroundColor: ColorTokens.goldLight),
                            onPressed: _scelta == c.voce
                                ? null
                                : () => _scegli(c.voce),
                            child:
                                Text(_scelta == c.voce ? 'Scelta' : 'Scegli'),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
