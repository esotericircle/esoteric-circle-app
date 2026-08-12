import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// I PRESIDI INTOCCABILI, dichiarati in un punto solo. Ordine P voce 15.
///
/// **Perche' un elenco.** Un presidio e' una prova che qualcuno, un giorno,
/// trovera' scomoda. La strada piu' facile per farla smettere di dare fastidio
/// non e' aggirarla: e' cancellarla, e una prova cancellata non lascia rosso
/// dietro di se'. E' gia' successo due volte in questo progetto, tutte e due
/// col cielo in parallasse, ed e' il motivo per cui la voce 02 chiede TRE
/// lucchetti diversi invece di uno.
///
/// **Cosa fa questo file.** Enumera i presidi che non si tolgono, e cade col
/// nome di quello sparito. Non protegge dal fatto che una prova diventi inerte,
/// che e' un altro difetto e ha altri rimedi: protegge dal fatto che smetta di
/// esistere.
///
/// **L'Alba entra qui con l'ordine P**, insieme al cielo in parallasse e agli
/// altri gia' registrati. Ha lo stesso diritto degli altri: e' l'unica
/// schermata dell'app che vive in un regime cromatico suo, cioe' l'unica che
/// nessuna regola scritta per il buio puo' proteggere.
class PresidioIntoccabile {
  const PresidioIntoccabile({
    required this.nome,
    required this.prova,
    required this.sorveglia,
    required this.perche,
  });

  /// Come si chiama, in una riga.
  final String nome;

  /// Il file della prova che lo tiene in piedi.
  final String prova;

  /// Cosa misura.
  final String sorveglia;

  /// Perche' non si toglie. Se questa riga non si sa scrivere, il presidio non
  /// e' intoccabile: e' solo una prova come le altre.
  final String perche;
}

const List<PresidioIntoccabile> presidi = [
  PresidioIntoccabile(
    nome: 'Il cielo in parallasse si muove',
    prova: 'test/i_tre_lucchetti_del_cielo_test.dart',
    sorveglia: 'il dato che cambia, i pixel che cambiano, e l\'enumerazione '
        'delle schermate che dichiarano il fondo cosmico',
    perche: 'si e\' fermato due volte, e tutte e due le volte per una modifica '
        'giusta fatta per un\'altra ragione: il costo di ridisegno su iOS. Un '
        'presidio solo era gia\' stato aggirato, quindi sono tre e cadono per '
        'ragioni diverse',
  ),
  PresidioIntoccabile(
    nome: 'Non si spedisce su rosso',
    prova: 'test/codemagic_regge_lo_schema_test.dart',
    sorveglia: 'che il file di build non riporti il permesso di ignorare le '
        'prove cadute',
    perche: 'la build 2171 e\' stata spedita con due test rossi perche\' la '
        'regola viveva in un documento, e un documento non ferma niente',
  ),
  PresidioIntoccabile(
    nome: 'I tre sentieri si disegnano davvero',
    prova: 'test/i_tre_sentieri_si_disegnano_test.dart',
    sorveglia: 'che il disegno di ciascun sentiero dipinga pixel suoi, e che i '
        'tre non siano lo stesso disegno ricolorato',
    perche: 'la schermata montava un elenco di righe col fondo cosmico dietro, '
        'e a colpo d\'occhio sembrava disegnata',
  ),
  PresidioIntoccabile(
    nome: 'La celebrazione parte sempre',
    prova: 'test/la_festa_arriva_sempre_test.dart',
    sorveglia: 'che la festa non dipenda dalla risposta del server',
    perche: 'l\'accredito stava prima della festa e senza protezione, quindi '
        'un errore della porta del Cerchio faceva sparire la celebrazione',
  ),
  PresidioIntoccabile(
    nome: 'Ogni arte entra nel cammino',
    prova: 'test/ogni_arte_entra_nel_cammino_test.dart',
    sorveglia: 'che ogni schermata che compie un gesto lo dichiari alla regia '
        'del cammino',
    perche: 'undici arti su quattordici non registravano niente, quindi i loro '
        'traguardi erano irraggiungibili e nessuno poteva accorgersene',
  ),
  PresidioIntoccabile(
    nome: 'Il debito tipografico puo\' solo scendere',
    prova: 'test/tipografia_nel_dato_test.dart',
    sorveglia: 'le misure di carattere scritte a mano, gli spazi scritti a '
        'mano e, dall\'ordine P, le coppie di colori sotto il contrasto',
    perche: 'il posto di un testo nella pagina si dichiara con un ruolo, e ogni '
        'misura scritta a mano e\' un pezzo di sistema deciso altrove',
  ),
  PresidioIntoccabile(
    nome: 'L\'ALBA SI LEGGE',
    prova: 'test/l_alba_si_legge_test.dart',
    sorveglia: 'il contrasto di ogni testo del Rito dell\'Alba misurato sul '
        'fotogramma vero, i quattro token del regime chiaro, e che nessuna '
        'schermata dipinga un fondo chiaro senza dichiararlo',
    perche: 'e\' l\'unica schermata che vive nel secondo regime cromatico '
        'dell\'app. Finche\' i regimi erano due e uno solo era governato dai '
        'token, nessun presidio automatico poteva proteggere l\'altro, ed e\' '
        'cosi\' che le sue etichette sono rimaste illeggibili per settimane '
        'mentre ogni censimento diceva zero',
  ),
];

void main() {
  test('ogni presidio intoccabile esiste ancora', () {
    final spariti = <String>[];
    for (final p in presidi) {
      if (!File(p.prova).existsSync()) {
        spariti.add('${p.nome}: ${p.prova} non esiste piu\'');
      }
    }
    expect(spariti, isEmpty,
        reason: 'questi presidi sono stati cancellati. Un presidio si puo\' '
            'sostituire con uno migliore, mai togliere: se la misura era '
            'sbagliata si cambia la grandezza misurata, non la si smette di '
            'misurare.\n${spariti.join("\n")}');
  });

  test('ogni presidio misura qualcosa davvero', () {
    // Un file di prova che esiste e non verifica niente e' peggio di un file
    // mancante: dice verde e non guarda.
    final inerti = <String>[];
    for (final p in presidi) {
      if (!File(p.prova).existsSync()) continue;
      final sorgente = File(p.prova).readAsStringSync();
      final quante = RegExp(r'\bexpect\(').allMatches(sorgente).length;
      if (quante < 3) {
        inerti.add('${p.nome}: solo $quante verifiche in ${p.prova}');
      }
    }
    expect(inerti, isEmpty,
        reason: 'questi presidi sono stati svuotati:\n${inerti.join("\n")}');
  });

  test('ogni presidio dichiara perche\' e\' intoccabile', () {
    for (final p in presidi) {
      expect(p.perche.length, greaterThan(60),
          reason: '${p.nome} non dice perche\' non si tocca. Se non si sa '
              'scrivere, non e\' un presidio intoccabile: e\' una prova come '
              'le altre, e sta bene dov\'e\' senza entrare in questo elenco');
      expect(p.sorveglia, isNotEmpty);
    }
  });

  test('l\'Alba e\' nell\'elenco', () {
    // Ordine P voce 15, scritta come riga sua: e' l'aggiunta che l'ordine
    // chiede, e una riga che si puo' togliere senza far cadere niente non e'
    // un'aggiunta.
    expect(presidi.map((p) => p.prova),
        contains('test/l_alba_si_legge_test.dart'));
  });
}
