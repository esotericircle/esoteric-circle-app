import 'dart:io';

import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE CINQUE CHIAMATE PARTONO TUTTE. Ordine CW, voce 06.
///
/// **Il fatto.** Il fondatore riceve due notifiche su cinque, l'Alba e il
/// Sogno. Il pulsante di prova funziona, quindi il canale e la registrazione
/// del recapito non c'entrano.
///
/// **MISURATO, e la causa non e' dove l'ordine la cercava.**
///
/// Il **fuso** non rifiuta piu': l'ordine sospettava ancora
/// `DateTime.now().timeZoneName`, l'abbreviazione senza barra. Quel difetto
/// c'era ed e' stato riparato dall'ordine CQ voce 1.09; oggi il telefono cerca
/// nel database dei fusi la zona che si comporta come lui adesso e fra sei
/// mesi, e manda un nome IANA vero.
///
/// La **pianificazione** non ne salta nessuno: tutti e cinque i Doni stanno in
/// `accesiDiPartenza`, e la regia percorre `quelliCheChiamano` per intero.
///
/// **La causa e' che la coda si svuota e nessuno la rimetteva.** Nel manifest
/// non c'era nessun receiver: senza `RECEIVE_BOOT_COMPLETED` e senza il
/// receiver del pacchetto, ogni avviso programmato sparisce al riavvio del
/// telefono e **a ogni aggiornamento dell'app**. Chi installa una build nuova
/// quasi ogni giorno azzera le cinque chiamate ogni volta, e restano solo
/// quelle fra l'apertura dell'app e l'installazione dopo.
void main() {
  test('Tutti e cinque i Doni chiamano di partenza', () {
    final scelta = SceltaDegliAvvisi();
    final accesi = scelta.quelliCheChiamano;
    expect(accesi.length, DailyElement.values.length,
        reason: 'i Doni che chiamano di partenza sono ${accesi.length} su '
            '${DailyElement.values.length}: ${accesi.map((d) => d.shortLabel)}');
    for (final d in DailyElement.values) {
      expect(scelta.chiama(d), isTrue,
          reason: 'il Dono ${d.shortLabel} non chiama di partenza');
    }
  });

  test('Le cinque ore sono distinte e in ordine', () {
    final scelta = SceltaDegliAvvisi();
    final ore = [for (final d in scelta.quelliCheChiamano) scelta.minutiDi(d)];
    expect(ore.length, 5, reason: 'le ore sono ${ore.length}');
    expect(ore.toSet().length, ore.length,
        reason: 'due Doni chiamano allo stesso minuto: $ore');
    final ordinate = [...ore]..sort();
    expect(ore, ordinate, reason: 'le chiamate non escono in ordine di ora');
  });

  test('Cinque pianificazioni distinte, e nessuna scartata', () async {
    final scelta = SceltaDegliAvvisi();
    final finto = _AvvisiFinti();
    final id = await AvvisiDelRito.programmaLeChiamateDelGiorno(
      servizio: finto,
      adesso: DateTime(2026, 9, 7, 9, 15),
      doniAccesi: scelta.quelliCheChiamano,
      oreScelte: {
        for (final d in scelta.quelliCheChiamano) d: scelta.minutiDi(d),
      },
    );
    expect(id.length, 5,
        reason: 'le pianificazioni sono ${id.length} invece di cinque');
    expect(id.toSet().length, 5,
        reason: 'due Doni condividono lo stesso id: $id');
    expect(finto.programmate.length, 5,
        reason: 'il servizio ha ricevuto ${finto.programmate.length} '
            'programmazioni: qualcuna e\' stata scartata per strada');

    // **NESSUNA NEL PASSATO.** Un avviso con l'ora gia' passata non suona mai,
    // ed e' il modo piu' silenzioso di perdere una chiamata.
    for (final q in finto.programmate) {
      expect(q.isAfter(DateTime(2026, 9, 7, 9, 15)), isTrue,
          reason: 'una chiamata e\' stata programmata nel passato, a $q');
    }
  });

  test('Il manifest rimette le chiamate dopo il riavvio e l\'aggiornamento',
      () {
    // **SI LEGGE IL MANIFEST, non si crede al codice Dart.** La coda degli
    // avvisi vive nel sistema, e chi la rimette e' un receiver dichiarato qui:
    // nessuna riga di Dart puo' sostituirlo, e nessuna prova di Dart puo'
    // accorgersi che manca.
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest.length, greaterThan(500),
        reason: 'il manifest e\' vuoto o non e\' stato letto: questa prova '
            'sarebbe verde per cecita\'');

    expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'),
        reason: 'senza questo permesso gli avvisi programmati spariscono al '
            'riavvio del telefono e non tornano piu\'');
    expect(manifest,
        contains('ScheduledNotificationBootReceiver'),
        reason: 'manca il receiver che rimette le chiamate in coda');

    for (final azione in const [
      'android.intent.action.BOOT_COMPLETED',
      'android.intent.action.MY_PACKAGE_REPLACED',
    ]) {
      expect(manifest, contains(azione),
          reason: 'il receiver non ascolta $azione. MY_PACKAGE_REPLACED e\' '
              'l\'occasione piu\' frequente di tutte: chi installa una build '
              'nuova ogni giorno azzera le cinque chiamate ogni giorno');
    }
  });

  test('L\'ora esatta resta NON richiesta, ed e\' una scelta', () {
    // Non e' una dimenticanza da riparare: da Android 14 quella permission e'
    // ristretta e Google Play la concede solo a sveglie e calendari. Chiederla
    // farebbe rifiutare la pubblicazione. La prova la blinda, cosi' nessuno la
    // aggiunge credendo di curare le notifiche.
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    for (final vietata in const ['USE_EXACT_ALARM']) {
      expect(manifest.contains('android:name="android.permission.$vietata"'),
          isFalse,
          reason: 'il manifest chiede $vietata: Google Play la concede solo ad '
              'app la cui funzione centrale e\' la sveglia o il calendario, e '
              'chiederla fa rifiutare la pubblicazione');
    }
  });
}

/// Un servizio che accetta tutto e ricorda cosa gli e' stato chiesto.
class _AvvisiFinti extends ServizioAvvisi {
  final List<DateTime> programmate = [];
  final List<int> annullate = [];

  @override
  bool get disponibile => true;

  @override
  Future<bool> chiediPermesso() async => true;

  @override
  Future<bool> permessoConcesso() async => true;

  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {
    programmate.add(quando);
  }

  @override
  Future<void> annulla(int id) async => annullate.add(id);

  @override
  Future<List<int>> inAttesa() async => const [];

  @override
  Future<void> mostraAdesso({
    required String titolo,
    required String testo,
  }) async {}
}
