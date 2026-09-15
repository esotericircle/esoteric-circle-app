/// LA RIGA MAGRA DI UN RICORDO. Ordine CG voce 03.
///
/// **Cosa e' e cosa non e'.** E' la riga che dice CHE COSA e' successo e
/// QUANDO, e dove vive il contenuto vero. Non porta il contenuto: una
/// conversazione sta nei suoi turni su Firestore, un responso custodito sta
/// nel suo magazzino, un traguardo sta nel Diario. Qui c'e' il puntatore.
///
/// **Perche' magra, col numero.** Un Adepto che usa meta' del suo tetto fa
/// circa cinquanta voci al giorno, cioe' millecinquecento al mese. Se la riga
/// portasse il testo pieno, il documento del mese peserebbe megabyte e
/// aprirlo costerebbe quanto leggere l'anno intero. Il tetto dichiarato e'
/// [pesoMassimo] byte per riga, e una prova lo misura sul dato vero.
///
/// **Il titolo si tronca e non si allunga.** Sopra [quantiCaratteriDelTitolo]
/// caratteri il titolo si taglia: e' la sola parte di lunghezza libera, quindi
/// e' la sola che puo' sfondare il tetto. Il testo intero non si perde, sta
/// dove il riferimento porta.
library;

import 'dart:convert';

/// Di che natura e' un ricordo.
///
/// **Serve a due cose, e nessuna e' decorativa**: dice come si riapre la voce
/// (una conversazione si riapre al turno, un responso si ridisegna) e da quale
/// pastiglia la ricerca la filtra.
enum TipoDelRicordo {
  /// Un turno di conversazione con un Maestro.
  conversazione('c'),

  /// Un responso di un'arte, custodito col gesto oppure per condivisione.
  responso('r'),

  /// Un gesto compiuto: una gettata, una stesa, un Dono aperto.
  gesto('g'),

  /// Un traguardo del cammino che si e' acceso.
  traguardo('t'),

  /// Un movimento di Eos.
  movimento('m');

  const TipoDelRicordo(this.sigla);

  /// UNA LETTERA E NON IL NOME, e la ragione e' il peso.
  ///
  /// `conversazione` costa tredici byte per riga, `c` ne costa uno: su
  /// millecinquecento righe al mese sono diciotto chilobyte risparmiati per
  /// persona, cioe' il tetto della riga che regge invece di sfondare.
  final String sigla;

  static TipoDelRicordo? dallaSigla(String s) {
    for (final t in TipoDelRicordo.values) {
      if (t.sigla == s) return t;
    }
    return null;
  }
}

/// Una riga dell'indice dei Ricordi.
class VoceDelRicordo {
  VoceDelRicordo({
    required this.quando,
    required this.arte,
    required this.maestro,
    required String titolo,
    required this.tipo,
    this.riferimento,
  }) : titolo = _tronca(titolo);

  /// Quando e' successo, al minuto.
  final DateTime quando;

  /// L'identificativo dell'arte o del gesto: `tarot_spread_three`, `gettata`,
  /// `oroscopo`. E' la stessa parola che il Diario del Cammino gia' usa,
  /// perche' due nomi per la stessa arte sarebbero due conteggi.
  final String arte;

  /// L'identificativo del Maestro: `medora`, `aura`, `caligo`.
  ///
  /// **Sta sulla VOCE e non sulla giornata, ed e' una decisione del fondatore
  /// del 31 agosto 2026**: "e' probabile che ne usi piu' di uno e l'app spinge
  /// a usarli giornalmente tutti e tre". Un giorno non ha un colore.
  final String maestro;

  /// La domanda della persona, oppure il titolo del responso. Troncato.
  final String titolo;

  final TipoDelRicordo tipo;

  /// Dove vive il contenuto vero. Per una conversazione e' l'identificativo
  /// del turno su Firestore, per un responso quello del custodito. Nullo per
  /// i gesti che non hanno niente da riaprire.
  final String? riferimento;

  /// IL TETTO DI PESO DI UNA RIGA, in byte, dichiarato dall'ordine.
  static const int pesoMassimo = 200;

