import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/identity/dimenticanza_del_telefono.dart';
import 'package:esoteric_circle/core/identity/scarico_dei_tuoi_dati.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE QUATTRO VOCI DELL'ACCOUNT. Ordine BC voce 02.
///
/// **Decisione del fondatore**, quattro voci con ripensamento:
///
/// 1. Esci dall'account, in evidenza e reversibile.
/// 2. Scarica i tuoi dati.
/// 3. Cancella i tuoi dati tenendo l'account.
/// 4. Cancella l'account, in fondo, con la schermata che elenca cosa sparisce
///    davvero, e trenta giorni di ripensamento.
///
/// **E il vincolo esterno non e' opinabile**: Apple obbliga dal 30 giugno 2022
/// ogni app che permette di creare un account a permettere di cancellarlo
/// dall'app stessa; Google Play dal 2024 chiede la cancellazione dentro l'app
/// e da una pagina web, piu' **un'opzione separata per cancellare solo i dati
/// tenendo l'account**; il diritto alla cancellazione del GDPR non si soddisfa
/// con un logout.
///
/// Che la cancellazione dimentichi davvero tutto lo misura
/// `test/cancellare_dimentica_tutto_test.dart`. Qui si guardano lo scarico e
/// l'esistenza delle quattro voci.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const finti = <String, Object>{
    'profile.nome': 'Sofia',
    'cammino.gesti': '{"alba":3}',
    'borsellino.movimenti': '[{"quanti":10}]',
    'sigilli.accesi': 'aur_1,aur_2',
    'account.custodito': true,
    // **Una che NON deve finire nell'archivio**: le impostazioni del telefono
    // non sono dati della persona, ed e' la stessa ragione per cui non si
    // cancellano.
    'settings.reduceAnimations': true,
  };

  test('BC.02: lo scarico raccoglie i dati e lascia fuori le impostazioni',
      () async {
    SharedPreferences.setMockInitialValues(finti);
    final albero = await ScaricoDeiTuoiDati.raccogli();
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: l archivio porta ${albero['quanteVoci']} voci, '
        'raggruppate in ${(albero['dati'] as Map).length} argomenti');
    expect(albero['quanteVoci'], 5,
        reason: 'l archivio porta ${albero['quanteVoci']} voci invece di '
            'cinque: o ne ha perse, o ci ha messo le impostazioni');
    final dati = albero['dati'] as Map;
    expect(dati.values.join(), isNot(contains('reduceAnimations')),
        reason: 'le impostazioni del telefono sono finite nei dati personali');
    expect(dati['Il tuo profilo'], isNotNull);
    expect(dati['I tuoi Eos'], isNotNull);
  });

  test('BC.02: il file JSON si rilegge, e dice cosa e', () async {
    SharedPreferences.setMockInitialValues(finti);
    final albero = await ScaricoDeiTuoiDati.raccogli();
    final testo = ScaricoDeiTuoiDati.comeJson(albero);
    // **SI RILEGGE**: un archivio che non si riapre non e' un archivio.
    final riletto = jsonDecode(testo) as Map<String, Object?>;
    expect(riletto['formato'], 'esoteric-circle/dati-personali');
    expect(riletto['versione'], ScaricoDeiTuoiDati.versione);
    expect(riletto['quanteVoci'], 5);
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: il JSON pesa ${testo.length} caratteri e si '
        'rilegge');
  });

  test('BC.02: e il riepilogo si legge in italiano, e dice cosa NON c e',
      () async {
    SharedPreferences.setMockInitialValues(finti);
    final albero = await ScaricoDeiTuoiDati.raccogli();
    final testo = ScaricoDeiTuoiDati.comeRiepilogo(albero);
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: il riepilogo comincia con "'
        '${testo.split("\\n").first}"');
    expect(testo, contains('I TUOI DATI NEL CERCHIO'));
    expect(testo, contains('IL TUO PROFILO'));
    expect(testo, contains('Sofia'),
        reason: 'il riepilogo non porta i dati veri');
    // **COSA NON C E DENTRO**, che e l informazione che nessun archivio si
    // ricorda mai di dare: la memoria dei Maestri vive sul server, e le
    // password non le vede nessuno qui.
    expect(testo, contains('COSA NON C\'È QUI DENTRO'));
    expect(testo, contains('password'));
  });

  test('BC.02: e non si scarica meno di quello che si cancella', () {
    // **LE DUE LISTE NON POSSONO INVECCHIARE PER CONTO LORO.** Se domani si
    // aggiungesse un prefisso alla dimenticanza senza aggiungerlo ai gruppi
    // dello scarico, ci sarebbe un dato che l app cancella e non sa mostrare:
    // qualcuno chiederebbe i propri dati e ne riceverebbe una parte, senza
    // che nessuno se ne accorga.
    final scoperti = ScaricoDeiTuoiDati.prefissiScoperti();
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: prefissi che si cancellano '
        '${DimenticanzaDelTelefono.prefissiDaDimenticare.length}, gruppi '
        'dello scarico ${ScaricoDeiTuoiDati.gruppi.length}, scoperti '
        '${scoperti.length}');
    expect(scoperti, isEmpty,
        reason: 'questi prefissi si cancellano ma non si scaricano: '
            '$scoperti');
  });

  test('BC.02: la voce cancella i dati tiene la custodia', () async {
    // **E LA SOLA DIFFERENZA CON L OBLIO.** Chi azzera il cammino resta nel
    // Cerchio: cancellargli la custodia vorrebbe dire chiudere fuori chi ha
    // chiesto soltanto di ricominciare.
    SharedPreferences.setMockInitialValues(finti);
    await DimenticanzaDelTelefono.dimentica(tenendo: const ['account.']);
    final prefs = await SharedPreferences.getInstance();
    final rimaste = prefs.getKeys().toList()..sort();
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: dopo aver azzerato i dati restano $rimaste');
    expect(prefs.getBool('account.custodito'), isTrue,
        reason: 'la custodia e stata cancellata: chi voleva solo ricominciare '
            'si ritrova chiuso fuori');
    expect(prefs.getString('cammino.gesti'), isNull,
        reason: 'il cammino non e stato azzerato');
    expect(prefs.getBool('settings.reduceAnimations'), isTrue,
        reason: 'le impostazioni del telefono sono state buttate');
  });

  test('BC.02: le quattro voci ci sono tutte, e la cancellazione e in fondo',
      () {
    final schermata = File('lib/features/account/account_screen.dart')
        .readAsStringSync();
    final ordine = <String>[];
    for (final id in const ['esci', 'scarica', 'azzera', 'oblio']) {
      final dove = schermata.indexOf("id: '$id'");
      expect(dove, greaterThan(0),
          reason: 'la voce "$id" non c e nel menu dell account');
      ordine.add('$id@$dove');
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: le quattro voci compaiono in questo ordine: '
        '$ordine');
    // **L ORDINE E QUELLO DECISO DAL FONDATORE**: esci in evidenza, poi
    // scarica, poi cancella i dati, e la cancellazione dell account IN FONDO.
    final posizioni = [
      for (final id in const ['esci', 'scarica', 'azzera', 'oblio'])
        schermata.indexOf("id: '$id'")
    ];
    for (var i = 1; i < posizioni.length; i++) {
      expect(posizioni[i], greaterThan(posizioni[i - 1]),
          reason: 'le quattro voci non sono nell ordine deciso dal fondatore: '
              'la cancellazione dell account deve stare in fondo');
    }
  });

  test('BC.02: e la porta VERA chiama davvero il server', () {
    // **LE DUE CHIAMATE HANNO UN COMPORTAMENTO DI DIFETTO**, perche' nel
    // progetto vivono diciannove porte finte e renderle obbligatorie avrebbe
    // voluto dire toccare diciannove file per una funzione che quelle prove
    // non usano. Il difetto e' prudente, nessuna data e nessun annullamento,
    // **ma un difetto silenzioso su una porta VERA sarebbe un oblio che non
    // parte e nessuno se ne accorge**: qui si guarda che quella vera lo
    // implementi.
    final porta = File('lib/services/server/porta_del_cerchio.dart')
        .readAsStringSync();
    for (final chiamata in const ["'chiediLOblio'", "'annullaLOblio'"]) {
      expect(porta.contains(chiamata), isTrue,
          reason: 'la porta vera non chiama piu $chiamata sul server: la '
              'richiesta di oblio non arriverebbe da nessuna parte');
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: la porta vera chiama chiediLOblio e '
        'annullaLOblio sul server');
  });

  test('BC.02: e i giorni che si dicono sono quelli che il server segna', () {
    // **UN NUMERO SOLO IN DUE POSTI, ed e il tipo di scarto che nessuno vede
    // finche non e troppo tardi**: se qui si dicesse trenta e il server ne
    // segnasse quindici, la persona leggerebbe una promessa e ne vivrebbe
    // un altra.
    final server = File('functions/src/cerchio.ts').readAsStringSync();
    final trovato =
        RegExp(r'GIORNI_DI_RIPENSAMENTO = (\d+)').firstMatch(server);
    expect(trovato, isNotNull,
        reason: 'il server non dichiara piu i giorni di ripensamento');
    // ignore: avoid_print
    print('ORDINE BC VOCE 02: l app dice $giorniDiRipensamento giorni, il '
        'server ne segna ${trovato!.group(1)}');
    expect(int.parse(trovato.group(1)!), giorniDiRipensamento);
  });
}
