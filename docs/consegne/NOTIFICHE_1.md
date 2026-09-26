# CONSEGNA, ORDINE NOTIFICHE 1

Ramo `claude/notifiche-1-b1e463`, partito da
`origin/claude/esoteric-circle-master-order-e798aj` a `2c2b7c6`, distanza zero
nei due sensi. Nessuna build, `versionCode` non toccato. `STATO_VIVO.md` e
`RIPRESA.md` non aperti in scrittura, per la deroga dichiarata.

## Le cinque premesse

| # | Premessa | Esito |
|---|---|---|
| 1 | Nessun sistema di notifiche nel repo | **vera**, riconfermata su `2c2b7c6` |
| 2 | I metadati esistono ancora | **vera**, e nessuno li legge |
| 3 | Il sorgere e' calcolabile | **vera** |
| 4 | Manifest e Info.plist non dichiarano notifiche | **vera** |
| 5 | L'ora esatta su Android 14 e' ristretta | **vera, e vincolante** |

**1.** Riverificata su questo commit, non a memoria: nessun pacchetto di
notifiche in `pubspec.yaml`, nessuna chiamata che programmi o chieda permessi
(l'unica `requestPermission` in tutto `lib` e' quella di Geolocator), nessun
import che sappia di notifiche.

**2. I metadati ci sono e non li legge nessuno.** `DailyElement.pushByDefault`
esiste su tutti e cinque gli elementi ed e' letto **solo** da
`DailyElements.defaultPushElements`, che a sua volta **non e' chiamato da
nessuna parte in `lib`**: l'unico lettore e' `test/daily_elements_test.dart`.
`DailyElement.id` non ha nessun lettore in `lib`. `AppPermission.notifications`
compare solo nella dichiarazione dell'enum e nel suo testo. Erano tre pezzi di
un sistema mai costruito, che descrivevano se stessi.

**4. Cosa dichiarano davvero.** AndroidManifest: `ACCESS_COARSE_LOCATION`,
`ACCESS_FINE_LOCATION`, `RECORD_AUDIO`, `CAMERA`, piu' `uses-feature` camera non
obbligatoria. Info.plist: `NSLocationWhenInUseUsageDescription`,
`NSMicrophoneUsageDescription`, `NSCameraUsageDescription`,
`NSPhotoLibraryUsageDescription`. **Nessuna delle due parla di notifiche.**

## La premessa 5, che ha deciso il progetto

**E' cosi', ed e' peggio di come sembra.** Da Android 14
`SCHEDULE_EXACT_ALARM` non viene piu' concesso di default alle app che puntano
API 33 o superiore. L'alternativa `USE_EXACT_ALARM` viene concessa
all'installazione senza chiedere niente alla persona, ma **e' una permission
ristretta**: Google Play la ammette solo per app la cui funzione centrale e' la
sveglia o il calendario, e chi la dichiara senza rientrarci **non viene
pubblicato**. Non e' un avviso, e' un blocco alla pubblicazione.

Esoteric Circle non e' una sveglia e non e' un calendario.

**Quindi: finestra approssimata, e dichiarata.** Si usa
`AndroidScheduleMode.inexactAllowWhileIdle`, che il sistema consegna in una
finestra attorno all'ora chiesta e non richiede nessuna permission ristretta.
Il manifest dichiara **solo** `POST_NOTIFICATIONS`, e accanto c'e' scritto
perche' non dichiariamo le altre due. Una prova cade se qualcuno le aggiunge.

E la spiegazione che la persona legge dice, in chiaro, che l'orario e'
indicativo: **non promettiamo un minuto che non possiamo mantenere**.

Fonti: la pagina di Android Developers sul cambio di comportamento in Android
14, e la documentazione di `flutter_local_notifications` sulle modalita' di
consegna.

## Il pacchetto, e il peso misurato

**`flutter_local_notifications: ^22.2.0`**, piu' `timezone: ^0.11.1` che gli
serve per programmare a un istante con fuso.

**Perche' questo.** E' lo standard di fatto per le notifiche locali in Flutter,
espone la modalita' di consegna approssimata che ci serve, e **non tira dentro
nessun servizio remoto**: niente Firebase Messaging, niente token, niente rete.
Un avviso locale programmato dal dispositivo, che e' esattamente quel che serve
e niente di piu'.

**Il peso, misurato su disco e non stimato.** Sei pacchetti nuovi:

| Pacchetto | Sorgente scaricato |
|---|---|
| `flutter_local_notifications` 22.2.0 | 1937 KB |
| `flutter_local_notifications_linux` 8.0.1 | 173 KB |
| `flutter_local_notifications_platform_interface` 12.1.0 | 19 KB |
| `flutter_local_notifications_web` 1.0.0 | 56 KB |
| `flutter_local_notifications_windows` 3.1.1 | 156 KB |
| `timezone` 0.11.1 | 4167 KB |
| **totale** | **6510 KB** |

La parte che riguarda Android: `flutter_local_notifications/android` 269 KB e
`lib` 268 KB. Il resto sono le implementazioni desktop e web, che su mobile non
entrano.

