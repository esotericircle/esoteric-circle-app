/// **IL VERBO ESSERE HA L'ACCENTO, e l'articolo si elide.**
///
/// **Da dove nasce.** L'11 settembre 2026, sul 767f596c, la schermata del
/// ritorno dal Mondo di Sotto diceva *"Non e nuovo"*, *"Questa non e la prima
/// volta"*, *"lo avevi gia' trovato di la"* e *"ti rimanda l'ombra che non e'
/// tua, un altra volta"*; la card della rivelazione, cioe' **il pezzo dell'app
/// che esce di casa e finisce nelle chat degli altri**, diceva *"mi ha trovato
/// il 11 settembre 2026"*.
///
/// **Cinque errori in due schermate, e tutte le guardie erano verdi.**
/// `testo_a_video` cerca *piu*, *gia*, *cosi*, *perche*, *cioe* e *meta*: e'
/// l'elenco nato dai difetti di allora, e **il verbo essere non ci era mai
/// finito** perche' nessuno lo aveva ancora sbagliato. Un elenco di parole
/// chiuso dice sempre la verita' su ieri.
///
/// **La grandezza misurata.** Non *"la stringa contiene una parola della
/// lista"*, ma **le sequenze in cui la lettera `e` non puo' essere una
/// congiunzione**: dopo *non*, dopo *che*, davanti a un articolo. In italiano
/// *"non e"* non esiste: fra la negazione e la congiunzione ci va sempre
/// qualcosa.
///
/// **Perche' non un correttore.** Perche' una guardia che pretendesse di
/// giudicare tutto l'italiano sarebbe rossa su frasi giuste, verrebbe spenta
/// il giorno dopo, e il giorno dopo ancora nessuno guarderebbe piu' niente.
/// Qui ci sono **sette sequenze che sono sempre un errore**, e basta una per
/// fermare una consegna.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/card_della_rivelazione.dart';
import 'package:esoteric_circle/features/maestri/chat/chat_openers.dart';

import 'sorgenti_di_lib.dart';