  /// Quanti caratteri del titolo si tengono.
  ///
  /// **Sessanta, e il numero viene dal tetto.** Le altre quattro parti di una
  /// riga hanno lunghezza limitata dal loro dominio: il tempo sta in otto
  /// cifre, l'arte nel piu' lungo dei nomi del catalogo, il Maestro in sei
  /// lettere, il tipo in una, il riferimento nei venti caratteri di un
  /// identificativo Firestore. Sommate con le virgolette del JSON fanno circa
  /// centoventi byte: sessanta caratteri di titolo, che in italiano valgono
  /// poco piu' di sessanta byte, tengono il totale sotto i duecento con
  /// margine, e una prova lo misura invece di crederci.
  static const int quantiCaratteriDelTitolo = 60;

  static String _tronca(String t) {
    final pulito = t.trim();
    if (pulito.length <= quantiCaratteriDelTitolo) return pulito;
    return pulito.substring(0, quantiCaratteriDelTitolo).trimRight();
  }

  /// LA CHIAVE DEL MESE, `AAAA-MM`.
  ///
  /// Con lo zero davanti al mese, cosi' l'ordine alfabetico e' l'ordine del
  /// tempo e nessuno deve riordinare dodici documenti dopo averli letti.
  static String chiaveDelMese(DateTime quando) =>
      '${quando.year.toString().padLeft(4, '0')}-'
      '${quando.month.toString().padLeft(2, '0')}';

  String get mese => chiaveDelMese(quando);

  /// LA CHIAVE DEL GIORNO dentro il mese, `AAAA-MM-GG`.
  static String chiaveDelGiorno(DateTime quando) =>
      '${chiaveDelMese(quando)}-${quando.day.toString().padLeft(2, '0')}';

  String get giorno => chiaveDelGiorno(quando);

  /// L'IDENTITA' DI UNA RIGA, e serve a fondere due apparecchi.
  ///
  /// **Perche' una riga ha un nome.** Se la persona usa il telefono e il
  /// tablet, tutti e due sincronizzano lo stesso mese. Se le righe fossero una
  /// lista, il secondo che scrive cancellerebbe le righe del primo. Con un
  /// nome per riga il documento del mese e' una MAPPA, si scrive con `merge` e
  /// i due apparecchi si sommano invece di sovrascriversi.
  ///
  /// **Il nome e' deterministico** e nasce dal minuto, dall'arte e dal
  /// riferimento: la stessa voce sincronizzata due volte da due apparecchi
  /// produce la stessa chiave e resta una riga sola.
  String get chiave {
    final minuti = quando.millisecondsSinceEpoch ~/ 60000;
    return '$minuti.$arte.${riferimento ?? tipo.sigla}';
  }

  /// LA FORMA TRASPORTABILE, con le chiavi di una lettera.
  ///
  /// I nomi lunghi (`quando`, `maestro`, `riferimento`) costerebbero da soli
  /// piu' del contenuto che introducono. Qui non li legge una persona, li
  /// legge il codice di questo file e nessun altro.
  Map<String, Object?> aMappa() => {
        'q': quando.millisecondsSinceEpoch ~/ 60000,
        'a': arte,
        'm': maestro,
        't': titolo,
        'k': tipo.sigla,
        if (riferimento != null) 'r': riferimento,
      };

  static VoceDelRicordo? daMappa(Object? grezzo) {
    if (grezzo is! Map) return null;
    final minuti = grezzo['q'];
    final arte = grezzo['a'];
    final maestro = grezzo['m'];
    final tipo = TipoDelRicordo.dallaSigla('${grezzo['k']}');
    if (minuti is! int || arte is! String || maestro is! String) return null;
    if (tipo == null) return null;
    final riferimento = grezzo['r'];
    return VoceDelRicordo(
      quando: DateTime.fromMillisecondsSinceEpoch(minuti * 60000),
      arte: arte,
      maestro: maestro,
      titolo: '${grezzo['t'] ?? ''}',
      tipo: tipo,
      riferimento: riferimento is String ? riferimento : null,
    );
  }

  /// QUANTO PESA DAVVERO QUESTA RIGA, in byte, misurata e non stimata.
  ///
  /// Si misura sulla forma che viaggia, cioe' il JSON con le chiavi corte,
  /// contando i byte della codifica UTF-8: un titolo con gli accenti pesa piu'
  /// dei suoi caratteri, e una misura che contasse i caratteri direbbe il
  /// falso proprio sull'italiano.
  int get peso => utf8.encode(jsonEncode(aMappa())).length;
}
