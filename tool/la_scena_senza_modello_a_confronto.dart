// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/il_responso_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

import 'il_banco_del_costo_comune.dart';

/// **LA SCENA DEL VIAGGIO SENZA MODELLO, A CONFRONTO.** Ordine EX voce 10.
///
/// Per ogni domanda: la domanda capita col modello (resta sul modello anche
/// dopo la voce), poi il responso della discesa composto nei due modi dallo
/// stesso `IlResponsoDelViaggio.componi` dell'app:
/// - "modello": la scena e i testi chiesti a `LaScenaDalModello` (prima della
///   voce, fino a tre chiamate);
/// - "casa": nessuna chiamata per la scena, la composizione dell'app e la voce
///   di casa (dopo la voce).
/// Venti domande, meta' scritte a mano e meta' dalla tavola dei temi, alla
/// discesa dopo il riconoscimento e prima, con la stessa storia vuota.
///
///     flutter test -r expanded tool/la_scena_senza_modello_a_confronto.dart
///
/// Scrive `docs/collaudo/EX/qualita/viaggio_modello.jsonl` e
/// `viaggio_casa.jsonl`, nella forma del banco della qualita'.

const _natale = NatalContext(
  sunSign: 'Cancro',
  moonSign: 'Bilancia',
  ascendant: 'Scorpione',
  lifeNumber: 7,
  lifeNumberTitle: 'il Cercatore',
);

const _scritte = [
  'Quando mi sposerò?',
  'Devo lasciare Torino per Berlino?',
  'Mia sorella mi perdonerà?',
  'Il colloquio di fine mese andrà bene?',
  'Apro la bottega di ceramica?',
  'Perché non riesco a dormire?',
  'Marco mi ama davvero?',
  'Come ritrovo la fiducia in me stessa?',
  'Devo prestare i soldi a mio fratello?',
  'Cosa mi blocca nel lavoro?',
  'Lui tornerà da me?',
  'Mi conviene cambiare casa quest\'anno?',
  'Come faccio pace con mia madre?',
  'Il mio progetto avrà successo?',
];

/// **QUANTE RICHIESTE PER LA SCENA**, dall'ambiente (TENTATIVI, di serie
/// quelle dell'app): con meno tentativi il giro misura la scena del modello
/// senza le richieste ripetute.
final int _tentativi = int.tryParse(Platform.environment['TENTATIVI'] ?? '') ??
    LaScenaDalModello.quantiTentativi;

/// Il nome del giro col modello (GIRO, di serie "modello").
final String _giro = Platform.environment['GIRO'] ?? 'modello';

void main() {
  setUpAll(preparaIlBanco);

  test('la scena senza modello a confronto', () async {
    final animale = AnimalCatalog.animals.first;
    final giorno = DateTime(2026, 10, 2);
    final domande = <String>[
      ..._scritte,
      for (final d in LaDomandaDelViaggio.gliaScritte.take(10)) d.testo,
    ];
    final modello = <String>[];
    final casa = <String>[];
    for (var i = 0; i < domande.length; i++) {
      final d = domande[i];
      final id = 'V${(i + 1).toString().padLeft(2, '0')}';
      final capita =
          await LaDomandaCapita.capisci(d, prendiUnaChiamata: () async => true);
      final daQui = registro.length;
      var permessi = 0;
      // Ordine EX Aggiunta 4, voce EX.10: ogni riga scartata, con la guardia
      // che l'ha scartata.
      final scarti = <Map<String, String>>[];
      final strato = i.isEven ? null : 1 + (i % 4);
      final scritta = await LaScenaDalModello.chiediTutto(
        CioCheSiSa(
          domanda: d,
          tema: capita.tema?.inLettere,
          animale: animale,
          natale: _natale,
          memoria: '',
          ultimeScene: const [],
          oggetto: capita.oggetto,
          strato: strato,
        ),
        prendiUnaChiamata: () async => ++permessi <= _tentativi,
        seScartata: (r) => scarti
            .add({'pezzo': r.pezzo, 'motivo': r.motivo.name, 'testo': r.testo}),
      ).timeout(const Duration(seconds: 20),
          onTimeout: () => (pezzi: null, testi: TestiDelModello.nessuno));
      final chiamateScena = registro.length - daQui;
      IlResponsoDelViaggio comp(PezziScelti? pezzi, TestiDelModello testi) =>
          IlResponsoDelViaggio.componi(
            dalModello: pezzi,
            domanda: d,
            giorno: giorno,
            nitidezza: 1,
            discesa: strato == null ? 5 : strato - 1,
            apparizioniPrima: strato == null ? 5 : strato - 1,
            giaOggi: 0,
            animale: animale,
            tema: capita.tema,
            storia: const [],
            scritti: testi,
            oggetto: capita.oggetto,
          );
      final conModello = comp(scritta.pezzi, scritta.testi);
      final senza = comp(null, TestiDelModello.nessuno);
      Map<String, Object?> riga(String giro, IlResponsoDelViaggio r, int n) => {
            'giro': giro,
            'id': id,
            'maestro': 'caligo',
            'tipo': 'merito',
            'nelLive': false,
            'domanda': d,
            'risposta': [
              if (r.titolo.isNotEmpty) r.titolo,
              ...r.paragrafi,
              if (r.risposta.isNotEmpty) r.risposta,
              if (r.gesto.isNotEmpty) '✦ ${r.gesto}',
            ].join('\n\n'),
            'seguito': null,
            'ripiego': false,
            'errore': null,
            'dalModello': r.dalModello,
            'chiamateScena': n,
            'scarti': giro == 'casa' ? const [] : scarti,
            'chiamateRisposta': const [],
            'fattiDellaMemoria': const [],
            'cieloDelleDate': const [],
          };
      // **IL SILENZIO DELL'ORDINE DR VOCE 07**: con la domanda scritta a
      // mano, se il modello ha parlato e i suoi testi non hanno retto, il
      // Mondo di Sotto tace. Nel "prima" e' cio' che la persona vede.
      final rigaModello = riga(_giro, conModello, chiamateScena);
      if (!conModello.dalModello && i < _scritte.length) {
        rigaModello['risposta'] =
            '(Silenzio: oggi il mondo di sotto non ha parlato.)';
      }
      modello.add(jsonEncode(rigaModello));
      casa.add(jsonEncode(riga('casa', senza, 0)));
      print('$id: scena col modello in $chiamateScena chiamate, '
          'dal modello ${conModello.dalModello}');
    }
    final c = Directory('docs/collaudo/EX/qualita')
      ..createSync(recursive: true);
    File('${c.path}/viaggio_$_giro.jsonl')
        .writeAsStringSync('${modello.join('\n')}\n');
    if (_giro == 'modello') {
      File('${c.path}/viaggio_casa.jsonl')
          .writeAsStringSync('${casa.join('\n')}\n');
    }
  }, timeout: const Timeout(Duration(minutes: 40)));
}
