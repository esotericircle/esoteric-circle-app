import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/permissions/app_permission.dart';
import '../core/permissions/esito_del_permesso.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/rituals/avvisi_del_rito.dart';

/// L'IMPLEMENTAZIONE VERA degli avvisi, sopra `flutter_local_notifications`.
///
/// **Perché questo pacchetto.** È lo standard di fatto per le notifiche locali
/// in Flutter, è l'unico che espone la modalità di consegna approssimata di cui
/// abbiamo bisogno (`AndroidScheduleMode.inexactAllowWhileIdle`), e non tira
/// dentro nessun servizio remoto: niente Firebase Messaging, niente token,
/// niente rete. Un avviso locale programmato dal dispositivo, che è
/// esattamente quello che serve e niente di più.
///
/// **L'ORA È APPROSSIMATA, per obbligo e non per pigrizia.** La ragione lunga
/// sta accanto ad [AvvisiDelRito]: su Android 14 l'ora esatta richiede una
/// permission che Google Play concede solo a sveglie e calendari, e chiederla
/// senza esserlo ci farebbe rifiutare la pubblicazione.
///
/// **Il fuso orario, e perché la versione corta.** `zonedSchedule` vuole un
/// istante con fuso, quindi serve il database dei fusi. Si usa `latest_10y`,
/// che copre dieci anni, invece di `latest`, che li copre tutti: il primo pesa
/// 290 KB di sorgente contro 1,1 MB, e per un avviso quotidiano dieci anni
/// bastano. Chi lo cambia deve sapere che sta aggiungendo ottocento KB.
class AvvisiLocali extends ServizioAvvisi {
  AvvisiLocali({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _pronto = false;

  /// Il canale Android su cui arriva l'avviso. Uno solo, con un nome che la
  /// persona riconosce nelle impostazioni di sistema.
  static const String _canaleId = 'rito_alba';
  static const String _canaleNome = 'Rito dell\'Alba';
  static const String _canaleDescrizione =
      'Un avviso al giorno, quando il sole sorge, che il Rito dell\'Alba è '
      'pronto.';

  @override
  bool get disponibile => true;

  /// Prepara plugin e fusi orari. Idempotente: chiamarla dieci volte non fa
  /// dieci inizializzazioni.
  Future<void> _prepara() async {
    if (_pronto) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Il permesso NON si chiede all'avvio: lo chiede il Rito dell'Alba la
          // prima volta che si apre, con la sua spiegazione davanti.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _pronto = true;
  }

  /// L'ESITO DELL'ULTIMA RICHIESTA, nei tre valori distinti.
  ///
  /// Ordine 2166, voce 2: `chiediPermesso` torna un si' o un no, e i due no
  /// finivano nello stesso valore. Chi aveva negato per sempre non vedeva
  /// piu' nessuna richiesta e il rito non diceva che l'unica via erano le
  /// impostazioni.
  EsitoDelPermesso? esitoDelPermesso;

  @override
  Future<bool> chiediPermesso() async {
    esitoDelPermesso = await PortaDelPermesso.chiedi(
      AppPermission.notifications,
      richiestaDiSistema: _chiediAlSistema,
    );
    return esitoDelPermesso == EsitoDelPermesso.concesso;
  }

  /// La richiesta nuda al sistema, che sa dire solo si' o no.
  Future<bool> _chiediAlSistema() async {
    await _prepara();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final darwin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (darwin != null) {
      return await darwin.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<bool> permessoConcesso() async {
    await _prepara();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    // Su iOS non esiste una lettura senza richiesta che sia affidabile qui: si
    // considera concesso solo dopo che la persona ha accettato, e chi decide
    // e' `AvvisiDelRito` insieme a cio' che il profilo ha registrato.
    return false;
  }

  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
  }) async {
    await _prepara();
    await _plugin.zonedSchedule(
      id: id,
      title: titolo,
      body: testo,
      scheduledDate: tz.TZDateTime.from(quando, tz.local),
      // QUI sta la scelta obbligata: consegna approssimata, nessuna permission
      // ristretta, nessun rischio di rifiuto dello store.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _canaleId,
          _canaleNome,
          channelDescription: _canaleDescrizione,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> annulla(int id) async {
    await _prepara();
    await _plugin.cancel(id: id);
  }

  @override
  Future<List<int>> inAttesa() async {
    await _prepara();
    final attesi = await _plugin.pendingNotificationRequests();
    return attesi.map((a) => a.id).toList(growable: false);
  }
}
