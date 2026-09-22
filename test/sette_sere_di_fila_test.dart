// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/rituals/sunset_rune_memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **SETTE SERE DI FILA, E UNA SALTATA SPEZZA IL FILO.** Ordine EE voce 03,
/// 23 settembre 2026.
///
/// **Il fatto del fondatore, verbatim**: *"la runa del tramonto non capisco
/// come memorizza le rune estratte nei giorni precedenti, forse memorizza
/// solo se estrai ogni giorno una runa e si azzera se salti un giorno? io
/// vorrei che fosse chiaro per l'utente che solo se fa 7 'runa del tramonto'
/// consecutive potra' ricevere il riassunto della sua settimana"*.
///
/// **Come funzionava, dichiarato prima di cambiarlo.** Non era ne' l'una ne'
/// l'altra delle due ipotesi: era una **finestra mobile su sette giorni di
/// calendario** (`sunset_rune_memory.dart`, `_giorniFinestra = 7`), in cui
/// i giorni saltati **non consumavano posto**. Chi faceva la runa il primo,
/// il terzo e il quinto giorno si trovava "terza sera su sette" senza che
/// niente glielo spiegasse. **Padre: PROVENIENZA IGNOTA**, la finestra
/// mobile nasce col file.
///
/// **Adesso e' una serie**, come il fondatore ha chiesto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Una sera salvata nel giorno [g] di settembre 2026.
  SeraSalvata sera(int g, String runa) => SeraSalvata(
        giorno: '2026-09-${g.toString().padLeft(2, '0')}',
        rune: runa,
        inOmbra: false,
        lasciare: 'lascia',
        porta: 'porta',
      );

  Future<void> scrivi(List<SeraSalvata> sere) async {
    SharedPreferences.setMockInitialValues({});
    for (final s in sere) {
      await SunsetRuneMemory.scriviEstrazione(s);
    }
  }

  test('sette sere di fila fanno una settimana piena', () async {
    await scrivi([for (var g = 1; g <= 7; g++) sera(g, 'Uruz')]);
    final settimana =
        await SunsetRuneMemory.settimanaCorrente(DateTime(2026, 9, 7));
    print('ORDINE EE VOCE 03, sette di fila: ${settimana.length} sere');
    expect(settimana, hasLength(7),
        reason: 'sette sere consecutive non compongono la settimana');
  });

  test('e una sera saltata spezza il filo: si riparte da capo', () async {
    // Sei sere, poi il salto del giorno 7, poi la sera dell'8: la serie che
    // arriva all'8 e' lunga UNA.
    await scrivi([
      for (var g = 1; g <= 6; g++) sera(g, 'Uruz'),
      sera(8, 'Ansuz'),
    ]);
    final settimana =
        await SunsetRuneMemory.settimanaCorrente(DateTime(2026, 9, 8));
    print('ORDINE EE VOCE 03, col salto del settimo giorno: '
        '${settimana.length} sere');
    expect(settimana, hasLength(1),
        reason: 'la sera saltata non ha spezzato il filo: con la finestra '
            'mobile le sei sere di prima contavano ancora, e la persona '
            'arrivava al riassunto senza aver fatto sette sere di fila');
  });

  test('e chi ne ha fatte tre di fila ne ha tre, non di piu\'', () async {
    // Il caso che nessuno capiva: sere sparse dentro la settimana di
    // calendario. Prima ne contava tre, ma come "terza su sette".
    await scrivi(
        [sera(1, 'Uruz'), sera(3, 'Ansuz'), sera(4, 'Laguz'), sera(5, 'Fehu')]);
    final settimana =
        await SunsetRuneMemory.settimanaCorrente(DateTime(2026, 9, 5));
    print('ORDINE EE VOCE 03, sparse: ${settimana.length} sere di fila');
    expect(settimana, hasLength(3),
        reason: 'la serie che arriva al 5 settembre e\' 3-4-5: il primo '
            'settembre appartiene a una striscia spezzata');
  });
}
