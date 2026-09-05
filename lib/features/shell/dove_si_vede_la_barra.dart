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

  // --- I RICORDI DEL CERCHIO, ordine CG voce 01 --------------------------
  //
  // **Non portano la barra**, e la ragione e' la stessa dei sentieri dei
  // Sigilli: sono un luogo dove si guarda il proprio cammino, non uno da cui
  // si naviga. Ci si arriva da tre porte e si torna indietro da dove si e'
  // entrati.
  'RicordiScreen': PresenzaDellaBarra.assente,
  'RicordoApertoScreen': PresenzaDellaBarra.assente,

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
  // ORDINE BO VOCE 13: la collezione delle coppie e' una schermata della
  // Sinastria, e sta dentro la sua rotta come le altre due: la barra non c'e'.
  'CollezioneScreen': PresenzaDellaBarra.assente,
  'GuideAnimalScreen': PresenzaDellaBarra.assente,
  'ResonanceScreen': PresenzaDellaBarra.assente,
  'CircleSealScreen': PresenzaDellaBarra.assente,
  'ArchetypeTestScreen': PresenzaDellaBarra.assente,
  'FaceConstellationScreen': PresenzaDellaBarra.assente,
  // Il Calendario degli Eventi si apre dal centro della barra sottile ed e'
  // una lettura, come il cielo di nascita: si esce col tasto indietro.
  'CalendarioDegliEventiScreen': PresenzaDellaBarra.assente,
  'AccountScreen': PresenzaDellaBarra.assente,
  // Il sottomenu Privacy e dati e la pagina della policy (ordine BH voci
  // 06 e 07): pagine di lettura e di gestione, la barra non c'entra.
  'PrivacyEDatiScreen': PresenzaDellaBarra.assente,
  'PrivacyPolicyScreen': PresenzaDellaBarra.assente,
  // **PRIVACY E PERMESSI**, ordine CE voce 03: il sotto menu' dove il
  // fondatore ha chiesto di raccogliere disclaimer, misura del ritorno, fonti
  // dei dati e permessi di sistema. E' una pagina di regolazione come le
  // Impostazioni da cui si apre, e la barra non c'entra.
  'PrivacyEPermessiScreen': PresenzaDellaBarra.assente,
  'SuonoScreen': PresenzaDellaBarra.assente,
  'SettingsScreen': PresenzaDellaBarra.assente,
  // Il menu' delle notifiche, ordine BC voce 05: si apre dall'account ed e'
  // una schermata di regolazione, come le Impostazioni.
  'NotificheScreen': PresenzaDellaBarra.assente,
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
/// **L'ELENCO E' PER ENUMERAZIONE DELLE SCENE DEL RITO. Ordine AQ voce 02
/// e voce 03.** Non si dichiara scena per scena dentro le schermate: si
/// nominano tutte qui, in un posto solo, e una scena nuova del rito che
/// nessuno nomini fa cadere la guardia invece di ereditare per caso il
/// comportamento sbagliato.
const Set<String> soglieSenzaBarraSottile = {
  'OnboardingScreen',
  // **IL RISVEGLIO, che mancava e si vedeva.** E' una rotta a se', spinta
  // con `pushReplacement` da `onboarding_screen.dart`, e porta dentro la
  // carta natale, la custodia del cielo e il Sigillo: da li' in poi la barra
  // compariva addosso al rito, misurato con la premessa P8.
  'RisveglioJourney',
  'MaestroRevealScreen',
  'ArtIntroScreen',
  // **LE SCENE CHE MAURO HA VISTO CON LA BARRA ADDOSSO, ordine AQ voce 03.**
  // Vivono dentro il Risveglio, che era gia' dichiarato, e non bastava: il
  // nome della rotta si cerca visitando l'albero costruito e fermandosi al
  // primo nome CONOSCIUTO, e nessuno di questi lo era. Il trionfo
  // dell'Animale Guida, quello degli Angeli, il cielo di nascita, la
  // risonanza, la custodia del cielo, il Sigillo e il Bentornato sono tutte
  // scene del rito.
  'TrionfoAnimale',
  'TrionfoAngeli',
  'NatalChartReveal',
  'SkyOverviewScreen',
  'ResonanceScreen',
  'CustodiaDelCieloStep',
  'SigilloStep',
  'ScenaDelRitrovamento',
};

/// **TUTTI I NOMI CHE IL GUSCIO SA RICONOSCERE.**
///
/// **La riga che rendeva vana ogni dichiarazione.** Chi guarda la pila delle
/// rotte visita l'albero della rotta in cima e si ferma al primo widget il cui
/// nome sia CONOSCIUTO; se non ne trova nessuno risponde nulla, e per il nulla
/// la barra sottile si vede. Finche' i nomi conosciuti erano solo quelli della
/// barra storica, ogni scena del rito rispondeva nulla, e la barra compariva
/// addosso al rito anche se il rito era dichiarato qui sopra. Adesso i nomi
/// sono l'unione dei due elenchi.
Set<String> get nomiDiSchermataConosciuti =>
    {...presenzaPerSchermata.keys, ...soglieSenzaBarraSottile};

/// Vero se su questa schermata si vede la barra SOTTILE dell'identita'.
bool barraSottileSiVede(String? nomeSchermata) =>
    !soglieSenzaBarraSottile.contains(nomeSchermata);

/// Vero se su questa schermata la barra si vede.
bool barraSiVede(String? nomeSchermata) =>
    presenzaPerSchermata[nomeSchermata] == PresenzaDellaBarra.presente;
