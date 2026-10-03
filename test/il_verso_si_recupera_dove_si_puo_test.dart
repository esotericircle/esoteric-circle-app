// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/ricordi/il_verso_recuperato.dart';
import 'package:esoteric_circle/core/ricordi/ricordo_custodito.dart';
import 'package:esoteric_circle/core/ricordi/artwork_del_ricordo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL VERSO SI RECUPERA DOVE SI PUO'.** Ordine EC voce 06, 21 settembre
/// 2026.
///
/// **Decisione del fondatore, verbatim**: *"Recupera dove si puo'"*.
///
/// **Cosa misura, e su Ricordi costruiti apposta.** Un Ricordo salvato prima
/// della voce EC.05 non ha la chiave dei versi, ma il suo testo nomina le
/// figure col verso. Qui si costruiscono i casi che contano e si conta:
/// **quanti recuperati, quanti rimasti com'erano, nessuno perso**.
///
/// **La regola che comanda su tutte: nessun verso si inventa.** Se il testo
/// non dice il verso di anche una sola figura, il Ricordo resta intatto.
void main() {
  RicordoCustodito custodito({
    required String arte,
    required String testo,
    required Map<String, String> dati,
  }) =>
      RicordoCustodito(
        quando: DateTime(2026, 9, 1, 10, 30),
        arte: arte,
        maestro: 'medora',
        titolo: 'Un responso di prima',
        testo: testo,
        comeENato: ComeENato.gesto,
        dati: dati,
      );

  /// I casi, col loro esito atteso: `true` si recupera, `false` resta com'e'.
  final casi = <String, (RicordoCustodito, bool, String?)>{
    'stesa con una carta rovesciata, e il testo lo dice': (
      custodito(
        arte: 'stesa',
        testo: 'Nel passato Il Papa parla di una regola accettata. Nel '
            'presente Re di Spade rovesciato mostra una durezza che non '
            'serve. Nel futuro Dieci di Spade chiude un peso.',
        dati: const {'carte': 'Il Papa,Re di Spade,Dieci di Spade'},
      ),
      true,
      'dritta,rovesciata,dritta',
    ),
    'stesa tutta dritta': (
      custodito(
        arte: 'stesa',
        testo: 'Il Papa, Re di Spade e Dieci di Spade parlano insieme.',
        dati: const {'carte': 'Il Papa,Re di Spade,Dieci di Spade'},
      ),
      true,
      'dritta,dritta,dritta',
    ),
    'gettata con una runa in merkstave': (
      custodito(
        arte: 'gettata',
        testo: 'Uruz diritta per cio\' che spinge, Ansuz in merkstave '
            '(rovesciata) per cio\' che tace, Laguz diritta per cio\' che '
            'scorre.',
        dati: const {'gettata': 'Le tre Norne', 'rune': 'Uruz,Ansuz,Laguz'},
      ),
      true,
      'dritta,ombra,dritta',
    ),
    'stesa il cui testo non nomina una carta: resta com\'e\'': (
      custodito(
        arte: 'stesa',
        testo: 'Il Papa apre, e il resto della lettura parla d\'altro.',
        dati: const {'carte': 'Il Papa,Re di Spade'},
      ),
      false,
      null,
    ),
    'gettata col testo che non dice il verso: resta com\'e\'': (
      custodito(
        arte: 'gettata',
        testo: 'Uruz e Ansuz si guardano.',
        dati: const {'rune': 'Uruz,Ansuz'},
      ),
      false,
      null,
    ),
    'un Ricordo che il verso ce l\'ha gia\': non si tocca': (
      custodito(
        arte: 'stesa',
        testo: 'Il Papa rovesciato apre la lettura.',
        dati: const {'carte': 'Il Papa', 'versi': 'dritta'},
      ),
      false,
      null,
    ),
    'un\'arte senza figure: non la riguarda': (
      custodito(
        arte: 'oroscopo',
        testo: 'Il cielo di oggi.',
        dati: const {'segno': 'Leone'},
      ),
      false,
      null,
    ),
  };

  test('il verso si recupera dal testo, e dove non c\'e\' non si inventa', () {
    cardinaleMinimo(casi.length, 7,
        cosa: 'Ricordi costruiti per il recupero',
        perche: 'Se l\'elenco si svuotasse, questa prova direbbe di si\' a '
            'niente. Servono i casi che recuperano E quelli che devono '
            'restare intatti.');
    var recuperati = 0;
    var intatti = 0;
    final storti = <String>[];
    casi.forEach((nome, caso) {
      final (ricordo, atteso, versiAttesi) = caso;
      final dati = IlVersoRecuperato.datiRecuperati(ricordo);
      if ((dati != null) != atteso) {
        storti.add('$nome: recuperato ${dati != null}, atteso $atteso');
        return;
      }
      if (dati == null) {
        intatti++;
        return;
      }
      recuperati++;
      if (dati['versi'] != versiAttesi) {
        storti.add('$nome: versi "${dati['versi']}" invece di "$versiAttesi"');
      }
    });
    print('ORDINE EC VOCE 06: casi ${casi.length}, recuperati $recuperati, '
        'rimasti com\'erano $intatti');
    expect(storti, isEmpty, reason: storti.join('\n'));
    expect(recuperati, 3);
    expect(intatti, 4);
  });

  test('il recupero non perde niente di quello che c\'era', () {
    // **La regola piu' importante dopo "non si inventa".** Un recupero che
    // perdesse il titolo, il testo o un altro dato sarebbe peggio del difetto
    // che cura: il difetto toglie un verso, questo toglierebbe un Ricordo.
    final prima = casi.values.first.$1;
    final dati = IlVersoRecuperato.datiRecuperati(prima)!;
    final dopo = prima.conDati(dati);
    print('ORDINE EC VOCE 06: dati prima ${prima.dati.length}, '
        'dopo ${dopo.dati.length}');
    expect(dopo.quando, prima.quando);
    expect(dopo.arte, prima.arte);
    expect(dopo.maestro, prima.maestro);
    expect(dopo.titolo, prima.titolo);
    expect(dopo.testo, prima.testo);
    expect(dopo.comeENato, prima.comeENato);
    for (final chiave in prima.dati.keys) {
      expect(dopo.dati[chiave], prima.dati[chiave],
          reason: 'il recupero ha cambiato il dato "$chiave"');
    }
    expect(dopo.dati.length, prima.dati.length + 1,
        reason: 'il recupero deve aggiungere una chiave sola');
  });

  test('e ripetere il recupero non cambia niente', () {
    // Il recupero gira a ogni apertura: la seconda volta non deve avere
    // niente da fare, o riscriverebbe lo scrigno per sempre.
    final prima = casi.values.first.$1;
    final unaVolta = prima.conDati(IlVersoRecuperato.datiRecuperati(prima)!);
    final dueVolte = IlVersoRecuperato.datiRecuperati(unaVolta);
    print('ORDINE EC VOCE 06, secondo giro: '
        '${dueVolte == null ? "niente da fare" : "riscrive"}');
    expect(dueVolte, isNull,
        reason: 'il recupero rifarebbe il lavoro a ogni apertura');
  });

  test('e il verso recuperato arriva davvero al disegno', () {
    // Senza questa, il recupero potrebbe scrivere una chiave che nessuno
    // legge, ed e' esattamente il difetto che l'Arcano dell'Alba aveva.
    final ricordo = casi.values.first.$1;
    final dati = IlVersoRecuperato.datiRecuperati(ricordo)!;
    final immagini = ArtworkDelRicordo.perArte('stesa', dati);
    final rovesciate = immagini.where((i) => i.rovesciata).length;
    print('ORDINE EC VOCE 06: immagini ${immagini.length}, '
        'rovesciate $rovesciate');
    expect(immagini, hasLength(3));
    expect(rovesciate, 1, reason: 'il verso recuperato non arriva al disegno');
    expect(immagini[1].rovesciata, isTrue,
        reason: 'la carta rovesciata non e\' la seconda: l\'ordine dei versi '
            'non segue l\'ordine delle carte');
  });
}
