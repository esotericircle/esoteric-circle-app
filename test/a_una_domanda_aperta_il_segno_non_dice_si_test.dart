import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:flutter_test/flutter_test.dart';

/// **A UNA DOMANDA APERTA IL SEGNO NON DICE SI' NE' NO.** Simulazione da
/// persona del 20 ottobre 2026 sul Realme 767f596c: *"Quali numeri usciranno
/// al lotto sabato?"* riceveva dalla via di riserva *"Il Cavallo ti si
/// avvicina. Vuol dire che quello che chiedi ha il suo si'"*. Ordine FZ voce
/// FZ.05: i tre gesti sono si', guarda meglio, no; a cio' che non chiede un
/// si' o un no risponde solo "guarda meglio". Padre: ordine DI voce 14 (la
/// riserva sceglie il gesto a caso, per qualunque domanda).
///
/// **Cosa misura**: per le domande aperte la riserva da' sempre "si volta",
/// per tutti e dodici gli animali e in trenta giorni diversi; per le domande
/// chiuse i tre gesti restano tutti possibili.
void main() {
  const aperte = [
    'Quali numeri usciranno al lotto sabato?',
    'Quando lo rivedrò?',
    'Come devo dirglielo?',
    'Perché mi ha lasciato?',
    'Chi mi vuole davvero bene?',
    'Che cosa devo fare adesso?',
    'Dove andrò a vivere?',
    'Quanto guadagnerò?',
  ];
  const chiuse = [
    'Devo accettare il nuovo lavoro?',
    'Mi ama ancora?',
    'È il momento di partire?',
  ];

  test(
      'PER LE DOMANDE APERTE LA RISERVA DA\' SEMPRE "GUARDA MEGLIO", per '
      'tutti e dodici gli animali e trenta giorni', () {
    var guardati = 0;
    final sbagliati = <String>[];
    for (final a in AnimalCatalog.animals) {
      for (final d in aperte) {
        for (var g = 0; g < 30; g++) {
          final s = GestiDelSegno.diRiserva(
              animale: a, domanda: d, giorno: DateTime(2026, 11, 1 + g));
          guardati++;
          if (s.gesto != GestoDelSegno.siVolta) {
            sbagliati.add('${a.name} "$d" ${s.gesto.name}');
          }
        }
      }
    }
    expect(sbagliati, isEmpty,
        reason: 'a domande aperte la riserva risponde si\' o no: '
            '${sbagliati.take(5).join('; ')}');
    expect(guardati, 12 * aperte.length * 30);
  });

  test('PER LE DOMANDE CHIUSE I TRE GESTI RESTANO POSSIBILI', () {
    final visti = <GestoDelSegno>{};
    for (final a in AnimalCatalog.animals) {
      for (final d in chiuse) {
        for (var g = 0; g < 30; g++) {
          visti.add(GestiDelSegno.diRiserva(
                  animale: a, domanda: d, giorno: DateTime(2026, 11, 1 + g))
              .gesto);
        }
      }
    }
    expect(visti, GestoDelSegno.values.toSet(),
        reason: 'per le domande chiuse la riserva non usa piu\' tutti e tre '
            'i gesti: la cura ha toccato anche loro');
  });
}
