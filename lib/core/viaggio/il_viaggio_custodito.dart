import 'dart:convert';

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
    // **ORDINE FZ VOCE 01 E 02, 17 ottobre 2026.** Il nome dell'animale
    // riconosciuto, e il segno che la migrazione una tantum e' gia' stata
    // fatta: senza il primo due dispositivi dello stesso account potrebbero
    // vedere due animali diversi dopo una fusione (`ilViaggioPiuAvanti`
    // sceglie il bagaglio intero, e se il nome non viaggia col resto il
    // dispositivo che vince la fusione mostrerebbe "Non ancora rivelato" a
    // chi aveva gia' riconosciuto il suo animale su un altro telefono);
    // senza il secondo, un telefono a meta' potrebbe rivedersi "riparte da
    // capo" a ogni fusione che adotta una copia non ancora migrata.
    'viaggio.animale_riconosciuto',
    'viaggio.fz02_migrato',
  ];

  /// **IL PESO CHE IL CERCHIO ACCETTA**, in caratteri del sacchetto scritto
  /// in JSON. E' `PESO_MASSIMO_DEL_DIARIO_DELL_ALBA` di
  /// `functions/src/cammino.ts`, che `leggiCammino` applica anche al
  /// Viaggio: **un sacchetto piu' pesante il server lo scarta in silenzio**.
  /// La guardia `il_viaggio_pesante_non_torna_indietro_test` legge il numero
  /// dal server e cade se i due si separano.
  static const int pesoMassimoDelCerchio = 20000;

  /// **QUANTO SI MANDA DAVVERO**, con un margine sotto il tetto del server:
  /// il server misura con `JSON.stringify` l'oggetto che riceve, non la
  /// stringa che parte, e un carattere di differenza non deve bastare a
  /// perdere il Viaggio.
  static const int pesoDaNonSuperare = 19000;

  /// **L'ULTIMO SACCHETTO MANDATO**, per riconoscerlo quando torna.
  static Map<String, Object?>? _ultimoMandato;

  /// **VERO SE IN QUESTO GIRO IL VIAGGIO NON E' POTUTO PARTIRE**, perche'
  /// anche alleggerito pesava piu' del tetto (le celle scoperte partono
  /// sempre intere, e dodici carte grattate per intero pesano da sole piu' di
  /// trentamila caratteri). Allora il Cerchio non ha visto il Viaggio di
  /// questo telefono, la copia che rimanda non si puo' giudicare, e non si
  /// adotta: sul telefono resta il suo.
  static bool _nonEPartito = false;

  /// Il Viaggio come sacchetto da mandare al Cerchio, o null se non c'e'
  /// niente: un guscio vuoto in piu' a ogni apertura non dice niente a
  /// nessuno.
  ///
  /// **SEMPRE SOTTO IL PESO CHE IL CERCHIO ACCETTA.** Ordine FZ, trovato
  /// dalla simulazione da persona del 20 ottobre 2026 sul Realme 767f596c:
  /// le discese del secondo e del terzo giorno sparivano dal Diario al primo
  /// ritorno dell'app in primo piano. **La causa, misurata**: il sacchetto
  /// pesava 22.218 caratteri, di cui 19.317 di solchi del dito; il server lo
  /// scartava (`leggiCammino`, tetto 20.000), la fusione vedeva solo la copia
  /// custodita, ferma alla prima discesa, e il telefono la adottava sopra la
  /// sua, piu' avanti. Padre: ordine EE voce 13, che ha dato al Viaggio il
  /// tetto del diario dell'Alba senza guardare quanto pesa (il Diario tiene
  /// fino a novanta discese, e da sole passano il tetto verso la trentesima);
  /// aggravato dall'ordine FZ voce FZ.04, che conserva i solchi di ogni
  /// animale. Vedi [alleggerito].
  static Future<Map<String, Object?>?> daCustodire() async {
    // **IL SACCHETTO RICORDATO VALE PER UN GIRO SOLO**: una raccolta nuova
    // dimentica quello di prima, cosi' un sacchetto vecchio non puo' mai
    // impedire di ritrovare il Viaggio, per esempio dopo aver dimenticato i
    // dati del telefono.
    _ultimoMandato = null;
    _nonEPartito = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final fuori = <String, Object?>{};
      for (final chiave in chiavi) {
        final valore = prefs.get(chiave);
        if (valore != null) fuori[chiave] = valore;
      }
      if (fuori.isEmpty) return null;
      final leggero = alleggerito(fuori);
      if (jsonEncode(leggero).length > pesoDaNonSuperare) {
        // Il server lo scarterebbe comunque: non lo si manda, e lo si dice
        // all'adozione.
        _nonEPartito = true;
        return null;
      }
      _ultimoMandato = leggero;
      return leggero;
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
  ///
  /// **E SE IL VIAGGIO DI QUESTO TELEFONO NON E' POTUTO PARTIRE**
  /// ([_nonEPartito]), non si adotta niente: il Cerchio ha deciso senza
  /// vederlo.
  ///
  /// **SE TORNA IL SACCHETTO APPENA MANDATO, NON SI SCRIVE NIENTE.** Vuol
  /// dire che il Cerchio ha dato ragione al telefono: riscriverlo non
  /// aggiungerebbe niente, e da quando il sacchetto si alleggerisce
  /// ([alleggerito]) toglierebbe al telefono i solchi e le discese piu'
  /// vecchie che non sono partite.
  static Future<void> adottaDalCerchio(Map<String, Object?>? dal) async {
    final nonEPartito = _nonEPartito;
    _nonEPartito = false;
    final mandato = _ultimoMandato;
    _ultimoMandato = null;
    if (dal == null || dal.isEmpty) return;
    if (nonEPartito) return;
    if (mandato != null && stessoSacchetto(mandato, dal)) return;
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

  /// **IL SACCHETTO SOTTO IL PESO CHE IL CERCHIO ACCETTA**, senza toccare
  /// cio' che decide la fusione.
  ///
  /// **Il conto (`viaggio.quante`), il riconoscimento, il nome
  /// dell'animale, il cammino e le celle scoperte partono sempre interi**:
  /// sono cio' che `ilViaggioPiuAvanti` confronta e cio' che un telefono
  /// nuovo deve ritrovare. Si toglie, in quest'ordine e solo finche' serve:
  /// prima **i solchi del dito**, che sono il disegno del gesto e non il
  /// conto (le celle dicono gia' quali pezzi sono scoperti); poi **le voci
  /// piu' vecchie** del Diario, dei segni e dei nutrimenti, che il telefono
  /// tiene dalla piu' recente. Sul telefono non si toglie niente: e' solo cio'
  /// che parte.
  static Map<String, Object?> alleggerito(
    Map<String, Object?> pieno, {
    int tetto = pesoDaNonSuperare,
  }) {
    final fuori = Map<String, Object?>.of(pieno);
    int peso() => jsonEncode(fuori).length;
    if (peso() <= tetto) return fuori;
    fuori.remove('viaggio.velo.solchi');
    for (final chiave in const [
      'viaggio.diario',
      'viaggio.segni',
      'viaggio.nutrimenti',
    ]) {
      while (peso() > tetto) {
        final lista = fuori[chiave];
        if (lista is! List || lista.isEmpty) break;
        fuori[chiave] = lista.sublist(0, lista.length - 1);
      }
    }
    return fuori;
  }

  /// **LO STESSO SACCHETTO**, chiave per chiave: i numeri si confrontano
  /// come numeri (dal server un intero puo' tornare come 2.0) e le liste
  /// voce per voce.
  static bool stessoSacchetto(Map<String, Object?> a, Map<String, Object?> b) {
    for (final chiave in chiavi) {
      final x = a[chiave];
      final y = b[chiave];
      if (x == null || y == null) {
        if (x != y) return false;
      } else if (x is num && y is num) {
        if (x != y) return false;
      } else if (x is List && y is List) {
        if (x.length != y.length) return false;
        for (var i = 0; i < x.length; i++) {
          if ('${x[i]}' != '${y[i]}') return false;
        }
      } else if (x != y) {
        return false;
      }
    }
    return true;
  }
}
