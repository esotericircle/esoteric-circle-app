import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE MEMORIE CHE TORNANO COL TUO ACCOUNT.** Ordine EV, il fondatore il 1
/// ottobre 2026, dopo una reinstallazione: *"non mi ha riaccreditato [...] gli
/// storici del dono "runa del tramonto". Avevo già accumulato 5 [...] e
/// adesso devo ricominciare da 1 [...] Se c'è una tipologia di problema,
/// probabilmente c'è lo stesso problema con altre funzionalità, per logica.
/// È tuo compito controllare dipendenze simili!"*
///
/// **Il fatto, contato.** Il Cerchio custodiva il cammino, i Sigilli,
/// l'identita', l'archetipo, l'Alba e il Viaggio, ognuno con una porta
/// scritta a mano; tutte le altre memorie della persona (le famiglie qui
/// sotto, il censimento sta nel rapporto dell'ordine EV) vivevano solo sul
/// telefono e sparivano con l'app.
///
/// **Una porta sola per tutte**, come il Viaggio (`IlViaggioCustodito`): le
/// chiavi si copiano com'erano, famiglia per famiglia, e il Cerchio le fonde
/// senza perdere niente (`functions/src/memorie.ts`: liste unite, numeri al
/// piu' alto, JSON uniti in profondita'). Al ritorno si riscrivono sul
/// telefono: e' gia' la fusione, quindi non toglie niente a nessuno.
///
/// **Una famiglia nuova si aggiunge qui** e torna da sola; una memoria che non
/// deve tornare (un permesso gia' chiesto, una cache, l'identita' del
/// telefono) non si aggiunge, e la prova
/// `test/le_memorie_tornano_col_tuo_account_test.dart` pretende che ogni
/// prefisso di `CioCheETuo.prefissi` sia o qui, o in una porta dedicata, o
/// dichiarato come memoria del telefono con la sua ragione.
abstract final class LeMemorieCustodite {
  /// Famiglia -> prefissi delle chiavi. Il nome della famiglia e' quello che
  /// il Cerchio vede.
  static const Map<String, List<String>> famiglie = {
    // Le sere della Runa del Tramonto e la cerniera col Sigillo del Sogno: il
    // caso del fondatore, cinque sere tornate a una.
    'tramonto': ['sunset_rune'],
    // Le serie dell'Alba e del Soffio del Destino.
    'riti': ['ritual.'],
    // Cio' che il diario del cammino non mandava: l'ultimo giorno di ogni
    // rito (senza, la serie che torna dal Cerchio si vede a 1), i giorni per
    // rito, i dettagli e l'ora fedele verso i traguardi non ancora accesi.
    'cammino': [
      'cammino.ultimoPerRito',
      'cammino.giorniPerRito',
      'cammino.dettagli',
      'cammino.oraDelGesto',
      'cammino.ultimoGiornoPerOra',
      'cammino.ultimoPerSentiero',
      'cammino.ultimoGiorno',
    ],
    // Il Libro dei Sigilli dell'intenzione.
    'sigilli': ['sigilli.'],
    // I posti per gli amici comprati con gli Eos (gli amici no: vedi
    // `delTelefono`).
    'amici': ['amici_offline_posti'],
    // Le coppie della Sinastria scoperte (riaprirle non consuma).
    'sinastria': ['sinastria.'],
    // Cio' che si e' comprato con gli Eos nell'Oroscopo, i giorni del
    // Sigillo dei Tre Cieli e le rivelazioni del segno gia' viste.
    'oroscopo': [
      'oroscopo_annuale_aperti',
      'oroscopo_lunga_comprata_il',
      'oroscopo_tre_cieli',
      'oroscopo_segno_rivelato',
      'oroscopo_testa_rivelata',
    ],
    // Le prose del mese del Cosmic Journal, che si pagano.
    'letture': ['ricordi.lettureDelMese'],
    // Il Loto, le sessioni di respiro e le sequenze costruite con Aura.
    'loto': ['loto.'],
    // I titoli delle conversazioni coi Maestri.
    'titoli': ['chat.titoli.'],
    // Gli orari scelti per gli avvisi dei Doni.
    'avvisi_scelti': ['rituale.'],
    // Il verso dell'animale, una volta nella vita.
    'verso': ['viaggio.verso.udito'],
    // Le voci del presagio delle rune lette negli ultimi sessanta giorni, e
    // l'identificativo che ne semina l'ordine: senza, un telefono nuovo
    // ripeterebbe voci gia' lette. Ordine EX voce 03. Chi getta il telo al
    // massimo ogni giorno puo' superare il peso di una famiglia (60.000
    // caratteri): allora il Cerchio tiene quella di prima.
    'rune': ['rune.presagio.'],
  };

