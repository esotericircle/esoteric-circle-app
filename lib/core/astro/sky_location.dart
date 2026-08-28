import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Un luogo sulla Terra, ridotto a cio' che serve per orientare il cielo:
/// latitudine e longitudine. Nessun indirizzo, nessun nome, solo le coordinate
/// che restano sul dispositivo.
class SkyPlace {
  const SkyPlace({
    required this.latitude,
    required this.longitude,
    this.citta,
  });

  final double latitude;
  final double longitude;

  /// IL NOME DELLA CITTA', quando il sistema sa dirlo. Ordine 2168, voce 4.
  ///
  /// **Nullo e' un valore pieno, non una mancanza da riempire.** Mauro ha
  /// deciso il ripiego: se il nome non arriva, il nome SPARISCE e restano le
  /// sole coordinate, senza nessun testo al posto suo. Un "luogo
  /// sconosciuto" scritto sotto il cielo sarebbe rumore che occupa la riga
  /// di una cosa vera.
  final String? citta;

  SkyPlace conCitta(String? nome) =>
      SkyPlace(latitude: latitude, longitude: longitude, citta: nome);
}

/// Da dove vengono le coordinate con cui il cielo e' stato calcolato.
///
/// Si dichiara a schermo: un cielo che non dice da dove e' guardato non si puo'
/// verificare, e chi lo guarda non sa se sta vedendo il proprio cielo o quello
/// del luogo dove e' nato.
enum OrigineCoordinate {
  /// Dal GPS del telefono.
  dispositivo('posizione del dispositivo'),

  /// Dal luogo di nascita registrato nel profilo.
  nascita('luogo di nascita'),

  /// Nessuna: non si calcola, e lo si dice.
  nessuna('nessun luogo disponibile');

  const OrigineCoordinate(this.etichetta);

  /// Come si scrive a schermo.
  final String etichetta;
}

/// Perche' la posizione non c'e'.
///
/// Prima esisteva solo null: negato, servizio spento e sensore assente erano
/// la stessa cosa, quindi la schermata non poteva ne' spiegare ne' offrire la
/// via d'uscita giusta. Chi negava e chi aveva il GPS spento vedevano lo
/// stesso messaggio, che per uno dei due era sbagliato.
enum EsitoPosizione {
  /// Permesso concesso e coordinate ottenute.
  concessa,

  /// La persona ha detto di no QUESTA VOLTA: il dialogo di sistema puo'
  /// ancora ricomparire, quindi il pulsante puo' chiedere di nuovo.
  negata,

  /// La persona ha detto di no PER SEMPRE: il dialogo di sistema non
  /// comparira' mai piu', quindi ripetere la richiesta e' una bugia. L'unica
  /// via vera sono le impostazioni del sistema, e la schermata deve portarci.
  ///
  /// Ordine 2161, voce 10: prima questo esito veniva APPIATTITO su [negata],
  /// cioe' un'informazione che esisteva veniva buttata a monte, la stessa
  /// forma di difetto della regola messa in una porta sola.
  negataPerSempre,

  /// Il permesso c'e' o si potrebbe chiedere, ma la posizione del telefono e'
  /// spenta di sistema: si rimanda alle impostazioni del dispositivo, non a
  /// quelle dell'app.
  servizioSpento,

  /// Nessun sensore, piattaforma senza posizione, errore.
  nonDisponibile,
}

/// Cosa e' successo quando si e' chiesta la posizione.
class RispostaPosizione {
  const RispostaPosizione(this.esito, [this.luogo, this.motivo]);

  final EsitoPosizione esito;
  final SkyPlace? luogo;

  /// **COSA E' SUCCESSO DAVVERO, quando non e' successo niente.**
  ///
  /// Segnalazione del fondatore dal suo iPhone 13: tocca "Orienta il cielo",
  /// il dialogo di sistema NON compare, e nella pagina dell'app dentro
  /// Impostazioni la riga Posizione non esiste. Su iOS quella riga nasce solo
  /// quando l'app ha chiesto davvero al sistema: se non c'e', la richiesta non
  /// e' mai partita. Il perche' lo sa solo il telefono, e fino a ieri l'app lo
  /// buttava via in un `catch` muto, che e' esattamente la cosa che questo
  /// progetto vieta.
  ///
  /// Qui ci finisce il testo dell'errore, e la schermata lo mostra: la
  /// prossima volta che succede si legge invece di indovinare.
  final String? motivo;

