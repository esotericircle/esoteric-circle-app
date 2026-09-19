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
/// sostituisce scrive nel referto **su quale telefono** le ha prese. Finche'
/// quel flag e' falso, la guardia `le_soglie_della_scansione_sono_provvisorie`
/// resta ROSSA APPOSTA: e' la stessa famiglia della riga rossa che i manifesti
/// tengono accesa finche' una voce resta aperta, e non si tocca per far
/// passare una build.
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
