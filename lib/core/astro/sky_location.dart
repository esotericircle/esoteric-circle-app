import 'package:geolocator/geolocator.dart';

/// Un luogo sulla Terra, ridotto a cio' che serve per orientare il cielo:
/// latitudine e longitudine. Nessun indirizzo, nessun nome, solo le coordinate
/// che restano sul dispositivo.
class SkyPlace {
  const SkyPlace({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
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
  Future<SkyPlace?> resolve();
}

/// Ripiego: nessuna posizione, nessuna richiesta. E' il default, cosi' i test
/// e le anteprime headless non vedono mai il pre-avviso.
class DisabledSkyLocation extends SkyLocation {
  const DisabledSkyLocation();

  @override
  bool get available => false;

  @override
  Future<SkyPlace?> resolve() async => null;
}

/// La sorgente reale, su `geolocator`. Ogni fallimento (servizio spento,
/// permesso negato, sensore assente, eccezione di piattaforma) diventa un null:
/// il cielo ripiega senza mai bloccarsi.
class GeolocatorSkyLocation extends SkyLocation {
  const GeolocatorSkyLocation();

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition();
      return SkyPlace(latitude: pos.latitude, longitude: pos.longitude);
    } catch (_) {
      // Nessun sensore, piattaforma senza posizione, timeout: ripiego pulito.
      return null;
    }
  }
}
