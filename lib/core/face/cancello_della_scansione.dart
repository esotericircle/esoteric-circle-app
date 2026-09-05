import 'face_classifier.dart';

/// **IL CANCELLO DELLA SCANSIONE: senza volto non c'e' responso.**
/// Ordine CR voce 01, 6 settembre 2026.
///
/// **Parole del fondatore**: *"ho provato a fare una foto a un muro e cmq la
/// funzionalita' mi ha dato un responso come se avessi fotografato un viso"*.
///
/// **IL DIFETTO CHE QUESTA PORTA CHIUDE, con la sua riga.** Nella schermata
/// della Costellazione il momento dello scatto cominciava cosi':
///
///     final contorni = _contorniVivi ?? FaceSilhouette.contorni();
///
/// `_contorniVivi` resta nullo finche' il rilevatore non trova un volto.
/// Davanti a un muro non lo trova mai, e quel `??` metteva al suo posto la
/// **sagoma neutra disegnata a mano**, nata per il ripiego tattile e per le
/// anteprime: proporzioni scelte da una persona, non misurate su nessuno. Da
/// li' in poi la lettura proseguiva identica a quella di un volto vero.
///
/// **Il ripiego tattile non era il difetto.** Esiste per progetto ed e' giusto
/// che ci sia: chi non ha fotocamera sceglie i propri tratti a mano e riceve
/// comunque la sua lettura. Il difetto e' che quel ripiego **si attivava da
/// solo al posto di una scansione fallita, facendola sembrare riuscita**.
///
/// **PERCHE' UNA PORTA E NON UN `if` DENTRO LA SCHERMATA.** Un `if` dentro un
/// widget si prova solo montando una fotocamera, che in prova non esiste: la
/// regola resterebbe scritta e mai misurata. Qui la decisione e' una funzione
/// pura, e una funzione pura si interroga.
class CancelloDellaScansione {
  const CancelloDellaScansione._();

  /// Giudica una scansione: o c'e' un volto rilevato, o non si passa.
  ///
  /// [contorniVivi] e' cio' che il rilevatore ha restituito, e **solo quello**:
  /// nessun valore di riserva entra da questa porta. Nullo vuol dire che
  /// nessun volto e' stato trovato, e allora non nasce nessuna lettura.
  static EsitoScansione giudica({required FaceContours? contorniVivi}) {
    if (contorniVivi == null) {
      return const NessunVolto(
        // La ragione si dice, e si dice a chi legge: chi resta senza responso
        // deve sapere cosa non ha funzionato, o crede che l'app sia rotta.
        // **E non si dice "errore"**: la scansione non e' fallita per un
        // guasto, semplicemente davanti alla fotocamera non c'era un volto.
        'Non ho trovato un volto da leggere. Inquadra il viso, con luce '
        'sufficiente, e riprova.',
      );
    }
    return VoltoTrovato(contorniVivi);
  }
}

/// L'esito di una scansione: due casi, e nessun terzo caso silenzioso.
sealed class EsitoScansione {
  const EsitoScansione();
}

/// Un volto c'e', e questi sono i suoi contorni MISURATI.
class VoltoTrovato extends EsitoScansione {
  const VoltoTrovato(this.contorni);

  /// I contorni che il rilevatore ha restituito. Non ne esiste una versione
  /// di riserva: se fosse possibile costruirli senza un volto, questa classe
  /// mentirebbe sul proprio nome.
  final FaceContours contorni;
}

/// Nessun volto: la funzione lo dice e si ferma.
class NessunVolto extends EsitoScansione {
  const NessunVolto(this.perche);

  /// Cosa e' successo, in una riga che si mostra a chi legge.
  final String perche;
}