  /// I prefissi di `CioCheETuo` che tornano con una porta loro, e quale.
  static const Map<String, String> conUnaPortaSua = {
    'arcano_alba.': 'il diario dell\'Alba, ArchivioDellAlba.adottaDalCerchio',
    'arti_preferite': 'le arti preferite, nel cammino',
    'cammino.': 'il diario del cammino, adottaIlCammino; le chiavi che '
        'mancavano viaggiano nella famiglia "cammino" di queste memorie',
    'profile.': 'il nome, la forma e la nascita, nell\'identità del '
        'cammino',
    'viaggio.': 'il Viaggio dello Sciamano, IlViaggioCustodito',
    'ricordi.': 'i Ricordi e le Carte custodite hanno la loro porta sul '
        'server (RegistroDeiRicordi.riprendiDalCerchio, '
        'ScrignoDeiCustoditi.riprendiDalServer); le prose del mese '
        'viaggiano nella famiglia "letture"',
    'allowance.': 'il saldo e i consumi stanno sul server, statoDelCerchio',
    'borsellino.': 'i movimenti degli Eos stanno sul server',
    'oroscopo_': 'gli acquisti, i Tre Cieli e le rivelazioni viaggiano '
        'nella famiglia "oroscopo"; l\'attesa piena di oggi resta del giorno',
  };

  /// I prefissi di `CioCheETuo` che restano del telefono, con la ragione.
  static const Map<String, String> delTelefono = {
    'account.': 'i rimandi e l\'ultimo invito a registrarsi, di questo '
        'telefono',
    'avvisi.': 'quali avvisi e permessi sono già stati chiesti su questo '
        'telefono: un telefono nuovo deve chiederli di nuovo',
    'avviso_dono_': 'gli avvisi programmati sul sistema di questo telefono',
    'carta.natale': 'la carta natale in cache, che si ricalcola dalla '
        'nascita',
    'carta_natale_': 'la forma vecchia della cache della carta natale',
    'natal.': 'la carta natale in cache, che si ricalcola',
    'chat.responsi_di_oggi': 'i responsi del giorno, che domani non valgono',
    'cielo_posizione': 'il permesso della posizione, di questo telefono',
    'filo.': 'la domanda e la parola del giorno, che domani cambiano',
    'luogo.': 'dove si trova questo telefono adesso',
    'onboarding.': 'l\'ingresso fatto, che il ritrovamento ricostruisce',
    'permesso.': 'i permessi chiesti su questo telefono',
    'santuario.': 'il saluto della home, una cosa della schermata',
    'sentiero.': 'quali mappe sono già state viste su questo telefono',
    'maestro.': 'la rotazione dei saluti dei Maestri, una cosa della '
        'schermata',
    'chat.cancellate.': 'le conversazioni in attesa che il server le tolga',
    'ingresso.': 'l\'indirizzo a cui questo telefono ha mandato il link',
    'arti_del_giorno.': 'le arti aperte oggi, per il puntino d\'oro',
    'push.': 'il gettone delle notifiche di questo telefono',
    'sogni.': 'prefisso senza chiavi: oggi nessuna memoria lo scrive',
    'device.id': 'l\'identità di questo telefono',
    'settings.': 'com\'è regolato questo telefono',
    'app_check_debug_token': 'il gettone di prova di App Check',
    // **TRE MEMORIE CHE RESTANO PER UNA PROMESSA SCRITTA**, ordine EV: la
    // schermata degli amici dice "I dati restano sul tuo telefono" e la
    // pagina della privacy dice che le letture del viso e lo storico
    // dell'Archetipo restano sul telefono. Farle viaggiare e' una decisione
    // del fondatore, insieme al testo che la dice.
    'amici_offline': 'gli amici, con nomi e nascite di altre persone: la '
        'schermata promette che restano sul telefono (i posti comprati '
        'invece viaggiano, famiglia "amici")',
    'viso.': 'le letture del viso: la privacy dice che restano sul telefono',
    'archetipo.': 'lo storico per esteso: la privacy dice che resta sul '
        'telefono; il dominante e il giorno tornano col cammino',
  };

