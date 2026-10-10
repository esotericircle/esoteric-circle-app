import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import '../../core/rituals/avvisi_del_rito.dart';
import '../../core/rituals/daily_elements.dart';
import '../avvisi_locali.dart';

/// **LA PUSH DI UN DONO, QUANDO ARRIVA AL TELEFONO. Ordine ES voce 17.**
///
/// Dal server la push del Dono arriva come dato, `{dono: "night"}`, e non
/// come notifica gia' fatta: la notifica la compone e la mostra l'app, con
/// lo stesso identificativo della chiamata locale del Dono, dalla porta sola
/// degli avvisi (`AvvisiDelRito.allaPushDelDono`). Prima il sistema la
/// mostrava da se', accanto alla locale: il fondatore ne ha ricevute tre per
/// un Dono.
///
/// Due strade la portano qui: [laPushInSottofondo] quando l'app e' chiusa o
/// in sottofondo, e [ascoltaLePushInPrimoPiano] quando e' aperta.

/// Il Dono nominato da una push, o nessuno se la push non ne nomina uno
/// vero (un Dono tolto, come l'Arcano del giorno, o un messaggio d'altro).
DailyElement? donoDellaPush(Map<String, dynamic> dati) {
  final nome = dati['dono'];
  for (final d in DailyElement.values) {
    if (d.name == nome) return d;
  }
  return null;
}

/// Consegna una push di Dono alla porta sola degli avvisi.
Future<EsitoDellaPush?> consegnaLaPush(
    Map<String, dynamic> dati, AvvisiLocali servizio) async {
  // **LA PUSH DEL CERCHIO, ordine EY voce 10**: un segno, un invito, un dono.
  // Il testo lo compone il server e nomina la cosa ("Lunaria ti ha mandato un
  // segno"), mai "apri l'app"; qui si mostra sul canale del Cerchio.
  if (dati['tipo'] == 'cerchio') {
    final testo = dati['testo'];
    if (testo is String && testo.isNotEmpty) {
      await servizio.mostraDelDono(
        id: 90100 + testo.hashCode.abs() % 800,
        titolo: (dati['titolo'] as String?) ?? 'Il Cerchio',
        testo: testo,
        canale: 'cerchio',
        carico: 'cerchio',
      );
    }
    return null;
  }
  final dono = donoDellaPush(dati);
  if (dono == null) return null;
  return AvvisiDelRito.allaPushDelDono(
      servizio: servizio, dono: dono, adesso: DateTime.now());
}

/// **CON L'APP CHIUSA O IN SOTTOFONDO.** Gira in un isolato suo, senza
/// l'app: per questo prepara da se' i canali dei plugin.
@pragma('vm:entry-point')
Future<void> laPushInSottofondo(RemoteMessage messaggio) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  try {
    await consegnaLaPush(messaggio.data, AvvisiLocali());
  } catch (errore) {
    // L'errore si IGNORA, e si dichiara perche': in sottofondo non c'e'
    // nessuno a cui dirlo, e la chiamata locale del Dono resta in coda come
    // rete di sicurezza.
  }
}

/// **CON L'APP APERTA.** Il sistema non mostra niente da se' per una push
/// di soli dati: la consegna la fa l'app, allo stesso modo.
void ascoltaLePushInPrimoPiano() {
  FirebaseMessaging.onMessage.listen((messaggio) async {
    try {
      await consegnaLaPush(messaggio.data, avvisiDelCerchio);
    } catch (errore) {
      // L'errore si IGNORA, e si dichiara perche': la chiamata locale del
      // Dono resta in coda, e l'app aperta non deve cadere per un avviso.
    }
  });
}