void main() {
  /// **LE SEQUENZE CHE SONO SEMPRE UN ERRORE**, ognuna con la sua forma
  /// giusta. Si confrontano in minuscolo, cosi' *Non e* e *non e* cadono
  /// insieme.
  ///
  /// **I CONFINI DI PAROLA NON SONO UN DETTAGLIO.** La prima stesura cercava
  /// il pezzo di testo `che e ` e cadeva su *"notifiche e sensori"*, su
  /// *"pratiche e tradizioni"* e su *"il passaggio che la prima volta"*:
  /// quattro frasi giuste accusate in un colpo. Una guardia che accusa il
  /// codice corretto e' una guardia che verra' spenta.
  final sbagliate = <RegExp, String>{
    RegExp(r"\bnon e(?!['a-z\u00e0-\u00ff])"): 'non è',
    RegExp(r"\bche e(?!['a-z\u00e0-\u00ff])"): 'che è',
    RegExp(r"\be la prima volta\b"): 'è la prima volta',
    RegExp(r"\bun altra\b"): "un'altra",
    RegExp(r"\bdi la\b"): 'di là',
    RegExp(r"\bil 8\b"): "l'8",
    RegExp(r"\bil 11\b"): "l'11",
  };

  /// Le stringhe letterali di `lib`, saltando i commenti: negli apostrofi dei
  /// commenti il verbo essere si scrive `e'` per regola di casa, ed e' giusto
  /// cosi'.
  /// **LE STRINGHE DI `lib`, LETTE RISPETTANDO IL DELIMITATORE CHE LE APRE.**
  ///
  /// Non con una espressione regolare sugli apici singoli: dentro una stringa
  /// scritta fra doppi apici, quella lettura prende per stringa il pezzo fra
  /// due apostrofi, e `"il suo verso d\'ombra. Non e\' un\'informazione"`
  /// diventa il frammento `ombra. Non e`. **La guardia accusava una frase che
  /// nessuno aveva scritto.**
  ///
  /// I commenti restano fuori: nei commenti il verbo essere si scrive `e\'`
  /// per regola di casa, ed e\' giusto cosi\'.
  List<(String, int, String)> stringheDiLib() {
    final trovate = <(String, int, String)>[];
    for (final f in sorgentiDiLib()) {
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        if (r.trimLeft().startsWith('//')) continue;
        var j = 0;
        while (j < r.length) {
          final c = r[j];
          if (c == "/" && j + 1 < r.length && r[j + 1] == "/") break;
          if (c != "'" && c != '"') {
            j++;
            continue;
          }
          final delimitatore = c;
          final dentro = StringBuffer();
          var k = j + 1;
          var chiusa = false;
          while (k < r.length) {
            if (r[k] == "\\" && k + 1 < r.length) {
              dentro.write(r[k + 1]);
              k += 2;
              continue;
            }
            if (r[k] == delimitatore) {
              chiusa = true;
              break;
            }
            dentro.write(r[k]);
            k++;
          }
          trovate.add((p, i + 1, dentro.toString()));
          j = chiusa ? k + 1 : r.length;
        }
      }
    }
    return trovate;
  }

  test('Nessuna stringa di lib scrive il verbo essere senza accento', () {
    final tutte = stringheDiLib();
    // **IL CARDINALE MINIMO.** Su un insieme vuoto questa prova sarebbe verde
    // senza aver guardato niente.
    expect(tutte.length, greaterThan(2000),
        reason: 'le stringhe di lib trovate sono troppo poche: la porta comune '
            'non sta leggendo il codice vero');
    final colpevoli = <String>[];
    for (final (file, riga, testo) in tutte) {
      final basso = ' ${testo.toLowerCase()} ';
      for (final entry in sbagliate.entries) {
        if (entry.key.hasMatch(basso)) {
          colpevoli.add('$file riga $riga: "$testo" '
              '(qui ci vuole "${entry.value}")');
        }
      }
    }
    // ignore: avoid_print
    print('IL VERBO ESSERE: guardate ${tutte.length} stringhe di lib, '
        'colpevoli ${colpevoli.length}');
    expect(colpevoli, isEmpty,
        reason: 'queste stringhe portano a video un italiano sbagliato:\n'
            '${colpevoli.join('\n')}');
  });

  test("L'articolo del giorno si elide davanti a otto e a undici, e a nessun "
      'altro', () {
    final elisi = <int>[];
    for (var giorno = 1; giorno <= 31; giorno++) {
      final articolo = CardDellaRivelazione.articoloDelGiorno(giorno);
      if (articolo == "l'") elisi.add(giorno);
      expect(articolo == "l'" || articolo == 'il ', isTrue,
          reason: 'il giorno $giorno ha un articolo che non esiste: $articolo');
    }
    // ignore: avoid_print
    print("L'ARTICOLO DEL GIORNO: si elide sui giorni $elisi");
    expect(elisi, [8, 11]);
  });

  test('La frase della rivelazione accorda articolo e pronome, per tutti e '
      'dodici', () {
    // **LA TABELLA E' SCRITTA A MANO E NON VIENE DAL CODICE**: se la prendessi
    // dal catalogo, questa prova direbbe soltanto che il codice e' uguale a se
    // stesso.
    const femmine = {'Aquila', 'Lince', 'Tartaruga', 'Volpe'};
    expect(AnimalCatalog.animals.length, 12);
    for (final a in AnimalCatalog.animals) {
      final attesa = femmine.contains(a.name);
      expect(a.femminile, attesa,
          reason: '${a.name}: il genere dichiarato non e quello della lingua '
              'italiana');
      // **LA TABELLA DEGLI ARTICOLI, scritta a mano.** Vale anche per
      // l'elisione davanti a vocale: `l'Orso` e `l'Aquila`, non `il Orso`.
      const articoli = {
        'Aquila': "l'",
        'Cavallo': 'il ',
        'Cervo': 'il ',
        'Corvo': 'il ',
        'Falco': 'il ',
        'Gufo': 'il ',
        'Lince': 'la ',
        'Lupo': 'il ',
        'Orso': "l'",
        'Serpente': 'il ',
        'Tartaruga': 'la ',
        'Volpe': 'la ',
      };
      expect(a.articolo, articoli[a.name],
          reason: '${a.name}: l articolo non e quello dell italiano');
      expect(a.pronome, attesa ? 'la' : 'lo');
      final frase = 'È ${a.articolo}${a.name}. Adesso ${a.pronome} conosci.';
      for (final sbagliata in const [
        'il Lince',
        'il Volpe',
        'il Tartaruga',
        'il Aquila',
        'il Orso',
        'la Aquila',
      ]) {
        expect(frase, isNot(contains(sbagliata)),
            reason: 'la frase della rivelazione dice "$sbagliata"');
      }
      // **E LA CHAT DICE LA STESSA COSA**, perche' la tabella che aveva per se
      // e' sparita: due tabelle sullo stesso fatto sono due verita'.
      expect(ChatOpeners.animale(a.name),
          'Il mio animale guida è ${a.articolo}${a.name}, cosa vuole dirmi?');
    }
  });
}
