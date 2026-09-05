library;

import 'package:flutter/widgets.dart';

import 'maestro.dart';

/// I VIDEO DI RIVELAZIONE DEI TRE MAESTRI. Ordine BQ.
///
/// **Decisione del fondatore, parole sue:** "facciamo un test: sostituisci i
/// video animati di rivelazione di Medora, Caligo e Aura al posto delle
/// immagini".
///
/// **LO STATO E' PROVVISORIO, e sta scritto qui accanto ai percorsi perche' chi
/// li trovera' fra un mese non leggera' l'ordine.** Sempre parole sue: "il video
/// Aura va bene, e' gia' 1080x1920 ma gli altri sono da ingrandire e hanno anche
/// il watermark, ma non importa per ora. tutto i video sono da ottimizzare".
/// Quindi: sono un test, due su tre portano un watermark e vanno ingranditi, e
/// tutti e tre vanno ottimizzati.
///
/// **Il percorso si COMPONE dall'identificativo del Maestro e non si scrive a
/// mano**: un elenco di tre stringhe sarebbe la solita seconda porta, e un
/// quarto Maestro avrebbe il suo video il giorno che nasce.
class RivelazioneInVideo {
  const RivelazioneInVideo._();

  /// La cartella, dichiarata nel `pubspec.yaml` anche da vuota, come
  /// `assets/audio/`: cosi' i file si vedono appena arrivano.
  static const String cartella = 'brand_assets/maestri/';

  /// Il video di [maestro]. Niente spazi e niente maiuscole: l'originale si
  /// chiamava "Medora Sorceress Video.mp4" e uno spazio dentro il nome di un
  /// asset e' una trappola che si paga molto piu' tardi.
  static String assetDi(Maestro maestro) =>
      '$cartella${maestro.id}_rivelazione.mp4';

  /// La nota sullo stato, in una riga sola, per chi legge il codice.
  static const String stato =
      'Provvisori: sono un test, due su tre portano un watermark e vanno '
      'ingranditi, tutti e tre vanno ottimizzati.';
}

/// IL LETTORE DELLA RIVELAZIONE, dietro una porta sola.
///
/// **Perche' esiste invece di usare `VideoPlayerController` diretto.** In una
/// prova headless non c'e' nessuna piattaforma che decodifichi un filmato,
/// quindi con il lettore vero ogni misura di questa voce sarebbe stata "il
/// video non parte": la misura del ritardo di avvio, quella del passaggio
/// all'immagine e quella dei lettori liberati non si sarebbero potute prendere
/// affatto. E' la stessa forma dello strato `AIProvider`: la cosa vera dietro
/// una porta, e una finta che si mette al suo posto per misurare.
///
/// Chi lo implementa promette una cosa sola: **non lancia mai**. Un file
/// mancante o un codec rifiutato si dichiarano con [pronto] falso, e la scena
/// resta quella che c'era.
abstract class LettoreDiRivelazione {
  /// Prepara il filmato e lo fa partire una volta sola, senza ciclo. Non lancia
  /// mai: se non ce la fa, [pronto] resta falso.
  Future<void> apri();

  /// Vero quando c'e' un fotogramma da mostrare.
  bool get pronto;

  /// Vero quando il filmato e' arrivato in fondo.
  bool get finito;

  /// Da chiamare a ogni cambio di stato del lettore.
  void ascolta(VoidCallback quandoCambia);

  /// Il fotogramma corrente. Si chiama solo quando [pronto] e' vero.
  Widget disegna();

  /// Libera tutto. Va chiamata sempre, anche se [apri] non ce l'ha fatta.
  void chiudi();
}

/// Chi costruisce un lettore per un asset. La finta delle prove si mette qui.
typedef FabbricaDiLettori = LettoreDiRivelazione Function(String asset);
