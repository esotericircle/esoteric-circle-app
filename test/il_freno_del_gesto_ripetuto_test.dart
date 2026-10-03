import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'istante_dichiarato.dart';

/// **IL FRENO DEL GESTO RIPETUTO, MISURATO DA SOLO.**
/// Ordine CQ voce 1.11, 3 settembre 2026.
///
/// **Il fatto: un innesto e' rimasto verde.** Nella prova del rosso
/// dell'ordine CP, togliere il freno della voce CP.02 non ha fatto cadere la
/// guardia dell'abuso. Il rapporto di allora lo aveva gia' spiegato: otto
/// gettate di fila non fanno feste per DUE ragioni indipendenti, e basta la
/// prima. La scala, perche' il prossimo gradino dell'Albero e' un pezzo
/// dell'identita' che una gettata non completa; e il corpus, perche' nessun
/// gradino della revisione F conta le aperture.
///
/// **Ma un freno che nessuna guardia vede e' un freno che sparisce.** Il
/// giorno che qualcuno lo togliesse per errore, o riscrivendo il diario,
/// tutta la suite resterebbe verde, e il difetto tornerebbe alla prima
/// revisione del corpus che scrivesse un gradino a volte invece che a giorni:
/// **cioe' proprio quando serve, e senza preavviso.**
///
/// **La grandezza che cambia e' quella giusta.** La guardia dell'abuso misura
/// le FESTE, ed e' un effetto lontano, protetto da due cause. Questa misura il
/// CONTATORE, che e' il posto in cui il freno agisce: fra i due c'e' tutta la
/// distanza che ha reso verde quell'innesto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // **L'ISTANTE E' DICHIARATO**, ordine U voce 00: un diario senza orologio
  // pesca dal giorno vero, e con lui dal cielo del giorno.
  late DateTime adesso;

  Future<DiarioDelCammino> diario() async {
    SharedPreferences.setMockInitialValues(const {});
    adesso = istanteDelleProve;
    final d = DiarioDelCammino(orologio: () => adesso);
    await d.carica();
    return d;
  }

  test('lo stesso gesto con gli stessi dettagli conta una volta al giorno',
      () async {
    final d = await diario();
    final letti = <int>[];
    for (var i = 0; i < 8; i++) {
      await d.segna('oroscopo', dettagli: const {'orizzonte': 'giorno'});
      letti.add(d.statoDelCammino().gestiCompiuti['oroscopo'] ?? 0);
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.11: otto interrogazioni identiche, il contatore '
        'legge $letti');
    cardinaleMinimo(letti.length, 8,
        cosa: 'interrogazioni identiche fatte di fila',
        perche: 'Con meno di due chiamate non ci sarebbe nessuna ripetizione '
            'da frenare, e la prova sarebbe verde senza aver provato niente.');
    expect(letti.last, 1,
        reason: 'otto interrogazioni identiche hanno contato ${letti.last} '
            'volte: e la consuetudine che il fondatore ha nominato per prima, '
            'otto feste in due funzionalita');
  });

  test('e i dettagli diversi contano davvero, che e varieta e non abuso',
      () async {
    final d = await diario();
    for (final orizzonte in const ['giorno', 'settimana', 'mese']) {
      // Due volte ciascuno: la seconda non deve contare.
      await d.segna('oroscopo', dettagli: {'orizzonte': orizzonte});
      await d.segna('oroscopo', dettagli: {'orizzonte': orizzonte});
    }
    final conto = d.statoDelCammino().gestiCompiuti['oroscopo'] ?? 0;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.11: tre orizzonti diversi, ciascuno chiesto due '
        'volte, il contatore legge $conto');
    expect(conto, 3,
        reason: 'tre orizzonti diversi contano $conto invece di tre: o il '
            'freno chiude sul solo nome del gesto, e allora mura i quindici '
            'gradini della varieta del dettaglio, oppure non frena affatto');
  });

  test('il freno si apre al confine del giorno rituale', () async {
    final d = await diario();
    await d.segna('oroscopo', dettagli: const {'orizzonte': 'giorno'});
    await d.segna('oroscopo', dettagli: const {'orizzonte': 'giorno'});
    final oggi = d.statoDelCammino().gestiCompiuti['oroscopo'] ?? 0;
    // Domani, alla stessa ora.
    adesso = adesso.add(const Duration(days: 1));
    await d.segna('oroscopo', dettagli: const {'orizzonte': 'giorno'});
    final domani = d.statoDelCammino().gestiCompiuti['oroscopo'] ?? 0;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.11: due interrogazioni oggi contano $oggi, e '
        'domani il conto arriva a $domani');
    expect(oggi, 1);
    expect(domani, 2,
        reason: 'domani lo stesso gesto conta ancora $domani: il freno non e '
            'di oggi, e diventa un limite di una volta per sempre');
  });
}
