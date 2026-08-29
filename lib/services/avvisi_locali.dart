import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/permissions/app_permission.dart';
import '../core/permissions/esito_del_permesso.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/rituals/avvisi_del_rito.dart';
import '../core/misura/misura_del_ritorno.dart';
import '../core/misura/registro_del_ritorno.dart';

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

  /// I CANALI, uno per chiamata, coi nomi che la persona riconosce nelle
  /// impostazioni di sistema: ognuno si spegne da solo, ordine M voce 2g.
  static const Map<String, (String, String)> canali = {
    'rito_alba': (
      'Rito dell\'Alba',
      'Un avviso al giorno, quando il sole sorge, che il Rito dell\'Alba è '
          'pronto.'
    ),
    'runa_tramonto': (
      'Runa del Tramonto',
      'Un avviso la sera, quando il sole scende, che la runa della sera ti '
          'aspetta.'
    ),
    // **I TRE CANALI STANTII SONO STATI TOLTI, ordine BG voce 03.** Il
    // cielo di oggi, i Sigilli del Cammino e le gettate di rune comparivano
    // nelle impostazioni di Android promettendo avvisi che nessuno
    // programma piu': un canale registrato e' una promessa a schermo, e le
    // promesse non mantenute si tolgono.
    // **I CINQUE CANALI DEI DONI. Ordine BC voce 05.**
    //
    // Uno per Dono, col nome che la persona riconosce: **cosi' ognuno si
    // spegne anche dalle impostazioni di Android**, e chi spegne il Sigillo
    // del Sogno non perde il Rito dell'Alba. Dentro l'app gli stessi cinque
    // hanno il loro interruttore nel menu' Notifiche.
    'dono_dawn': (
      'Rito dell\'Alba',
      'Un avviso al mattino, quando il sole sorge, che il Rito dell\'Alba è '
          'pronto.'
    ),
    'dono_breath': (
      'Soffio del Destino',
      'Un avviso a metà mattina, quando è l\'ora del respiro.'
    ),
    'dono_oracle': (
      'Arcano del Giorno',
      'Un avviso a mezzogiorno passato, quando la carta di oggi si può '
          'scoprire.'
    ),
    'dono_rune': (
      'Runa del Tramonto',
      'Un avviso la sera, quando il sole scende e la runa ti aspetta.'
    ),
    'dono_night': (
      'Sigillo del Sogno',
      'Un avviso a tarda sera, quando c\'è un Sigillo da chiudere prima di '
          'dormire.'
    ),
  };

  /// CHI APRE LA SCENA PROMESSA. L'app lo imposta all'avvio: riceve il
  /// carico dell'avviso toccato e porta alla scena, mai alla home. Statico
  /// perche' il tocco su una notifica puo' arrivare prima di qualunque
  /// widget.
  static void Function(String carico)? suApertura;

  @override
  bool get disponibile => true;

  /// Prepara plugin e fusi orari. Idempotente: chiamarla dieci volte non fa
  /// dieci inizializzazioni.
  Future<void> _prepara() async {
    if (_pronto) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      onDidReceiveNotificationResponse: (risposta) {
        final carico = risposta.payload ?? '';
        // **IL RITORNO DA UN AVVISO SI SEGNA QUI. Ordine CC voce 09.**
        //
        // E' la sola riga dell'app che sa che si e' entrati toccando una
        // notifica, e la voce chiede proprio "quale notifica le riporta
        // dentro". Il contesto e' il nome del Dono, che sta in un elenco
        // chiuso: il carico ha la forma `dono:<nome>` e nient'altro viene
        // passato, cosi' un carico di domani con dentro qualcosa di diverso
        // non finisce nella misura per sbaglio.
        const prefisso = 'dono:';
        RegistroDelRitorno.segnalo(
          EventoDelRitorno.ritornoDaAvviso,
          contesto: carico.startsWith(prefisso)
              ? carico.substring(prefisso.length)
              : null,
        );
        if (carico.isNotEmpty) AvvisiLocali.suApertura?.call(carico);
      },
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
    try {
      await _prepara();
    } catch (errore) {
      // Si ignora e si risponde no: senza piattaforma (le prove, un ambiente
      // monco) chiedere il permesso non ha senso, e un no e' la verita'.
      return false;
    }
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
    // SENZA PIATTAFORMA NIENTE PANICO: nelle prove il plugin non esiste e
    // ogni chiamata solleverebbe. Un servizio di avvisi che non riesce a
    // rispondere risponde no, e l'app resta intera.
    try {
      await _prepara();
    } catch (errore) {
      // Si ignora e si risponde no: un servizio di avvisi che non riesce a
      // prepararsi non ha il permesso, qualunque cosa sia andata storta.
      return false;
    }
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
    String canale = 'rito_alba',
    String carico = '',
  }) async {
    await _prepara();
    final (nome, descrizione) = canali[canale] ?? canali['rito_alba']!;
    await _plugin.zonedSchedule(
      id: id,
      title: titolo,
      body: testo,
      payload: carico,
      scheduledDate: tz.TZDateTime.from(quando, tz.local),
      // QUI sta la scelta obbligata: consegna approssimata, nessuna permission
      // ristretta, nessun rischio di rifiuto dello store.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          canale,
          nome,
          channelDescription: descrizione,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
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

/// IL SERVIZIO CONDIVISO DELL'APP, uno solo.
///
/// **Prima non esisteva, e va detto forte: nessun punto di lib costruiva
/// `AvvisiLocali`,** quindi il Rito dell'Alba parlava col servizio SPENTO di
/// default e nessun avviso partiva davvero sul telefono. Le scene continuano
/// ad accettare l'iniezione per le prove; l'app vera passa questo.
final AvvisiLocali avvisiDelCerchio = AvvisiLocali();
