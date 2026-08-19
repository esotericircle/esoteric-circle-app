import 'dart:io';

import 'package:esoteric_circle/core/cammino/rinascita_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// IL CAMMINO RIPARTE PULITO, UNA VOLTA SOLA. Ordine AR voce 06.
///
/// **Strada A, scelta da Mauro.** Il Cammino e' stato riprogettato: i
/// contatori accumulati mentre si provava l'app raccontano una storia che non
/// esiste piu', e si azzerano. Ma un azzeramento e' la cosa piu' pericolosa
/// che si possa scrivere in un'app: se si ripete, cancella ogni volta il
/// lavoro di chi torna; se prende troppo, porta via anche il denaro.
///
/// Queste prove sorvegliano esattamente quelle tre paure: che azzeri, che
/// azzeri UNA volta sola, e che NON tocchi il saldo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Un telefono con un cammino gia' percorso e un saldo guadagnato.
  Future<SharedPreferences> telefonoConUnPassato() async {
    SharedPreferences.setMockInitialValues({
      'cammino.gesti': '{"stesa":12,"oracolo":30}',
      'cammino.accesi': <String>['med_1', 'med_2'],
      'cammino.accreditati': <String>['med_1'],
      'cammino.feste_in_attesa': <String>['med_2'],
      'cammino.serie': '{"stesa":4}',
      RinascitaDelCammino.chiaveDelSaldoCheResta: 340,
    });
    return SharedPreferences.getInstance();
  }

  test('il cammino si azzera, e il saldo resta intatto', () async {
    final prefs = await telefonoConUnPassato();
    final raccontare = await RinascitaDelCammino.rinasci(preferenze: prefs);
    // **L'ELENCO DI QUESTA PROVA E' SUO, e non quello di lib.** Prima
    // guardava le chiavi che lib dichiara: togliendone una, la prova non la
    // cercava piu' e restava verde. Una guardia che chiede all'imputato quali
    // capi d'accusa leggere non e' una guardia. Qui i nomi sono scritti a
    // mano, e sono tutto cio' che il Cammino ha lasciato su questo telefono.
    const cheDeveSparire = [
      'cammino.gesti',
      'cammino.accesi',
      'cammino.accreditati',
      'cammino.feste_in_attesa',
      'cammino.serie',
    ];
    final rimaste = cheDeveSparire.where(prefs.containsKey).toList();
    // ignore: avoid_print
    print('ORDINE AR VOCE 06: dopo la rinascita restano $rimaste, saldo '
        '${prefs.getInt(RinascitaDelCammino.chiaveDelSaldoCheResta)}');
    expect(rimaste, isEmpty,
        reason: 'queste chiavi del cammino sono sopravvissute: $rimaste');
    expect(prefs.getInt(RinascitaDelCammino.chiaveDelSaldoCheResta), 340,
        reason: 'IL SALDO EOS E STATO AZZERATO: gli Eos sono denaro gia '
            'guadagnato, e questa e la decisione dichiarata di Mauro');
    expect(raccontare, isTrue,
        reason: 'chi aveva un cammino deve leggere la riga onesta');
  });

  test('alla seconda apertura non si azzera piu niente', () async {
    final prefs = await telefonoConUnPassato();
    await RinascitaDelCammino.rinasci(preferenze: prefs);
    // Si ricomincia a camminare dopo la rinascita.
    await prefs.setString('cammino.gesti', '{"stesa":1}');
    final seconda = await RinascitaDelCammino.rinasci(preferenze: prefs);
    // ignore: avoid_print
    print('ORDINE AR VOCE 06: alla seconda apertura ha azzerato $seconda, i '
        'gesti sono ${prefs.getString('cammino.gesti')}');
    expect(seconda, isFalse,
        reason: 'la rinascita si e ripetuta: cancellerebbe il cammino nuovo a '
            'ogni apertura');
    expect(prefs.getString('cammino.gesti'), '{"stesa":1}',
        reason: 'il cammino cominciato dopo la rinascita e stato cancellato');
    expect(await RinascitaDelCammino.serveRinascere(preferenze: prefs), isFalse);
  });

  test('un Cerchio nuovo non legge la riga', () async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();
    final raccontare = await RinascitaDelCammino.rinasci(preferenze: prefs);
    // ignore: avoid_print
    print('ORDINE AR VOCE 06: un Cerchio nuovo racconta la rinascita? '
        '$raccontare');
    expect(raccontare, isFalse,
        reason: 'a chi apre l app per la prima volta si racconta di una '
            'perdita che non ha subito');
    expect(await RinascitaDelCammino.serveRinascere(preferenze: prefs), isFalse,
        reason: 'anche un Cerchio nuovo deve restare segnato alla generazione '
            'attuale, altrimenti la rinascita lo aspetta al varco domani');
  });

  test('il saldo non e nell elenco di cio che si cancella', () {
    // La stessa pretesa dell'altra prova, presa dal lato del DATO invece che
    // del comportamento: cosi' cade anche chi aggiungesse la chiave del saldo
    // all'elenco "per pulizia" senza far girare niente.
    expect(
        RinascitaDelCammino.chiaviDaAzzerare
            .contains(RinascitaDelCammino.chiaveDelSaldoCheResta),
        isFalse,
        reason: 'la chiave del saldo e finita fra quelle da cancellare');
  });

  test('il diario svuota anche la MEMORIA, non solo il disco', () async {
    // Cancellare le chiavi e lasciare i conti vivi dentro l oggetto vorrebbe
    // dire riscriverli tali e quali al primo salvataggio successivo.
    SharedPreferences.setMockInitialValues({
      'cammino.gesti': '{"stesa":12}',
      'cammino.accesi': <String>['med_1'],
    });
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    expect(diario.accesi, isNotEmpty, reason: 'il diario non ha letto niente');
    await diario.azzeraPerLaRinascita();
    // ignore: avoid_print
    print('ORDINE AR VOCE 06: dopo l azzeramento il diario ha '
        '${diario.accesi.length} traguardi accesi');
    expect(diario.accesi, isEmpty,
        reason: 'i traguardi accesi sono rimasti in memoria');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('cammino.accesi') ?? const [], isEmpty,
        reason: 'la memoria svuotata non e arrivata al disco');
  });

  test('il server dimentica prima di fondere', () {
    // **PERCHE' QUESTA PROVA GUARDA IL SORGENTE DEL SERVER.** La fusione
    // difende sempre il numero piu' alto: se il server fondesse e poi
    // dimenticasse, il cammino vecchio tornerebbe indietro tutto intero al
    // primo avvio. L ordine conta, e qui si sorveglia.
    final server = File('functions/src/cerchio.ts').readAsStringSync();
    expect(server.contains('azzeraIlCammino'), isTrue,
        reason: 'il server non sa piu dimenticare il cammino');
    final dove = server.indexOf('const custodito = azzeraIlCammino');
    final fusione = server.indexOf('fondiCammini(custodito');
    expect(dove, greaterThan(0),
        reason: 'il server non azzera piu il cammino custodito');
    expect(dove, lessThan(fusione),
        reason: 'il server fonde PRIMA di dimenticare: il cammino vecchio '
            'tornerebbe indietro tutto intero');
  });

  test('la riga onesta dice cosa e successo e cosa NON e successo', () {
    final riga = RinascitaDelCammino.rigaOnesta.toLowerCase();
    // ignore: avoid_print
    print('ORDINE AR VOCE 06: la riga dice "$riga"');
    expect(riga.contains('eos'), isTrue,
        reason: 'la riga non dice che gli Eos non sono stati toccati, ed e la '
            'prima cosa che chi apre vuole sapere');
    expect(riga.contains('riparte') || riga.contains('riprogettato'), isTrue,
        reason: 'la riga non dice che il Cammino e stato riprogettato');
    // E la home la mostra da sola, senza che nessuno la vada a cercare.
    final home =
        File('lib/features/santuario/santuario_screen.dart').readAsStringSync();
    expect(home.contains('FoglioDellaRinascita.seServe'), isTrue,
        reason: 'la home non mostra piu la riga: chi apre trova il Journal '
            'spento e nessuno gli dice perche');
  });
}