  bool get concessa => esito == EsitoPosizione.concessa && luogo != null;
}

/// Sorgente della posizione dell'utente, dietro un'astrazione: il cielo non
/// sa se dietro c'e' il GPS, un valore finto nei test o nulla. Cosi' la veduta
/// resta testabile e il ripiego elegante e' sempre a portata.
abstract class SkyLocation {
  const SkyLocation();

  /// Se ha senso proporre l'orientamento sul luogo reale. Quando e' falso il
  /// cielo parte dalla veduta attuale, senza chiedere nulla.
  bool get available;

  /// Chiede il permesso e restituisce il luogo, oppure null se il permesso
  /// manca, il sensore non c'e' o qualcosa va storto. Non lancia mai.
  ///
  /// ATTENZIONE: puo' aprire il dialogo di sistema. Va chiamata SOLO da un gesto
  /// esplicito dell'utente, mai da un initState: nessuna schermata deve provocare
  /// una richiesta di permesso come effetto collaterale della propria apertura.
  Future<SkyPlace?> resolve();

  /// Come [resolve], ma dice anche PERCHE' e' andata come e' andata.
  ///
  /// Ha un corpo di ripiego apposta: le sorgenti finte dei test conoscono solo
  /// resolve, e obbligarle tutte a riscrivere anche questo non proverebbe
  /// niente di piu'. Chi vuole distinguere gli esiti la riscrive.
  Future<RispostaPosizione> chiedi() async {
    final luogo = await resolve();
    return luogo != null
        ? RispostaPosizione(EsitoPosizione.concessa, luogo)
        : const RispostaPosizione(EsitoPosizione.negata);
  }

  /// Il luogo solo se il permesso e' GIA' concesso, altrimenti null. Non chiede
  /// mai nulla e non apre alcun dialogo: e' la via che possono usare le viste
  /// che si aprono da sole, come la striscia dei Doni del Santuario.
  Future<SkyPlace?> resolveSeConcesso();

  /// Apre le impostazioni dell'app nel sistema: e' l'unica via vera quando
  /// il permesso e' stato negato per sempre. Nel ripiego non fa nulla e dice
  /// falso, cosi' le prove possono osservare la chiamata.
  Future<bool> apriImpostazioni() async => false;

  /// IL NOME DELLA CITTA' per delle coordinate, quando il sistema sa dirlo.
  ///
  /// Ordine 2168, voce 4. **Passa dai servizi del sistema operativo, quindi
  /// dalla rete**, ed e' l'unico punto dell'app che lo fa per la posizione:
  /// sta qui, dietro l'astrazione, cosi' le prove e le anteprime non
  /// chiamano mai niente e la promessa fatta alla persona resta misurabile
  /// in un posto solo.
  ///
  /// Nullo quando il nome non arriva: chi lo riceve fa sparire il nome e
  /// lascia le coordinate, senza scrivere niente al posto suo.
  Future<String?> nomeDelLuogo(double latitudine, double longitudine) async =>
      null;
}

/// Ripiego: nessuna posizione, nessuna richiesta. E' il default, cosi' i test
/// e le anteprime headless non vedono mai il pre-avviso.
class DisabledSkyLocation extends SkyLocation {
  const DisabledSkyLocation();

  @override
  bool get available => false;

  @override
  Future<SkyPlace?> resolve() async => null;

  @override
  Future<RispostaPosizione> chiedi() async =>
      const RispostaPosizione(EsitoPosizione.nonDisponibile);

  @override
  Future<SkyPlace?> resolveSeConcesso() async => null;
}

/// La sorgente reale, su `geolocator`. Ogni fallimento (servizio spento,
/// permesso negato, sensore assente, eccezione di piattaforma) diventa un null:
/// il cielo ripiega senza mai bloccarsi.
class GeolocatorSkyLocation extends SkyLocation {
  const GeolocatorSkyLocation();

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async => (await chiedi()).luogo;

