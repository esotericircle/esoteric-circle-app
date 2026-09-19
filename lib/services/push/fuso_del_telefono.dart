/// **IL FUSO DEL TELEFONO, COL NOME CHE IL SERVER SI ASPETTA.**
/// Ordine CQ voce 1.09, 3 settembre 2026.
///
/// **Il fatto, misurato sui log di Google Cloud.** Ventitre chiamate a
/// `scriviLeScelteDellePush` e ventitre risposte 400, e la raccolta
/// `push_dei_doni` su Firestore **non esiste**: nessuna scelta di push e' mai
/// arrivata sul server, quindi nessuna push e' mai partita.
///
/// **Quale dei tre controlli scattava, e non e' una deduzione.** La callable
/// rifiuta per tre motivi: token troppo corto o troppo lungo, fuso che non
/// somiglia a un nome IANA, doni che non sono un oggetto. Il telefono mandava
/// il nome corto del fuso di Dart, che su Android **non e' un nome IANA**: e'
/// l'abbreviazione della zona, `CEST` d'estate e `CET` d'inverno, e su certi
/// telefoni e' addirittura il nome tradotto nella lingua del sistema. Il
/// controllo del server pretende `Area/Citta`, cioe' una barra in mezzo, e
/// `CEST` non ne ha nessuna. **Il secondo dei tre, sempre, per tutti.**
///
/// **Perche' non basta allargare il controllo del server.** Il nome serve al
/// server per convertire l'ora locale scelta in minuti UTC, e lo fa
/// interrogando il database dei fusi: `CEST` li' dentro non esiste, quindi la
/// conversione tornerebbe un numero sbagliato invece di un errore. Un
/// controllo che lascia passare un dato inservibile e' peggio di un controllo
/// che lo respinge.
///
/// **Come si trova il nome giusto senza aggiungere una dipendenza.** Il
/// pacchetto `timezone` e' gia' nel progetto per gli avvisi locali, e porta il
/// database intero. Si misura lo scarto dall'UTC del telefono ADESSO e fra sei
/// mesi, e si cerca la prima zona che si comporta uguale in tutti e due i
/// momenti: **due misure e non una**, perche' d'estate Roma e Johannesburg
/// hanno lo stesso scarto e d'inverno no. Zone diverse che si comportano
/// uguale tutto l'anno sono intercambiabili per cio' che il server deve
/// farci, cioe' convertire un'ora.
library;

import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Il ripiego quando nessuna zona corrisponde: e' un nome IANA valido, passa
/// il controllo del server, e mette la persona sull'ora di Greenwich invece
/// che fuori dal servizio. **Meglio una push a un'ora spostata che nessuna
/// push mai**, ed e' il caso che i log hanno mostrato.
const String fusoDiRipiego = 'Etc/UTC';

bool _databasePronto = false;

/// Quante zone ci sono nel database caricato. Serve alla guardia, che senza
/// questo numero non saprebbe distinguere "nessuna zona corrisponde" da
/// "nessuna zona esiste".
int get quanteZoneConosciute {
  _preparaIlDatabase();
  return tz.timeZoneDatabase.locations.length;
}

void _preparaIlDatabase() {
  if (_databasePronto) return;
  tzdata.initializeTimeZones();
  _databasePronto = true;
}

/// Il nome IANA di una zona che si comporta come il telefono.
///
/// [adesso] e [fraSeiMesi] esistono per la guardia: cosi' si puo' chiedere
/// "che nome esce per un telefono a piu' due che d'inverno va a piu' uno"
/// senza spostare l'orologio della macchina.
String fusoDelTelefono({DateTime? adesso}) {
  _preparaIlDatabase();
  final ora = adesso ?? DateTime.now();
  final dopo = ora.add(const Duration(days: 183));
  final scartoOra = ora.timeZoneOffset;
  final scartoDopo = dopo.toLocal().timeZoneOffset;
  try {
    final candidate = <String>[];
    for (final voce in tz.timeZoneDatabase.locations.entries) {
      final zona = voce.value;
      if (!voce.key.contains('/')) continue;
      final quiOra = zona.timeZone(ora.millisecondsSinceEpoch).offset;
      final quiDopo = zona.timeZone(dopo.millisecondsSinceEpoch).offset;
      if (quiOra != scartoOra) continue;
      if (quiDopo != scartoDopo) continue;
      candidate.add(voce.key);
    }
    if (candidate.isEmpty) return fusoDiRipiego;
    // **SI SCEGLIE SEMPRE LO STESSO NOME**, e non uno a caso fra gli
    // equivalenti: il telefono manda le scelte a ogni apertura, e un nome che
    // cambia farebbe riscrivere il documento tutte le volte senza che niente
    // sia cambiato davvero.
    candidate.sort();
    return candidate.first;
  } catch (errore) {
    debugPrint('Push: il fuso non si e ricavato. $errore');
    return fusoDiRipiego;
  }
}
