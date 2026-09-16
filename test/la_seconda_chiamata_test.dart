import 'dart:convert';

import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/il_responso_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SECONDA CHIAMATA QUANDO UNA GUARDIA SCARTA.** Ordine DQ voce 06,
/// 15 settembre 2026.
///
/// **IL FATTO.** Dopo l'ordine DN la risposta dal modello e' scesa al 66,4
/// per cento: le righe che passano sono migliori di prima, ma quando una riga
/// viene scartata non si riprova, e si cade sulla voce di casa. **Adesso il
/// modello si richiama una volta sola, col motivo dello scarto per nome.**
/// Un solo tentativo in piu', mai due: se anche il secondo viene scartato,
/// vale la voce di casa.
void main() {
  final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
  final s = CioCheSiSa(
    domanda: 'Devo lasciare la banca per aprire una bottega?',
    tema: 'Una scelta da fare',
    animale: lupo,
    natale: const NatalContext(sunSign: 'Cancro'),
    memoria: '',
    ultimeScene: const [],
  );

  String risposta({
    String luogo = 'grotta',
    String titolo = 'La bottega ti somiglia',
    String testo = 'Sulla bottega puoi scegliere tu il primo passo.',
    String azione = 'Stasera scrivi su un foglio cosa ti serve per la bottega.',
  }) =>
      jsonEncode({
        'luogo': luogo,
        'cosa': 'chiave',
        'gesto': 'aspetta',
        'momento': 'alba',
        'titolo': titolo,
        'risposta': testo,
        'azione': azione,
      });

  const conGergo = 'Sulla bottega abbraccia il cambiamento.';

  test('una riga scartata fa richiamare il modello col motivo per nome',
      () async {
    final richieste = <String>[];
    final ammessiVisti = <PezziAmmessi>[];
    final scritta = await LaScenaDalModello.chiediTutto(s,
        chiamata: (i, r, a) async {
          richieste.add(r);
          ammessiVisti.add(a);
          return richieste.length == 1
              ? risposta(testo: conGergo)
              : risposta(titolo: 'Un titolo diverso', testo: s.domanda
                  .replaceAll('Devo lasciare', 'Puoi guardare')
                  .replaceAll('?', '.'));
        },
        prendiUnaChiamata: () async => true);
    expect(richieste, hasLength(2),
        reason: 'la risposta scartata non ha fatto richiamare il modello');
    // Il motivo per nome, e la riga scartata.
    expect(richieste[1], contains('gergo'));
    expect(richieste[1], contains(conGergo));
    // La scena resta quella: alla seconda chiamata ogni elenco ha solo il
    // pezzo scelto alla prima.
    expect(ammessiVisti[1].luoghi, ['grotta']);
    expect(ammessiVisti[1].cose, ['chiave']);
    expect(scritta.pezzi?.luogo.id, 'grotta');
    // La riga ripresa e' quella della seconda; il titolo buono della prima
    // resta.
    expect(scritta.testi.risposta, startsWith('Puoi guardare'));
    expect(scritta.testi.titolo, 'La bottega ti somiglia');
    expect(scritta.testi.dallaSeconda, {'risposta'});
    expect(scritta.testi.recuperate.map((r) => r.motivo),
        [MotivoDelloScarto.gergo]);
  });

  test('MAI PIU DI TRE CHIAMATE: se anche la terza e scartata vale casa',
      () async {
    // **ERANO DUE FINO ALL'ORDINE DQ, SONO TRE DALL'ORDINE DR VOCE 07.** Il
    // fondatore ha ricevuto quattro strati di ripiego su una domanda scritta
    // a mano: i tentativi salgono a tre, ognuno col motivo dello scarto di
    // prima. **Il tetto resta un tetto**: alla quarta chiamata non si arriva
    // mai, e se anche la terza cade vale la voce di casa.
    var chiamate = 0;
    final scritta = await LaScenaDalModello.chiediTutto(s,
        chiamata: (i, r, a) async {
          chiamate++;
          return risposta(testo: conGergo);
        },
        prendiUnaChiamata: () async => true);
    expect(chiamate, LaScenaDalModello.quantiTentativi);
    expect(chiamate, 3);
    expect(scritta.testi.risposta, isNull,
        reason: 'la riga scartata tre volte deve lasciare la voce di casa');
    expect(scritta.testi.titolo, isNotNull);
  });

  test('LA TERZA CHIAMATA SALVA LA RIGA che le prime due avevano perso',
      () async {
    // Ordine DR voce 07: con un modello che sbaglia due volte e la terza no,
    // lo strato esce dal modello e non ripiega.
    var chiamate = 0;
    final scritta = await LaScenaDalModello.chiediTutto(s,
        chiamata: (i, r, a) async {
          chiamate++;
          return chiamate < 3 ? risposta(testo: conGergo) : risposta();
        },
        prendiUnaChiamata: () async => true);
    expect(chiamate, 3);
    expect(scritta.testi.risposta, isNotNull,
        reason: 'la terza risposta regge alle guardie e deve valere');
  });

  test('senza scarti il modello si chiama una volta sola', () async {
    var chiamate = 0;
    await LaScenaDalModello.chiediTutto(s,
        chiamata: (i, r, a) async {
          chiamate++;
          return risposta();
        },
        prendiUnaChiamata: () async => true);
    expect(chiamate, 1);
  });

  test('scena scartata e testi scartati: le chiamate restano entro il tetto',
      () async {
    final richieste = <String>[];
    final scritta = await LaScenaDalModello.chiediTutto(s,
        chiamata: (i, r, a) async {
          richieste.add(r);
          // La prima ha un luogo inventato e la risposta col gergo.
          return richieste.length == 1
              ? risposta(luogo: 'castello', testo: conGergo)
              : risposta();
        },
        prendiUnaChiamata: () async => true);
    expect(richieste, hasLength(2));
    expect(richieste[1], contains('gergo'),
        reason: 'la richiesta della scena rifatta non porta il motivo dello '
            'scarto dei testi');
    expect(scritta.pezzi, isNotNull);
    expect(scritta.testi.risposta, isNotNull);
  });

  test('la fonte del Diario dice quale testo viene dalla seconda chiamata', () {
    final r = IlResponsoDelViaggio.componi(
      dalModello: null,
      domanda: s.domanda,
      giorno: DateTime(2026, 9, 15),
      nitidezza: 1,
      discesa: 0,
      giaOggi: 0,
      animale: lupo,
      tema: TemaDellaDomanda.scelta,
      storia: const [],
      scritti: const TestiDelModello(
          titolo: 'La bottega ti somiglia',
          risposta: 'Sulla bottega puoi scegliere tu il primo passo.',
          dallaSeconda: {'risposta'}),
    );
    expect(r.fonti['risposta'], 'modello: seconda chiamata');
    expect(r.fonti['titolo'], 'modello');
  });

  test('ogni motivo dello scarto si dice al modello in parole sue', () {
    for (final m in MotivoDelloScarto.values) {
      final detto = LeGuardieDelResponso.perIlModello(m);
      expect(detto.length, greaterThan(12), reason: m.name);
    }
  });
}
