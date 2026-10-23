import 'package:esoteric_circle/core/maestro/corpus_neutro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il corpus neutro resta neutro.
///
/// Le venti domande servono a misurare se i tre Maestri hanno tre voci vere.
/// Se una domanda scivolasse nel dominio di uno dei tre, la misura direbbe che
/// le voci si distinguono quando invece si distingue l'argomento: lo strumento
/// darebbe un numero alto e sbagliato, che e' peggio di un numero basso.
///
/// Un corpus che nessuno sorveglia si sporca da solo, una domanda alla volta.
void main() {
  test('Le domande sono venti', () {
    expect(CorpusNeutro.domande.length, 20,
        reason: 'venti risposte per Maestro fanno sessanta risposte da '
            'attribuire, ed e\' il numero su cui la soglia dell\'85 per cento '
            'e\' stata scelta');
  });

  test('Nessuna domanda ripete un\'altra', () {
    final viste = <String>{};
    for (final domanda in CorpusNeutro.domande) {
      final chiave = domanda.trim().toLowerCase();
      expect(viste.contains(chiave), isFalse,
          reason: 'la domanda "$domanda" compare due volte: una domanda '
              'doppia pesa il doppio nella matrice senza dirlo');
      viste.add(chiave);
    }
  });

  test('Nessuna domanda cade nel dominio di un Maestro', () {
    final colpe = <String>[];
    for (final domanda in CorpusNeutro.domande) {
      final dominio = CorpusNeutro.paroleDiDominioIn(domanda);
      if (dominio != null) {
        colpe.add('"$domanda" contiene "$dominio", che e\' una parola di '
            'dominio: la risposta si distinguerebbe per argomento e non per '
            'voce');
      }
    }
    expect(colpe, isEmpty, reason: '\n${colpe.join('\n')}\n');
  });

  test('Il setaccio non e\' cieco', () {
    // Senza questa, la prova qui sopra passerebbe anche con un setaccio che
    // non guarda niente. Si prova su una parola vera di ogni Maestro, non su
    // una inventata.
    for (final maestro in Maestro.values) {
      final firma = VoceDelMaestro.di(maestro).lessicoDiFirma.first;
      expect(CorpusNeutro.paroleDiDominioIn('cosa dice il mio $firma'), firma,
          reason: 'il setaccio non riconosce "$firma", che e\' firma di '
              '${maestro.id}');
      final arte = VoceDelMaestro.artiDi(maestro).first;
      expect(CorpusNeutro.paroleDiDominioIn('parlami di $arte'),
          arte.toLowerCase(),
          reason: 'il setaccio non riconosce l\'arte "$arte"');
    }
    // E non deve bocciare una domanda neutra per una somiglianza di lettere:
    // "mi sento" contiene "sent" ma non la parola "sentire".
    expect(CorpusNeutro.paroleDiDominioIn('oggi mi sento fermo'), isNull);
  });
}
