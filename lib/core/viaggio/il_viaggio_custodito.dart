import 'package:shared_preferences/shared_preferences.dart';

/// **IL VIAGGIO DELLO SCIAMANO VIVE SULL'ACCOUNT, NON SUL TELEFONO.** Ordine
/// EE voce 13, 23 settembre 2026.
///
/// **Il fatto del fondatore, verbatim**: *"adesso ho aggiornato l'app alla
/// nuova build e ho aperto il viaggio dello SCIAMANO che io avevo gia'
/// concluso e invece devo rifarlo da zero"*.
///
/// **La causa, misurata prima di curare.** Il Viaggio viveva su otto chiavi di
/// `SharedPreferences` e **non aveva nessuna porta verso il Cerchio**: zero
/// chiamate al server in tutto `diario_dei_viaggi.dart`. Non era un difetto di
/// sincronizzazione, era un dato che non aveva mai lasciato il telefono.
/// Quattro discese che il diario stesso dichiara costare **quattro giorni**,
/// una al giorno, sparivano con l'app.
///
/// **PERCHE' LE CHIAVI E NON IL DIARIO.** `DiarioDeiViaggi` non e' un
/// singleton: lo costruiscono quattro schermate diverse, e ognuna rilegge
/// dalle prefs. Non esiste un'istanza da cui raccogliere, e farne una avrebbe
/// voluto dire cambiare il modo in cui il Viaggio vive per poterlo custodire.
/// **Qui si copiano le chiavi com'erano**, senza toccare il comportamento del
/// diario: il Cerchio riceve un sacchetto che non interpreta, esattamente come
/// fa gia' col diario dell'Arcano dell'Alba.
///
/// **Il Cerchio non decide chi vince: lo decide il Cerchio.** La fusione sta
/// in un punto solo, `functions/src/cammino.ts`, `ilViaggioPiuAvanti`: chi ha
/// riconosciuto batte chi no, e a parita' vince chi ha piu' discese. Se la
/// regola vivesse anche qui sarebbero due regole, e il giorno che una cambia
/// il viaggio di qualcuno si spezzerebbe a meta'.
abstract final class IlViaggioCustodito {
  /// Le chiavi del Viaggio, quelle e solo quelle.
  ///
  /// **Il prefisso `viaggio.` non basta come regola**, e non si usa: le
  /// chiavi si enumerano, perche' una chiave nuova che finisse qui dentro
  /// senza che nessuno l'abbia pensata viaggerebbe verso il Cerchio senza
  /// che nessuno sappia cosa contiene.
  static const List<String> chiavi = [
    'viaggio.diario',
    'viaggio.nutrimenti',
    'viaggio.segni',
    'viaggio.velo',
    'viaggio.velo.solchi',
    'viaggio.quante',
    'viaggio.cammino',
    'viaggio.riconosciuto',
  ];

  /// Il Viaggio come sacchetto da mandare al Cerchio, o null se non c'e'
  /// niente: un guscio vuoto in piu' a ogni apertura non dice niente a
  /// nessuno.
  static Future<Map<String, Object?>?> daCustodire() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fuori = <String, Object?>{};
      for (final chiave in chiavi) {
        final valore = prefs.get(chiave);
        if (valore != null) fuori[chiave] = valore;
      }
      if (fuori.isEmpty) return null;
      return fuori;
    } catch (errore) {
      // Se le preferenze non ci sono, non si custodisce niente: il Viaggio
      // di oggi resta quello che e', e al prossimo giro si riprova.
      return null;
    }
  }

  /// Riscrive sul telefono il Viaggio che il Cerchio ha custodito.
  ///
  /// **Si scrive solo cio' che il Cerchio manda, e non si cancella altro**:
  /// il Cerchio ha gia' deciso quale delle due copie e' la piu' avanti, e se
  /// ha mandato la sua e' perche' vale piu' di quella locale.
  static Future<void> adottaDalCerchio(Map<String, Object?>? dal) async {
    if (dal == null || dal.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final chiave in chiavi) {
        final valore = dal[chiave];
        if (valore == null) continue;
        if (valore is bool) {
          await prefs.setBool(chiave, valore);
        } else if (valore is int) {
          await prefs.setInt(chiave, valore);
        } else if (valore is double) {
          await prefs.setDouble(chiave, valore);
        } else if (valore is String) {
          await prefs.setString(chiave, valore);
        } else if (valore is List) {
          await prefs.setStringList(
              chiave, valore.map((e) => '$e').toList(growable: false));
        }
      }
    } catch (errore) {
      // Il Viaggio resta quello del telefono: si riprova alla prossima
      // apertura, e nel frattempo la persona non perde niente di cio' che
      // ha gia' sotto gli occhi.
    }
  }
}
