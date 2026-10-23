import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/i_quattro_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/le_ombre_che_ritornano.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ANIMALE SI TROVA, NON SI CALCOLA.** Ordine FZ voce 01, 17 ottobre
/// 2026; ordine FZA voci 01 e 02, 19 ottobre 2026 (nove ombre al posto di
/// tre, a caso per persona).
///
/// **DOMANDA**, le parole del fondatore alla lettera, 17 ottobre 2026:
/// *"La 2."* (l'animale che si rivela nel viaggio, con la regola delle
/// quattro apparizioni di Harner) e *"3 si"* alla domanda dell'Architetto
/// *"L'animale viene riconosciuto quando la persona ha seguito la stessa
/// ombra quattro volte, come dice Harner?"*; *"1 tuo suggerimento"* sulla
/// regola delle ombre che ritornano. Poi, 19 ottobre 2026, 20:03 e 20:11:
/// *"Non mi piace il fatto che siano cmq riconoscibili e, quindi, pensavo
/// di farli diventare 9 e l'utente può sceglierne solo 1"*; *"Preferisco 9
/// ombre, anche se riconoscibili, perché con lince, volpe e lupo cmq
/// sarebbero simili e mettono più curiosità."*
///
/// **PROVA**: `lib/core/viaggio/le_ombre_che_ritornano.dart`, le funzioni
/// pure [LeOmbreCheRitornano.trovaIlRiconosciuto] e
/// [LeOmbreCheRitornano.ombreProposte], misurate qui senza montare nessun
/// Diario: sono funzioni pure su liste di nomi, esattamente cio' che
/// l'ordine chiede ("non serve montare widget per i cento casi").
///
/// **MISURA**: per cento sequenze di scelte diverse, il riconoscimento non
/// arriva mai prima della quarta volta della stessa ombra, e arriva sempre
/// esattamente a quella quarta volta; le ombre gia' seguite tornano sempre
/// fra le nove proposte della discesa successiva; cento persone diverse
/// alla prima discesa non vedono tutte lo stesso gruppo di nove, e la
/// stessa persona che rientra lo ritrova identico.
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

  group('FZA.01: nove ombre, se ne segue una', () {
    test(
        'le ombre gia\' seguite tornano sempre fra le nove proposte della '
        'discesa dopo', () {
      final gia = ['Lupo', 'Aquila', 'Lupo'];
      final proposte = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: gia, identita: 'prova_1');
      expect(proposte, hasLength(9));
      expect(proposte, contains('Lupo'),
          reason: 'Lupo e\' stato seguito due volte e deve tornare');
      expect(proposte, contains('Aquila'),
          reason: 'Aquila e\' stata seguita una volta e deve tornare');
    });

    test(
        'a parita\' di conteggio, le piu\' seguite vincono sulle piu\' '
        'nuove, e il resto si completa con ombre mai viste, tutte diverse', () {
      final gia = ['Lupo', 'Lupo', 'Aquila', 'Lupo'];
      final proposte = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: gia, identita: 'prova_2');
      expect(proposte, hasLength(9));
      expect(proposte, containsAll(['Lupo', 'Aquila']));
      expect(proposte.toSet().length, 9,
          reason: 'le nove proposte devono essere nove ombre diverse, mai '
              'una ripetuta');
    });

    test(
        'quando le ombre gia\' seguite sono piu\' di nove, tornano le nove '
        'piu\' seguite, a parita\' le piu\' recenti', () {
      // Orso 3 volte, Lupo 2 volte, Aquila 2 volte (piu' recente di Lupo):
      // tre nomi con conteggio superiore a uno. Poi sette ombre seguite una
      // volta sola: con tetto nove, le prime tre piu' le sei piu' recenti
      // dei sette singoli arrivano a nove, e una resta fuori. Dieci nomi
      // distinti in tutto, uno di troppo per il tetto di nove.
      final gia = [
        'Orso', 'Lupo', 'Aquila', 'Orso', 'Lupo', 'Aquila', 'Orso', // 7
        'Volpe', 'Cervo', 'Corvo', 'Falco', 'Gufo', 'Lince', 'Tartaruga', // 7
      ];
      final proposte = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: gia, identita: 'prova_3');
      expect(proposte, hasLength(9));
      expect(proposte, containsAll(['Orso', 'Aquila', 'Lupo']));
      // Fra i sette seguiti una volta sola, i sei piu' recenti vincono
      // sulla Volpe, la prima di quei sette e quindi la meno recente.
      expect(proposte, isNot(contains('Volpe')),
          reason: 'la Volpe, la meno recente delle ombre a una sola '
              'apparizione, deve restare fuori: ci sono gia\' nove ombre '
              'piu\' seguite o piu\' recenti di lei (dieci nomi distinti '
              'seguiti, uno di troppo per il tetto di nove)');
    });

    test(
        'senza nessuna discesa fatta, le nove proposte sono comunque nove, '
        'tutte diverse', () {
      final proposte = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: const [], identita: 'prova_4');
      expect(proposte, hasLength(9));
      expect(proposte.toSet().length, 9,
          reason: 'le nove proposte alla prima discesa devono essere nove '
              'ombre diverse');
    });

    test(
        'IL CARDINALE MINIMO: il catalogo ha almeno dodici animali, o la '
        'prova delle nove ombre starebbe girando su un insieme troppo '
        'piccolo', () {
      expect(AnimalCatalog.animals.length, greaterThanOrEqualTo(12),
          reason: 'le prove sopra assumono almeno dodici animali diversi '
              'per poter completare le nove proposte con ombre mai viste');
    });

    test(
        'se il catalogo ha meno di nove animali, le proposte sono quante '
        'il catalogo ne ha', () {
      final sette = AnimalCatalog.animals.take(7).toList();
      final proposte = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: const [], identita: 'prova_5', catalogo: sette);
      expect(proposte, hasLength(7));
      expect(proposte.toSet().length, 7);
    });
  });

  group('FZA.02: le ombre nuove, a caso per ogni persona', () {
    test(
        'cento persone diverse alla prima discesa non vedono tutte lo '
        'stesso gruppo di nove', () {
      final gruppi = <String>{};
      for (var i = 0; i < 100; i++) {
        final proposte = LeOmbreCheRitornano.ombreProposte(
            scelteInOrdine: const [], identita: 'persona_$i');
        gruppi.add(proposte.join(','));
      }
      // **NON TUTTI UGUALI**: con un seme per persona, cento persone non
      // possono ritrovarsi tutte lo stesso identico ordine delle nove su
      // dodici disponibili, a meno di una collisione dell'hash che sarebbe
      // praticamente impossibile su cento prove.
      expect(gruppi.length, greaterThan(1),
          reason: 'cento persone diverse vedono tutte lo stesso gruppo: le '
              'ombre nuove non escono piu\' a caso per persona, FZA.02 non '
              'e\' rispettata');
      // ignore: avoid_print
      print('ORDINE FZA VOCE 02: ${gruppi.length} gruppi diversi su 100 '
          'persone alla prima discesa');
    });

    test(
        'la stessa persona che rientra nella stessa discesa ritrova lo '
        'stesso gruppo, negli stessi posti', () {
      final gia = ['Lupo', 'Orso'];
      final prima = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: gia, identita: 'device_stabile_1');
      final dopo = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: gia, identita: 'device_stabile_1');
      expect(dopo, prima,
          reason: 'la stessa persona, alla stessa discesa, deve ritrovare '
              'lo stesso gruppo nello stesso ordine: chi esce e rientra non '
              'deve vedere le ombre rimescolarsi');
    });

    test(
        'la stessa persona a discese diverse vede gruppi diversi (il seme '
        'include il numero della discesa)', () {
      final senzaDiscese = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: const [], identita: 'device_stabile_2');
      final dopoUnaDiscesa = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: ['Lupo'], identita: 'device_stabile_2');
      expect(dopoUnaDiscesa, isNot(senzaDiscese),
          reason: 'il seme deve cambiare da una discesa all\'altra, non '
              'restare fisso per sempre sulla stessa persona');
    });

    test(
        'due persone diverse, stessa storia di scelte: le ombre gia\' '
        'seguite sono identiche, ma il resto del gruppo o il suo ordine '
        'cambia', () {
      final gia = ['Lupo', 'Lupo'];
      final personaA = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: gia, identita: 'alfa');
      final personaB = LeOmbreCheRitornano.ombreProposte(
          scelteInOrdine: gia, identita: 'beta');
      expect(personaA, contains('Lupo'));
      expect(personaB, contains('Lupo'));
      expect(personaA, isNot(personaB),
          reason: 'due persone con la stessa unica ombra gia\' seguita '
              'devono comunque vedere gruppi diversi: le ombre nuove e il '
              'posto di tutte non dipendono solo dalla storia');
    });
  });
}
