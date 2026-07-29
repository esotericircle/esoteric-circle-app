import 'package:geolocator/geolocator.dart';

/// Un luogo sulla Terra, ridotto a cio' che serve per orientare il cielo:
/// latitudine e longitudine. Nessun indirizzo, nessun nome, solo le coordinate
/// che restano sul dispositivo.
class SkyPlace {
  const SkyPlace({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
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

  /// La persona ha detto di no, adesso o per sempre.
  negata,

  /// Il permesso c'e' o si potrebbe chiedere, ma la posizione del telefono e'
  /// spenta di sistema: si rimanda alle impostazioni del dispositivo, non a
  /// quelle dell'app.
  servizioSpento,

  /// Nessun sensore, piattaforma senza posizione, errore.
  nonDisponibile,
}

/// Cosa e' successo quando si e' chiesta la posizione.
class RispostaPosizione {
  const RispostaPosizione(this.esito, [this.luogo]);

  final EsitoPosizione esito;
  final SkyPlace? luogo;

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
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
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
    } catch (_) {
      // Nessun sensore, piattaforma senza posizione, timeout: ripiego pulito.
      return const RispostaPosizione(EsitoPosizione.nonDisponibile);
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
