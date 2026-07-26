import 'dart:io';

import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

/// Nessuna misura tipografica sotto il minimo del suo token.
///
/// I tre costruttori di `TypographyTokens` alzano la misura al minimo con un
/// `math.max`, quindi chiedere `label(size: 10)` e `label(size: 12)` produce lo
/// stesso identico risultato a video: 12.5. Il codice dichiara una gerarchia che
/// lo schermo non puo' onorare, e nessuno se ne accorge perche' il clamp e'
/// silenzioso. Questo test lo rende rumoroso: chiedere una misura impossibile e'
/// un bug, non una svista di stile.
///
/// Si legge il SORGENTE e non l'albero dei widget, cosi' la regola vale anche
/// per le schermate che nessun test monta.
/// Il debito preesistente, congelato e dichiarato.
///
/// La misura che motiva questa lista: su 571 chiamate con misura esplicita sotto
/// lib, 457 stanno sotto il minimo del proprio token, cioe' l'ottanta per cento,
/// distribuite su 64 file. Con quel rapporto il difetto non e' nei punti di
/// chiamata: e' nella taratura dei minimi. Un design system in cui otto
/// chiamate su dieci violano il minimo sta dicendo che il minimo e' sbagliato,
/// non che il codice lo e'. Alzarle tutte in un passaggio solo avrebbe cambiato
/// il layout di quasi tutte le schermate dell'app, molto oltre lo scope, e le
/// anteprime non sarebbero state verificabili una per una.
///
/// Il test quindi nasce con questa lista congelata e vale da subito su tutto il
/// resto: ogni file nuovo e ogni file bonificato sono coperti. La Runa del
/// Tramonto e' stata bonificata per intero, quindi NON compare qui.
///
/// Per rientrare dal debito ci sono due strade, da decidere insieme: rivedere i
/// minimi del token perche' rispecchino le misure vere del prodotto, oppure
/// bonificare i file a gruppi, togliendone uno alla volta da questa lista.
const debitoStorico = <String>{
  'lib/core/permissions/app_permission.dart',
  'lib/design_system/components/art_card.dart',
  'lib/design_system/components/feature_sheet.dart',
  'lib/design_system/components/feature_tile.dart',
  'lib/design_system/components/section_title.dart',
  'lib/features/account/account_screen.dart',
  'lib/features/account/profile_screen.dart',
  'lib/features/home/widgets/demo_controls.dart',
  'lib/features/horoscope/answer_depth.dart',
  'lib/features/horoscope/oroscopo_screen.dart',
  'lib/features/horoscope/oroscopo_share_card.dart',
  'lib/features/identity/circle_seal_screen.dart',
  'lib/features/identity/widgets/identity_widgets.dart',
  'lib/features/maestri/art_intro_screen.dart',
  'lib/features/maestri/ask/ask_maestri_screen.dart',
  'lib/features/maestri/aura/archetype/archetype_share_card.dart',
  'lib/features/maestri/aura/archetype/archetype_test_screen.dart',
  'lib/features/maestri/aura/face/face_constellation_screen.dart',
  'lib/features/maestri/aura/face/face_share_card.dart',
  'lib/features/maestri/aura/meditation/meditation_screen.dart',
  'lib/features/maestri/caligo/animal/animal_journey.dart',
  'lib/features/maestri/caligo/animal/guide_animal_screen.dart',
  'lib/features/maestri/caligo/animal/guide_animal_share_card.dart',
  'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
  'lib/features/maestri/caligo/rune/rune_share_card.dart',
  'lib/features/maestri/chat/maestro_chat_screen.dart',
  'lib/features/maestri/chat/widgets/chat_bubble.dart',
  'lib/features/maestri/chat/widgets/chat_composer.dart',
  'lib/features/maestri/chat/widgets/chat_empty_state.dart',
  'lib/features/maestri/chat/widgets/chat_suggestions.dart',
  'lib/features/maestri/chat/widgets/diagnostics_dialog.dart',
  'lib/features/maestri/chat/widgets/maestro_disclaimer.dart',
  'lib/features/maestri/maestro_screen.dart',
  'lib/features/maestri/widgets/domain_pillars.dart',
  'lib/features/onboarding/birth_sky_hero.dart',
  'lib/features/onboarding/maestro_reveal_screen.dart',
  'lib/features/onboarding/natal_chart_reveal.dart',
  'lib/features/onboarding/onboarding_screen.dart',
  'lib/features/onboarding/resonance_screen.dart',
  'lib/features/onboarding/widgets/sky_thread.dart',
  'lib/features/passport/cosmic_passport_screen.dart',
  'lib/features/pricing/pricing_screen.dart',
  'lib/features/pricing/upgrade_invite.dart',
  'lib/features/rituals/breath_destiny_screen.dart',
  'lib/features/rituals/dawn_rite_screen.dart',
  'lib/features/rituals/day_oracle_screen.dart',
  'lib/features/rituals/dream_rite_card.dart',
  'lib/features/rituals/dream_rite_screen.dart',
  'lib/features/rituals/ritual_gift_card.dart',
  'lib/features/rituals/ritual_view.dart',
  'lib/features/rituals/sunset_rune_card.dart',
  'lib/features/santuario/daily_strip.dart',
  'lib/features/santuario/greeting_banner.dart',
  'lib/features/santuario/santuario_screen.dart',
  'lib/features/santuario/sky_overview_screen.dart',
  'lib/features/settings/settings_screen.dart',
  'lib/features/synastry/sinastria_gallery_screen.dart',
  'lib/features/synastry/sinastria_share_card.dart',
  'lib/features/synastry/sinastria_vip_screen.dart',
  'lib/features/tarot/stesa_share_card.dart',
  'lib/features/tarot/stesa_tre_carte_screen.dart',
  'lib/features/tarot/tarot_card_art.dart',
  'lib/features/tarot/tarot_selectors.dart',
};

void main() {
  test('Nessuna misura tipografica sotto il minimo del suo token', () {
    final minimi = <String, double>{
      'label': TypographyTokens.minLabel,
      'body': TypographyTokens.minBody,
      'display': TypographyTokens.minDisplay,
    };
    // Cattura TypographyTokens.label(size: 10), anche con altri argomenti dopo.
    final chiamata = RegExp(
        r'TypographyTokens\.(label|body|display)\(\s*size:\s*([0-9]+(?:\.[0-9]+)?)');

    final colpevoli = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !debitoStorico
            .contains(f.path.replaceAll(r'\', '/')))) {
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        for (final m in chiamata.allMatches(righe[i])) {
          final famiglia = m.group(1)!;
          final misura = double.parse(m.group(2)!);
          final minimo = minimi[famiglia]!;
          if (misura < minimo) {
            colpevoli.add('${f.path.replaceAll(r'\', '/')}:${i + 1} '
                '$famiglia(size: $misura) sotto il minimo $minimo');
          }
        }
      }
    }

    expect(
      colpevoli,
      isEmpty,
      reason: 'Misure tipografiche sotto il minimo del token: verrebbero alzate '
          'in silenzio dal clamp, quindi la gerarchia dichiarata non esiste a '
          'video. Alza la misura richiesta a un valore reale, e se il layout non '
          'la regge sistema il layout: i minimi esistono per leggibilita\'.\n'
          '${colpevoli.join('\n')}',
    );
  });
}
