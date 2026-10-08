import 'tier.dart';

/// UNA VOCE DEL LISTINO: cosa si compra, quanto costa, e quante volte al
/// giorno e' gratis per ciascun piano.
class VoceDelListino {
  const VoceDelListino({
    required this.id,
    required this.nome,
    required this.costo,
    required this.budget,
    required this.gratisAlGiorno,
  });

  /// L'identificativo dell'arte nel catalogo, quando ne ha uno.
  final String id;

  /// Come si chiama per una persona.
  final String nome;

  /// Quanti Eos costa una volta finito il gratuito del giorno.
  final int costo;

  /// Il budget del server che conta gli usi gratuiti, quando esiste: e' la
  /// stessa parola che `functions/src/budget.ts` conosce, mai una copia.
  final String? budget;

  /// Quante volte al giorno e' gratis, per piano: Viandante, Iniziato,
  /// Adepto, Illuminato. Nullo vuol dire senza tetto.
  final Map<Tier, int?> gratisAlGiorno;

  /// Quante ne restano oggi con questo piano, dato quante se ne sono gia'
  /// usate. Nullo se il piano non ha tetto: li' non c'e' un residuo da dire.
  int? quanteRestano(Tier tier, int giaUsate) {
    final tetto = gratisAlGiorno[tier];
    if (tetto == null) return null;
    final resta = tetto - giaUsate;
    return resta < 0 ? 0 : resta;
  }
}

/// IL LISTINO DEGLI EOS, IN UN PUNTO SOLO. Ordine AN voce 05.
///
/// **Perche' un listino e non un numero sparso per le schermate.** Un costo
/// scritto dentro la schermata che lo mostra e' un costo che diverge dal
/// prossimo ritocco: la stessa stesa costerebbe 120 in un posto e 150 in un
/// altro, e nessuna prova se ne accorgerebbe. Qui c'e' il dato, e le
/// schermate lo leggono.
///
/// **I numeri.** Vengono dall'economia approvata il 2 agosto e dai briefing,
/// che li confermano dove si sovrappongono
/// (`docs/02_Briefing_Progetto_Definitivo.md`, tabella della sezione 19):
/// carta di tarocchi extra 50, sinastria extra 150, domanda extra a un
/// Maestro 80, stesa completa 250. Il 120 della stesa a tre carte non sta
/// nei briefing e arriva come decisione di Mauro del 18 agosto: e' scritto
/// qui perche' si sappia da dove viene.
///
/// **Cosa gli Eos NON comprano mai**, e non e' una dimenticanza: la memoria
/// dei Maestri, la voce, la profondita' delle risposte, la compatibilita' a
/// tre livelli e le altre funzioni di relazione continuativa restano
/// dell'abbonamento. Un Eos compra un'esperienza singola e conclusa, mai un
/// accesso che dura. La voce AN.06 usa questa distinzione per dire, davanti
/// a ogni lucchetto, quale strada esiste davvero.
class ListinoDegliEos {
  const ListinoDegliEos._();

  /// IL PREMIO DI CHI ARRIVA CON UN INVITO, in Eos. Ordine FD voce 06.5: il
  /// numero del messaggio "Entrando da qui ricevi NN Eos" si legge da qui, e
  /// non si scrive a mano nel testo. Lo paga il server
  /// (`EOS_A_CHI_ARRIVA_CON_UN_INVITO` in `functions/src/borsellino.ts`), e
  /// la prova `la_rubrica_resta_sul_telefono_test.dart` pretende che i due
  /// numeri siano uguali: un premio promesso diverso da quello pagato e' una
  /// promessa falsa.
  static const int premioDiChiArrivaConUnInvito = 150;

  /// LA STESA A TRE CARTE.
  static const stesaTreCarte = VoceDelListino(
    id: 'tarot_spread_three',
    nome: 'Una stesa a tre carte',
    costo: 120,
    budget: 'gettate',
    gratisAlGiorno: {
      Tier.free: 1,
      Tier.tier1: null,
      Tier.tier2: null,
      Tier.tier3: null,
    },
  );

