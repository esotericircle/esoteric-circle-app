import 'vip_catalog.dart';

/// IL VIP CHE SI RICONOSCE NEL CATALOGO. Ordine BO voce 13 punto 7.
///
/// **L'app non lo dichiara: lo CHIEDE.** Un riconoscimento automatico
/// sbaglierebbe su due persone nate lo stesso giorno nello stesso luogo, e
/// dichiarare a qualcuno "tu sei Rihanna" perche' e' nato a Bridgetown il 20
/// febbraio 1988 sarebbe un errore che nessuna scusa ripara. Una domanda
/// gentile invece non sbaglia mai: al massimo riceve un no.
class RiconoscimentoDelVip {
  const RiconoscimentoDelVip._();

  /// Quanto possono distare due luoghi e valere ancora lo stesso, in gradi.
  ///
  /// **Un decimo di grado, cioe' circa undici chilometri**: e' la stessa
  /// tolleranza con cui l'app tratta una citta' come un punto solo, perche'
  /// dentro una citta' la differenza fra un quartiere e l'altro non sposta
  /// niente di cio' che conta qui.
  static const double tolleranzaInGradi = 0.1;

  /// Quanti minuti possono distare due ore di nascita e valere lo stesso.
  ///
  /// **Trenta**: sotto la mezz'ora l'Ascendente si sposta di meno di otto
  /// gradi, e nessuna fonte biografica e' piu' precisa di cosi'.
  static const int tolleranzaInMinuti = 30;

  /// Il VIP che potrebbe essere questa persona, oppure nullo.
  ///
  /// **Serve la data E il luogo**, e l'ora solo quando si conosce da tutte e
  /// due le parti: con l'ora nota da un lato solo non si puo' confrontare, e
  /// pretenderla escluderebbe tutti e cinquanta i VIP del catalogo, che l'ora
  /// non ce l'hanno.
  static Vip? forse({
    required DateTime nascita,
    double? latitudine,
    double? longitudine,
    int? oreDiNascita,
    int? minutiDiNascita,
  }) {
    if (latitudine == null || longitudine == null) return null;
    for (final v in VipCatalog.vips) {
      if (v.annoDiNascita != nascita.year ||
          v.meseDiNascita != nascita.month ||
          v.giornoDiNascita != nascita.day) {
        continue;
      }
      final luogo = v.luogoDiNascita;
      if (luogo == null) continue;
      if ((luogo.latitudine - latitudine).abs() > tolleranzaInGradi) continue;
      if ((luogo.longitudine - longitudine).abs() > tolleranzaInGradi) {
        continue;
      }
      // L'ora entra nel confronto solo se la sanno tutti e due.
      if (oreDiNascita != null && v.ora.eNota) {
        final sua = v.ora.ore! * 60 + (v.ora.minuti ?? 0);
        final tua = oreDiNascita * 60 + (minutiDiNascita ?? 0);
        if ((sua - tua).abs() > tolleranzaInMinuti) continue;
      }
      return v;
    }
    return null;
  }

  /// **LA RIGA GARBATA CHE CHIEDE, e non dichiara.** Nessun "sei tu": una
  /// domanda, e la persona risponde.
  static String domandaPer(Vip vip) =>
      'I tuoi dati di nascita coincidono con quelli di ${vip.name}. '
      'Sei tu, per caso?';

  /// Cosa si dice quando la persona risponde di no. **Si chiude e non si
  /// richiede piu'**: insistere su una domanda del genere e' molesto.
  static const String seDiceDiNo =
      'Allora siete nati lo stesso giorno, nello stesso posto: '
      'una coincidenza che non capita a tutti.';
}