**Il grosso e' il database dei fusi, e l'ho ridotto.** `timezone` pesa 4,1 MB
quasi tutti di dati. Importando `data/latest.dart` si porta dentro **1,1 MB** di
sorgente; importando `data/latest_10y.dart`, che copre dieci anni, se ne portano
**290 KB**. Per un avviso quotidiano dieci anni bastano, quindi si usa il
secondo, e accanto all'import c'e' scritto che cambiarlo costa ottocento KB.

**QUELLO CHE NON POSSO DIRTI, e non voglio spacciarlo per misurato.** Questi
sono i pesi dei sorgenti su disco, **non il delta dell'archivio**. Quanto cresca
davvero l'APK o l'AAB si sa solo costruendolo, e la build me l'hai vietata. Il
numero vero lo avrai al primo `flutter build`, e finche' non c'e' chiunque
citasse una cifra sull'archivio starebbe stimando.

## Cosa e' chiuso

**Una porta sola**, `lib/core/rituals/avvisi_del_rito.dart`: tutte le regole di
quando si avvisa e cosa si scrive. Il trasporto vero sta in
`lib/services/avvisi_locali.dart` ed e' l'unico file che conosce il plugin. Le
regole non lo conoscono, ed e' per questo che si possono provare senza toccare
la piattaforma.

- **Il permesso si chiede all'apertura del Rito dell'Alba**, dopo il primo
  fotogramma, non all'avvio dell'app. Si chiede **una volta sola**: chi ha detto
  no non deve ritrovarsi la domanda ogni mattina.
- **Chi dice no continua a usare tutto.** Una prova monta il rito con permesso
  concesso e con permesso rifiutato e pretende che gesto, respiro, parola, via
  col dito e fascia del risveglio siano identici.
- **L'avviso e' all'alba vera** quando la posizione lo consente, sull'ora media
  altrimenti, **e in quel caso non si dichiara nessuna ora**: la stessa regola
  gia' scritta per il testo della fascia. Nei casi polari si ripiega sull'ora
  media invece di tacere.
- **Se il rito di oggi e' gia' stato aperto, l'avviso di oggi non parte** e
  scivola a domani. "Aperto oggi" si legge da `RitualStreak.fattoOggi`, che
  legge la stessa chiave che il rito scrive: non c'e' un secondo posto che lo
  sappia.
- **Un id solo**, `1001`: riprogrammare sostituisce invece di affiancare. Una
  prova programma cinque volte e pretende un avviso solo.
- **Il testo non promette e non anticipa**: non nomina il Maestro di turno, non
  dice cosa contiene il dono, non promette esiti. Invita ad aprire.

## Le prove del rosso, viste cadere

Le tre che l'ordine chiedeva, piu' tredici di contorno. Le tre, mutate una per
una e viste rosse prima che verdi:

| Prova | Mutazione | Esito |
|---|---|---|
| Chi rifiuta vede il rito intero | tolto il controllo del permesso | **rossa** |
| L'avviso non parte se gia' aperto | forzato `giaFatto` a falso | **rossa** |
| Una porta sola programma avvisi | aggiunto `zonedSchedule` in `daily_rituals.dart` | **rossa** |

## Un difetto trovato per strada, che non ho corretto

`permissionCopy(AppPermission.notifications)` in
`lib/core/permissions/app_permission.dart` dice gia' oggi: *"Ti avvisiamo solo
per i momenti che contano: il tuo ritorno solare, una Luna piena, un transito
importante."* **Sono tre avvisi che non esistono e che nessuno manda.**

E' testo morto: nessuno chiede quel permesso in modo generico, quindi oggi non
lo legge nessuno. Ma il giorno in cui qualcuno colleghi le notifiche passando da
li', quella frase diventa una promessa falsa mostrata alla persona. **Non l'ho
cambiata**, perche' descrive una funzione piu' larga di quest'ordine e cambiarla
vorrebbe dire decidere cosa quella funzione sara'. Il Rito dell'Alba non la usa:
passa la sua spiegazione, che parla solo di cio' che esiste.

## Cosa NON e' il massimo

1. **Un avviso solo, e non riprogrammato di suo.** L'avviso del giorno dopo si
   programma quando l'app si apre. Chi non apre l'app per una settimana riceve
   il primo avviso e poi piu' niente, perche' non c'e' nessun risveglio in
   background che riprogrammi. Servirebbe una catena o un lavoro periodico, che
   e' un ordine suo.

2. **Su iOS `permessoConcesso` torna sempre falso.** Non esiste una lettura
   affidabile dello stato senza richiederlo, quindi finche' non si registra la
   risposta nel profilo, su iOS l'avviso si programma solo subito dopo che la
   persona ha accettato. Va chiuso registrando la scelta.

3. **La finestra e' quella del sistema e non la controlliamo.** Con la modalita'
   inesatta Android puo' consegnare con parecchi minuti di ritardo, di piu' se
   il telefono e' in risparmio energetico. Diciamo che e' indicativa, ma non
   sappiamo dire quanto larga.

4. **Nessuna impostazione per spegnerlo dentro l'app.** `AvvisiDelRito.spegni`
   esiste ma non e' collegata a nessun interruttore: chi cambia idea deve
   passare dalle impostazioni di sistema. Va messo in Account.

5. **Gli altri quattro riti non avvisano.** `pushByDefault` dice che anche
   Oracolo e Buonanotte dovrebbero, ma quest'ordine parlava solo dell'Alba, e
   quel metadato resta senza lettori.
