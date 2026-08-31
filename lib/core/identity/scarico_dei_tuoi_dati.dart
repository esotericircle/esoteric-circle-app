import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'dimenticanza_del_telefono.dart';
import 'cio_che_e_tuo.dart';

/// SCARICA I TUOI DATI. Ordine BC voce 02, seconda delle quattro voci.
///
/// **Decisione del fondatore**: fra le quattro voci dell'account c'e'
/// "Scarica i tuoi dati", e la forma scelta e' **un file coi dati piu' un
/// riepilogo scritto in italiano**: chi lo apre deve capire cosa ha in mano,
/// invece di trovarsi davanti delle parentesi graffe.
///
/// **PERCHE' SI LEGGE DAL DISCO E NON DAI CONTROLLER.** I controller tengono
/// cio' che questa sessione ha caricato, che puo' essere meno di quello che
/// c'e' scritto: chi apre l'app e va dritto alle impostazioni non ha ancora
/// fatto caricare il diario ne' il registro degli Eos. **Il disco e' la
/// verita'**, e le chiavi sono le stesse che la cancellazione dimentica.
///
/// **E NON SI INVENTA NIENTE.** Quello che il telefono non ha, non compare:
/// un archivio che dichiara campi vuoti fa credere di avere risposto a una
/// domanda a cui non ha risposto.
/// **QUANTI GIORNI DI RIPENSAMENTO PRIMA CHE L'OBLIO SIA DEFINITIVO.**
/// Ordine BC voce 02.
///
// **I TRENTA GIORNI NON ESISTONO PIU', ordine BE voce 07**: la costante
// che li dichiarava e' stata rimossa con la regola, per decisione del
// fondatore. La cancellazione e' immediata e totale.

class ScaricoDeiTuoiDati {
  const ScaricoDeiTuoiDati._();

  /// La versione del formato: se un giorno cambia, chi ha vecchi archivi sa
  /// cosa sta leggendo.
  static const int versione = 1;

  /// **I GRUPPI IN CUI SI RACCOLGONO LE CHIAVI**, col nome che una persona
  /// riconosce. Sono i prefissi che la dimenticanza usa gia': tenerli
  /// allineati vuol dire che **cio' che si puo' scaricare e' esattamente cio'
  /// che si puo' cancellare**, e nessuna delle due liste puo' invecchiare per
  /// conto suo.
  static const gruppi = <String, String>{
    'profile.': 'Il tuo profilo',
    'account.': 'Il tuo account',
    'cammino.': 'Il tuo cammino',
    'sigilli.': 'I tuoi Sigilli',
    'borsellino.': 'I tuoi Eos',
    'allowance.': 'Cosa hai usato oggi',
    'archetipo.': 'Il tuo Archetipo',
    'rituale.': 'I tuoi riti',
    'santuario.': 'Il Santuario',
    'onboarding.': 'Il tuo ingresso nel Cerchio',
    // **I DUE GRUPPI NUOVI DELL'ORDINE BX VOCE 11.** Il quaderno dei sogni e
    // lo storico delle letture del viso si cancellano con tutto il resto:
    // devono anche potersi scaricare, perche' l'ordine BC voce 02 dice che
    // non si scarica meno di quello che si cancella. Il quaderno e' la
    // memoria piu' privata che questa app custodisca, e chi la scrive ha
    // diritto di riaverla.
    'sogni.': 'Il tuo quaderno dei sogni',
    'viso.': 'Le tue letture del viso',
    // **E I DIECI GRUPPI DELL'ORDINE BZ VOCE 01.** Lo scarico costruiva il
    // proprio elenco dalla lista della cancellazione, quindi cio' che non si
    // cancellava non si scaricava nemmeno: dieci famiglie di dati esistevano
    // sul telefono e non comparivano ne' nell'oblio ne' nell'archivio che la
    // persona chiede.
    'arti_preferite': 'Le arti che hai messo fra le preferite',
    'avvisi.': 'Gli avvisi che ti sono stati proposti',
    'carta.natale': 'La tua carta natale conservata',
    'carta_natale_': 'La tua carta natale, nella forma vecchia',
    'cielo_posizione': 'Il permesso di posizione per il cielo',
    'filo.': 'Il filo del giorno',
    'luogo.': 'Dove sei adesso',
    'natal.': 'La tua carta natale dal Cerchio',
    'oroscopo_': 'Le tue letture dell\'Oroscopo',
    'permesso.': 'Quali permessi ti sono già stati chiesti',
    'ricordi.': 'L\'indice dei tuoi Ricordi del Cerchio',
    'ritual.': 'Le serie dei tuoi riti',
    'sentiero.': 'Le mappe dei sentieri che hai aperto',
    'sinastria.': 'Le coppie che hai scoperto',
    'maestro.': 'Quali benvenuti ti hanno già detto i Maestri',
    'sunset_rune': 'Le tue Rune del Tramonto',
    'device.id': 'L\'identità di questo dispositivo',
  };

  /// **IL GRUPPO DI CHI NON HA UN NOME, e non e' un dettaglio.** Ordine BZ
  /// voce 01: se domani nasce una chiave che appartiene alla persona e
  /// nessuno le da' un nome qui, finisce comunque nell'archivio, sotto questo
  /// gruppo. **Lo scarico non puo' perdere niente per una dimenticanza di
  /// prosa**, e la prova che legge il codice dira' subito che manca il nome.
  static const String gruppoSenzaNome = 'Altri tuoi dati';

