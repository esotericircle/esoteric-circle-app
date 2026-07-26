import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune_memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La memoria settimanale della Runa del Tramonto: finestra mobile su sette
/// giorni rituali.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  SeraSalvata sera(DateTime giorno, String rune, {bool ombra = false}) =>
      SeraSalvata(
        giorno: SunsetRune.iso(giorno),
        rune: rune,
        inOmbra: ombra,
        lasciare: "Lascia fuori una prova.",
        porta: "Porta dentro una prova.",
      );

  test('La finestra tiene solo i sette giorni rituali fino a oggi', () async {
    final base = DateTime(2026, 7, 1);
    for (var i = 0; i < 10; i++) {
      await SunsetRuneMemory.scriviEstrazione(sera(base.add(Duration(days: i)), 'Fehu'));
    }
    final settimana =
        await SunsetRuneMemory.settimanaCorrente(base.add(const Duration(days: 9)));
    // Sette sere, dal giorno tre al giorno nove, non tutte e dieci.
    expect(settimana.length, 7);
    expect(settimana.first.giorno, SunsetRune.iso(base.add(const Duration(days: 3))));
    expect(settimana.last.giorno, SunsetRune.iso(base.add(const Duration(days: 9))));
  });

  test('I giorni saltati non consumano uno slot', () async {
    final base = DateTime(2026, 7, 1);
    // Solo tre sere, con salti dentro la finestra dei sette giorni.
    await SunsetRuneMemory.scriviEstrazione(sera(base, 'Fehu'));
    await SunsetRuneMemory.scriviEstrazione(sera(base.add(const Duration(days: 3)), 'Uruz'));
    await SunsetRuneMemory.scriviEstrazione(sera(base.add(const Duration(days: 6)), 'Ansuz'));
    final settimana =
        await SunsetRuneMemory.settimanaCorrente(base.add(const Duration(days: 6)));
    // Restano tutte e tre: la finestra e' per data, i buchi non le espellono.
    expect(settimana.map((s) => s.rune), ['Fehu', 'Uruz', 'Ansuz']);
  });

  test('Una sola sera per giorno rituale, l\'ultima vince', () async {
    final giorno = DateTime(2026, 7, 10);
    await SunsetRuneMemory.scriviEstrazione(sera(giorno, 'Fehu'));
    await SunsetRuneMemory.scriviEstrazione(sera(giorno, 'Laguz'));
    final settimana = await SunsetRuneMemory.settimanaCorrente(giorno);
    expect(settimana.length, 1);
    expect(settimana.single.rune, 'Laguz');
  });

  test('Rileva la runa ripetuta entro sette giorni, non oltre', () async {
    final oggi = DateTime(2026, 7, 20);
    await SunsetRuneMemory.scriviEstrazione(sera(oggi.subtract(const Duration(days: 3)), 'Laguz'));
    expect(await SunsetRuneMemory.runaRipetutaNegliUltimi7('Laguz', oggi), isTrue);
    expect(await SunsetRuneMemory.runaRipetutaNegliUltimi7('Fehu', oggi), isFalse);
    // Una runa di otto giorni fa e' fuori finestra.
    await SunsetRuneMemory.scriviEstrazione(sera(oggi.subtract(const Duration(days: 8)), 'Tiwaz'));
    expect(await SunsetRuneMemory.runaRipetutaNegliUltimi7('Tiwaz', oggi), isFalse);
    // La sera di oggi stessa non conta come ritorno.
    await SunsetRuneMemory.scriviEstrazione(sera(oggi, 'Sowilo'));
    expect(await SunsetRuneMemory.runaRipetutaNegliUltimi7('Sowilo', oggi), isFalse);
  });

  test('La chiave della cerniera col Sogno tiene l\'ultima runa', () async {
    final e = SunsetRune.estrai(DateTime(2026, 7, 13, 20),
        dataNascita: DateTime(1988, 7, 5), identita: '1988-07-05');
    await SunsetRuneMemory.scriviEstrazione(
        SunsetRuneMemory.seraDa(e, lasciare: 'A', porta: 'B'));
    final c = await SunsetRuneMemory.ultimaPerCerniera();
    expect(c, isNotNull);
    expect(c!.rune, e.rune.name);
    expect(c.giorno, e.giornoIso);
  });

  test('Senza nulla salvato, tutto vuoto e nessuna eccezione', () async {
    expect(await SunsetRuneMemory.settimanaCorrente(DateTime(2026, 7, 1)), isEmpty);
    expect(await SunsetRuneMemory.runaRipetutaNegliUltimi7('Fehu', DateTime(2026, 7, 1)),
        isFalse);
    expect(await SunsetRuneMemory.ultimaPerCerniera(), isNull);
  });
}
