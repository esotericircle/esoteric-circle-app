import 'intention_sigil.dart';
import '../tempo/confine_del_giorno.dart';
import '../viaggio/scena_del_viaggio.dart';

/// **I QUATTRO STATI DI UN SIGILLO**, e non di piu'. Ordine DO voce 02,
/// 15 settembre 2026.
enum StatoDelSigillo {
  /// Tracciato e non ancora scaduto.
  vivo,

  /// La persona ha dichiarato che si e' avverato.
  compiuto,

  /// La persona lo ha lasciato andare.
  lasciato,

  /// La data e' passata e la persona non ha ancora risposto.
  scaduto,
}

/// **IL SIGILLO E' UN OGGETTO CON UNO STATO.** Ordine DO voce 02.
///
/// Parole del fondatore: alla fine della funzione ci si chiedeva *"e adesso?
/// cosa mi rimane? cosa ho ottenuto?"*. **Il Sigillo era un momento, e nella
/// tradizione e' un oggetto**: in Austin Osman Spare il tracciare e' il primo
/// di piu' momenti, poi si carica, si dimentica, e alla fine si compie o si
/// lascia andare. Qui il sigillo tracciato si conserva, e la sua vita si legge
/// dalle date.
///
/// **Nasce vivo e spento**, cioe' con carica a zero: e' il cambiamento che
/// regge tutti gli altri, perche' fino a ieri nasceva gia' finito.
class SigilloVivo {
  const SigilloVivo({
    required this.id,
    required this.intenzione,
    required this.riformulata,
    required this.via,
    required this.nascita,
    required this.scadenza,
    this.cariche = const [],
    this.dichiarato,
    this.chiusoIl,
    this.titolo,
    this.responso,
    this.testoDelCompimento,
  });

  final String id;

  /// L'intenzione come la persona l'ha scritta.
  final String intenzione;

  /// Il testo da cui nasce il segno: di solito l'intenzione, riformulata
  /// quando chiedeva di agire sulla volonta' di un altro.
  final String riformulata;

  /// La via scelta dalla persona prima di scrivere, voce DO.09.
  final ViaMagica via;

  final DateTime nascita;

  /// Il giorno scelto come scadenza: e' il giorno in cui Caligo chiede
  /// com'e' andata.
  final DateTime scadenza;

  /// Gli istanti delle cariche, dalla prima all'ultima.
  final List<DateTime> cariche;

  /// Compiuto o lasciato, quando la persona l'ha dichiarato; nullo prima.
  final StatoDelSigillo? dichiarato;

  /// Quando e' stato chiuso con la dichiarazione.
  final DateTime? chiusoIl;

  /// Il titolo e il responso scritti sull'intenzione vera, voce DO.10.
  final String? titolo;
  final String? responso;

  /// La riga ricevuta alla dichiarazione di compimento, voce DO.05.
  final String? testoDelCompimento;

  /// **QUANTE CARICHE SERVONO PER LA LUCE PIENA.** Sette, una settimana di
  /// gesti: e' la stessa unita' della nitidezza del Viaggio.
  static const int caricheDellaLucePiena = 7;

  /// **LO STATO ADESSO.** Compiuto e lasciato li dichiara la persona; vivo e
  /// scaduto li dice il calendario. **Il sigillo arriva alla sua data
  /// all'inizio del giorno scelto**, e da quel momento la domanda aspetta:
  /// la chiamata della voce DO.08 suona quel giorno, e chi la tocca deve
  /// trovare la domanda nel Libro, non un sigillo ancora vivo.
  StatoDelSigillo statoA(DateTime adesso) {
    if (dichiarato != null) return dichiarato!;
    final inizio = DateTime(scadenza.year, scadenza.month, scadenza.day);
    return adesso.isBefore(inizio)
        ? StatoDelSigillo.vivo
        : StatoDelSigillo.scaduto;
  }

  bool eVivoA(DateTime adesso) => statoA(adesso) == StatoDelSigillo.vivo;

  /// **UNA CARICA AL GIORNO PER CIASCUN SIGILLO VIVO**, voce DO.03.
  bool siPuoCaricareA(DateTime adesso) =>
      eVivoA(adesso) &&
      !cariche.any((c) =>
          ConfineDelGiorno.chiaveDi(c) == ConfineDelGiorno.chiaveDi(adesso));

