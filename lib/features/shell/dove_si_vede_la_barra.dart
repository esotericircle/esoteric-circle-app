/// DOVE SI VEDE LA BARRA DEL CERCHIO, dichiarato in un posto solo.
///
/// **Decisione di Mauro del 6 agosto 2026.** La barra e' UNA sola in tutta
/// l'app, ed e' quella storica del guscio. Si vede in cinque schermate e in
/// nessun'altra:
///
/// - la home, cioe' Il Cerchio;
/// - il Cosmic Passport;
/// - il dominio di ogni Maestro;
/// - la chat di ogni Maestro;
/// - il confronto fra i Maestri, cioe' il Consiglio.
///
/// **Tutto il resto non ce l'ha, e non e' un elenco da completare.** Le
/// esperienze immersive (stesa, riti, meditazione) e tutti e cinque i Doni del
/// giorno restano senza barra: chi e' dentro un gesto che dura non deve avere
/// una via d'uscita sempre a vista, e si esce col tasto indietro, che c'e'
/// sempre.
///
/// **La decisione non vive dentro le schermate.** Se ogni schermata decidesse
/// da se', la regola avrebbe tante porte quante sono le schermate, e una regola
/// messa in molte porte non e' una regola. Qui c'e' l'elenco, e sopra il
/// Navigator c'e' il solo punto che lo legge.
library;

/// Se su questa schermata la barra si vede.
enum PresenzaDellaBarra {
  /// La barra c'e': ritratta o in vista, a seconda di come si e' scorso.
  presente,

  /// La barra non c'e' affatto. Vale per tutto quel che non e' una delle
  /// cinque schermate dichiarate: immersive, Doni del giorno, soglie e ogni
  /// altra lettura.
  assente,
}

/// L'elenco, per nome di classe della schermata.
///
/// Il nome di classe e non il tipo, perche' la prova che lo sorveglia legge i
/// sorgenti: cosi' una schermata nuova fa cadere la prova finche' qualcuno non
/// dichiara cosa deve succedere, invece di ereditare un comportamento per caso.
const Map<String, PresenzaDellaBarra> presenzaPerSchermata = {
  // --- LE CINQUE CHE LA PORTANO ------------------------------------------
  'SantuarioScreen': PresenzaDellaBarra.presente,
  'CosmicPassport': PresenzaDellaBarra.presente,
  'DomainScreen': PresenzaDellaBarra.presente,
  'MaestroChatScreen': PresenzaDellaBarra.presente,
  // Il Consiglio: la classe si chiama ancora AskMaestriScreen,
  // dal nome che la funzione aveva prima.
  'AskMaestriScreen': PresenzaDellaBarra.presente,
  // I SENTIERI DEI SIGILLI, ordine O: si aprono dal Passaporto e sono un
  // luogo dove si guarda il proprio cammino, non uno da cui si naviga: la
  // barra non li accompagna, come per le altre scene d'arte.

  // --- I CINQUE DONI DEL GIORNO ------------------------------------------
  // Ognuno e' un appuntamento che si compie con un gesto: la barra li
  // interromperebbe proprio mentre il gesto e' in corso.
  'SentieroScreen': PresenzaDellaBarra.assente,
  'DawnRiteScreen': PresenzaDellaBarra.assente,
  'BreathDestinyScreen': PresenzaDellaBarra.assente,
  'DayOracleScreen': PresenzaDellaBarra.assente,
  'SunsetRuneScreen': PresenzaDellaBarra.assente,
  'DreamRiteScreen': PresenzaDellaBarra.assente,

  // --- LE IMMERSIVE ------------------------------------------------------
  'StesaTreCarteScreen': PresenzaDellaBarra.assente,
  'MeditationScreen': PresenzaDellaBarra.assente,
  'RuneDrawScreen': PresenzaDellaBarra.assente,
  'SigilloIntenzioneScreen': PresenzaDellaBarra.assente,

  // --- LE SOGLIE ---------------------------------------------------------
  'OnboardingScreen': PresenzaDellaBarra.assente,
  'MaestroRevealScreen': PresenzaDellaBarra.assente,
  'DatiDiNascitaScreen': PresenzaDellaBarra.assente,
  'ArtIntroScreen': PresenzaDellaBarra.assente,

  // --- LE ALTRE LETTURE --------------------------------------------------
  // Non sono immersive e non sono Doni, ma non sono nemmeno fra le cinque:
  // la regola e' chiusa, quindi qui la barra non c'e'.
  'MaestroScreen': PresenzaDellaBarra.assente,
  'OroscopoScreen': PresenzaDellaBarra.assente,
  'SkyOverviewScreen': PresenzaDellaBarra.assente,
  'AngelsScreen': PresenzaDellaBarra.assente,
  'SinastriaGalleryScreen': PresenzaDellaBarra.assente,
  'SinastriaVipScreen': PresenzaDellaBarra.assente,
  'GuideAnimalScreen': PresenzaDellaBarra.assente,
  'ResonanceScreen': PresenzaDellaBarra.assente,
  'CircleSealScreen': PresenzaDellaBarra.assente,
  'ArchetypeTestScreen': PresenzaDellaBarra.assente,
  'FaceConstellationScreen': PresenzaDellaBarra.assente,
  // Il Calendario degli Eventi si apre dal centro della barra sottile ed e'
  // una lettura, come il cielo di nascita: si esce col tasto indietro.
  'CalendarioDegliEventiScreen': PresenzaDellaBarra.assente,
  'AccountScreen': PresenzaDellaBarra.assente,
  'SettingsScreen': PresenzaDellaBarra.assente,
  'ProfileScreen': PresenzaDellaBarra.assente,
  'PricingScreen': PresenzaDellaBarra.assente,
};

/// **DOVE NON SI VEDE LA BARRA SOTTILE DELL'IDENTITA'. Ordine AP voce 07.**
///
/// Sono due barre diverse con due regole diverse, e per questo l'elenco e'
/// un secondo: la barra STORICA del guscio si vede in cinque schermate e in
/// nessun'altra, mentre la barra SOTTILE si vede quasi ovunque e sparisce
/// solo nel rito d'ingresso. Ma la domanda che si fanno e' la stessa, "dove
/// si vede questa barra", quindi la casa e' una: prima le soglie della barra
/// sottile vivevano dentro `barra_dell_identita.dart` e nessuno che
/// guardasse qui poteva saperlo.
///
/// **La decisione di Mauro del 18 agosto**: la barra sottile non compare
/// durante l'onboarding e compare dalla home in poi. Chi attraversa il
/// Risveglio non ha ancora ne' volto ne' saldo ne' cammino, e una barra
/// dell'identita' sopra il rito d'ingresso e' una promessa vuota.
const Set<String> soglieSenzaBarraSottile = {
  'OnboardingScreen',
  // **IL RISVEGLIO, che mancava e si vedeva.** E' una rotta a se', spinta
  // con `pushReplacement` da `onboarding_screen.dart`, e porta dentro la
  // carta natale, la custodia del cielo e il Sigillo: da li' in poi la barra
  // compariva addosso al rito, misurato con la premessa P8.
  'RisveglioJourney',
  'MaestroRevealScreen',
  'ArtIntroScreen',
};

/// Vero se su questa schermata si vede la barra SOTTILE dell'identita'.
bool barraSottileSiVede(String? nomeSchermata) =>
    !soglieSenzaBarraSottile.contains(nomeSchermata);

/// Vero se su questa schermata la barra si vede.
bool barraSiVede(String? nomeSchermata) =>
    presenzaPerSchermata[nomeSchermata] == PresenzaDellaBarra.presente;
