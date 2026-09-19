import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// IL DIARIO NON RIPARTE MAI DA ZERO. Ordine AO voce 04.
///
/// **IL DIFETTO, ed e' quello che Mauro ha visto.** L'ordine chiedeva di
/// enumerare i passi del filo dei premi e di provarli uno per uno: sette
/// passi e quattro candidati, tutti verdi. Il filo REGGE. Il premio non
/// arrivava perche' il traguardo non maturava, e non maturava perche' il
/// conto dei gesti si azzerava.
///
/// **La causa, e viene dalla stessa famiglia della voce AN.04.** L'app
/// costruisce il diario e lancia il caricamento senza attenderlo, con la
/// cascata che chiama `carica` sul costruttore. Chi apre l'app e fa subito
/// un gesto,
/// e succede a chiunque apra l'app per fare qualcosa, incontra questa
/// sequenza:
///   1. `carica()` parte e va a leggere il disco, che e' lento;
///   2. `segna()` non aspetta nessuno: incrementa i contatori partendo da
///      mappe ANCORA VUOTE, quindi il conto delle stese diventa 1 invece
///      di 4;
///   3. `segna()` chiama `_salva()`, che scrive quel conto povero SUL
///      DISCO, cancellando la storia vera;
///   4. `carica()` finisce e rilegge... cio' che il passo 3 ha appena
///      scritto.
/// Il cammino di giorni torna al primo giorno, i traguardi si allontanano e
/// i premi non arrivano. Non tutti: quelli che dipendono da un conteggio.
///
/// **La prova riproduce l'attimo vero**, non una versione comoda: si lancia
/// il caricamento e si fa il gesto SUBITO, senza lasciar respirare niente.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Quante volte un gesto risulta compiuto, letto dalla fotografia che il
  /// diario espone: e' la stessa che guardano i traguardi.
  int quanteVolte(DiarioDelCammino diario, String gesto) =>
      diario.statoDelCammino().gestiCompiuti[gesto] ?? 0;

  /// Un disco che ha gia' una storia: tre stese, due gettate, due giorni.
  void discoConStoria() {
    SharedPreferences.setMockInitialValues({
      'cammino.gesti': '{"stesa":3,"gettata":2}',
      'cammino.giorni': '{"stesa":2,"gettata":1}',
      'cammino.accesi': ['med_1'],
    });
  }

  test('un gesto fatto mentre il disco si legge NON cancella la storia',
      () async {
    discoConStoria();
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    // **L'ATTIMO VERO**: il caricamento e' in volo, come lo lancia l'app.
    final lettura = diario.carica();
    await diario.segna('stesa');
    await lettura;

    // ignore: avoid_print
    print('ORDINE AO VOCE 04: dopo il gesto in volo, stese '
        '${quanteVolte(diario, 'stesa')}, gettate '
        '${quanteVolte(diario, 'gettata')}, accesi ${diario.accesi}');
    expect(quanteVolte(diario, 'stesa'), 4,
        reason: 'le stese sono ${quanteVolte(diario, 'stesa')} invece di 4: il '
            'gesto e\' stato contato su un diario ancora vuoto e la storia di '
            'prima e\' stata cancellata, quindi i traguardi che aspettavano '
            'quel conto si sono allontanati e i loro premi non arriveranno');
    expect(quanteVolte(diario, 'gettata'), 2,
        reason: 'le gettate non c\'entravano niente col gesto fatto, e sono '
            '${quanteVolte(diario, 'gettata')} invece di 2');
    expect(diario.accesi, contains('med_1'),
        reason: 'il Sigillo gia\' acceso e\' sparito dal diario');
  });

  test('e nemmeno il disco viene riscritto povero', () async {
    // **SI GUARDA IL DISCO, non solo la memoria.** Il danno peggiore non e'
    // il numero sbagliato di questo istante: e' che `_salva` lo scrive, e da
    // li' in poi la storia vera non esiste piu' per nessuno.
    discoConStoria();
    final primo = DiarioDelCammino(orologio: orologioDelleProve);
    final lettura = primo.carica();
    await primo.segna('stesa');
    await lettura;

    // Si riapre l'app: un diario nuovo legge cio' che c'e' sul disco.
    final dopoIlRiavvio = DiarioDelCammino(orologio: orologioDelleProve);
    await dopoIlRiavvio.carica();
    // ignore: avoid_print
    print('ORDINE AO VOCE 04: al riavvio il disco dice stese '
        '${quanteVolte(dopoIlRiavvio, 'stesa')}, accesi '
        '${dopoIlRiavvio.accesi}');
    expect(quanteVolte(dopoIlRiavvio, 'stesa'), 4,
        reason: 'il disco porta ${quanteVolte(dopoIlRiavvio, 'stesa')} stese '
            'invece di 4: la storia e\' stata cancellata per sempre');
    expect(dopoIlRiavvio.accesi, contains('med_1'),
        reason: 'il disco ha perso il Sigillo che era acceso');
  });

  test('anche accendere un Sigillo aspetta il disco', () async {
    // Stessa famiglia: `accendi` scrive la lista degli accesi, e se la
    // scrive mentre il disco non e' ancora stato letto si porta via quelli
    // di prima.
    discoConStoria();
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    final lettura = diario.carica();
    await diario.accendi('med_9');
    await lettura;
    // ignore: avoid_print
    print('ORDINE AO VOCE 04: accesi dopo l\'accensione in volo '
        '${diario.accesi}');
    expect(diario.accesi, containsAll(<String>['med_1', 'med_9']),
        reason: 'accendendo un Sigillo mentre il disco si legge, quelli di '
            'prima spariscono: ${diario.accesi}');
  });
}
