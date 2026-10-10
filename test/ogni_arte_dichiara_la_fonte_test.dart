import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **OGNI ARTE ATTIVA DICHIARA LA SUA FONTE A VIDEO.** Ordine CS, voce S2
/// della scansione, 7 settembre 2026.
///
/// **IL FATTO CHE HA FATTO NASCERE QUESTA GUARDIA.** L'ordine CS e' nato
/// perche' il fondatore ha aperto il tooltip *Fonti e metodo* dei Tre Angeli e
/// ci ha letto la nostra superficialita'. La scansione che ne e' seguita ha
/// misurato una cosa peggiore: **quattro arti attive non avevano nessun
/// tooltip delle fonti**, cioe' non dichiaravano niente affatto.
///
/// Il caso piu' netto era il Sigillo dell'Intenzione: il commento in testa alla
/// sua schermata nomina **Austin Osman Spare** e la **Rosa dei Petali della
/// Golden Dawn**, due tradizioni precise, scritte nel codice e mai a video. La
/// Sinastria VIP citava **Tolomeo, Tetrabiblos I.12 e I.17-18** dentro
/// `altre_affinita.dart`, e a schermo non compariva da nessuna parte.
///
/// **COSA MISURA, e cosa non puo' misurare.** Verifica che ogni arte attiva
/// abbia nel suo file la via che apre le fonti. **Non puo' giudicare se il
/// testo dice il vero**: quello lo sa solo chi ha aperto le opere. Cio' che
/// puo' fare, e fa, e' impedire che un'arte viva torni a tacere del tutto.
void main() {
  /// Le arti attive, e dove vive la loro schermata.
  ///
  /// La tavola sta qui e non nel catalogo perche' e' una mappa fra un'arte e
  /// un file, che il catalogo non conosce: chi porta viva un'arte nuova
  /// aggiunge una riga, e nel farlo si accorge di dover dichiarare la fonte.
  const schermate = <String, String>{
    'horoscope': 'lib/features/horoscope/oroscopo_screen.dart',
    'synastry_vip': 'lib/features/synastry/sinastria_vip_screen.dart',
    'tarot_spread_three': 'lib/features/tarot/stesa_tre_carte_screen.dart',
    'meditation':
        'lib/features/maestri/aura/meditation/meditation_screen.dart',
    'archetype_test':
        'lib/features/maestri/aura/archetype/archetype_test_screen.dart',
    'face_constellation':
        'lib/features/maestri/aura/face/face_constellation_screen.dart',
    'rune_draw': 'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
    'guide_animal':
        'lib/features/maestri/caligo/animal/guide_animal_screen.dart',
    'magic_sigil':
        'lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart',
    'guardian_angel': 'lib/features/angels/angels_screen.dart',
  };

  /// I modi in cui una schermata puo' dichiarare le sue fonti. Sono piu' di
  /// uno perche' cinque arti se lo erano scritto ognuna a modo suo, prima che
  /// nascesse la porta comune.
  const modi = <String>[
    'FoglioDelleFonti',
    'Fonti e metodo',
    'Da dove nasce',
    '_mostraFonti',
  ];

  test('le arti attive del catalogo sono tutte nella tavola', () {
    // **LA META\' CHE DIFENDE.** Chi porta viva un'arte nuova e non la mette
    // qui fa cadere questa prova, e nel rimediare deve dire dove sta la sua
    // schermata: a quel punto la fonte se la pone.
    final catalogo =
        File('lib/core/arts/art_catalog.dart').readAsStringSync();
    final righe = catalogo.split('\n');
    final attive = <String>[];
    String? ultimoId;
    for (final r in righe) {
      final m = RegExp(r"id: '([a-z_]+)'").firstMatch(r);
      if (m != null) ultimoId = m.group(1);
      if (r.contains('ArtState.attiva') && ultimoId != null) {
        attive.add(ultimoId);
        ultimoId = null;
      }
    }
    expect(attive.length, greaterThanOrEqualTo(9),
        reason: 'il catalogo non porta piu\' le arti attive attese: la lettura '
            'di questa prova non sta misurando niente');
    final fuoriTavola =
        attive.where((a) => !schermate.containsKey(a)).toList();
    expect(fuoriTavola, isEmpty,
        reason: 'queste arti sono attive e non stanno nella tavola delle '
            'schermate: $fuoriTavola. Aggiungile, e dichiara la loro fonte');
  });

  test('ogni arte attiva ha una via per le sue fonti', () {
    final mute = <String>[];
    schermate.forEach((arte, percorso) {
      final f = File(percorso);
      if (!f.existsSync()) {
        mute.add('$arte: il file $percorso non esiste');
        return;
      }
      final testo = f.readAsStringSync();
      if (!modi.any(testo.contains)) mute.add(arte);
    });
    expect(mute, isEmpty,
        reason: 'queste arti attive non dichiarano nessuna fonte a chi legge: '
            '$mute. E\' il difetto che ha aperto l\'ordine CS, e una funzione '
            'che poggia su una tradizione senza nominarla chiede fiducia '
            'cieca');
  });

  test('i testi delle quattro fonti nuove nominano opera e autore', () {
    // **UNA FONTE SENZA NOME NON E\' UNA FONTE.** Dire «la tradizione» non
    // basta: chi legge deve poter risalire all'opera.
    final testi = File('lib/features/maestri/widgets/foglio_delle_fonti.dart')
        .readAsStringSync();
    const attesi = <String, List<String>>{
      'tarocchi': ['Rider-Waite-Smith', 'Waite', 'Pamela Colman Smith', '1909'],
      'sinastria': ['Tolomeo', 'Tetrabiblos'],
      'sigillo': ['Austin Osman Spare', 'Golden Dawn'],
      'soffio': ['transiti', 'effemeridi'],
    };
    final mancanti = <String>[];
    attesi.forEach((arte, nomi) {
      for (final n in nomi) {
        if (!testi.contains(n)) mancanti.add('$arte non nomina «$n»');
      }
    });
    expect(mancanti, isEmpty, reason: mancanti.join('\n'));
  });

  test('nessun testo delle fonti si scusa', () {
    // La stessa regola della nota degli Angeli, decisa dal fondatore il
    // 6 settembre 2026: positivo, senza dubbi ne' confessioni.
    final testi = File('lib/features/maestri/widgets/foglio_delle_fonti.dart')
        .readAsStringSync();
    // Si guarda solo la parte dei testi, non i commenti che raccontano il
    // difetto: quelli parlano a chi legge il codice, non alla persona.
    final da = testi.indexOf('class TestiDelleFonti');
    expect(da, greaterThan(0));
    final soloTesti = testi.substring(da);
    for (final scusa in const [
      'seconda mano',
      'non verificat',
      'non consultat',
      'edizione primaria',
    ]) {
      expect(soloTesti.contains(scusa), isFalse,
          reason: 'un testo delle fonti contiene «$scusa»: e\' una scusa, e '
              'una nota che si scusa manda chi legge a controllare da sola');
    }
  });
}
