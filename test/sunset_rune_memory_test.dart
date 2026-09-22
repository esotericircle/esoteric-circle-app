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
      await SunsetRuneMemory.scriviEstrazione(
          sera(base.add(Duration(days: i)), 'Fehu'));
    }
    final settimana = await SunsetRuneMemory.settimanaCorrente(
        base.add(const Duration(days: 9)));
    // Sette sere, dal giorno tre al giorno nove, non tutte e dieci.
    expect(settimana.length, 7);
    expect(settimana.first.giorno,
        SunsetRune.iso(base.add(const Duration(days: 3))));
    expect(settimana.last.giorno,
        SunsetRune.iso(base.add(const Duration(days: 9))));
  });

  // **QUI MISURAVA LA REGOLA DI PRIMA, E LA REGOLA E' CAMBIATA.** Fino al 22
  // settembre 2026 questa prova si chiamava *"I giorni saltati non consumano
  // uno slot"* e pretendeva `['Fehu', 'Uruz', 'Ansuz']` da tre sere con due
  // buchi in mezzo: la settimana era **una finestra mobile di sette giorni**,
  // e chi saltava tre sere su sette arrivava lo stesso in fondo.
  //
  // **L'ordine EE voce 03 ha deciso che sono sette sere DI FILA**, e la
  // schermata adesso lo dice: *"Salti una sera e il filo si spezza: si
  // riparte da qui"*. La misura di prima e' rimasta rossa nella suite intera
  // del 22 settembre, ed e' cosi' che si e' saputo che c'era una prova che
  // difendeva la regola vecchia. **La lapide resta**, perche' chi legge
  // `['Fehu', 'Uruz', 'Ansuz']` in un vecchio rapporto deve poter capire
  // dov'e' andata quella misura.
  test('Un giorno saltato spezza il filo, e si riparte da li\'', () async {
    final base = DateTime(2026, 7, 1);
    // Le stesse tre sere di prima, con gli stessi due buchi.
    await SunsetRuneMemory.scriviEstrazione(sera(base, 'Fehu'));
    await SunsetRuneMemory.scriviEstrazione(
        sera(base.add(const Duration(days: 3)), 'Uruz'));
    await SunsetRuneMemory.scriviEstrazione(
        sera(base.add(const Duration(days: 6)), 'Ansuz'));
    final settimana = await SunsetRuneMemory.settimanaCorrente(
        base.add(const Duration(days: 6)));
    expect(settimana.map((s) => s.rune), ['Ansuz'],
        reason: 'fra Uruz e Ansuz ci sono due sere vuote: il filo si e\' '
            'spezzato, e la serie corrente comincia dall\'ultima sera');

    // E due sere attaccate restano attaccate: la regola nuova non e' "vale
    // solo l'ultima", e' "vale la serie che arriva fino a oggi".
    await SunsetRuneMemory.scriviEstrazione(
        sera(base.add(const Duration(days: 5)), 'Kenaz'));
    final serie = await SunsetRuneMemory.settimanaCorrente(
        base.add(const Duration(days: 6)));
    expect(serie.map((s) => s.rune), ['Kenaz', 'Ansuz']);
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
    await SunsetRuneMemory.scriviEstrazione(
        sera(oggi.subtract(const Duration(days: 3)), 'Laguz'));
    expect(
        await SunsetRuneMemory.runaRipetutaNegliUltimi7('Laguz', oggi), isTrue);
    expect(
        await SunsetRuneMemory.runaRipetutaNegliUltimi7('Fehu', oggi), isFalse);
    // Una runa di otto giorni fa e' fuori finestra.
    await SunsetRuneMemory.scriviEstrazione(
        sera(oggi.subtract(const Duration(days: 8)), 'Tiwaz'));
    expect(await SunsetRuneMemory.runaRipetutaNegliUltimi7('Tiwaz', oggi),
        isFalse);
    // La sera di oggi stessa non conta come ritorno.
    await SunsetRuneMemory.scriviEstrazione(sera(oggi, 'Sowilo'));
    expect(await SunsetRuneMemory.runaRipetutaNegliUltimi7('Sowilo', oggi),
        isFalse);
  });

  test('La chiave della cerniera col Sogno tiene l\'ultima runa', () async {
    final e =
        SunsetRune.estrai(DateTime(2026, 7, 13, 20), identita: '1988-07-05');
    await SunsetRuneMemory.scriviEstrazione(
        SunsetRuneMemory.seraDa(e, lasciare: 'A', porta: 'B'));
    final c = await SunsetRuneMemory.ultimaPerCerniera();
    expect(c, isNotNull);
    expect(c!.rune, e.rune.name);
    expect(c.giorno, e.giornoIso);
  });

  test('Senza nulla salvato, tutto vuoto e nessuna eccezione', () async {
    expect(await SunsetRuneMemory.settimanaCorrente(DateTime(2026, 7, 1)),
        isEmpty);
    expect(
        await SunsetRuneMemory.runaRipetutaNegliUltimi7(
            'Fehu', DateTime(2026, 7, 1)),
        isFalse);
    expect(await SunsetRuneMemory.ultimaPerCerniera(), isNull);
  });
}
