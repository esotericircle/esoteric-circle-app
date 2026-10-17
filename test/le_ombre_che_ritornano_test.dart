import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/i_quattro_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/le_ombre_che_ritornano.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ANIMALE SI TROVA, NON SI CALCOLA.** Ordine FZ voce 01, 17 ottobre
/// 2026.
///
/// **DOMANDA**, le parole del fondatore alla lettera, 17 ottobre 2026:
/// *"La 2."* (l'animale che si rivela nel viaggio, con la regola delle
/// quattro apparizioni di Harner) e *"3 si"* alla domanda dell'Architetto
/// *"L'animale viene riconosciuto quando la persona ha seguito la stessa
/// ombra quattro volte, come dice Harner?"*; *"1 tuo suggerimento"* sulla
/// regola delle ombre che ritornano.
///
/// **PROVA**: `lib/core/viaggio/le_ombre_che_ritornano.dart`, le funzioni
/// pure [LeOmbreCheRitornano.trovaIlRiconosciuto] e
/// [LeOmbreCheRitornano.treOmbreProposte], misurate qui senza montare nessun
/// Diario: sono funzioni pure su liste di nomi, esattamente cio' che
/// l'ordine chiede ("non serve montare widget per i cento casi").
///
/// **MISURA**: per cento sequenze di scelte diverse, il riconoscimento non
/// arriva mai prima della quarta volta della stessa ombra, e arriva sempre
/// esattamente a quella quarta volta; le ombre gia' seguite tornano sempre
/// fra le tre proposte della discesa successiva.
void main() {
  group('FZ.01: il riconoscimento arriva alla quarta, mai prima', () {
    /// Dato [scelte], il piu' alto conteggio raggiunto da un solo nome nei
    /// primi [fino] elementi.
    int massimoConteggio(List<String> scelte, int fino) {
      final conto = <String, int>{};
      var massimo = 0;
      for (var i = 0; i < fino; i++) {
        final n = (conto[scelte[i]] ?? 0) + 1;
        conto[scelte[i]] = n;
        if (n > massimo) massimo = n;
      }
      return massimo;
    }

    /// Verifica, su [scelte], che [LeOmbreCheRitornano.trovaIlRiconosciuto]
    /// non riconosca mai prima che un nome arrivi a quattro, e riconosca
    /// esattamente quel nome non appena ci arriva.
    void verificaSequenza(String etichetta, List<String> scelte) {
      for (var fino = 1; fino <= scelte.length; fino++) {
        final prefisso = scelte.sublist(0, fino);
        final trovato = LeOmbreCheRitornano.trovaIlRiconosciuto(prefisso);
        final massimo = massimoConteggio(scelte, fino);
        if (massimo < IQuattroViaggi.quanteDiscese) {
          expect(trovato, isNull,
              reason: '$etichetta: a $fino discese il massimo e\' $massimo, '
                  'e ha gia\' riconosciuto "$trovato": il riconoscimento e\' '
                  'arrivato prima della quarta volta della stessa ombra.');
        } else {
          expect(trovato, isNotNull,
              reason: '$etichetta: a $fino discese il massimo e\' $massimo '
                  '(>= 4) e non ha ancora riconosciuto niente.');
          // Il nome riconosciuto e\' quello che a questo punto ha davvero
          // raggiunto quattro.
          final conto = <String, int>{};
          for (var i = 0; i < fino; i++) {
            conto[prefisso[i]] = (conto[prefisso[i]] ?? 0) + 1;
          }
          expect(conto[trovato],
              greaterThanOrEqualTo(IQuattroViaggi.quanteDiscese),
              reason: '$etichetta: "$trovato" e\' stato dichiarato '
                  'riconosciuto con solo ${conto[trovato]} volte.');
        }
      }
    }

    test(
        'CENTO PERSONE con scelte diverse: sempre alla quarta volta della '
        'stessa ombra, mai prima', () {
      final nomi = [for (final a in AnimalCatalog.animals) a.name];
      final persone = <String, List<String>>{};

      // 12 persone: sempre la stessa ombra, una per ogni animale del
      // catalogo. Riconoscimento garantito esattamente alla quarta discesa.
      for (final nome in nomi) {
        persone['sempre_$nome'] = List.filled(6, nome);
      }

      // 12 x 11 persone: due ombre alternate (A, B, A, B, ...). La prima
      // ombra arriva a quattro all'ottava discesa (posizioni 1,3,5,7), la
      // seconda non arriva mai a quattro prima, perche' ne fa tre al massimo
      // nello stesso arco.
      for (final a in nomi) {
        for (final b in nomi) {
          if (a == b) continue;
          persone['alterna_${a}_$b'] =
              List.generate(8, (i) => i.isEven ? a : b);
        }
      }

      // 100 persone esatte: le prime 100 chiavi, in ordine deterministico
      // (le mappe Dart conservano l'ordine di inserimento).
      final scelte = persone.entries.take(100).toList();
      expect(scelte.length, 100,
          reason: 'le combinazioni generate sono troppo poche per isolare '
              'cento persone');
      for (final voce in scelte) {
        verificaSequenza(voce.key, voce.value);
      }
      // ignore: avoid_print
      print('ORDINE FZ VOCE 01: verificate ${scelte.length} persone, '
          'nessun riconoscimento prima della quarta volta della stessa '
          'ombra');
    });

    test(
        'UN CAMBIO OGNI VOLTA: nessun riconoscimento finche\' il giro non '
        'ripete la stessa ombra quattro volte', () {
      // Un giro tra tutti e dodici: nessuna ombra torna prima del tredicesimo
      // passo, quindi nessuna arriva a quattro prima del trentasettesimo
      // (tre giri completi piu' uno).
      final nomi = [for (final a in AnimalCatalog.animals) a.name];
      final giri = <String>[];
      for (var giro = 0; giro < 4; giro++) {
        giri.addAll(nomi);
      }
      verificaSequenza('un_giro_dopo_l_altro', giri);
      final trovato = LeOmbreCheRitornano.trovaIlRiconosciuto(giri);
      expect(trovato, nomi.first,
          reason: 'al quarto giro completo la prima ombra del giro ha fatto '
              'quattro volte, ed e\' quella che deve risultare riconosciuta');
    });
  });

  group('FZ.01: le ombre che ritornano', () {
    test(
        'le ombre gia\' seguite tornano sempre fra le tre proposte della '
        'discesa dopo', () {
      final gia = ['Lupo', 'Aquila', 'Lupo'];
      final proposte =
          LeOmbreCheRitornano.treOmbreProposte(scelteInOrdine: gia);
      expect(proposte, hasLength(3));
      expect(proposte, contains('Lupo'),
          reason: 'Lupo e\' stato seguito due volte e deve tornare');
      expect(proposte, contains('Aquila'),
          reason: 'Aquila e\' stata seguita una volta e deve tornare');
    });

    test(
        'a parita\' di conteggio, le piu\' seguite vincono sulle piu\' '
        'nuove, e il resto si completa con ombre mai viste', () {
      // Lupo seguito tre volte, Aquila una sola: Lupo deve tornare sempre,
      // Aquila una volta sola non basta a scavalcare un'ombra mai vista se
      // le gia' seguite sono piu' di tre... qui sono solo due, quindi
      // tornano tutte e due, e la terza e' nuova.
      final gia = ['Lupo', 'Lupo', 'Aquila', 'Lupo'];
      final proposte =
          LeOmbreCheRitornano.treOmbreProposte(scelteInOrdine: gia);
      expect(proposte, hasLength(3));
      expect(proposte, containsAll(['Lupo', 'Aquila']));
      expect(proposte.where((n) => n != 'Lupo' && n != 'Aquila'), hasLength(1),
          reason: 'la terza proposta deve essere un\'ombra mai vista');
    });

    test(
        'quando le ombre gia\' seguite sono piu\' di tre, tornano le tre '
        'piu\' seguite, a parita\' le piu\' recenti', () {
      // Orso 3 volte, Lupo 2 volte, Aquila 2 volte (piu' recente di Lupo),
      // Volpe 1 volta: le prime tre per conteggio sono Orso, Aquila, Lupo
      // (Aquila batte Lupo perche' seguita piu' di recente a parita' di
      // due).
      final gia = [
        'Orso',
        'Lupo',
        'Aquila',
        'Orso',
        'Lupo',
        'Aquila',
        'Orso',
        'Volpe',
      ];
      final proposte =
          LeOmbreCheRitornano.treOmbreProposte(scelteInOrdine: gia);
      expect(proposte, hasLength(3));
      expect(proposte, containsAll(['Orso', 'Aquila', 'Lupo']));
      expect(proposte, isNot(contains('Volpe')),
          reason: 'la Volpe, seguita una sola volta, deve restare fuori '
              'quando ci sono gia\' tre ombre piu\' seguite di lei');
    });

    test('senza nessuna discesa fatta, le tre proposte sono comunque tre', () {
      final proposte =
          LeOmbreCheRitornano.treOmbreProposte(scelteInOrdine: const []);
      expect(proposte, hasLength(3));
      expect(proposte.toSet().length, 3,
          reason: 'le tre proposte alla prima discesa devono essere tre '
              'ombre diverse');
    });

    test(
        'IL CARDINALE MINIMO: il catalogo ha almeno dodici animali, o la '
        'prova delle tre ombre starebbe girando su un insieme troppo '
        'piccolo', () {
      expect(AnimalCatalog.animals.length, greaterThanOrEqualTo(12),
          reason: 'le prove sopra assumono almeno dodici animali diversi '
              'per poter completare le tre proposte con ombre mai viste');
    });
  });
}
