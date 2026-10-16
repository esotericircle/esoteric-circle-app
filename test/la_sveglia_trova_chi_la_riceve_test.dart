import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LA SVEGLIA TROVA CHI LA RICEVE.** Ordine CZ, voce 11.
///
/// **LA PROVA VIENE DAL TELEFONO, non dal banco**, come l'ordine impone.
/// L'8 settembre 2026 sul dispositivo 767f596c: sveglia programmata per le
/// 04:40, alle 04:41 **uscita dalla coda** di `dumpsys alarm`, e in
/// `dumpsys notification` **nessuna notifica dell'app**. La sveglia parte e la
/// notifica non compare: sono due fatti distinti, e questo e' il secondo.
///
/// **LA CAUSA.** `flutter_local_notifications` non posta la notifica da se':
/// mette in coda un `AlarmManager` che, allo scadere, manda un broadcast a
/// **`ScheduledNotificationReceiver`**. Se quel receiver non e' dichiarato nel
/// manifest dell'app, **il broadcast non trova nessuno**: la sveglia scatta,
/// esce dalla coda, e non succede niente.
///
/// **PERCHE' NON L'AVEVA PRESO LA VOCE CW.06.** Quella voce aveva aggiunto
/// `ScheduledNotificationBootReceiver`, che e' un altro receiver e serve a
/// un'altra cosa: rimettere in coda gli avvisi dopo un riavvio o un
/// aggiornamento. **Ho aggiunto quello del ritorno e non quello dell'arrivo**,
/// e la guardia che avevo scritto chiedeva il primo per nome, quindi era
/// verde su un manifest che non poteva funzionare.
///
/// E' ancora una volta il pezzo sano misurato accanto al pezzo rotto, e la
/// **REGOLA H** nata in questo ordine e' scritta per questo: una guardia che
/// dimostra una presenza deve dimostrare anche cio' che manca.
///
/// **PERCHE' IL PULSANTE DI PROVA FUNZIONAVA.** `mostraAdesso` chiama
/// `_plugin.show`, che posta la notifica **subito e nel processo dell'app**:
/// non passa da nessun receiver. Il canale, il permesso e il recapito erano
/// sani, ed e' per questo che la prova a mano diceva di si' mentre le cinque
/// chiamate del giorno tacevano.
void main() {
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  test('Il manifest e\' stato letto davvero', () {
    expect(manifest.length, greaterThan(1000),
        reason: 'il manifest e\' vuoto o non e\' stato letto: ogni pretesa '
            'qui sotto sarebbe verde per cecita\'');
  });

  test('IL RECEIVER CHE RICEVE LA SVEGLIA e\' dichiarato', () {
    expect(manifest, contains('ScheduledNotificationReceiver'),
        reason: 'senza questo receiver la sveglia parte, esce dalla coda e '
            'la notifica non nasce: e\' misurato sul telefono 767f596c l\'8 '
            'settembre 2026, sveglia delle 04:40 partita e nessuna notifica');
  });

  test('E NON SI CONFONDE COL RECEIVER DEL RIAVVIO', () {
    // **REGOLA H: si prova anche cio' che il primo non e'.** I due nomi si
    // somigliano e fanno due lavori diversi: uno rimette in coda gli avvisi
    // dopo un riavvio, l'altro posta la notifica quando la sveglia scatta.
    // Avere solo il primo e' esattamente lo stato in cui il fondatore non
    // riceveva niente, e una prova che cerca "ScheduledNotification" e basta
    // sarebbe verde su tutti e due i casi.
    expect(manifest, contains('ScheduledNotificationBootReceiver'),
        reason: 'manca il receiver del riavvio: gli avvisi sparirebbero a ogni '
            'aggiornamento dell\'app');

    // Il nome del receiver dell'arrivo deve comparire **da solo**, cioe' non
    // soltanto come pezzo del nome di quello del riavvio.
    final senzaIlBoot =
        manifest.replaceAll('ScheduledNotificationBootReceiver', '');
    expect(senzaIlBoot, contains('ScheduledNotificationReceiver'),
        reason: 'nel manifest c\'e\' solo `ScheduledNotificationBootReceiver`, '
            'e la ricerca del nome corto lo trovava dentro quello lungo: e\' '
            'la cecita\' per cui la voce CW.06 e\' passata verde su un '
            'manifest che non poteva consegnare nessuna notifica');
  });

  test('I due receiver non sono esportati', () {
    // Un receiver esportato lo puo' svegliare qualunque app installata: qui
    // non serve a nessuno da fuori.
    final quanti = 'android:exported="false"'.allMatches(manifest).length;
    expect(quanti, greaterThanOrEqualTo(2),
        reason: 'nel manifest ci sono $quanti dichiarazioni di non esportato: '
            'i due receiver delle notifiche devono esserlo entrambi');
  });
}
