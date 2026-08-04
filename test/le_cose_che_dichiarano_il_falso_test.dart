import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/lang/euphonic.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_welcome.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_suggestions.dart';
import 'package:esoteric_circle/features/maestri/widgets/domain_pillars.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE COSE CHE SI VEDONO E DICHIARANO IL FALSO.
///
/// Correzioni trovate dal fondatore guardando lo schermo, non leggendo il
/// codice. Ognuna qui sotto ha la sua prova, e ognuna enumera invece di
/// guardare il punto noto: correggere i punti che qualcuno ha visto lascia
/// scoperto quello che nasce domani.
void main() {
  group('Il disclaimer sta in UN posto solo', () {
    /// L'UNICO POSTO, e la ragione per cui e' quello.
    ///
    /// Un disclaimer ripetuto smette di essere letto, e diventa un modo di
    /// scaricare la responsabilita' invece di dirla.
    const casa = 'lib/features/settings/settings_screen.dart';

    test('Nessun\'altra schermata mostra un disclaimer', () {
      // COSA SI CERCA: il TESTO, non la parola "disclaimer". Un file puo'
      // nominarla per spiegare perche' il disclaimer non c'e', e infatti sei
      // file lo fanno.
      final pezzi = [
        ArtCatalog.disclaimerCornice,
        'non come cura medica',
        'nessuna promessa deterministica',
        'non una sentenza sul tuo destino',
      ];
      final colpe = <String>[];
      for (final voce in Directory('lib').listSync(recursive: true)) {
        if (voce is! File || !voce.path.endsWith('.dart')) continue;
        final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
        if (percorso == casa) continue;
        // Il posto dove il TESTO vive come dato non e' un posto dove si
        // mostra: e' la sorgente da cui l'unico punto lo prende.
        if (percorso == 'lib/core/arts/art_catalog.dart') continue;
        // **LA RIGA NON E' L'UNITA' GIUSTA, e una prova del rosso l'ha
        // dimostrato.** Rimettendo il disclaimer degli Angeli spezzato su due
        // righe, come il formattatore Dart spezza ogni frase lunga, la prova
        // restava verde: nessuna singola riga conteneva la frase intera.
        //
        // Qui il file si legge tutto, si tolgono i commenti e si ricuciono i
        // letterali adiacenti, che e' esattamente cio' che fa il compilatore.
        // Cosi' si cerca il testo che la persona LEGGE, non il testo per come
        // e' stato mandato a capo.
        final cucito = _cucito(voce.readAsStringSync());
        for (final pezzo in pezzi) {
          if (cucito.contains(pezzo)) {
            colpe.add('$percorso: $pezzo');
          }
        }
      }
      expect(colpe, isEmpty,
          reason: 'un disclaimer e\' rispuntato fuori dall\'area privacy. Ne '
              'esistevano SETTE, e le linee guida dicevano da sempre "una '
              'volta sola":\n${colpe.join("\n")}');
    });

    test('E nell\'area privacy c\'e\'', () {
      final s = File(casa).readAsStringSync();
      expect(s, contains('privacy_disclaimer'),
          reason: 'il disclaimer non c\'e\' piu\' da nessuna parte: toglierlo '
              'da sette punti e da nessuno rimetterlo e\' peggio di sette');
      expect(s, contains('ArtCatalog.disclaimerCornice'),
          reason: 'l\'unico disclaimer non nasce piu\' dal punto unico');
    });
  });

  group('Le preposizioni si fondono col loro articolo', () {
    test('La tavola delle sette preposizioni, caso per caso', () {
      expect(preposizioneArticolata('di', 'il Creativo'), 'del Creativo');
      expect(preposizioneArticolata('di', 'l\'Iniziatore'), 'dell\'Iniziatore');
      expect(preposizioneArticolata('di', 'la Soglia'), 'della Soglia');
      expect(preposizioneArticolata('a', 'il Cerchio'), 'al Cerchio');
      expect(preposizioneArticolata('da', 'il Custode'), 'dal Custode');
      expect(preposizioneArticolata('in', 'il Cerchio'), 'nel Cerchio');
      expect(preposizioneArticolata('su', 'la Luna'), 'sulla Luna');
      expect(preposizioneArticolata('di', 'gli Angeli'), 'degli Angeli');
      // Un nome senza articolo resta accostato, e la maiuscola non si tocca.
      expect(preposizioneArticolata('di', 'Medora'), 'di Medora');
    });

    test('NESSUN benvenuto composto incolla una preposizione a un articolo',
        () {
      // **SI ENUMERA, e non si guarda "il Creativo".** Il difetto visto dal
      // fondatore era su un titolo del numero della vita, ma la stessa frase
      // si compone per dodici titoli, tre Maestri e dodici segni. Una prova
      // che guarda un caso trova un caso.
      final rotti = <String>[];
      var composte = 0;
      for (final maestro in Maestro.values) {
        for (var n = 1; n <= 33; n++) {
          final titolo = lifeTitleOf(n);
          for (final segno in [null, Zodiac.cancer]) {
            final frase = MaestroWelcome.compose(
              maestro: maestro,
              profile: UserProfile.empty,
              memory: MaestroMemory.empty,
              premium: false,
              rotation: n,
              natal: NatalContext(
                sunSign: segno?.italianName,
                lifeNumber: n,
                lifeNumberTitle: titolo,
              ),
            );
            composte++;
            for (final rotta in _incollature) {
              if (frase.contains(rotta)) {
                rotti.add('"$rotta" in: $frase');
              }
            }
          }
        }
      }
      expect(composte, greaterThan(100),
          reason: 'sono state composte solo $composte frasi');
      expect(rotti.toSet().toList(), isEmpty,
          reason: 'una preposizione e\' incollata al suo articolo invece di '
              'fondersi:\n${rotti.toSet().join("\n")}');
    });
  });

  test('Le vie proposte sotto il benvenuto sono TRE', () {
    expect(SuggestionSets.quanteVie, 3,
        reason: 'un invito iniziale e\' un assaggio, non un menu');
    for (final maestro in Maestro.values) {
      expect(SuggestionSets.starters(maestro), hasLength(3),
          reason: '${maestro.displayName} propone '
              '${SuggestionSets.starters(maestro).length} vie');
    }
  });

  test('Il dominio si scrive in UNA forma sola', () {
    for (final maestro in Maestro.values) {
      // La schermata del dominio e la chat dicono la STESSA cosa, allo stesso
      // modo: qui c'era "Astrologia · Cartomanzia · Destino" coi punti medi e
      // in chat "Astrologia, Cartomanzia e Destino" con le virgole.
      expect(DomainPillars.of(maestro).join(' · '),
          isNot(maestro.domainArtsPhrase),
          reason: 'questa prova non distingue le due forme');
    }
    // E la forma coi punti medi non si compone piu' da nessuna parte.
    final colpe = <String>[];
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      final righe = voce.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final riga = righe[i];
        if (riga.trimLeft().startsWith('//')) continue;
        // Il modo in cui si componeva: unire i pilastri con un punto medio.
        if (riga.contains("join(' · ')")) {
          colpe.add('$percorso riga ${i + 1}: ${riga.trim()}');
        }
      }
    }
    expect(colpe, isEmpty,
        reason: 'il dominio si compone di nuovo in una seconda forma:\n'
            '${colpe.join("\n")}');
  });
}

