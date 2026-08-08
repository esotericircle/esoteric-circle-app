import 'app_permission.dart';

/// IL REGISTRO DEI PERMESSI: cosa chiede l'app, dove lo dichiara, chi lo
/// chiede davvero.
///
/// **Perche' esiste, e non e' una lista di comodo.** Su iOS un permesso
/// chiesto senza la sua chiave in `Info.plist` non produce un errore: il
/// sistema UCCIDE l'app nel momento della richiesta, senza crash e senza
/// rapporto. E' la stessa famiglia del difetto del pittore del cosmo, che
/// per settimane e' sembrata un'app che "spariva". Un permesso dichiarato e
/// mai chiesto e' l'altro difetto, opposto e piu' silenzioso: fa comparire
/// nella scheda dello store una richiesta che non serve a niente, e in
/// revisione Apple la contesta.
///
/// Qui i due lati stanno insieme, e una prova li confronta con i file veri.
class VoceDelRegistro {
  const VoceDelRegistro({
    required this.permesso,
    required this.chiaveIos,
    required this.ragioneSenzaChiave,
    required this.vociAndroid,
    required this.doveSiChiede,
    required this.ripiego,
  });

  final AppPermission permesso;

  /// La chiave di `ios/Runner/Info.plist` che DEVE esistere con un testo non
  /// vuoto. Nulla quando iOS non ne prevede nessuna per quel permesso.
  final String? chiaveIos;

  /// Perche' non c'e' una chiave: si scrive, cosi' nessuno domani pensa che
  /// sia una dimenticanza. Vuota quando la chiave c'e'.
  final String ragioneSenzaChiave;

  /// Le voci che devono comparire in `AndroidManifest.xml`. Vuota quando
  /// Android non chiede nulla per quella funzione.
  final List<String> vociAndroid;

  /// Il punto del codice che chiede il permesso davvero, file e riga
  /// indicativa: serve a chi legge, e la prova verifica che il file esista.
  final String doveSiChiede;

  /// Cosa resta alla persona quando il permesso non c'e'. Mai "niente".
  final String ripiego;
}

/// L'elenco completo. Una prova lo enumera e cade se un permesso non ha la
/// sua chiave iOS con un testo non vuoto o la sua voce nel manifest.
class RegistroDeiPermessi {
  const RegistroDeiPermessi._();

  static const List<VoceDelRegistro> voci = [
    VoceDelRegistro(
      permesso: AppPermission.location,
      chiaveIos: 'NSLocationWhenInUseUsageDescription',
      ragioneSenzaChiave: '',
      vociAndroid: [
        'android.permission.ACCESS_COARSE_LOCATION',
        'android.permission.ACCESS_FINE_LOCATION',
      ],
      doveSiChiede: 'lib/core/astro/sky_location.dart',
      ripiego: 'Il cielo si orienta sul luogo di nascita, oppure sul luogo '
          'scelto a mano nelle impostazioni.',
    ),
    VoceDelRegistro(
      permesso: AppPermission.microphone,
      chiaveIos: 'NSMicrophoneUsageDescription',
      ragioneSenzaChiave: '',
      vociAndroid: ['android.permission.RECORD_AUDIO'],
      doveSiChiede: 'lib/services/breath_detector.dart',
      ripiego: 'Il soffio si compie col dito, spazzando i semi o tenendo '
          'premuto.',
    ),
    VoceDelRegistro(
      permesso: AppPermission.camera,
      chiaveIos: 'NSCameraUsageDescription',
      ragioneSenzaChiave: '',
      vociAndroid: ['android.permission.CAMERA'],
      doveSiChiede: 'lib/features/synastry/user_photo.dart',
      ripiego: 'La card della Sinastria si compone col simbolo del segno al '
          'posto del volto, e la Costellazione del Viso resta toccabile.',
    ),
    VoceDelRegistro(
      permesso: AppPermission.photoLibrary,
      chiaveIos: 'NSPhotoLibraryUsageDescription',
      ragioneSenzaChiave: '',
      // Da Android 13 la lettura di una foto scelta dalla persona passa dal
      // selettore di sistema e NON chiede un permesso: dichiararlo sarebbe
      // chiedere piu' di quanto serve.
      vociAndroid: [],
      doveSiChiede: 'lib/features/synastry/user_photo.dart',
      ripiego: 'La card si compone senza foto, col simbolo del segno.',
    ),
    VoceDelRegistro(
      permesso: AppPermission.notifications,
      // **SU IOS NON ESISTE UNA CHIAVE PER LE NOTIFICHE**, e va scritto
      // perche' la sua assenza non venga presa per una dimenticanza: il
      // permesso si chiede a runtime al centro notifiche, e il testo lo
      // scrive il sistema, non l'app.
      chiaveIos: null,
      ragioneSenzaChiave: 'iOS non prevede una chiave di Info.plist per le '
          'notifiche: il permesso si chiede a runtime e la frase la scrive '
          'il sistema.',
      vociAndroid: ['android.permission.POST_NOTIFICATIONS'],
      doveSiChiede: 'lib/services/avvisi_locali.dart',
      ripiego: 'Il Rito dell\'Alba si apre lo stesso dall\'app, e la striscia '
          'del giorno dice che l\'avviso non arrivera\'.',
    ),
    VoceDelRegistro(
      permesso: AppPermission.motion,
      // **LA CHIAVE DEL MOVIMENTO C'E' ANCHE SE PROBABILMENTE NON SERVE.**
      // L'app legge accelerometro e giroscopio grezzi, che su iOS non
      // richiedono autorizzazione; la chiave serve alle API di attivita' e
      // pedometro, che qui non si usano. Sta lo stesso, perche' costa una
      // riga e la sua assenza, se un domani un plugin toccasse CoreMotion in
      // modo diverso, costerebbe un'app uccisa senza rapporto. Non essendoci
      // un iPhone in questa sessione, la cosa NON e' stata verificata su un
      // dispositivo, ed e' dichiarata.
      chiaveIos: 'NSMotionUsageDescription',
      ragioneSenzaChiave: '',
      // Android non chiede permessi per accelerometro e giroscopio.
      vociAndroid: [],
      doveSiChiede: 'lib/core/motion/parallax_controller.dart',
      ripiego: 'La parallasse segue lo scorrimento del dito, la gettata delle '
          'rune e la stesa si compiono col tocco.',
    ),
  ];

  /// La voce di un permesso, per chi la vuole senza scorrere la lista.
  static VoceDelRegistro di(AppPermission p) =>
      voci.firstWhere((v) => v.permesso == p);
}
