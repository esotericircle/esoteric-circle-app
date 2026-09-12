import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/rituals/animal_constellations.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI ANIMALE HA LA SUA COSTELLAZIONE, ordine L voce 3d.
///
/// Dodici insiemi di punti cardinali presi dalla sagoma di CIASCUN animale,
/// in un file di dati solo: non un disegno generico ripetuto dodici volte.
/// Questa prova enumera i dodici animali del catalogo e pretende per ognuno
/// il suo insieme, diverso da tutti gli altri.
void main() {
  test('i dodici animali del catalogo hanno ciascuno la sua costellazione', () {
    expect(AnimalCatalog.animals.length, 12,
        reason: 'Il catalogo non porta piu\' dodici animali: la prova va '
            'riletta prima di toccare i dati.');
    for (final animale in AnimalCatalog.animals) {
      final c = costellazioneDi(animale.name);
      expect(c.figura.punti.length, greaterThanOrEqualTo(5),
          reason: '${animale.name}: meno di cinque punti non disegnano una '
              'sagoma, disegnano un segno qualunque.');
      expect(c.figura.fili, isNotEmpty,
          reason: '${animale.name}: senza fili non c\'e\' niente da unire.');
      for (final p in c.figura.punti) {
        expect(p.nome.trim(), isNotEmpty,
            reason: '${animale.name}: un punto senza nome anatomico non si '
                'puo\' correggere guardando la sagoma.');
        expect(p.punto.dx >= 0 && p.punto.dx <= 1, isTrue,
            reason: '${animale.name}, ${p.nome}: fuori dalla tela in x.');
        expect(p.punto.dy >= 0 && p.punto.dy <= 1, isTrue,
            reason: '${animale.name}, ${p.nome}: fuori dalla tela in y.');
      }
      for (final (a, b) in c.figura.fili) {
        expect(a >= 0 && a < c.figura.punti.length, isTrue,
            reason: '${animale.name}: un filo parte da un punto che non '
                'esiste ($a).');
        expect(b >= 0 && b < c.figura.punti.length, isTrue,
            reason: '${animale.name}: un filo arriva a un punto che non '
                'esiste ($b).');
        expect(a != b, isTrue,
            reason: '${animale.name}: un filo su se stesso.');
      }
    }
  });

  test('le dodici costellazioni sono tutte diverse fra loro', () {
    // IL DISEGNO GENERICO RIPETUTO e' il difetto che questa prova esiste per
    // prendere: due animali con gli stessi punti sono lo stesso disegno con
    // due nomi.
    String impronta(CostellazioneAnimale c) => c.figura.punti
        .map((p) => '${p.punto.dx.toStringAsFixed(3)},'
            '${p.punto.dy.toStringAsFixed(3)}')
        .join(';');
    final viste = <String, String>{};
    for (final animale in AnimalCatalog.animals) {
      final c = costellazioneDi(animale.name);
      final i = impronta(c);
      expect(viste.containsKey(i), isFalse,
          reason: '${animale.name} e ${viste[i]} hanno la STESSA '
              'costellazione: e\' un disegno generico ripetuto, non la '
              'sagoma di ciascuno.');
      viste[i] = animale.name;
    }
  });
}
