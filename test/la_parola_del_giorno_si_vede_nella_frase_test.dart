import 'package:esoteric_circle/core/rituals/filo_del_giorno.dart';
import 'package:esoteric_circle/design_system/components/frase_con_la_parola.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/letture_dell_alba_dati.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LA PAROLA DEL GIORNO SI VEDE, DENTRO LA FRASE.** Ordine DD voce 02,
/// 10 settembre 2026.
///
/// **Il fatto del fondatore**: la Parola del giorno, quando compare dentro una
/// frase, non si distingue dal resto. La sera il Sigillo del Sogno scriveva
/// *"Stamattina la tua parola era Fiducia"*, e quella parola, che e' la sola
/// cosa che chi legge deve portarsi via, pesava quanto *"stamattina"* e quanto
/// *"era"*.
///
/// **La regola**: fra virgolette basse **e** in grassetto. Le virgolette
/// reggono anche dove il grassetto non arriva, cioe' in un testo condiviso o
/// in un messaggio di chat; il grassetto la fa trovare all'occhio.
///
/// **REGOLA H, e sono due meta'.** Che la parola sia virgolettata nelle frasi
/// e' la prima; che **nessuna frase la lasci nuda** e' la seconda, e senza di
/// lei basterebbe virgolettarne una per far passare la prova mentre le altre
/// restano com'erano. La seconda meta' enumera i sorgenti di `lib` dalla porta
/// comune.
void main() {
  const parola = 'Fiducia';

  test('LE FRASI CHE PORTANO LA PAROLA LA VIRGOLETTANO', () {
    final frasi = <String, String>{
      'il richiamo della sera nel Sigillo':
          FiloDelGiorno.richiamoDellaParola(parola),
      // **Dall'ordine DT la parola la da' l'Arcano dell'Alba**, e il Sigillo
      // la richiama passando dal dono della carta: una carta del corpus che
      // porta proprio questa parola.
      'il richiamo del dono della carta nel Sigillo':
          FiloDelGiorno.richiamoDelDono(ResponsoDellAlba.componi(
              lettureDellAlba.firstWhere((l) => l.parola == parola),
              apertura: 0,
              clausola: 0)),
    };
    cardinaleMinimo(frasi.length, 2,
        cosa: 'frasi che portano dentro la Parola del giorno',
        perche: 'Con una frase sola questa prova direbbe che la regola vale '
            'ovunque per averla vista in un posto.');
    for (final e in frasi.entries) {
      // ignore: avoid_print
      print('ORDINE DD VOCE 02: ${e.key} -> "${e.value}"');
      expect(e.value.contains(FraseConLaParola.virgolettata(parola)), isTrue,
          reason: '${e.key} scrive la parola nuda dentro la frase, senza le '
              'virgolette che la staccano dal discorso: "${e.value}"');
    }
  });

  testWidgets('E A VIDEO LA PAROLA E IN GRASSETTO, il contorno no',
      (tester) async {
    final frase = FiloDelGiorno.richiamoDellaParola(parola);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FraseConLaParola(
          frase: frase,
          parola: parola,
          stile: TypographyTokens.lettura(),
        ),
      ),
    ));

    final ricco = tester.widget<RichText>(find.byType(RichText).first);
    final pezzi = <String, FontWeight?>{};
    ricco.text.visitChildren((span) {
      if (span is TextSpan && span.text != null && span.text!.isNotEmpty) {
        pezzi[span.text!] = span.style?.fontWeight;
      }
      return true;
    });
    // ignore: avoid_print
    print('ORDINE DD VOCE 02: pezzi della frase a video $pezzi');
    cardinaleMinimo(pezzi.length, 2,
        cosa: 'pezzi in cui la frase e spezzata a video',
        perche: 'Con un pezzo solo la frase e tutta dello stesso peso, e la '
            'parola non e in risalto da nessuna parte.');

    final virgolettata = FraseConLaParola.virgolettata(parola);
    expect(pezzi[virgolettata], FontWeight.w700,
        reason: 'la parola «$parola» non e in grassetto dentro la frase');
    for (final e in pezzi.entries) {
      if (e.key == virgolettata) continue;
      expect(e.value == FontWeight.w700, isFalse,
          reason: 'anche "${e.key}" e in grassetto: se e grassetto tutto, '
              'non e in risalto niente');
    }
  });

  test('REGOLA H: NESSUNA FRASE LASCIA LA PAROLA NUDA', () {
    // **La meta che guarda dove non si e' guardato.** La prima prova legge
    // due frasi che conosco; questa cerca in tutto `lib` le frasi che
    // interpolano la parola e pretende che ognuna la porti virgolettata.
    // Una terza frase scritta domani cade qui.
    final sorgenti = sorgentiDiLib();
    final nude = <String>[];
    var guardate = 0;
    // Le interpolazioni della Parola del giorno: il nome della variabile e
    // uno di questi due in tutti i punti che la scrivono.
    final cercate = [
      RegExp(r'[^«]\$parola'),
      RegExp(r'[^«]\$word'),
    ];
    for (final f in sorgenti) {
      for (final riga in f.readAsLinesSync()) {
        final pulita = riga.trimLeft();
        // I commenti non sono testo a video.
        if (pulita.startsWith('//')) continue;
        if (!riga.contains(r'$parola') && !riga.contains(r'$word')) continue;
        guardate++;
        for (final r in cercate) {
          if (r.hasMatch(riga)) {
            nude.add('${f.path.split('lib').last}: ${riga.trim()}');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 02: righe di lib che interpolano la parola '
        '$guardate, righe che la lasciano nuda ${nude.length}');
    cardinaleMinimo(guardate, 2,
        cosa: 'righe di lib che scrivono la Parola dentro una frase',
        perche: 'Se non se ne trovasse nessuna, questa prova sarebbe verde '
            'per non aver trovato il soggetto, e la regola non sarebbe '
            'sorvegliata da nessuna parte.');
    expect(nude, isEmpty,
        reason: 'queste frasi scrivono la Parola del giorno nuda, senza le '
            'virgolette basse: ${nude.join(" | ")}');
  });
}
