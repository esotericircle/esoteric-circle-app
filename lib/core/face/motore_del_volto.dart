import 'dart:typed_data';

import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import 'face_classifier.dart';

/// **LA PORTA UNICA VERSO IL MOTORE DEL VOLTO.** Ordine CR voce 02, 6
/// settembre 2026.
///
/// **PERCHE' ESISTE, ED E' LA RISPOSTA AL RISCHIO CHE L'ORDINE CHIEDE DI
/// DICHIARARE.** La voce CR.02 chiede: *"se scegli una dipendenza esterna,
/// dichiara nel referto cosa succede il giorno che smette di essere mantenuta e
/// quanto costa sostituirla"*.
///
/// `mediapipe_face_mesh` ha undici like e duemila download alla settimana: e'
/// giovane. Se domani sparisse, senza questa porta bisognerebbe cercare il suo
/// nome in ogni schermata che tocca il volto. Con questa porta si riscrive
/// **un file**, e la firma resta quella: entra un fotogramma, escono i contorni,
/// gli angoli della testa e i coefficienti dell'espressione.
///
/// **NIENTE DI CIO' CHE ENTRA QUI ESCE DAL DISPOSITIVO.** Ordine CR voce 11: i
/// fotogrammi arrivano dalla fotocamera, attraversano il motore in memoria e
/// non vengono ne' salvati ne' inviati. Questa classe non conosce la rete e non
/// conosce il disco: non ha un client HTTP, non apre file, non scrive
/// preferenze. E' una garanzia strutturale, non una promessa.
abstract class MotoreDelVolto {
  const MotoreDelVolto();

  /// Prepara il motore. Va chiamata una volta prima di [leggi].
  Future<void> avvia();

  /// Legge un fotogramma NV21 dalla fotocamera.
  ///
  /// Restituisce nulla quando **nessun volto e' presente**: e' il caso del
  /// muro, ed e' la ragione per cui questo metodo puo' restituire nulla invece
  /// di inventare un volto neutro. Chi lo chiama passa il risultato al
  /// `CancelloDellaScansione` e non aggira mai il nulla con un valore di
  /// riserva.
  Future<LetturaDelVolto?> leggi({
    required Uint8List byte,
    required int larghezza,
    required int altezza,
    required int rotazione,
    required bool specchiata,

    /// I byte di una riga del piano Y, come la fotocamera li dichiara.
    /// **Dedurli dalla larghezza sarebbe sbagliato**: molti telefoni
    /// allineano le righe a un multiplo, e la riga e' piu' lunga dei
    /// pixel che contiene. Un fotogramma letto con la lunghezza sbagliata
    /// diventa un'immagine storta, e il motore non ci trova nessun volto.
    required int byteDiRiga,
  });

  /// **GUARDA DENTRO LA FOTOGRAFIA, e non i contorni di un istante prima.**
  /// Ordine CX voci 02 e 04, 8 settembre 2026.
  ///
  /// **Il difetto che questo metodo esiste per chiudere.** Il cancello della
  /// scansione certifica i CONTORNI VIVI; la fotografia si scatta dopo, in un
  /// istante successivo, da una fotocamera che nel frattempo puo' guardare
  /// qualunque cosa. **Nessuno ha mai guardato dentro la fotografia.** Il
  /// fondatore ha ricevuto il proprio responso con la foto di un muro, e la
  /// cura dell'ordine CR non era stata aggirata: faceva il suo lavoro sul
  /// pezzo che le era stato dato da guardare, mentre il pezzo rotto era
  /// l'immagine.
  ///
  /// Restituisce vero solo se dentro quei pixel c'e' una faccia con la stessa
  /// confidenza che si pretende dal fotogramma vivo. **Un ripiego a vero
  /// riaprirebbe esattamente la porta che questo metodo chiude**, quindi
  /// l'implementazione che non sa rispondere risponde falso.
  Future<bool> laFotoHaUnVolto({
    required Uint8List rgba,
    required int larghezza,
    required int altezza,
  });

  /// Rilascia le risorse native. Senza questa, i contesti MediaPipe restano
  /// vivi oltre la schermata.
  Future<void> spegni();
}

/// Cio' che il motore restituisce per un fotogramma con un volto dentro.
class LetturaDelVolto {
  const LetturaDelVolto({
    required this.contorni,
    required this.yaw,
    required this.pitch,
    required this.roll,
    required this.espressione,
    required this.punti,
    required this.confidenzaDelRilevamento,
    required this.confidenzaDellaMesh,
    required this.proporzioneDelFotogramma,
  });

  /// I contorni nella forma che il classificatore dei tratti gia' conosce, cosi'
  /// la lettura di CR.05 continua a funzionare senza riscriverla.
  final FaceContours contorni;

  /// Testa girata: positivo verso destra di chi guarda lo schermo.
  final double yaw;

  /// Mento alzato: positivo verso l'alto.
  final double pitch;

  /// Testa inclinata di lato.
  final double roll;

  /// I 52 coefficienti dell'espressione, da zero a uno. E' cio' che il volto
  /// **sta facendo adesso**, e da qui nasce la lettura dell'istante di CR.07.
  final Map<FaceBlendshape, double> espressione;

  /// I 478 punti della mesh, in coordinate normalizzate. Servono al fascio di
  /// luce e alla maschera che segue il volto.
  final List<FaceMeshLandmark> punti;

  /// **QUANTO IL RILEVATORE E' SICURO CHE LI' CI SIA UNA FACCIA.**
  /// Da zero a uno. Esiste perche' una lista di punti non vuota non dice
  /// niente su cosa ci sia davanti all'obiettivo.
  final double confidenzaDelRilevamento;

  /// **QUANTO BENE I PUNTI SI SONO POSATI SU QUELLA FACCIA.** Da zero a
  /// uno. E' un giudizio diverso dal primo: si puo' essere sicuri che ci
  /// sia un volto e non riuscire a misurarlo.
  final double confidenzaDellaMesh;

  /// **LARGHEZZA DIVISO ALTEZZA DEL FOTOGRAMMA da cui vengono i punti.**
  ///
  /// I punti arrivano normalizzati da zero a uno sui due lati, e i due lati
  /// non sono lunghi uguale: senza questo numero, ogni rapporto fra una
  /// larghezza e un'altezza esce sbagliato di quanto il fotogramma e'
  /// schiacciato, e su un tre quarti sono trentatre' punti percentuali.
  final double proporzioneDelFotogramma;
}
