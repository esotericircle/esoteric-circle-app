import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/sensi/regia_della_musica.dart';
import '../../core/settings/settings_controller.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'riga_interruttore.dart';

/// IL SUONO, il sotto menu' dedicato. Ordine CN voce 07, 1 settembre 2026.
///
/// **Perche' un sotto menu' e non quattro righe in fila.** Vale la stessa
/// ragione scritta per Privacy e permessi: le Impostazioni sono la schermata
/// dove si cerca una cosa sola, e quattro comandi del suono in cima
/// allungherebbero la strada verso tutto il resto per servire chi li tocca una
/// volta. Dietro una riga sola restano raggiungibili e smettono di stare fra i
/// piedi.
///
/// **L'interruttore unico NON entra qui.** Resta nelle Impostazioni, sopra la
/// riga che apre questa pagina, perche' comanda anche la vibrazione, che col
/// suono non c'entra. Chi vuole silenzio totale lo trova senza entrare da
/// nessuna parte.
///
/// **I cursori riflettono lo stato globale e non lo scavalcano.** Quando
/// l'interruttore unico e' spento, tutto qui dentro e' spento e non si tocca:
/// mostrare un cursore vivo sotto un comando gia' spento direbbe il falso, e
/// muoverlo non farebbe uscire un suono.
class SuonoScreen extends StatelessWidget {
  const SuonoScreen({super.key});

  static Route<void> route() =>
      PassaggioDelCerchio.rotta<void>((_) => const SuonoScreen());

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    final settings = context.watch<SettingsController>();
    final acceso = settings.suonoEVibrazione;

    // **LA ROTTA SPINTA PORTA IL PROPRIO MaestroScope.**
    //
    // Quello dell'app sta DENTRO la home: un `push` mette la schermata
    // nuova sopra il Navigator, quindi fuori da li'. Senza questo
    // involucro `SectionTitle` non trova lo scope e solleva, e la
    // pagina resta bianca. Misurato il 1 settembre 2026 dalla prova
    // dell'interruttore degli effetti, che dopo il tocco non trovava
    // piu' niente.
    return MaestroScope(
      child: Scaffold(
        key: const Key('suono_schermata'),
        backgroundColor: palette.deepest,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: palette.goldSoft),
          title: Text('Suono',
              style: TypographyTokens.titoloDiSchermata()
                  .copyWith(color: palette.goldSoft)),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.xxl),
            children: [
              const SectionTitle(
                title: 'Gli effetti',
                subtitle: 'I suoni che rispondono a un gesto.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                padding: EdgeInsets.zero,
                child: RigaInterruttore(
                  itemKey: const Key('suono_effetti'),
                  icon: Icons.graphic_eq_rounded,
                  title: 'Effetti sonori',
                  subtitle: 'I tredici suoni del Cerchio. Spegnili e la '
                      'vibrazione resta.',
                  value: settings.suonoPermesso,
                  onChanged: acceso ? settings.setEffettiSonori : null,
                  palette: palette,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              _CursoreDelVolume(
                chiave: const Key('suono_volume_effetti'),
                titolo: 'Volume degli effetti',
                valore: settings.volumeEffetti,
                attivo: acceso && settings.effettiSonori,
                palette: palette,
                onChanged: settings.setVolumeEffetti,
              ),
              const SizedBox(height: SpacingTokens.xl),

              const SectionTitle(
                title: 'La musica',
                subtitle: 'Il tappeto d\'ambiente, sotto tutto il resto.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                padding: EdgeInsets.zero,
                child: RigaInterruttore(
                  itemKey: const Key('suono_musica'),
                  icon: Icons.music_note_rounded,
                  title: 'Musica d\'ambiente',
                  subtitle: 'Un anello per luogo, che scende da solo quando '
                      'suona qualcos\'altro.',
                  value: settings.musicaPermessa,
                  onChanged: acceso
                      ? (v) {
                          settings.setMusicaAttiva(v);
                          RegiaDellaMusica.sola.aggiorna(settings);
                        }
                      : null,
                  palette: palette,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              _CursoreDelVolume(
                chiave: const Key('suono_volume_musica'),
                titolo: 'Volume della musica',
                valore: settings.volumeMusica,
                attivo: acceso && settings.musicaAttiva,
                palette: palette,
                onChanged: (v) {
                  settings.setVolumeMusica(v);
                  RegiaDellaMusica.sola.aggiorna(settings);
                },
              ),
              const SizedBox(height: SpacingTokens.lg),

              // **LA RIGA CHE SPIEGA IL RAPPORTO, e serve.** Senza, chi trova
              // la musica al sessanta e gli effetti al cento crede che sia una
              // svista, e li pareggia. Non sono pari perche' non devono esserlo.
              Text(
                'La musica parte più bassa degli effetti di proposito: così '
                'un suono si sente sopra il tappeto senza che tu debba alzare '
                'niente.',
                key: const Key('suono_perche_diversi'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un cursore del volume, con la sua percentuale scritta accanto.
class _CursoreDelVolume extends StatelessWidget {
  const _CursoreDelVolume({
    required this.chiave,
    required this.titolo,
    required this.valore,
    required this.attivo,
    required this.palette,
    required this.onChanged,
  });

  final Key chiave;
  final String titolo;
  final double valore;
  final bool attivo;
  final MaestroPalette palette;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colore = attivo ? palette.goldSoft : ColorTokens.textSecondary;
    return DepthCard(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // **IL TESTO DEVE POTER CEDERE**, come vuole la voce CM.09
              // famiglia A: accanto c'e' una percentuale di misura fissa.
              Flexible(
                child: Text(titolo,
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: colore)),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text('${(valore * 100).round()}%',
                  key: Key('${chiave.toString()}_percento'),
                  style: TypographyTokens.didascalia().copyWith(
                    color: colore,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
            ],
          ),
          Slider(
            key: chiave,
            value: valore,
            activeColor: palette.gold,
            // La traccia spenta prende l'oro velato e non un token del
            // testo: un token del testo su una TRACCIA non e' testo, ma
            // la guardia dei grigi legge i sorgenti e non puo' saperlo,
            // e aveva ragione a chiedermelo. L'oro e' anche il colore
            // giusto: la traccia appartiene all'accento, non alla parola.
            inactiveColor: palette.gold.withValues(alpha: 0.25),
            // Venti tacche: un centesimo alla volta sarebbe una precisione
            // che nessuno sente e che rende difficile fermarsi su un numero.
            divisions: 20,
            label: '${(valore * 100).round()}%',
            onChanged: attivo ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
