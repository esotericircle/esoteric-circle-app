import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/angels/angel_lore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il contenuto degli angeli che arriva a schermo, e la politica che lo governa.
///
/// Il Corpus porta in testa una politica di pubblicazione scritta dai
/// verificatori: guarigione e salute in ogni forma, promesse di esito, entita'
/// avverse e corrispondenze goetiche non si pubblicano. Qui si verifica che
/// quella politica valga davvero sul testo che l'utente legge, invece di
/// doverla ricontrollare a mano ogni volta che il Corpus cambia.
void main() {
  /// I termini che non devono comparire. L'elenco e' esposto apposta, cosi' si
  /// allunga senza cercare dove.
  const vietati = [
    'guarigione',
    'guarire',
    'guarisce',
    'guaritore',
    'salute',
    'malattia',
    'malattie',
    'malato',
    'malati',
    'fertilita',
    'fecondita',
    'sterilita',
    'longevita',
    'medicina',
    'medico',
    'panacea',
    'pietra filosofale',
    'tesori',
    'tesoro',
    'nemici',
    'nemico',
    'prigionieri',
    'prigioniero',
    'promozione',
    'promozioni',
    'vittoria',
    'demone',
    'demoni',
    'goetia',
    'goetica',
    'goetiche',
    'angelo contrario',
    'angeli contrari',
  ];

  String piatto(String s) {
    const da = 'àáèéìíòóùú';
    const a = 'aaeeiioouu';
    final b = StringBuffer();
    for (final c in s.toLowerCase().split('')) {
      final i = da.indexOf(c);
      b.write(i >= 0 ? a[i] : c);
    }
    return b.toString();
  }

  test('Tutti e settantadue leggono dal Corpus', () {
    expect(kAngelLore.length, 72);
    for (var n = 1; n <= 72; n++) {
      expect(kAngelLore[n], isNotNull, reason: 'manca il numero $n');
      expect(AngelCatalog.byNumber(n).lore, isNotNull);
    }
  });

  test('I sette campi ci sono, su dodici angeli, uno per coro piu\' tre', () {
    // Uno per coro (1, 9, 17, 25, 33, 41, 49, 57, 65) piu' tre sparsi.
    for (final n in const [1, 9, 17, 25, 33, 41, 49, 57, 65, 2, 44, 72]) {
      final a = AngelCatalog.byNumber(n);
      final l = a.lore!;
      expect(a.name.trim(), isNotEmpty, reason: 'nome, angelo $n');
      expect(a.number, n);
      expect(a.choir.name.trim(), isNotEmpty, reason: 'coro, angelo $n');
      expect(a.choir.archangel.trim(), isNotEmpty,
          reason: 'arcangelo, angelo $n');
      expect(l.degrees.trim(), isNotEmpty, reason: 'arco di gradi, angelo $n');
      expect(l.sign.trim(), isNotEmpty, reason: 'segno, angelo $n');
      expect(l.psalm.trim(), isNotEmpty, reason: 'salmo, angelo $n');
      // Il salmo porta la sua numerazione, che cambia fra le edizioni.
      expect(l.psalm.toLowerCase().contains('salmo'), isTrue,
          reason: 'il salmo dell\'angelo $n non dice quale');
    }
  });

  test('Nessun termine vietato nei testi mostrati', () {
    final trovati = <String>[];
    for (final a in AngelCatalog.all) {
      final l = a.lore!;
      final testi = <String>[
        a.name,
        l.degrees,
        l.sign,
        l.psalm,
        l.tradition,
        l.reading,
      ];
      for (final t in testi) {
        final p = piatto(t);
        for (final v in vietati) {
          if (p.contains(v)) {
            trovati.add('angelo ${a.number} ${a.name}: "$v" in "$t"');
          }
        }
      }
    }
    expect(trovati, isEmpty,
        reason: 'la politica del Corpus e\' violata:\n${trovati.join('\n')}');
  });

  test('Il nome mostrato viene dal Corpus, non dallo stem dell\'immagine', () {
    // Ieliel e Jeliel sono lo stesso angelo: a schermo vale la grafia della
    // fonte verificata, il file resta quello che e'.
    final due = AngelCatalog.byNumber(2);
    expect(due.name, kAngelLore[2]!.name);
    expect(due.artStem, 'ang_02_jeliel_v1');
    // I settantadue nomi mostrati restano distinti fra loro.
    final nomi = AngelCatalog.all.map((a) => a.name).toSet();
    expect(nomi.length, 72);
  });

  test('Dove la fonte regge poco si mostra meno', () {
    // La confidenza e' dichiarata per ogni angelo e la carta la usa per
    // decidere se mostrare il dominio secondo la tradizione.
    for (final a in AngelCatalog.all) {
      expect(a.lore!.confidence.trim(), isNotEmpty,
          reason: 'confidenza mancante sull\'angelo ${a.number}');
    }
  });
}
