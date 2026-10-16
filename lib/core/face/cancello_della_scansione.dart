import 'face_classifier.dart';
import 'soglie_del_rilevamento.dart';

/// **IL CANCELLO DELLA SCANSIONE: senza volto non c'e' responso.**
/// Ordine CR voce 01, 6 settembre 2026. **Seconda stesura lo stesso giorno,
/// dopo che il fondatore ha fotografato un muro e ha ricevuto un responso
/// nonostante questo cancello fosse gia' in produzione.**
///
/// **Parole del fondatore, prima stesura**: *"ho provato a fare una foto a un
/// muro e cmq la funzionalita' mi ha dato un responso come se avessi
/// fotografato un viso"*.
///
/// **Parole del fondatore, dopo la prima cura**: *"dopodiche' ho fatto la foto
/// al muro e mi e' uscito ugualmente il responso con la foto del muro"*.
///
/// **IL DIFETTO CHE LA PRIMA STESURA AVEVA CHIUSO.** Nella schermata il
/// momento dello scatto cominciava cosi':
///
///     final contorni = _contorniVivi ?? FaceSilhouette.contorni();
///
/// e quel `??` metteva la sagoma disegnata a mano al posto di un volto che non
/// c'era. Quello era vero, ed e' stato chiuso.
///
/// **PERCHE' IL MURO PASSAVA LO STESSO, e sono due ragioni diverse dalla
/// prima.**
///
/// UNO, alla fonte: la catena di MediaPipe nasce con l'inseguimento acceso, e
/// dopo il primo aggancio **il rilevatore non gira piu'**. La mesh continuava a
/// posare punti dentro la regione dove il volto era stato, quindi davanti a una
/// parete arrivavano ancora punti. Curato nel motore, che adesso fa girare il
/// rilevatore su ogni fotogramma e pretende due punteggi di confidenza.
///
/// DUE, qui: **questo cancello guardava l'ultima lettura senza chiedersi di
/// quando fosse**. Fra l'ultimo fotogramma con un volto e il dito che tocca lo
/// scatto possono passare secondi, e in quei secondi la fotocamera puo' essere
/// finita su tutt'altro. Una lettura vecchia non e' una lettura, e' un ricordo.
///
/// **PERCHE' UNA PORTA E NON UN `if` DENTRO LA SCHERMATA.** Un `if` dentro un
/// widget si prova solo montando una fotocamera, che in prova non esiste: la
/// regola resterebbe scritta e mai misurata. Qui la decisione e' una funzione
/// pura, e una funzione pura si interroga.
class CancelloDellaScansione {
  const CancelloDellaScansione._();

  /// Giudica una scansione: o c'e' un volto rilevato ADESSO, o non si passa.
  ///
  /// [contorniVivi] e' cio' che il motore ha restituito, e **solo quello**:
  /// nessun valore di riserva entra da questa porta.
  ///
  /// [eta] e' quanto tempo e' passato da quando quella lettura e' stata fatta.
  /// Nulla vuol dire che nessuna lettura e' mai arrivata.
  static EsitoScansione giudica({
    required FaceContours? contorniVivi,
    required Duration? eta,
  }) {
    if (contorniVivi == null || eta == null) {
      return const NessunVolto(
        // La ragione si dice, e si dice a chi legge: chi resta senza responso
        // deve sapere cosa non ha funzionato, o crede che l'app sia rotta.
        // **E non si dice "errore"**: la scansione non e' fallita per un
        // guasto, semplicemente davanti alla fotocamera non c'era un volto.
        'Non ho trovato un volto da leggere. Inquadra il viso con luce '
        'sufficiente e riprova.',
      );
    }
    if (eta > SoglieDelRilevamento.letturaAncoraFresca) {
      return const NessunVolto(
        // **UNA RAGIONE DIVERSA MERITA PAROLE DIVERSE.** Qui un volto c'era,
        // e non c'e' piu': dire "non ho trovato un volto" manderebbe la
        // persona a cercare piu' luce quando il problema e' che ha spostato
        // il telefono.
        'Ti ho perso di vista. Rimetti il viso davanti alla fotocamera e '
        'riprova.',
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