/// LE INCOLLATURE, cioe' le preposizioni appiccicate a un articolo.
///
/// Sono le sette preposizioni che si articolano, per i sei articoli. Ognuna di
/// queste sequenze e' italiano sbagliato, sempre, in qualunque frase.
final List<String> _incollature = [
  for (final p in ['di', 'a', 'da', 'in', 'su', 'con'])
    for (final a in ['il', 'lo', 'la', 'i', 'gli', 'le']) ' $p $a ',
];

/// Il testo di un sorgente per come lo legge chi guarda lo schermo.
///
/// Toglie i commenti, ricuce i letterali adiacenti che il formattatore ha
/// mandato a capo, e appiattisce gli spazi. E' l'operazione che rende
/// confrontabile una frase con quella che il compilatore mettera' insieme.
String _cucito(String sorgente) {
  final senzaCommenti = const LineSplitter()
      .convert(sorgente)
      .where((r) => !r.trimLeft().startsWith('//'))
      .join(' ');
  return senzaCommenti
      // "abc " seguito da "def" diventa "abc def": e' cio' che fa il
      // compilatore coi letterali adiacenti, e cio' che legge la persona.
      .replaceAll(RegExp(r"'\s*'"), '')
      .replaceAll(RegExp(r'"\s*"'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}
