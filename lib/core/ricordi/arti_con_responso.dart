/// LE ARTI CHE PRODUCONO UN RESPONSO. Ordine CG voci 06, 07 e 08.
///
/// **Perche' questo censimento esiste.** Tre voci di questo ordine chiedono la
/// stessa cosa a tutte le arti: che ognuna offra CUSTODISCI accanto a
/// Condividi, che ognuna finisca nella griglia delle Carte, e che ognuna porti
/// il pulsante che apre la chat col suo Maestro col responso gia' dentro. Tre
/// pretese sulla stessa lista, e la lista non esisteva: viveva sparsa in
/// quattordici schermate, quindi nessuno poteva dire quante fossero.
///
/// **Il fondatore ha scritto "quasi ogni funzionalita'", e "quasi" non e' un
/// numero.** Qui diventa un numero, e le eccezioni portano la loro ragione
/// scritta invece di essere assenze silenziose.
///
/// **Cosa NON e' un'arte con responso.** La meditazione non produce un
/// responso, produce un tempo passato; lo Scarico dei dati e la Celebrazione
/// di un traguardo condividono qualcosa che responso non e'. Sono dichiarati
/// qui sotto, non dimenticati.
library;

/// Un'arte che produce un responso, e cosa quel responso deve offrire.
class ArteConResponso {
  const ArteConResponso({
    required this.arte,
    required this.maestro,
    required this.titolo,
    required this.doveViveIlResponso,
    required this.apertura,
    this.perche,
  });

  /// L'identificativo dell'arte o del Dono: la stessa parola di
  /// `ContiDelleArti`, perche' due nomi per la stessa arte sarebbero due
  /// conteggi.
  final String arte;

  /// Il Maestro proprietario dell'arte, che e' quello con cui si parla.
  final String maestro;

  /// Come si chiama a video, per le Carte e per la timeline.
  final String titolo;

  /// Il file dove il responso si mostra e dove le tre azioni devono stare.
  /// Una prova apre questo file e verifica che ci siano.
  final String doveViveIlResponso;

  /// Il nome del metodo di `ChatOpeners` che compone la prima domanda, cioe'
  /// il modo con cui il responso ENTRA nella conversazione.
  ///
  /// **Non e' un dettaglio di comodo**: l'ordine chiede che il responso entri
  /// nel contesto del primo turno, non che si apra una chat vuota. Senza una
  /// riga qui, il pulsante ci sarebbe e la persona dovrebbe raccontare al
  /// Maestro cosa ha appena letto.
  final String apertura;

  /// Una nota, quando quest'arte ha qualcosa di suo da dichiarare.
  final String? perche;
}

/// Qualcosa che si condivide e responso non e', dichiarato invece che omesso.
class CondivideSenzaResponso {
  const CondivideSenzaResponso({required this.dove, required this.perche});

  final String dove;
  final String perche;
}

class ArtiConResponso {
  const ArtiConResponso._();

