import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../core/rituals/avvisi_del_rito.dart';
import '../core/rituals/scelta_degli_avvisi.dart';
import 'avvisi_locali.dart';

/// LA REGIA DELLE CHIAMATE DEL GIORNO, in un punto solo. Ordine M voce 2.
///
/// Chi ha bisogno di riprogrammare le chiamate passa da qui: l'app all'avvio,
/// e l'Estrazione Rune quando l'ultima gettata del giorno si consuma. Due
/// chiamanti, una regia, cosi' i dati (carta, gettate, tramonto) si leggono
/// sempre allo stesso modo e la porta `programmaLeChiamateDelGiorno` resta
/// l'unica che decide cosa parte davvero.
class RegiaDelleChiamate {
  const RegiaDelleChiamate._();

  /// Riprogramma le chiamate coi dati veri del momento. Legge i provider dal
  /// contesto, quindi va chiamata quando l'albero e' vivo. Il `servizio` si
  /// inietta solo nelle prove: l'app vera usa `avvisiDelCerchio`.
  static Future<List<int>> riprogramma(
    BuildContext context, {
    ServizioAvvisi? servizio,
  }) async {
    final porta = servizio ?? avvisiDelCerchio;
    // Il permesso si guarda PRIMA di toccare i provider: senza permesso non
    // parte niente, e chi monta una scena senza tutto l'albero (le prove)
    // non paga letture che non servono. La porta lo ricontrolla comunque.
    // **LA SCELTA SI LEGGE PRIMA DELL'ATTESA.** Il contesto non si usa dopo
    // un `await`: dopo, l'albero puo' non esserci piu'.
    //
    // **E SI LEGGE CON PRUDENZA, che non e' pigrizia.** Questa regia la
    // chiamano tre punti: l'app all'avvio, il menu' delle notifiche, e
    // l'Estrazione Rune quando l'ultima gettata si consuma. **La prima
    // stesura la pretendeva dal contesto, e ha fatto cadere quarantina di
    // prove in famiglie che non c'entravano niente**, dalle rune al pozzo di
    // Urdhr: quelle schermate montano una parte sola dell'albero, e una
    // scelta che non si trova faceva morire il rito invece di programmare un
    // avviso in meno.
    //
    // Senza provider si legge il disco, che e' la verita' comunque: costa una
    // lettura in piu' solo dove il provider non c'e'.
    SceltaDegliAvvisi? scelta;
    try {
      scelta = context.read<SceltaDegliAvvisi>();
    } catch (senzaProvider) {
      scelta = null;
    }
    if (!porta.disponibile || !await porta.permessoConcesso()) {
      return const [];
    }

    // **LE CHIAMATE DI PRIMA SI SPENGONO, UNA PER UNA.** Ordine BC voce 05.
    //
    // Su un telefono che aggiorna l'app, le tre chiamate vecchie sono gia' in
    // coda dentro il sistema: nessuno le annulla da solo, e resterebbero a
    // suonare accanto alle cinque nuove. Si spengono a nome, per id, una volta
    // per avvio: costa quattro chiamate e vale un anno di avvisi fantasma.
    for (final vecchio in AvvisiDelRito.idDelleChiamateDiPrima) {
      await porta.annulla(vecchio);
    }

    scelta ??= SceltaDegliAvvisi();
    if (!scelta.caricata) await scelta.carica();

    // **L'ORA ANCORATA PER TUTTI E CINQUE, e l'alba vera la mette il rito.**
    //
    // Qui non c'e' la posizione: quella la conosce il Rito dell'Alba, che la
    // chiede quando qualcuno lo apre. La regia programma le cinque chiamate
    // alle ore che i Doni portano scritte dentro; poi, alla prima apertura
    // del rito, `programmaProssimo` rimette quella dell'Alba **sullo stesso
    // id** e sul sorgere vero del luogo. Due porte, un id, nessun doppione.
    return AvvisiDelRito.programmaLeChiamateDelGiorno(
      servizio: porta,
      adesso: DateTime.now(),
      doniAccesi: scelta.quelliCheChiamano,
      // **E ALL'ORA CHE LA PERSONA HA SCELTO.** Ordine BC voce 05, coda:
      // "l'utente deve poter cambiare anche l'orario di ogni notifica".
      oreScelte: {
        for (final d in scelta.quelliCheChiamano) d: scelta.minutiDi(d),
      },
    );
  }
}
