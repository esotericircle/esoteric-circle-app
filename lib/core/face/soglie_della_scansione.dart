/// **LE SOGLIE DELLA SCANSIONE A QUATTRO POSE.**
/// Ordine CR voci 03 e 13, 6 settembre 2026.
///
/// **QUESTI NUMERI NON SONO STATI MISURATI SU NESSUN TELEFONO.**
///
/// E' una decisione del fondatore, scritta nella voce CR.13: *"le soglie degli
/// angoli e i tempi di tenuta delle quattro pose non si possono misurare oggi:
/// il fondatore non ha un telefono collegato"*. Si parte da valori ragionati,
/// li si dichiara provvisori, e la taratura vera arriva dopo.
///
/// **DA DOVE VENGONO, VISTO CHE NON VENGONO DA UNA MISURA.**
/// - **Venti gradi** per il giro a destra e a sinistra: e' l'angolo a cui una
///   persona ha girato la testa in modo riconoscibile, ma non tanto da perdere
///   di vista un occhio. Sopra i trenta gradi il profilo comincia a nascondere
///   i landmark del lato lontano, e la mesh si degrada proprio mentre serve.
/// - **Quindici gradi** per l'alto e il basso: il collo si inclina meno di
///   quanto ruoti, e chiedere venti in verticale vuol dire chiedere una
///   smorfia invece di un movimento.
/// - **Cinque gradi** di tolleranza sul fronte: una testa perfettamente dritta
///   non esiste, e pretenderla bloccherebbe la scansione al primo passo.
/// - **Ottocento millisecondi** di tenuta: sotto il mezzo secondo un
///   attraversamento involontario conterebbe come posa, sopra il secondo e
///   mezzo la scansione diventa faticosa. Otto decimi e' il compromesso che
///   lascia il tempo a due o tre fotogrammi buoni di seguito.
///
/// **COME SMETTONO DI ESSERE PROVVISORIE.** Si sostituiscono con misure prese
/// su un telefono vero, si porta [tarateSuUnDispositivo] a vero, e chi le
/// sostituisce scrive nel referto **su quale telefono** le ha prese.
///
/// **LA GUARDIA, DALL'ORDINE FC VOCE 11.** Fino al 5 ottobre 2026 la guardia
/// `le_soglie_della_scansione_sono_provvisorie` restava ROSSA APPOSTA finche'
/// questo flag era falso. La misura aspetta una persona davanti al telefono
/// che gira la testa nelle quattro pose: un gesto che sul ramo non esiste e
/// che il codice non puo' fare (una fotocamera senza un volto non da' nessun
/// angolo, e un volto stampato misurerebbe il riconoscitore, non il collo).
/// Il fondatore ha scelto la cura (3) dell'ordine FC voce 11: la prova gira
/// sul ramo e pretende che il flag e questa riga dicano la stessa cosa.
///
/// ASPETTA: una persona davanti al Realme che gira la testa nelle quattro pose, con gli angoli scritti nel registro, e il referto col nome del telefono in docs/collaudo/CR/taratura_delle_soglie.txt.
class SoglieDellaScansione {
  const SoglieDellaScansione._();

  /// **L'INTERRUTTORE DELLA VERITA'.** Falso vuol dire che i numeri qui sotto
  /// non li ha misurati nessuno su un dispositivo. Si porta a vero SOLO
  /// insieme a numeri presi da una misura, mai da solo.
  static const bool tarateSuUnDispositivo = false;

  /// Quanto deve girare la testa, in gradi, perche' il profilo sia compiuto.
  static const double gradiDiProfilo = 20;

  /// Quanto deve inclinarsi la testa, in gradi, in alto e in basso.
  static const double gradiDiInclinazione = 15;

  /// Quanto puo' scostarsi una testa "dritta" prima di non esserlo piu'.
  static const double tolleranzaDelFronte = 5;

  /// Per quanto tempo l'angolo deve restare dentro la soglia.
  static const Duration tenuta = Duration(milliseconds: 800);
}
