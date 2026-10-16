import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:esoteric_circle/features/onboarding/maestro_reveal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attorno_alla_rivelazione.dart';

/// **LA RIVELAZIONE CHIEDE IL GESTO DEL SUO OGGETTO.** Ordine DK voce 02,
/// 13 settembre 2026.
///
/// *"La frase 'Trascina il dito per svelare' resta viva nella rivelazione del
/// Maestro, dove non c'e' cenere. Diventa una frase per ciascun oggetto. [...]
/// Guarda quale dei due e' montato e usa quella che corrisponde: una frase che
/// chiede un gesto diverso da quello che l'app aspetta e' peggio di nessuna
/// frase."*
///
/// **Montato e' il tocco**, per tutti e tre gli oggetti: trascinare o toccare
/// ovunque sulla schermata fa avanzare il rito, e il microfono si accende
/// soltanto se la persona lo sceglie. Percio' alla prima apertura la frase
/// chiede il dito, e col microfono acceso chiede il soffio col dito come
/// ripiego.
void main() {
  test('UNA FRASE PER OGGETTO, e il gesto e quello che l app aspetta', () {
    expect(MaestroRevealScreen.fraseDelGesto(Maestro.caligo, microfono: false),
        'Passa il dito sulla fiamma.');
    expect(MaestroRevealScreen.fraseDelGesto(Maestro.medora, microfono: false),
        'Passa il dito sul vetro.');
    expect(MaestroRevealScreen.fraseDelGesto(Maestro.aura, microfono: false),
        'Sfiora il soffione con il dito.');
    for (final m in Maestro.values) {
      final senza = MaestroRevealScreen.fraseDelGesto(m, microfono: false);
      final con = MaestroRevealScreen.fraseDelGesto(m, microfono: true);
      expect(senza.toLowerCase(), isNot(contains('soffia')),
          reason: '${m.name}: senza microfono la frase chiede un soffio che '
              'nessuno ascolta');
      expect(senza, contains('dito'));
      expect(con, startsWith('Soffia'),
          reason: '${m.name}: col microfono la frase non chiede il soffio');
      expect(con, contains('dito'),
          reason: '${m.name}: col microfono il tocco non e piu dichiarato come '
              'ripiego, e il tocco funziona ancora');
      expect(senza + con, isNot(contains('Trascina il dito per svelare')));
    }
    expect(MaestroRevealScreen.fraseDelGesto(Maestro.aura, microfono: true),
        startsWith('Soffia piano'));
  });

  for (final m in Maestro.values) {
    testWidgets('ALLA PRIMA APERTURA ${m.name} CHIEDE IL DITO, con la frase '
        'del suo oggetto', (tester) async {
      final banco = BancoDeiLettori();
      await tester.pumpWidget(attornoAllaRivelazione(MaestroRevealScreen(
        maestro: m,
        onRevealed: (_) {},
        fabbricaDelVideo: banco.crea,
      )));
      await tester.pump();
      final frase = tester
          .widget<ParagrafiDiLettura>(
              find.byKey(const Key('reveal_frase_del_gesto')))
          .testo;
      expect(frase, MaestroRevealScreen.fraseDelGesto(m, microfono: false));
      expect(find.textContaining('Trascina il dito'), findsNothing);
    });
  }
}