  /// LA CARTA SINGOLA IN PIU'.
  static const cartaExtra = VoceDelListino(
    id: 'tarot_card_extra',
    nome: 'Una carta in più',
    costo: 50,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 1,
      Tier.tier1: 3,
      Tier.tier2: null,
      Tier.tier3: null,
    },
  );

  /// LA DOMANDA IN PIU' A UN MAESTRO.
  static const domandaExtra = VoceDelListino(
    id: 'maestro_question',
    nome: 'Una domanda in più',
    costo: 80,
    budget: 'domande',
    gratisAlGiorno: {
      Tier.free: 3,
      Tier.tier1: 5,
      Tier.tier2: 10,
      Tier.tier3: null,
    },
  );

  /// LA SINASTRIA CELEB IN PIU'.
  static const sinastriaExtra = VoceDelListino(
    id: 'synastry_vip',
    nome: 'Una sinastria in più',
    costo: 150,
    budget: 'confronti',
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: 3,
      Tier.tier2: 5,
      Tier.tier3: null,
    },
  );

  /// LA STESA COMPLETA, la Croce Celtica.
  static const stesaCompleta = VoceDelListino(
    id: 'tarot_spread_full',
    nome: 'Una stesa completa',
    costo: 250,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: 0,
      Tier.tier2: 0,
      Tier.tier3: 0,
    },
  );

  /// **L'OROSCOPO ANNUALE, ordine ES voce 04.** Dall'Adepto in su e'
  /// compreso; chi non ce l'ha lo apre per l'anno che corre con 300 Eos,
  /// come l'annuale dell'Architetto approvato dal fondatore ("Per il resto
  /// approvo tutto"). Un'esperienza singola e conclusa: l'anno di un
  /// compleanno.
  static const oroscopoAnnuale = VoceDelListino(
    id: 'oroscopo_annuale',
    nome: 'L\'oroscopo dell\'anno',
    costo: 300,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: 0,
      Tier.tier2: null,
      Tier.tier3: null,
    },
  );

  /// **LA LUNGA DELL'OROSCOPO OCCIDENTALE DEL GIORNO, ordine EU voce 15.**
  /// La tabella della voce ES.06, approvata dal fondatore: *"Occidentale del
  /// giorno, Approfondita: 50 Eos, per la giornata e le quattro schede"*; e
  /// il 30 settembre, alla domanda *"Chi può scegliere la profondità
  /// Lunga?"*, *"Premium più Eos"*. Contro la regola scritta sopra (la
  /// profondita' resta dell'abbonamento) la decisione e' sua e porta la sua
  /// data: si compra una giornata, non un accesso che dura. La Vedica e la
  /// Cinese non si comprano con gli Eos (la stessa tabella).
  static const oroscopoLungaDelGiorno = VoceDelListino(
    id: 'oroscopo_lunga_del_giorno',
    // Il nome che si legge sopra il pulsante della spesa: dal 1 ottobre 2026
    // con le parole del fondatore, "l'oroscopo completo", non "la Lunga".
    nome: 'L\'oroscopo completo di oggi, per tutte e quattro le schede',
    costo: 50,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: null,
      Tier.tier2: null,
      Tier.tier3: null,
    },
  );

  /// **UN POSTO IN PIU' FRA GLI AMICI OFFLINE, ordine ES voci 06 e 12.** Il
  /// fondatore: "3 per l'Iniziato, 10 per l'Adepto, nessun limite per
  /// l'Illuminato [...] 100 Eos per un posto in più", "ok , approvato". E'
  /// l'unica voce che compra qualcosa che resta, contro la regola scritta
  /// sopra: la decisione e' sua e porta la sua data.
  ///
  /// **Il nullo dell'Illuminato se n'e' andato, ordine EZ voce 06**: anche
  /// l'Illuminato ha un numero (50, nella matrice dei piani), e oltre quel
  /// numero il posto si compra come per gli altri piani.
  static const amicoInPiu = VoceDelListino(
    id: 'amico_in_piu',
    nome: 'Un posto in più fra gli amici',
    costo: 100,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: 0,
      Tier.tier2: 0,
      Tier.tier3: 0,
    },
  );

  /// **UN CONFRONTO DEL CIELO IN PIU', ordine EY voce 13**: 30 Eos, quando i
  /// confronti del giorno del piano sono finiti. Il server lo conta sul budget
  /// `cieli` e il prezzo lo ripete `PREZZI_DEL_RISCATTO` in
  /// `functions/src/borsellino.ts`; una prova pretende che i due coincidano.
  static const confrontoDelCieloInPiu = VoceDelListino(
    id: 'confronto_del_cielo',
    nome: 'Un confronto del cielo in più',
    costo: 30,
    budget: 'cieli',
    gratisAlGiorno: {
      Tier.free: 1,
      Tier.tier1: 5,
      Tier.tier2: 15,
      Tier.tier3: 30,
    },
  );

  /// **LA SCINTILLA, ordine EY voce 12**: il secondo dei tre doni, dall'Adepto
  /// in su. Il dono non conia Eos a chi lo riceve: riceve l'oggetto. Il
  /// prezzo lo ripete `PREZZI_DEI_DONI` in `functions/src/sociale.ts`.
  static const scintilla = VoceDelListino(
    id: 'dono_scintilla',
    nome: 'Una scintilla da donare',
    costo: 30,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: 0,
      Tier.tier2: 0,
      Tier.tier3: 0,
    },
  );

  /// **IL SIGILLO DA DONARE, ordine EY voce 12**: il dono piu' alto,
  /// dall'Adepto in su. Il cenno e' gratuito e non sta nel listino.
  static const sigilloDaDonare = VoceDelListino(
    id: 'dono_sigillo',
    nome: 'Un sigillo da donare',
    costo: 80,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: 0,
      Tier.tier2: 0,
      Tier.tier3: 0,
    },
  );

  /// **UN INDIZIO, ordine FF voce 03**: nei giochi del Cerchio il primo
  /// indizio di ogni partita e' gratis, dal secondo costa cinque Eos. Il
  /// gratis e' per partita e non per giorno, e lo decide il server: qui la
  /// soglia giornaliera resta a zero. Il prezzo lo ripete
  /// `PREZZO_DELL_INDIZIO` in `functions/src/gli_indizi.ts`.
  static const indizio = VoceDelListino(
    id: 'indizio_del_cerchio',
    nome: 'Un indizio in più',
    costo: 5,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: 0,
      Tier.tier2: 0,
      Tier.tier3: 0,
    },
  );

  /// **IL SEGNO DI CHI TI HA INDOVINATO, ordine FF voce 04**: venti Eos, uno
  /// alla volta. Il segno si', il nome mai, a nessun prezzo.
  static const segnoDiChiTiHaIndovinato = VoceDelListino(
    id: 'segno_di_chi_indovina',
    nome: 'Il segno di chi ti ha riconosciuto',
    costo: 20,
    budget: null,
    gratisAlGiorno: {
      Tier.free: 0,
      Tier.tier1: 0,
      Tier.tier2: 0,
      Tier.tier3: 0,
    },
  );

  static const List<VoceDelListino> tutte = [
    stesaTreCarte,
    cartaExtra,
    domandaExtra,
    sinastriaExtra,
    stesaCompleta,
    oroscopoAnnuale,
    oroscopoLungaDelGiorno,
    amicoInPiu,
    confrontoDelCieloInPiu,
    scintilla,
    sigilloDaDonare,
    indizio,
    segnoDiChiTiHaIndovinato,
  ];

  /// La voce di un'arte, oppure nulla se quell'arte non si compra a Eos.
  static VoceDelListino? perArte(String id) {
    for (final voce in tutte) {
      if (voce.id == id) return voce;
    }
    return null;
  }

  /// **LA SOGLIA DELLA CONFERMA, dichiarata.** Sotto questa cifra la spesa
  /// parte col tocco, perche' chiedere conferma per ogni piccola cosa
  /// insegna a rispondere di si' senza leggere. Sopra, si chiede una volta,
  /// con la possibilita' di non farselo chiedere piu'.
  static const int sogliaDellaConferma = 100;

  /// COME SI CHIAMA LA MONETA, in un punto solo: la parola vive qui e chi
  /// scrive una cifra la compone, invece di incollarla accanto al numero.
  static const String moneta = 'Eos';

  /// Come si scrive un costo, in un punto solo: "120 Eos".
  static String prezzo(int costo) => '$costo $moneta';

  /// Come si dice quanto resta oggi, in lingua del Cerchio.
  static String residuo(int quante, String cosa) {
    if (quante <= 0) return 'Nessuna $cosa gratis oggi';
    if (quante == 1) return '1 $cosa rimasta oggi';
    return '$quante $cosa rimaste oggi';
  }
}