  @override
  Future<RispostaPosizione> chiedi() async {
    try {
      // Il permesso si chiede PRIMA di guardare se il servizio e' acceso.
      // Prima era l'opposto, e col GPS spento si usciva subito: al tocco su
      // "attiva la posizione" non compariva nessuna richiesta di sistema e
      // sembrava che il pulsante non facesse niente.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      // I DUE NO RESTANO DISTINTI FINO A SCHERMO: negato una volta puo'
      // richiedere, negato per sempre porta alle impostazioni. Appiattirli
      // era il difetto della voce 10 del 2161.
      if (permission == LocationPermission.deniedForever) {
        return const RispostaPosizione(EsitoPosizione.negataPerSempre);
      }
      if (permission == LocationPermission.denied) {
        // **PRIMA DI DIRE "hai detto di no", SI GUARDA SE POTEVA DIRE SI'.**
        // Col servizio di sistema spento iOS non mostra nessun dialogo e
        // l'API risponde negato lo stesso: dire alla persona che ha rifiutato
        // sarebbe falso, e mandarla nei permessi dell'app la porterebbe in una
        // pagina dove la riga Posizione non esiste nemmeno. La via giusta e'
        // l'interruttore della Localizzazione, che sta nelle impostazioni del
        // SISTEMA.
        if (!await Geolocator.isLocationServiceEnabled()) {
          return const RispostaPosizione(EsitoPosizione.servizioSpento);
        }
        return const RispostaPosizione(EsitoPosizione.negata);
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const RispostaPosizione(EsitoPosizione.servizioSpento);
      }
      final pos = await Geolocator.getCurrentPosition();
      return RispostaPosizione(
        EsitoPosizione.concessa,
        SkyPlace(latitude: pos.latitude, longitude: pos.longitude),
      );
    } catch (errore) {
      // **NESSUN CATCH MUTO, e qui costava caro.** Se il canale del plugin non
      // risponde, o il sistema solleva, l'app tornava "non disponibile" senza
      // dire altro: a schermo diventava "resto sul cielo della tua nascita", e
      // nessuno poteva sapere che il dialogo di sistema non era mai partito.
      // Adesso il motivo viaggia fino alla schermata.
      debugPrint('SkyLocation.chiedi: la posizione non risponde ($errore)');
      return RispostaPosizione(
          EsitoPosizione.nonDisponibile, null, errore.toString());
    }
  }

  @override
  Future<bool> apriImpostazioni() => Geolocator.openAppSettings();

  @override
  Future<String?> nomeDelLuogo(double latitudine, double longitudine) async {
    try {
      final luoghi = await placemarkFromCoordinates(latitudine, longitudine);
      if (luoghi.isEmpty) return null;
      final p = luoghi.first;
      // La citta' prima di tutto; se il servizio non la sa, la localita' o
      // la zona amministrativa. Se non sa niente di leggibile, NULLO: il
      // nome sparisce e restano le coordinate, che sono vere comunque.
      for (final candidato in [p.locality, p.subAdministrativeArea,
        p.administrativeArea]) {
        if (candidato != null && candidato.trim().isNotEmpty) {
          return candidato.trim();
        }
      }
      return null;
    } catch (errore) {
      // NON E' UN GUASTO DA MOSTRARE: senza rete, senza servizio o con una
      // piattaforma che non lo espone, il nome semplicemente non c'e'. Il
      // cielo si calcola lo stesso dalle coordinate, che sono gia' in mano.
      return null;
    }
  }

  @override
  Future<SkyPlace?> resolveSeConcesso() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      // Si guarda soltanto: nessuna requestPermission, quindi nessun dialogo.
      final permission = await Geolocator.checkPermission();
      final concesso = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!concesso) return null;
      final pos = await Geolocator.getCurrentPosition();
      return SkyPlace(latitude: pos.latitude, longitude: pos.longitude);
    } catch (_) {
      return null;
    }
  }
}
