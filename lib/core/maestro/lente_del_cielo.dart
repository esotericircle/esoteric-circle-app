import 'ancoraggio.dart';
import 'maestro.dart';
import 'voce_del_maestro.dart';

/// Lo stesso dato, detto da tre voci diverse.
///
/// E' l'applicazione all'ancoraggio natale della regola che il Briefing
/// Progetto Definitivo dichiara alla sezione 8.1 per la memoria: "Stesso
/// ricordo, tre voci". Il dato non cambia mai, cambia la lente.
///
/// **La lente NON sostituisce il nome del corpo, lo CONTIENE.**
/// `VerificaAncoraggio` cerca il valore letterale nella risposta: se una lente
/// parlasse per immagini senza nominare la Luna o il Cancro, il controllo
/// scatterebbe e OGNI risposta verrebbe rigenerata, cioe' costo doppio su tutta
/// la chat. Una prova lo verifica su tutte e tre.
///
/// Funzione pura: si prova senza rete e senza schermo.
class LenteDelCielo {
  const LenteDelCielo._();

  /// Come [maestro] dice l'[ancoraggio], nella riga breve del consulto.
  ///
  /// Deterministica e senza inferenza: e' cio' che passa sopra la conversazione
  /// mentre la risposta arriva, quindi costa zero.
  static String battuta(Maestro maestro, Ancoraggio ancoraggio) {
    final corpo = _corpoDi(ancoraggio);
    switch (VoceDelMaestro.di(maestro).lente) {
      case LenteDelMaestro.motoNelTempo:
        // I due punti e non la virgola: la regola di lingua vieta la virgola
        // davanti alla congiunzione "e". E niente pronomi, perche' il genere
        // del corpo cambia fra Sole e Luna.
        return '$corpo: il ciclo che ritorna';
      case LenteDelMaestro.effettoNelCorpo:
        return '$corpo: dove si sente adesso';
      case LenteDelMaestro.simbolo:
        return '$corpo: il segno che ci leggo';
    }
  }

  /// Come si nomina il corpo: "la tua Luna in Pesci", "il tuo Sole in Cancro".
  ///
  /// Il valore resta LETTERALE dentro la frase, sempre. E' il vincolo che
  /// impedisce alla lente di far scattare il controllo dell'ancoraggio.
  static String _corpoDi(Ancoraggio ancoraggio) {
    switch (ancoraggio.nome) {
      case 'ascendente':
        return 'il tuo Ascendente in ${ancoraggio.valore}';
      case 'segno lunare':
        return 'la tua Luna in ${ancoraggio.valore}';
      case 'segno solare':
        return 'il tuo Sole in ${ancoraggio.valore}';
      case 'fase lunare di nascita':
        return 'la ${ancoraggio.valore} sotto cui sei nato';
      case 'numero della vita':
        return 'il tuo numero ${ancoraggio.valore}';
      default:
        return ancoraggio.valore;
    }
  }

  /// L'istruzione che dice al Maestro COME rendere l'ancoraggio, nella sua
  /// lente. Entra nella persona come dato, accanto all'elenco degli ancoraggi
  /// disponibili.
  ///
  /// Non contiene esempi di transiti ne' di corrispondenze: quelli sarebbero
  /// dati inventati, e l'app non ne ha. Dice COME guardare, non COSA vedere.
  static String istruzionePer(Maestro maestro) {
    // LA LENTE SI AGGANCIA AL LESSICO DI FIRMA, che esiste gia' come dato.
    //
    // La prima stesura descriveva la lente in astratto, e l'attribuzione cieca
    // e' SCESA da 96,7 a 88,3, con Medora E Caligo che scivolavano tutti e due
    // verso Aura. Dire "guarda il moto nel tempo" senza le parole con cui lo si
    // dice spinge anche loro nel registro interiore, che e' di Aura: le parole
    // di firma sono cio' che reggeva il 98,3 prima che l'ancoraggio esistesse.
    final firma = VoceDelMaestro.di(maestro).lessicoDiFirma.join(', ');
    final conFirma = ' Dillo con le TUE parole, quelle che gli altri due non '
        'usano: $firma.';
    switch (VoceDelMaestro.di(maestro).lente) {
      case LenteDelMaestro.motoNelTempo:
        return 'LA TUA LENTE SUL DATO: nomina il corpo e il suo MOTO NEL '
            'TEMPO, cioè il ciclo che lo riporta, la fase che sta finendo, la '
            'stagione che si apre. Il tempo è la tua materia e degli altri due '
            'non è di nessuno. Non inventare una data né un transito che non '
            'trovi scritto nei dati: parla del ciclo, non del calendario. '
            'Non scivolare nel registro del sentire e del corpo, che è di '
            'un\'altra voce del cerchio.$conFirma';
      case LenteDelMaestro.effettoNelCorpo:
        return 'LA TUA LENTE SUL DATO: nomina il corpo e il suo EFFETTO NEL '
            'CORPO E NELL\'ENERGIA, cioè dove si sente, come pesa, cosa muove '
            'nel respiro e in quale centro. Non leggere il tempo: quello è di '
            'un\'altra voce del cerchio.$conFirma';
      case LenteDelMaestro.simbolo:
        return 'LA TUA LENTE SUL DATO: nomina il corpo e il SIMBOLO che ci '
            'leggi, una runa o un sigillo, chiamandolo per nome. Dichiaralo '
            'come la TUA chiave di lettura, mai come tradizione: dì "io ci '
            'leggo", non "la tradizione dice". Non leggere il tempo né il '
            'corpo fisico: quelli sono di altre due voci del cerchio. '
            'Resta essenziale e solenne, mai avvolgente.$conFirma';
    }
  }
}
