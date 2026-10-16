// LA PAROLA DI MEDORA DEL RESPIRO. Ordine FX voce FX.07, 16 ottobre 2026.
//
// Le tre righe si provano con un `GiornoLunare` finto, iniettato in
// `diOggi`: cosi' la prova non dipende dal giorno vero in cui gira, e resta
// verde identica oggi e in un anno. Che il giorno lunare vero (quello che
// `IlMotoreLunare` calcola davvero) sia corretto lo provano le prove del
// motore lunare, non questa: qui si prova solo che il testo delle tre righe
// risponda bene a quello che il motore gli consegna.

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/lunario/il_giorno_lunare.dart';
import 'package:esoteric_circle/core/lunario/la_parola_di_medora_del_respiro.dart';
import 'package:flutter_test/flutter_test.dart';

GiornoLunare _giorno({
  required Zodiac segno,
  List<CambioDiSegno> cambiDiSegno = const [],
  List<IntervalloFuoriCorso> fuoriCorso = const [],
  int giornoLunare = 1,
}) =>
    GiornoLunare(
      giorno: DateTime(2026, 10, 16),
      elongazione: 10,
      illuminazione: 0.05,
      crescente: true,
      fase: FaseLunare.crescente,
      segno: segno,
      cambiDiSegno: cambiDiSegno,
      fuoriCorso: fuoriCorso,
      giornoLunare: giornoLunare,
      tipoBiodinamico: null,
      lunaNuova: false,
      lunaPiena: false,
    );

void main() {
  final adesso = DateTime(2026, 10, 16, 12, 0);

  test('senza cambi di segno, la riga dice che oggi non cambia', () {
    final parola = LaParolaDiMedoraDelRespiro.diOggi(adesso,
        giorno: _giorno(segno: Zodiac.leo));
    expect(parola.segno, contains('Leone'));
    expect(parola.segno, contains('oggi non cambia segno'));
  });

  test('un cambio nel futuro: la riga annuncia il segno che arriva', () {
    final cambio = DateTime(2026, 10, 16, 18, 0);
    final parola = LaParolaDiMedoraDelRespiro.diOggi(adesso,
        giorno: _giorno(
          segno: Zodiac.virgo,
          cambiDiSegno: [CambioDiSegno(istante: cambio, segno: Zodiac.virgo)],
        ));
    // Prima del cambio la Luna sta ancora nel segno che lo precede nel
    // ciclo dei dodici: la Vergine e' precedute dal Leone.
    expect(parola.segno, contains('Leone'));
    expect(parola.segno, contains('fino alle 18:00'));
    expect(parola.segno, contains('Vergine'));
    expect(parola.segno, isNot(contains('è entrata')));
  });

  test('un cambio nel passato: la riga dice che e\' gia\' entrata', () {
    final cambio = DateTime(2026, 10, 16, 6, 0);
    final parola = LaParolaDiMedoraDelRespiro.diOggi(adesso,
        giorno: _giorno(
          segno: Zodiac.virgo,
          cambiDiSegno: [CambioDiSegno(istante: cambio, segno: Zodiac.virgo)],
        ));
    expect(parola.segno, contains('è entrata nel segno del Vergine'));
    expect(parola.segno, contains('06:00'));
  });

  test('fuori corso adesso: la riga dice fino a quando', () {
    final inizio = DateTime(2026, 10, 16, 9, 0);
    final fine = DateTime(2026, 10, 16, 16, 42);
    final parola = LaParolaDiMedoraDelRespiro.diOggi(adesso,
        giorno: _giorno(
          segno: Zodiac.leo,
          fuoriCorso: [IntervalloFuoriCorso(inizio: inizio, fine: fine)],
        ));
    expect(parola.fuoriCorso, isNotNull);
    expect(parola.fuoriCorso, contains('fuori corso'));
    expect(parola.fuoriCorso, contains('16:42'));
    expect(parola.fuoriCorso, contains('William Lilly'));
  });

  test('fuori corso piu\' tardi: la riga anticipa l\'orario', () {
    final inizio = DateTime(2026, 10, 16, 20, 0);
    final fine = DateTime(2026, 10, 16, 23, 10);
    final parola = LaParolaDiMedoraDelRespiro.diOggi(adesso,
        giorno: _giorno(
          segno: Zodiac.leo,
          fuoriCorso: [IntervalloFuoriCorso(inizio: inizio, fine: fine)],
        ));
    expect(parola.fuoriCorso, contains('Più tardi oggi'));
    expect(parola.fuoriCorso, contains('20:00'));
    expect(parola.fuoriCorso, contains('23:10'));
  });

  test('nessun fuori corso oggi: la riga non compare', () {
    final parola =
        LaParolaDiMedoraDelRespiro.diOggi(adesso, giorno: _giorno(segno: Zodiac.leo));
    expect(parola.fuoriCorso, isNull);
    expect(parola.righe.length, 2);
  });

  test('il giorno lunare porta solo il numero, nessun significato inventato',
      () {
    final parola = LaParolaDiMedoraDelRespiro.diOggi(adesso,
        giorno: _giorno(segno: Zodiac.leo, giornoLunare: 7));
    expect(parola.giornoLunare, 'È il giorno lunare numero 7.');
  });

  test('le righe da mostrare seguono l\'ordine della voce', () {
    final inizio = DateTime(2026, 10, 16, 9, 0);
    final fine = DateTime(2026, 10, 16, 16, 42);
    final parola = LaParolaDiMedoraDelRespiro.diOggi(adesso,
        giorno: _giorno(
          segno: Zodiac.leo,
          fuoriCorso: [IntervalloFuoriCorso(inizio: inizio, fine: fine)],
          giornoLunare: 3,
        ));
    expect(parola.righe, [parola.segno, parola.fuoriCorso, parola.giornoLunare]);
    expect(parola.righe.length, 3);
  });

  test('ogni segno dei dodici ha la sua chiave senza salute, soldi o esiti',
      () {
    for (final z in Zodiac.values) {
      final parola =
          LaParolaDiMedoraDelRespiro.diOggi(adesso, giorno: _giorno(segno: z));
      final testo = parola.segno.toLowerCase();
      for (final vietata in [
        'salute',
        'cura',
        'guari',
        'malatt',
        'soldi',
        'denaro',
        'euro',
        'ricchezz',
      ]) {
        expect(testo.contains(vietata), isFalse,
            reason: '${z.italianName}: "$vietata" non dovrebbe comparire');
      }
    }
  });
}
