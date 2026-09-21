// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/ricordi/artwork_del_ricordo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **IL RICORDO CUSTODITO PORTA IL VERSO.** Ordine EC voce 05, 21 settembre
/// 2026.
///
/// **Il fatto.** *"Una carta rovesciata interpretata come dritta e' un
/// responso sbagliato, non una sfumatura"*, ordine EB voce 01, che aveva
/// visto il difetto sulla Stesa e lo aveva lasciato fuori dal suo perimetro.
/// Il censimento di quest'ordine lo ha trovato **piu' largo in due modi**.
///
/// **Primo: non e' solo la Stesa.** Delle quattro arti che custodiscono
/// carte o rune, due non salvavano il verso nei dati, la Stesa
/// (`stesa_tre_carte_screen.dart`) e l'Estrazione Rune
/// (`rune_draw_screen.dart`), tutte e due col nome nudo.
///
/// **Secondo, e piu' grave: il verso che due arti gia' salvavano non
/// arrivava mai al disegno delle carte.** In `ricordi_screen.dart` il ramo
/// della carta tornava con `TarotCardArt` **prima** della rotazione, e quella
/// rotazione parlava di rune e di rune sole. Quindi una carta rovesciata si
/// disegnava sempre dritta, e **l'Arcano dell'Alba, che il verso lo salva da
/// sempre, non lo ha mai mostrato**. **Padre: PROVENIENZA IGNOTA**, la
/// rotazione nasce per le rune e nessun ordine risulta aver considerato le
/// carte.
void main() {
  /// Le quattro arti che custodiscono carte o rune, col nome della chiave dei
  /// nomi e di quella del verso.
  const conFigure = <String, (String, String)>{
    'stesa': ('carte', 'versi'),
    'gettata': ('rune', 'versi'),
    'alba': ('carta', 'verso'),
    'tramonto': ('runa', 'verso'),
  };

  test('le quattro arti con figure salvano il verso, e si contano', () {
    cardinaleMinimo(conFigure.length, 4,
        cosa: 'arti che custodiscono carte o rune',
        perche: 'Se la tavola si svuotasse, questa prova direbbe di si\' a '
            'niente. Le dodici arti che custodiscono un Ricordo stanno nel '
            'manifesto dell\'ordine EC, e quattro di loro hanno figure.');

    // **Si legge il sorgente senza i commenti**: i commenti di questa cura
    // nominano il difetto che cura, e una prova che li leggesse cadrebbe su
    // se stessa. E' un inciampo che questa casa ha gia' pagato tre volte.
    final schermate = <String, String>{
      'stesa': 'lib/features/tarot/stesa_tre_carte_screen.dart',
      'gettata': 'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
      'alba': 'lib/features/rituals/arcano_dell_alba_screen.dart',
      'tramonto': 'lib/features/rituals/sunset_rune_screen.dart',
    };
    final senza = <String>[];
    schermate.forEach((arte, percorso) {
      final sorgente = senzaCommenti(File(percorso).readAsStringSync());
      final chiave = conFigure[arte]!.$2;
      if (!sorgente.contains("'$chiave':")) {
        senza.add('$arte non scrive la chiave "$chiave" nei dati custoditi '
            '($percorso)');
      }
    });
    print('ORDINE EC VOCE 05: arti con figure ${conFigure.length}, '
        'senza il verso ${senza.length}');
    expect(senza, isEmpty, reason: senza.join('\n'));
  });

  test('e il verso salvato arriva all\'immagine, per tutte e quattro', () {
    // Una figura rovesciata per arte, come la scriverebbe la schermata.
    const casi = <String, Map<String, String>>{
      'stesa': {'carte': 'Il Papa,Re di Spade', 'versi': 'dritta,rovesciata'},
      'gettata': {'rune': 'Uruz,Ansuz', 'versi': 'dritta,rovesciata'},
      'alba': {'carta': 'La Torre', 'verso': 'rovesciata'},
      'tramonto': {'runa': 'Laguz', 'verso': 'ombra'},
    };
    final storti = <String>[];
    casi.forEach((arte, dati) {
      final immagini = ArtworkDelRicordo.perArte(arte, dati);
      if (immagini.isEmpty) {
        storti.add('$arte: nessuna immagine, la prova misurerebbe il vuoto');
        return;
      }
      final rovesciate = immagini.where((i) => i.rovesciata).length;
      print('ORDINE EC VOCE 05, $arte: immagini ${immagini.length}, '
          'rovesciate $rovesciate');
      if (rovesciate != 1) {
        storti.add('$arte: le immagini rovesciate sono $rovesciate e doveva '
            'essercene una, quindi il verso salvato non arriva al disegno');
      }
    });
    expect(storti, isEmpty, reason: storti.join('\n'));
  });

  test('e chi disegna la carta le passa il verso', () {
    // **La seconda meta', e senza di lei la prima resta verde a vuoto.** Il
    // dato puo' dire che la carta e' rovesciata e il disegno tornare prima di
    // guardarlo: e' esattamente cio' che succedeva.
    final schermo = senzaCommenti(
        File('lib/features/ricordi/ricordi_screen.dart').readAsStringSync());
    expect(schermo.contains('TarotCardArt('), isTrue,
        reason: 'la schermata dei Ricordi non disegna piu\' nessuna carta: la '
            'prova misurerebbe il vuoto');
    final dove = schermo.indexOf('TarotCardArt(');
    final attorno =
        schermo.substring(dove, (dove + 260).clamp(0, schermo.length));
    print('ORDINE EC VOCE 05, il disegno della carta:\n$attorno');
    expect(attorno.contains('reversed:'), isTrue,
        reason: 'la carta di un Ricordo si disegna sempre dritta: il verso '
            'salvato non arriva a chi la disegna, e una carta rovesciata '
            'mostrata dritta dice un\'altra cosa');
  });
}
