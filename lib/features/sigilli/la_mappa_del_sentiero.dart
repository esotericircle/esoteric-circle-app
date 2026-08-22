import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/maestro/maestro.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../shell/barra_del_cerchio.dart';
import 'segno_del_sentiero.dart';

/// LA MAPPA DEL SENTIERO. Ordine AU voce 13.
///
/// **Cosa dice, e sono tre cose sole.** Dove sei, quante perle su
/// cinquantacinque e in che fascia stai. Cosa manca, la condizione del prossimo
/// gradino con le parole del corpus. Da dove si comincia, la porta dell'arte
/// che accende quel gradino, toccabile.
///
/// **Cosa NON e'.** Non e' la bolla del prossimo traguardo che il fondatore ha
/// fatto eliminare il 20 agosto: quella stava in HOME, arrivava senza che
/// nessuno la chiedesse e diceva cosa fare dopo. Questa sta DENTRO il sentiero,
/// la si chiede da un punto interrogativo, e spiega la mappa di dove ci si
/// trova. La differenza non e' di forma: e' che una interrompe e l'altra
/// risponde.
///
/// **Livello visivo prima del testo**, come dice la legge di casa: il segno del
/// sentiero con le sue perle accese, e solo sotto le tre righe.
class LaMappaDelSentiero {
  const LaMappaDelSentiero._();

  static String _chiaveDelPrimoIngresso(Sentiero sentiero) =>
      'sentiero.mappa_vista.${sentiero.name}';

  /// Vero se in questo sentiero non si e' mai entrati.
  static Future<bool> eIlPrimoIngresso(Sentiero sentiero) async {
    final disco = await SharedPreferences.getInstance();
    return !(disco.getBool(_chiaveDelPrimoIngresso(sentiero)) ?? false);
  }

  static Future<void> segnaLIngresso(Sentiero sentiero) async {
    final disco = await SharedPreferences.getInstance();
    await disco.setBool(_chiaveDelPrimoIngresso(sentiero), true);
  }

  /// Apre la mappa. La chiama il primo ingresso e il punto interrogativo.
  static Future<void> mostra(BuildContext context, Sentiero sentiero) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FoglioDellaMappa(sentiero: sentiero),
    );
  }
}

/// **DA DOVE SI COMINCIA.** Ordine AU voce 13, terza riga.
///
/// Il traguardo dichiara nel corpus la porta che apre, ma come TESTO: "L'
/// Estrazione delle Rune". Un testo non si tocca. Qui il gesto della condizione
/// diventa la via che lo compie, e quando il gesto non ha una via propria si
/// va alla casa del suo Maestro, che e' dove le sue arti stanno: **mai un
/// vicolo cieco**, che e' la regola di casa piu' vecchia di tutte.
class PortaDellArte {
  const PortaDellArte._();

  /// Il gesto che un traguardo chiede, letto dalla firma della condizione.
  /// Nulla se quella condizione non chiede un gesto.
  static String? gestoDi(Traguardo traguardo) {
    final pezzi = traguardo.condizione.firma.split(':');
    if (pezzi.length < 2) return null;
    final gesto = switch (pezzi.first) {
      'gesti' || 'seguito' || 'arco' => pezzi[1].split('.').first,
      'cielo' => pezzi.length > 2 ? pezzi[2] : null,
      'varieta' || 'coincidenza' => pezzi[1].split('.').first,
      _ => null,
    };
    // **"presenza" NON E' UN GESTO**: e' il modo in cui una finestra del cielo
    // dice che basta esserci quel giorno. Lasciarlo passare farebbe cercare
    // un'arte che non esiste.
    return gesto == 'presenza' ? null : gesto;
  }

  /// Come si chiama a schermo l'arte di quel gesto.
  static const Map<String, String> nomeDellArte = {
    'alba': "Il Rito dell'Alba",
    'soffio': 'Il Soffio del Destino',
    'oracolo': 'Arcano del Giorno',
    'oroscopo': "L'Oroscopo",
    'stesa': 'La Stesa di Tarocchi',
    'gettata': "L'Estrazione delle Rune",
    'tramonto': 'La Runa del Tramonto',
    'sogno': 'Il Sigillo del Sogno',
    'sigillo': "Il Sigillo dell'Intenzione",
    'viso': 'La Costellazione del Viso',
    'archetipo': "Il test dell'Archetipo",
    'sinastria': 'La Sinastria',
    'carta_natale': 'Il Cosmic Passport',
    'passaporto': 'Il Cosmic Passport',
    'angelo_custode': "L'Angelo Custode",
    'animale_guida': "L'Animale Guida",
  };

  /// Il nome dell'arte da mostrare, oppure la casa del Maestro.
  static String comeSiChiama(Traguardo traguardo, Sentiero sentiero) {
    final gesto = gestoDi(traguardo);
    return nomeDellArte[gesto] ?? 'La casa di ${sentiero.maestro.displayName}';
  }
}

class _FoglioDellaMappa extends StatelessWidget {
  const _FoglioDellaMappa({required this.sentiero});

  final Sentiero sentiero;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(sentiero.maestro));
    final diario = context.watch<DiarioDelCammino>();
    final tutti = Sentieri.di(sentiero);
    final accesi =
        tutti.where((t) => diario.accesi.contains(t.id)).length;
    final prossimo = diario.prossimoDi(sentiero);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(SpacingTokens.md),
        padding: const EdgeInsets.all(SpacingTokens.lg),
        decoration: BoxDecoration(
          color: palette.surfaceElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // **IL LIVELLO VISIVO VIENE PRIMA DEL TESTO**, legge di casa: il
            // segno del sentiero, con dentro le perle che si sono accese.
            SegnoDelSentiero(
              sentiero: sentiero,
              misura: 72,
              colore: palette.gold,
            ),
            const SizedBox(height: SpacingTokens.md),
            // 1. DOVE SEI.
            Text(
              '$accesi perle accese su ${tutti.length}'
              '${prossimo == null ? "" : ", nella fascia ${prossimo.fascia.toLowerCase()}"}',
              key: const Key('mappa_dove_sei'),
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft),
            ),
            const SizedBox(height: SpacingTokens.sm),
            // 2. COSA MANCA, con le parole del corpus.
            if (prossimo != null) ...[
              Text(
                prossimo.frase,
                key: const Key('mappa_cosa_manca'),
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4),
              ),
              const SizedBox(height: SpacingTokens.md),
              // 3. DA DOVE SI COMINCIA, e si tocca.
              FilledButton.icon(
                key: const Key('mappa_da_dove_si_comincia'),
                onPressed: () {
                  Navigator.of(context).maybePop();
                  NavigazioneDellaBarra.alDominio(context, sentiero.maestro);
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(PortaDellArte.comeSiChiama(prossimo, sentiero)),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.gold.withValues(alpha: 0.18),
                  foregroundColor: palette.goldSoft,
                ),
              ),
            ] else
              Text(
                'Questo sentiero e compiuto.',
                key: const Key('mappa_cosa_manca'),
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textPrimary),
              ),
          ],
        ),
      ),
    );
  }
}
