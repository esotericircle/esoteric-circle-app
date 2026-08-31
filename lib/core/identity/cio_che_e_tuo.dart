/// CIO' CHE E' TUO, in un posto solo. Ordine BZ voce 01.
///
/// **Perche' esiste, e perche' non poteva esistere prima.** L'app aveva DUE
/// verita' su cosa appartiene a una persona, e non coincidevano: una lista in
/// `DimenticanzaDelTelefono` con dodici prefissi, un'altra in `ProfileStore`
/// con sette prefissi e una chiave, e un elenco per lo scarico dei dati
/// costruito dalla prima. La via dell'Account cancellava secondo la prima, la
/// via delle Impostazioni secondo la seconda, e **le due promettevano alla
/// persona la stessa cosa**: tutto il tuo cammino. Chi cancellava dalle
/// Impostazioni si teneva il cammino, il borsellino, i Sigilli, i sogni, le
/// letture del viso e l'ingresso nel Cerchio.
///
/// **Un elenco a mano e' fallito due volte**, con l'ordine BE voce 07 che
/// trovo' otto chiavi scoperte e con l'ordine BX voce 11 che ne trovo' altre
/// due. Non fallisce perche' chi lo scrive e' distratto: fallisce perche' una
/// funzione nuova nasce con la sua memoria e nessuno, scrivendola, pensa a
/// una lista che sta in un altro file. **La cura non e' un elenco piu' lungo,
/// e' una prova che legge il codice e trova da sola le chiavi nuove**:
/// `test/niente_resta_di_te_test.dart` cerca ogni chiave che l'app scrive e
/// pretende che una di queste righe la copra.
///
/// **Le voci sono PREFISSI, e si confrontano con `startsWith`.** Una chiave
/// nuova che comincia per `cammino.` e' gia' coperta il giorno che nasce.
class CioCheETuo {
  const CioCheETuo._();

  /// **TUTTO CIO' CHE PARLA DELLA PERSONA e se ne va con lei.**
  ///
  /// L'ordine non conta, ma l'elenco e' alfabetico perche' si legga.
  static const List<String> prefissi = <String>[
    // L'account, i rimandi della custodia e l'ultimo invito a custodire.
    'account.',
    // Cosa hai usato oggi, il saldo degli Eos, la coda dei consumi.
    'allowance.',
    // Il tuo Archetipo e il suo storico.
    'archetipo.',
    // Le arti che hai messo fra le preferite. **Senza il punto**: la chiave
    // vera si chiama `arti_preferite_v1`, e un prefisso col punto non la
    // avrebbe mai toccata.
    'arti_preferite',
    // Se ti e' gia' stato chiesto di essere avvisato per un dono.
    'avvisi.',
    // Il registro dei movimenti degli Eos.
    'borsellino.',
    // Il diario del cammino: gesti, giorni, ore, dettagli, feste in attesa.
    'cammino.',
    // La carta natale conservata. **Due forme, e la seconda e' un debito
    // vecchio**: `carta.natale` e' quella di oggi, `carta_natale_` e' la
    // vecchia, il cui NOME portava in chiaro data, ora, minuto, latitudine,
    // longitudine e fuso della nascita. Non esiste piu' (vedi
    // `ArchivioCarta`), ma il prefisso resta perche' i telefoni che l'hanno
    // scritta la cancellino al primo oblio.
    'carta.natale',
    'carta_natale_',
    // Se hai concesso la posizione al cielo di sopra.
    'cielo_posizione',
    // Il filo del giorno: la domanda di Medora e la parola del giorno.
    'filo.',
    // Dove sei adesso, che e' un dato di posizione.
    'luogo.',
    // La carta natale calcolata dal server, conservata sul telefono.
    'natal.',
    // Che l'ingresso nel Cerchio e' stato fatto.
    'onboarding.',
    // La riflessione piena dell'Oroscopo, che e' un testo tuo.
    'oroscopo_',
    // Quali permessi ti sono gia' stati chiesti.
    'permesso.',
    // Il profilo: nome, data, ora e luogo di nascita, fotografia del volto.
    'profile.',
    // I riti: le serie, gli avvisi scelti, l'ultimo giorno di ognuno. **Due
    // forme, e le due liste vecchie ne conoscevano una per una**: `ritual.`
    // sta nelle serie dei riti, `rituale.` negli avvisi.
    'ritual.',
    'rituale.',
    // Il saluto del Santuario e cio' che la home ricorda di te.
    'santuario.',
    // Quali mappe dei sentieri hai gia' aperto.
    'sentiero.',
    // I Sigilli accesi.
    'sigilli.',
    // Le coppie della Sinastria che hai scoperto.
    'sinastria.',
    // Quale formula di benvenuto ti ha gia' detto ogni Maestro. **L'HA
    // TROVATA LA PROVA**, non una persona: e' la quarantaseiesima chiave, e
    // non la cancellava nessuna delle due vie.
    'maestro.',
    // L'indice dei Ricordi del Cerchio: le righe magre di cio' che hai fatto,
    // mese per mese, e la data dell'ultima sincronia. Ordine CG voce 03.
    'ricordi.',
    // Il quaderno dei sogni, con le parole che hai scritto.
    'sogni.',
    // La Runa del Tramonto: la settimana e la cerniera. **Senza il punto**,
    // perche' una delle due chiavi usa il trattino basso (`sunset_rune_last`)
    // e l'altra il punto (`sunset_rune.settimana`).
    'sunset_rune',
    // Le letture del viso, con le loro date.
    'viso.',
    // L'identita' del dispositivo, che regge i Doni deterministici: e' un
    // numero che ti identifica, quindi e' tuo.
    'device.id',
  ];

  /// **CIO' CHE NON E' DI NESSUNO, e resta.** Ogni voce porta la ragione
  /// scritta accanto: una riga senza ragione domani sembra una dimenticanza.
  ///
  /// La prova le legge da qui: se una chiave nuova non e' ne' tua ne'
  /// dichiarata qui, la prova cade.
  static const Map<String, String> restano = <String, String>{
    'settings.': 'come questo telefono è regolato, non chi lo usa: qualità '
        'grafica, movimento ridotto, sottotitoli, suono. Buttarli vorrebbe '
        'dire punire chi esce e rimettere a mano un\'accessibilità che '
        'qualcuno aveva scelto per necessità.',
    'app_check_debug_token': 'il gettone di prova di App Check, che appartiene '
        'alla macchina e non alla persona.',
  };

  /// Vero se quella chiave appartiene alla persona.
  static bool eTua(String chiave) => prefissi.any(chiave.startsWith);

  /// Vero se quella chiave e' dichiarata come non appartenente a nessuno.
  static bool resta(String chiave) => restano.keys.any(chiave.startsWith);
}