  /// **LA LUCE DEL SEGNO**, da 0 (spento) a 1 (pieno). Voce DO.03.
  ///
  /// Non una barra, non una percentuale, non un numero: la ricompensa e' che
  /// il segno si vede meglio. **Cresce con le cariche** fino a sette, e **si
  /// affievolisce con la stessa curva lenta della nitidezza del Viaggio**,
  /// `NitidezzaDellaScena.dopoGiorni`: sotto la settimana non succede niente,
  /// perche' quella e' la vita normale di una persona.
  double luceA(DateTime adesso) {
    if (cariche.isEmpty) return 0;
    final quante = cariche.length.clamp(0, caricheDellaLucePiena);
    final crescita = quante / caricheDellaLucePiena;
    final giorni = ConfineDelGiorno.giorniDa(cariche.last, adesso);
    return (crescita * NitidezzaDellaScena.dopoGiorni(giorni)).clamp(0.0, 1.0);
  }

  SigilloVivo conCarica(DateTime quando) =>
      _copia(cariche: [...cariche, quando]);

  SigilloVivo dichiara(StatoDelSigillo stato, DateTime quando,
          {String? testoDelCompimento}) =>
      _copia(
        dichiarato: stato,
        chiusoIl: quando,
        testoDelCompimento: testoDelCompimento,
      );

  /// **IL RINNOVO**: una data nuova, e la carica riparte, voce DO.05.
  SigilloVivo rinnova(DateTime nuovaScadenza) => SigilloVivo(
        id: id,
        intenzione: intenzione,
        riformulata: riformulata,
        via: via,
        nascita: nascita,
        scadenza: nuovaScadenza,
        titolo: titolo,
        responso: responso,
      );

  SigilloVivo conScadenza(DateTime nuova) => _copia(scadenza: nuova);

  /// Il titolo e il responso, arrivati dopo la nascita: il modello scrive
  /// mentre il segno si traccia, e il sigillo si salva prima che finisca.
  SigilloVivo conITesti(String titolo, String responso) => SigilloVivo(
        id: id,
        intenzione: intenzione,
        riformulata: riformulata,
        via: via,
        nascita: nascita,
        scadenza: scadenza,
        cariche: cariche,
        dichiarato: dichiarato,
        chiusoIl: chiusoIl,
        titolo: titolo,
        responso: responso,
        testoDelCompimento: testoDelCompimento,
      );

  SigilloVivo _copia({
    DateTime? scadenza,
    List<DateTime>? cariche,
    StatoDelSigillo? dichiarato,
    DateTime? chiusoIl,
    String? testoDelCompimento,
  }) =>
      SigilloVivo(
        id: id,
        intenzione: intenzione,
        riformulata: riformulata,
        via: via,
        nascita: nascita,
        scadenza: scadenza ?? this.scadenza,
        cariche: cariche ?? this.cariche,
        dichiarato: dichiarato ?? this.dichiarato,
        chiusoIl: chiusoIl ?? this.chiusoIl,
        titolo: titolo,
        responso: responso,
        testoDelCompimento: testoDelCompimento ?? this.testoDelCompimento,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'intenzione': intenzione,
        'riformulata': riformulata,
        'via': via.name,
        'nascita': nascita.toIso8601String(),
        'scadenza': scadenza.toIso8601String(),
        'cariche': [for (final c in cariche) c.toIso8601String()],
        if (dichiarato != null) 'dichiarato': dichiarato!.name,
        if (chiusoIl != null) 'chiusoIl': chiusoIl!.toIso8601String(),
        if (titolo != null) 'titolo': titolo,
        if (responso != null) 'responso': responso,
        if (testoDelCompimento != null)
          'testoDelCompimento': testoDelCompimento,
      };

  /// Nullo se il documento non si legge: un sigillo guasto non rompe il
  /// Libro, si salta.
  static SigilloVivo? fromJson(Map<String, Object?> j) {
    try {
      final via = ViaMagica.values.firstWhere((v) => v.name == j['via']);
      final dichiarato = j['dichiarato'] == null
          ? null
          : StatoDelSigillo.values.firstWhere((s) => s.name == j['dichiarato']);
      return SigilloVivo(
        id: j['id']! as String,
        intenzione: j['intenzione']! as String,
        riformulata: j['riformulata']! as String,
        via: via,
        nascita: DateTime.parse(j['nascita']! as String),
        scadenza: DateTime.parse(j['scadenza']! as String),
        cariche: [
          for (final c in (j['cariche'] as List? ?? const []))
            DateTime.parse(c as String),
        ],
        dichiarato: dichiarato,
        chiusoIl: j['chiusoIl'] == null
            ? null
            : DateTime.parse(j['chiusoIl']! as String),
        titolo: j['titolo'] as String?,
        responso: j['responso'] as String?,
        testoDelCompimento: j['testoDelCompimento'] as String?,
      );
    } catch (errore) {
      // Un documento che non si legge si salta: un sigillo guasto non rompe
      // il Libro, e gli altri restano.
      return null;
    }
  }
}
