import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/widgets/striscia_altre_arti.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA FILA "LE ALTRE ARTI DEL CERCHIO". Ordine AK voce 02.
///
/// In home la fila e' il COMPLEMENTO PURO: le arti attive del catalogo che
/// non stanno nello scaffale, calcolate e mai cablate. Un'arte non compare
/// mai in due posti della stessa schermata; se la fila resta vuota, la
/// sezione sparisce intera. Il calcolo si prova sul dato (artiDaScoprire con
/// corrente nullo), che e' l'unica porta della fila.
void main() {
  final attive = <String>{
    for (final m in Maestro.values)
      for (final a in ArtCatalog.activeOf(m)) a.id,
  };

  test("col seme di Mauro la fila e' Test Archetipo e Sigillo", () {
    final gia = ArtiPreferiteController.semePer(null).toSet();
    final fila = artiDaScoprire(null, gia: gia, giorno: DateTime(2026, 8, 17))
        .map((a) => a.id)
        .toList();
    // ignore: avoid_print
    print('ORDINE AK VOCE 02: fila col seme: $fila');
    expect(fila.toSet(), attive.difference(gia),
        reason: 'la fila non e\' il complemento delle preferite');
    expect(fila.toSet(), {'archetype_test', 'magic_sigil'},
        reason: 'oggi il resto del catalogo e\' Test Archetipo e Sigillo '
            'dell\'Intenzione');
  });

  test('cambiate le preferite, la fila mostra il resto e mai doppioni', () {
    final gia = {'horoscope', 'meditation'};
    final fila = artiDaScoprire(null, gia: gia, giorno: DateTime(2026, 8, 17))
        .map((a) => a.id)
        .toList();
    expect(fila.toSet(), attive.difference(gia),
        reason: 'la fila non segue le preferite della persona');
    expect(fila.toSet().length, fila.length,
        reason: 'la fila porta la stessa arte due volte');
    for (final id in gia) {
      expect(fila, isNot(contains(id)),
          reason: 'l\'arte $id sta nello scaffale E nella fila: due posti '
              'nella stessa schermata');
    }
  });

  test("a scaffale pieno di tutto, la fila e' vuota", () {
    final fila =
        artiDaScoprire(null, gia: attive, giorno: DateTime(2026, 8, 17));
    expect(fila, isEmpty,
        reason: 'con tutte le attive nello scaffale non resta niente da '
            'mostrare, e la sezione deve sparire');
  });
}