  /// L'elenco, arte per arte.
  static const List<ArteConResponso> tutte = [
    ArteConResponso(
      arte: 'oroscopo',
      maestro: 'medora',
      titolo: 'Oroscopo',
      doveViveIlResponso: 'lib/features/horoscope/oroscopo_screen.dart',
      apertura: 'oroscopo',
    ),
    ArteConResponso(
      arte: 'stesa',
      maestro: 'medora',
      titolo: 'Stesa di Tarocchi',
      doveViveIlResponso: 'lib/features/tarot/stesa_tre_carte_screen.dart',
      apertura: 'stesa',
    ),
    ArteConResponso(
      arte: 'sinastria',
      maestro: 'medora',
      titolo: 'Sinastria VIP',
      doveViveIlResponso: 'lib/features/synastry/sinastria_vip_screen.dart',
      apertura: 'sinastria',
    ),
    ArteConResponso(
      arte: 'archetipo',
      maestro: 'aura',
      titolo: 'Test Archetipo',
      doveViveIlResponso:
          'lib/features/maestri/aura/archetype/archetype_test_screen.dart',
      apertura: 'archetipo',
    ),
    ArteConResponso(
      arte: 'viso',
      maestro: 'aura',
      titolo: 'Costellazione del Viso',
      doveViveIlResponso:
          'lib/features/maestri/aura/face/face_constellation_screen.dart',
      apertura: 'viso',
    ),
    ArteConResponso(
      arte: 'gettata',
      maestro: 'caligo',
      titolo: 'Estrazione Rune',
      doveViveIlResponso:
          'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
      apertura: 'runa',
    ),
    ArteConResponso(
      arte: 'animale_guida',
      maestro: 'caligo',
      titolo: 'Animale Guida',
      doveViveIlResponso:
          'lib/features/maestri/caligo/animal/guide_animal_screen.dart',
      apertura: 'animale',
    ),
    ArteConResponso(
      arte: 'sigillo',
      maestro: 'caligo',
      titolo: 'Sigillo dell\'Intenzione',
      doveViveIlResponso:
          'lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart',
      apertura: 'sigillo',
      perche: 'NON HA UN CONDIVIDI. Non è una dimenticanza: il Sigillo '
          'non produce una carta da mandare, produce un segno tracciato col '
          'dito. Inventargli un\'immagine da condividere sarebbe una '
          'funzione nuova e non questa voce. Custodisci e Parlane ci sono, '
          'perché quelli non hanno bisogno di un\'immagine.',
    ),
    // --- I CINQUE DONI DEL GIORNO -------------------------------------
    // Non sono arti dello scaffale, ma un responso lo producono eccome, ed e'
    // quello che una persona vede piu' spesso di ogni altro.
    ArteConResponso(
      arte: 'alba',
      maestro: 'medora',
      titolo: 'Rito dell\'Alba',
      doveViveIlResponso: 'lib/features/rituals/dawn_rite_screen.dart',
      apertura: 'alba',
    ),
    ArteConResponso(
      arte: 'soffio',
      maestro: 'aura',
      titolo: 'Soffio del Destino',
      doveViveIlResponso: 'lib/features/rituals/breath_destiny_screen.dart',
      apertura: 'soffio',
    ),
    ArteConResponso(
      arte: 'oracolo',
      maestro: 'medora',
      titolo: 'Arcano del Giorno',
      doveViveIlResponso: 'lib/features/rituals/day_oracle_screen.dart',
      apertura: 'oracolo',
      perche: 'NON HA UN CONDIVIDI. Non è una dimenticanza: l\'artwork '
          'del mazzo è arte del Cerchio e non un responso della persona, '
          'quindi non c\'è una carta sua da mandare. Custodisci e Parlane '
          'ci sono.',
    ),
    ArteConResponso(
      arte: 'tramonto',
      maestro: 'caligo',
      titolo: 'Runa del Tramonto',
      doveViveIlResponso: 'lib/features/rituals/sunset_rune_screen.dart',
      apertura: 'runaTramonto',
    ),
    ArteConResponso(
      arte: 'sogno',
      maestro: 'caligo',
      titolo: 'Rito della Notte',
      doveViveIlResponso: 'lib/features/rituals/dream_rite_screen.dart',
      apertura: 'sogno',
    ),
  ];

  /// **CHI CONDIVIDE SENZA PRODURRE UN RESPONSO**, dichiarato per nome.
  ///
  /// Sono i punti che chiamano `PortaDellaCondivisione` e che una guardia
  /// troverebbe cercando chi condivide: senza questa dichiarazione sembrerebbe
  /// che a tre arti manchi il Custodisci.
  static const List<CondivideSenzaResponso> condividonoAltro = [
    CondivideSenzaResponso(
      dove: 'lib/features/sigilli/celebrazione.dart',
      perche: 'condivide un TRAGUARDO acceso, non un responso. Il traguardo '
          'vive già per sempre nel Diario del Cammino e nella mappa dei '
          'sentieri: custodirlo una seconda volta sarebbe un secondo '
          'magazzino della stessa cosa.',
    ),
    CondivideSenzaResponso(
      dove: 'lib/features/identity/circle_seal_screen.dart',
      perche: 'condivide il Sigillo del Cerchio, che è l\'identità della '
          'persona e non un responso: non nasce da una domanda e non cambia '
          'da un giorno all\'altro.',
    ),
    CondivideSenzaResponso(
      dove: 'lib/features/santuario/sky_overview_screen.dart',
      perche: 'condivide la veduta del cielo di adesso, che è un dato '
          'astronomico e non una lettura: il cielo di stasera lo può '
          'ridisegnare chiunque in qualunque momento, quindi non c\'è '
          'niente da custodire.',
    ),
    CondivideSenzaResponso(
      dove: 'lib/features/account/account_screen.dart',
      perche: 'è lo scarico dei tuoi dati, che manda dei file e non un '
          'responso.',
    ),
  ];

  /// **LE ARTI VIVE CHE UN RESPONSO NON LO PRODUCONO.**
  static const Map<String, String> senzaResponso = {
    'meditation': 'la meditazione non produce un responso, produce un tempo '
        'passato: non c\'è nessun testo da custodire né da portare in chat. '
        'Un pulsante che promettesse di parlarne aprirebbe una conversazione '
        'su niente.',
  };

  static ArteConResponso? di(String arte) {
    for (final a in tutte) {
      if (a.arte == arte) return a;
    }
    return null;
  }

  static List<ArteConResponso> delMaestro(String maestro) =>
      tutte.where((a) => a.maestro == maestro).toList(growable: false);
}
