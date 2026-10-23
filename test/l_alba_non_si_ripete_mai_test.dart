import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ALBA NON SI RIPETE MAI.** Ordine CY, voce 01, 8 settembre 2026.
///
/// **Parole del fondatore, sulla build 2232 appena scaricata**: *"ho fatto il
/// rito dell'Alba e i testi vengono ripetuti 3 volte CAZZO."*
///
/// **LA COLPA E' DELLA VOCE CW.07, ED E' MIA.** Quella voce chiedeva di
/// evidenziare il rituale dentro un riquadro col titolo IL MANTRA DI OGGI. Ho
/// aggiunto il riquadro e **non ho tolto il testo dal corpo del responso**: il
/// gesto e la via tattile finiscono a schermo due volte, una sotto l'altra.
///
/// **E la mia guardia non poteva accorgersene.** Pretendeva che il riquadro
/// CONTENESSE il mantra, e lo conteneva. Non ha mai chiesto se quel testo
/// fosse anche ALTROVE: **ho misurato il pezzo che avevo aggiunto invece
/// dell'insieme**, che in questo progetto e' la famiglia piu' costosa di
/// tutte. La duplicazione era gia' visibile nello screenshot che avevo
/// catturato io, `docs/verifica/CW/55_alba_rituale.png`, e non l'ho vista.
///
/// **Cosa misura questa prova.** Il DATO, prima ancora della schermata: il
/// responso del Dono dell'Alba non deve contenere il gesto, perche' il gesto
/// vive nel riquadro. E nessuna delle frasi che l'Alba porta a schermo deve
/// aprire con la stessa proposizione di un'altra: tre paragrafi di fila che
/// cominciano con *"La Luna e' calante"* si leggono come una ripetizione anche
/// quando dicono cose diverse.
void main() {
  const lat = 45.4642;
  const lon = 9.1900;
  const fuso = Duration(hours: 2);

  RitoDiOggi ritoDi(DateTime giorno) => RitoAlba.diOggi(
        giorno,
        posizione: PosizioneDiStamattina.da(
          const SkyPlace(latitude: lat, longitude: lon),
          fuso,
        ),
      )!;

  /// La prima proposizione di un testo, cioe' cio' che l'occhio incontra per
  /// primo. Si taglia al primo punto o ai due punti, perche' e' li' che una
  /// frase dichiara di cosa parla.
  String apertura(String testo) {
    final t = testo.trim();
    final fine = [t.indexOf('.'), t.indexOf(':')]
        .where((i) => i > 0)
        .fold<int>(t.length, (a, b) => a < b ? a : b);
    return t.substring(0, fine).trim().toLowerCase();
  }

  test('Il gesto non entra nel responso, perche\' vive nel riquadro', () {
    // Trecentosessantacinque giorni: una ripetizione che compare solo con
    // certe fasi lunari non si trova guardandone uno.
    final colpevoli = <String>[];
    for (var g = 0; g < 365; g++) {
      final giorno = DateTime(2026, 1, 1).add(Duration(days: g));
      // **SI GUARDA IL DONO, NON IL RITO.** Il primo giro di questa prova
      // cercava il gesto dentro `rito.risposta.risposta` e restava verde:
      // il gesto non sta li', sta in `DawnGift.orientation`, che e' il
      // campo che la carta stampa. Misurare il campo accanto a quello
      // rotto e' esattamente l'errore che ha prodotto questa voce.
      final dono = DawnGift.forMaestro(giorno, Maestro.medora,
          posizione: PosizioneDiStamattina.da(
            const SkyPlace(latitude: lat, longitude: lon),
            fuso,
          ));
      final rito = dono.rito;
      if (rito == null) continue;
      final responso = dono.orientation;
      if (responso.contains(rito.gesto)) {
        colpevoli.add('${giorno.toIso8601String().substring(0, 10)}: il '
            'responso contiene il gesto per intero');
      }
      if (responso.contains(rito.viaTattile)) {
        colpevoli.add('${giorno.toIso8601String().substring(0, 10)}: il '
            'responso contiene la via tattile');
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'il responso ripete cio\' che sta gia\' nel riquadro del '
            'mantra, su ${colpevoli.length} giorni:\n'
            '${colpevoli.take(5).join('\n')}');
  });

  test('Il Soffio non porta a schermo nessun gesto da compiere', () {
    // **PAROLE DEL FONDATORE, sulla 2232**: *"C'E' ANCORA IL RITO CHE IN
    // QUESTA FUNZIONALITA' DOVEVI ELIMINARE"*, e prima ancora, il 7
    // settembre: *"non serve un rito da compiere per il soffio, c'e' gia' la
    // respirazione da compiere"*.
    //
    // **La causa era la stessa dell'Alba doppia**: tutti e cinque i Doni
    // montano la stessa scheda, e il responso portava dentro il gesto. Nel
    // Soffio il riquadro del mantra non c'e', quindi quel gesto non era una
    // ripetizione: era un rito in piu' in una funzione che non deve averlo.
    final colpevoli = <String>[];
    for (var g = 0; g < 365; g++) {
      final giorno = DateTime(2026, 1, 1).add(Duration(days: g));
      final soffio = DawnGift.forMaestro(giorno, Maestro.aura,
          posizione: PosizioneDiStamattina.da(
            const SkyPlace(latitude: lat, longitude: lon),
            fuso,
          ));
      final rito = soffio.rito;
      if (rito == null) continue;
      if (soffio.orientation.contains(rito.gesto) ||
          soffio.orientation.contains(rito.viaTattile)) {
        colpevoli.add(giorno.toIso8601String().substring(0, 10));
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'il responso del Soffio porta un gesto da compiere in '
            '${colpevoli.length} giorni su 365. Il rito del Soffio e il '
            'respiro, e un secondo rito accanto lo fa somigliare al Rito '
            'dell Alba');
  });

  test('Risposta e gesto non aprono con la stessa proposizione', () {
    // **E' IL DIFETTO CHE IL FONDATORE HA VISTO A SCHERMO.** Tre paragrafi di
    // fila che cominciano con "La Luna e' calante" si leggono come lo stesso
    // testo ripetuto, e chi li ha scritti lo sa che dicono cose diverse: chi
    // legge no.
    final colpevoli = <String>[];
    for (var g = 0; g < 365; g++) {
      final giorno = DateTime(2026, 1, 1).add(Duration(days: g));
      final rito = ritoDi(giorno);
      final a = apertura(rito.risposta.risposta);
      final b = apertura(rito.soloIlGesto);
      if (a.isNotEmpty && a == b) {
        colpevoli.add('${giorno.toIso8601String().substring(0, 10)}: "$a"');
      }
    }
    // **IL CARDINALE SI DICHIARA**: trecentosessantacinque giorni guardati.
    expect(colpevoli.length, lessThan(365),
        reason: 'nessun giorno e\' stato guardato: la prova sarebbe verde per '
            'cecita\'');
    expect(colpevoli, isEmpty,
        reason: 'la risposta e il gesto aprono con la stessa proposizione in '
            '${colpevoli.length} giorni su 365, e a schermo stanno uno sotto '
            'l\'altro:\n${colpevoli.take(5).join('\n')}');
  });
}