  /// Tutto cio' che il telefono sa di te, in un albero.
  static Future<Map<String, Object?>> raccogli() async {
    final dentro = <String, Map<String, Object?>>{};
    var quante = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final chiave in prefs.getKeys()) {
        final gruppo = _gruppoDi(chiave);
        if (gruppo == null) continue;
        dentro.putIfAbsent(gruppo, () => {})[chiave] = prefs.get(chiave);
        quante++;
      }
    } catch (discoMuto) {
      // Un disco che non risponde da' un archivio vuoto, non un errore in
      // faccia: chi voleva i suoi dati riprova, e intanto l'app sta in piedi.
    }
    return {
      'formato': 'esoteric-circle/dati-personali',
      'versione': versione,
      'quando': DateTime.now().toIso8601String(),
      'quanteVoci': quante,
      'dati': dentro,
    };
  }

  static String? _gruppoDi(String chiave) {
    // Il prefisso piu' lungo vince: `carta_natale_` e `carta.natale` non si
    // rubano le chiavi a vicenda, e un gruppo piu' preciso batte uno generico.
    String? scelto;
    var lunghezza = -1;
    for (final voce in gruppi.entries) {
      if (chiave.startsWith(voce.key) && voce.key.length > lunghezza) {
        scelto = voce.value;
        lunghezza = voce.key.length;
      }
    }
    if (scelto != null) return scelto;
    // **CIO' CHE E' TUO ENTRA COMUNQUE.** Ordine BZ voce 01: la verita' unica
    // dice se una chiave e' della persona, e se lo e' si consegna, col nome
    // che ha o senza.
    if (CioCheETuo.eTua(chiave)) return gruppoSenzaNome;
    return null;
  }

  /// L'archivio in JSON, scritto largo perche' si possa leggere.
  static String comeJson(Map<String, Object?> albero) =>
      const JsonEncoder.withIndent('  ').convert(albero);

  /// **IL RIEPILOGO IN ITALIANO, che e' la meta' che serve alla persona.**
  ///
  /// Un file di dati risponde alla domanda "cosa avete di me" solo a chi sa
  /// leggerlo. Questo dice le stesse cose a parole: quanti dati ci sono, come
  /// sono raggruppati, e **cosa NON c'e' dentro**, che e' l'informazione che
  /// nessun archivio si ricorda mai di dare.
  static String comeRiepilogo(Map<String, Object?> albero) {
    final dati = (albero['dati'] as Map?) ?? {};
    final righe = StringBuffer()
      ..writeln('I TUOI DATI NEL CERCHIO')
      ..writeln('')
      ..writeln('Preparato il ${_dataItaliana(DateTime.now())}.')
      ..writeln('')
      ..writeln('Questo archivio contiene tutto ciò che Esoteric Circle '
          'tiene di te su questo telefono: ${albero['quanteVoci']} voci in '
          'tutto, raccolte qui sotto per argomento. Il file che lo accompagna '
          'porta gli stessi dati in forma leggibile da un programma.')
      ..writeln('');
    for (final gruppo in gruppi.values) {
      final dentro = dati[gruppo];
      if (dentro is! Map || dentro.isEmpty) continue;
      righe.writeln('${gruppo.toUpperCase()} (${dentro.length} voci)');
      for (final v in dentro.entries) {
        righe.writeln('  ${v.key}: ${_leggibile(v.value)}');
      }
      righe.writeln('');
    }
    righe
      ..writeln('COSA NON C\'È QUI DENTRO')
      ..writeln('')
      ..writeln('La memoria che i Maestri tengono delle vostre conversazioni '
          'vive sul server e non su questo telefono, quindi non compare in '
          'questo archivio. Puoi farla cancellare dalla voce "Cancella i tuoi '
          'dati" del menu Account.')
      ..writeln('')
      ..writeln('Non ci sono le tue password: il Cerchio non le vede mai, le '
          'custodisce chi ti fa entrare, Google o Apple o la tua email.');
    return righe.toString();
  }

  static String _leggibile(Object? valore) {
    if (valore == null) return 'niente';
    if (valore is List) return valore.join(', ');
    final testo = '$valore';
    // Le stringhe lunghe sono quasi sempre JSON: si dichiara la misura invece
    // di rovesciare tremila caratteri dentro un riepilogo che deve leggersi.
    if (testo.length > 120) return '${testo.length} caratteri, nel file JSON';
    return testo;
  }

  static String _dataItaliana(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  /// **I GRUPPI COPRONO CIO' CHE LA CANCELLAZIONE DIMENTICA.**
  ///
  /// Se un domani si aggiungesse un prefisso alla dimenticanza senza
  /// aggiungerlo qui, ci sarebbe un dato che l'app cancella e non sa
  /// mostrare: la prova `test/scaricare_i_tuoi_dati_test.dart` confronta le
  /// due liste e cade col nome del prefisso che manca.
  static List<String> prefissiScoperti() => DimenticanzaDelTelefono
      .prefissiDaDimenticare
      .where((p) => !gruppi.containsKey(p))
      .toList();
}