  /// Quante volte e' stata riscritta una famiglia dal Cerchio: le prove lo
  /// leggono.
  static int adozioni = 0;

  static String? _famigliaDi(String chiave) {
    for (final voce in famiglie.entries) {
      for (final p in voce.value) {
        if (chiave.startsWith(p)) return voce.key;
      }
    }
    return null;
  }

  static Map<String, Object?>? _valore(Object? v) {
    if (v is String) return {'t': 's', 'v': v};
    if (v is bool) return {'t': 'b', 'v': v};
    if (v is int) return {'t': 'i', 'v': v};
    if (v is double) return {'t': 'd', 'v': v};
    if (v is List)
      return {
        't': 'l',
        'v': [for (final x in v) '$x']
      };
    return null;
  }

  /// Le memorie del telefono come le riceve il Cerchio, o null se non c'e'
  /// niente.
  static Future<Map<String, Object?>?> daCustodire() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fuori = <String, Map<String, Object?>>{};
      for (final chiave in prefs.getKeys()) {
        final famiglia = _famigliaDi(chiave);
        if (famiglia == null) continue;
        final v = _valore(prefs.get(chiave));
        if (v == null) continue;
        (fuori[famiglia] ??= {})[chiave] = v;
      }
      return fuori.isEmpty ? null : fuori;
    } catch (errore) {
      debugPrint('Memorie custodite: il telefono non si legge. $errore');
      return null;
    }
  }

  /// Riscrive sul telefono le memorie che il Cerchio ha fuso. Torna le
  /// famiglie che sono cambiate.
  static Future<Set<String>> adottaDalCerchio(Map<String, Object?>? dal) async {
    final cambiate = <String>{};
    if (dal == null || dal.isEmpty) return cambiate;
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final voce in dal.entries) {
        if (!famiglie.containsKey(voce.key)) continue;
        final chiavi = voce.value;
        if (chiavi is! Map) continue;
        for (final c in chiavi.entries) {
          final chiave = '${c.key}';
          if (_famigliaDi(chiave) != voce.key) continue;
          final v = c.value;
          if (v is! Map) continue;
          final t = v['t'];
          final valore = v['v'];
          final prima = prefs.get(chiave);
          switch (t) {
            case 's' when valore is String:
              if (prima != valore) {
                await prefs.setString(chiave, valore);
                cambiate.add(voce.key);
              }
            case 'b' when valore is bool:
              if (prima != valore) {
                await prefs.setBool(chiave, valore);
                cambiate.add(voce.key);
              }
            case 'i' when valore is num:
              if (prima != valore.toInt()) {
                await prefs.setInt(chiave, valore.toInt());
                cambiate.add(voce.key);
              }
            case 'd' when valore is num:
              if (prima != valore.toDouble()) {
                await prefs.setDouble(chiave, valore.toDouble());
                cambiate.add(voce.key);
              }
            case 'l' when valore is List:
              final lista = [for (final x in valore) '$x'];
              if (!listEquals(
                  prima is List ? prima.cast<String>() : null, lista)) {
                await prefs.setStringList(chiave, lista);
                cambiate.add(voce.key);
              }
          }
        }
      }
    } catch (errore) {
      debugPrint('Memorie custodite: il telefono non si scrive. $errore');
    }
    if (cambiate.isNotEmpty) adozioni++;
    return cambiate;
  }
}
