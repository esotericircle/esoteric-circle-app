import '../maestro/maestro.dart';
import 'daily_rituals.dart';

/// I cinque appuntamenti giornalieri del Cerchio, con l'ora della loro fascia e
/// il Maestro che ne porta il colore.
///
/// Il Rito dell'Alba e il Rito della Buonanotte non hanno un Maestro fisso
/// (ruotano di giorno in giorno) e il loro accento resta l'oro; gli altri tre
/// seguono il loro Maestro: Soffio del Destino verde di Aura, Oracolo del
/// Giorno blu di Medora, Runa del Tramonto rosso di Caligo.
///
/// L'ordine di dichiarazione e' anche l'ordine nella striscia: Alba, Soffio,
/// Oracolo, Tramonto, Notte.
enum DailyElement {
  dawn(
    title: 'Rito dell\'Alba',
    shortLabel: 'Alba',
    anchorHour: 7,
    anchorMinute: 0,
    guide: null,
    pushByDefault: true,
    description:
        'Apre la giornata con una parola guida e l\'energia dell\'alba, '
        'per orientare le tue prossime ore.',
  ),
  breath(
    title: 'Soffio del Destino',
    shortLabel: 'Soffio',
    anchorHour: 10,
    anchorMinute: 30,
    guide: Maestro.aura,
    pushByDefault: false,
    description:
        'Un respiro guidato che allinea il tuo destino del momento e '
        'scioglie la tensione.',
  ),
  oracle(
    title: 'Oracolo del Giorno',
    shortLabel: 'Oracolo',
    anchorHour: 13,
    anchorMinute: 0,
    guide: Maestro.medora,
    pushByDefault: true,
    description:
        'Il responso centrale del giorno, che illumina la domanda che porti '
        'con te.',
  ),
  rune(
    title: 'La Runa del Tramonto',
    shortLabel: 'Tramonto',
    anchorHour: 18,
    anchorMinute: 30,
    guide: Maestro.caligo,
    pushByDefault: false,
    description:
        'La runa della sera che raccoglie e custodisce quello che il giorno '
        'ti ha lasciato.',
  ),
  night(
    title: 'Rito del Sogno',
    shortLabel: 'Notte',
    anchorHour: 22,
    anchorMinute: 30,
    guide: null,
    pushByDefault: true,
    description:
        'Uno sguardo al giorno appena concluso: la nebbia si dirada col fiato, '
        'emergono le stelle del cielo notturno reale, unisci la costellazione '
        'del segno in cui si trova la Luna adesso, poi il saluto della notte '
        'con la sua carta. Ripiego tattile sempre presente.',
  );

  const DailyElement({
    required this.title,
    required this.shortLabel,
    required this.anchorHour,
    required this.anchorMinute,
    required this.guide,
    required this.pushByDefault,
    required this.description,
  });

  final String title;
  final String shortLabel;
  final int anchorHour;
  final int anchorMinute;

  /// Il Maestro che presta il colore all'elemento. Null per i due riti che
  /// ruotano di giorno in giorno (Alba e Buonanotte), che restano oro.
  final Maestro? guide;

  /// Se di default questo elemento invia una notifica push. Unico punto di
  /// verita': di default solo Alba, Oracolo e Buonanotte notificano; Soffio e
  /// Tramonto restano disponibili in app, attivabili in futuro dall'utente.
  final bool pushByDefault;

  /// La spiegazione breve dell'elemento, cosa e' e a cosa serve, per il popup
  /// informativo della striscia.
  final String description;

  int get anchorMinutes => anchorHour * 60 + anchorMinute;

  /// L'orario di apertura della fascia, nel formato h:mm (ad esempio 7:00,
  /// 10:30). Serve al riquadro orario nella striscia del giorno.
  String get clockLabel =>
      '$anchorHour:${anchorMinute.toString().padLeft(2, '0')}';

  /// L'id stabile per il deep-link da notifica push.
  String get id => name;

  static DailyElement? fromId(String? id) {
    for (final e in values) {
      if (e.name == id) return e;
    }
    return null;
  }
}

/// La selezione deterministica dell'elemento della fascia oraria attiva.
class DailyElements {
  const DailyElements._();

  /// L'elemento "corrente", scelto dalla fascia oraria attiva sull'ora locale.
  /// La fascia va da un'ancora alla successiva; la fascia dopo le 22:30 e prima
  /// delle 7:00 appartiene al Rito della Buonanotte, cosi' la notte fonda resta
  /// sua.
  static DailyElement current(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    if (minutes < DailyElement.dawn.anchorMinutes) return DailyElement.night;
    if (minutes < DailyElement.breath.anchorMinutes) return DailyElement.dawn;
    if (minutes < DailyElement.oracle.anchorMinutes) return DailyElement.breath;
    if (minutes < DailyElement.rune.anchorMinutes) return DailyElement.oracle;
    if (minutes < DailyElement.night.anchorMinutes) return DailyElement.rune;
    return DailyElement.night;
  }

  /// Il Maestro attivo di un elemento: per i riti che ruotano (Alba e
  /// Buonanotte) e' il Maestro di turno del giorno; per gli altri tre e' il
  /// loro Maestro fisso, Soffio ad Aura, Oracolo a Medora, Runa a Caligo.
  static Maestro maestroFor(DailyElement element, DateTime now) =>
      element.guide ?? DailyRituals.dawnMaestro(now);

  /// Gli elementi che di default inviano una notifica push: Rito dell'Alba,
  /// Oracolo del Giorno e Rito della Buonanotte. Soffio del Destino e Runa del
  /// Tramonto restano disponibili in app senza push, attivabili in futuro.
  static List<DailyElement> get defaultPushElements =>
      DailyElement.values.where((e) => e.pushByDefault).toList(growable: false);
}
