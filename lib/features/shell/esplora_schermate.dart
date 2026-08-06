/// DOVE SI VEDE ESPLORA, DICHIARATO IN UN POSTO SOLO.
///
/// **La decisione non vive dentro le schermate.** Se ogni schermata decidesse
/// da se' se mostrare la striscia, la regola avrebbe tante porte quante sono le
/// schermate, e sarebbe la ventunesima occorrenza della famiglia di difetti piu'
/// numerosa di questo progetto: una regola messa in una porta quando le porte
/// sono molte non e' una regola. Qui c'e' l'elenco, e attorno ad `AppShell` c'e'
/// il solo punto che lo legge.
///
/// **Questo elenco e' nuovo, e non si ricava da `ImmersiveTarget`.** In
/// `lib/core/chat/immersive_intents.dart` esiste gia' un enum che si chiama
/// immersivo, ma elenca un'altra cosa: dove la CHAT puo' instradare. Contiene
/// `oroscopoGiorno`, `cartaNatale` e `sinastriaVip`, che sono schermate di
/// lettura in cui Esplora ci deve stare. Riusarlo avrebbe spento la striscia
/// nell'Oroscopo, ed e' il motivo per cui i due elenchi restano due.
library;

/// Come si comporta Esplora su una schermata.
enum PresenzaEsplora {
  /// La striscia c'e': ritratta a linguetta, oppure aperta.
  ///
  /// E' il caso normale, e comprende le chat dei Maestri: e' li' che nasce il
  /// problema che ha generato Esplora, cioe' che da chat, Consiglio e ritorno a
  /// un altro Maestro tornare alla home diventa lungo.
  presente,

  /// Esperienza immersiva: la striscia non c'e', e non c'e' nemmeno richiusa.
  ///
  /// Sono la stesa, i riti e la meditazione. Li' l'assenza e' una scelta: la
  /// persona e' dentro un gesto che dura, e una via d'uscita sempre a vista lo
  /// interrompe. Si esce col tasto indietro, che resta.
  immersiva,

  /// Il guscio ha gia' la sua barra: Esplora non ci va, perche' duplicherebbe.
  ///
  /// Sono il Santuario e il Cosmic Passport, cioe' le due sole viste di
  /// `ShellView`, dove `SantuarioBottomBar` mostra gia' il Cerchio, i tre
  /// Maestri e il Passport. **Non e' una questione di gusto: era una
  /// regressione.** Esplora e' un `Positioned` sopra il contenuto, quindi
  /// intercettava i tocchi della barra del guscio e nel Santuario e nel
  /// Passport la barra non rispondeva piu'. Undici prove lo hanno preso il 6
  /// agosto 2026, fra cui il tocco su Passport, l'icona Maestro che non portava
  /// al dominio e le Impostazioni irraggiungibili.
  ///
  /// Esplora accorcia le strade dove non ce n'e' gia' una: qui ce n'e' una.
  barraDelGuscio,

  /// Soglia: si e' prima del Cerchio, oppure fuori dal suo corpo navigabile.
  ///
  /// L'onboarding, la rivelazione del Maestro, i dati di nascita, l'intro di
  /// un'arte: qui la striscia non ha dove portare, perche' le vie che contiene
  /// non esistono ancora o non sono il punto. **Questa terza voce esiste per non
  /// dichiarare il falso:** l'alternativa era classificare l'onboarding come
  /// immersivo, e l'onboarding non e' un'esperienza immersiva, e' una soglia.
  soglia,
}

/// L'elenco, per nome di classe della schermata.
///
/// Il nome di classe e non il tipo, perche' la prova che lo sorveglia legge i
/// sorgenti: cosi' una schermata nuova fa cadere la prova finche' qualcuno non
/// dichiara cosa deve succedere, invece di ereditare un comportamento per caso.
const Map<String, PresenzaEsplora> presenzaPerSchermata = {
  // --- Le due viste del guscio, che la barra ce l'hanno gia' --------------
  'SantuarioScreen': PresenzaEsplora.barraDelGuscio,
  'CosmicPassport': PresenzaEsplora.barraDelGuscio,

  // --- Il corpo navigabile del Cerchio -----------------------------------
  'DomainScreen': PresenzaEsplora.presente,
  'MaestroScreen': PresenzaEsplora.presente,
  'MaestroChatScreen': PresenzaEsplora.presente,
  'AskMaestriScreen': PresenzaEsplora.presente,
  'OroscopoScreen': PresenzaEsplora.presente,
  'SkyOverviewScreen': PresenzaEsplora.presente,
  'AngelsScreen': PresenzaEsplora.presente,
  'DayOracleScreen': PresenzaEsplora.presente,
  'SinastriaGalleryScreen': PresenzaEsplora.presente,
  'SinastriaVipScreen': PresenzaEsplora.presente,
  'GuideAnimalScreen': PresenzaEsplora.presente,
  'ResonanceScreen': PresenzaEsplora.presente,
  'CircleSealScreen': PresenzaEsplora.presente,
  'ArchetypeTestScreen': PresenzaEsplora.presente,
  'FaceConstellationScreen': PresenzaEsplora.presente,
  'AccountScreen': PresenzaEsplora.presente,
  'SettingsScreen': PresenzaEsplora.presente,
  'ProfileScreen': PresenzaEsplora.presente,
  'PricingScreen': PresenzaEsplora.presente,

  // --- Le immersive: stesa, riti, meditazione ----------------------------
  'StesaTreCarteScreen': PresenzaEsplora.immersiva,
  'DawnRiteScreen': PresenzaEsplora.immersiva,
  'SunsetRuneScreen': PresenzaEsplora.immersiva,
  'DreamRiteScreen': PresenzaEsplora.immersiva,
  'MeditationScreen': PresenzaEsplora.immersiva,
  'BreathDestinyScreen': PresenzaEsplora.immersiva,
  'RuneDrawScreen': PresenzaEsplora.immersiva,
  'SigilloIntenzioneScreen': PresenzaEsplora.immersiva,

  // --- Le soglie ----------------------------------------------------------
  'OnboardingScreen': PresenzaEsplora.soglia,
  'MaestroRevealScreen': PresenzaEsplora.soglia,
  'DatiDiNascitaScreen': PresenzaEsplora.soglia,
  'ArtIntroScreen': PresenzaEsplora.soglia,
};

/// Vero se su questa schermata la striscia si vede, anche solo a linguetta.
bool esploraSiVede(String nomeSchermata) =>
    presenzaPerSchermata[nomeSchermata] == PresenzaEsplora.presente;
