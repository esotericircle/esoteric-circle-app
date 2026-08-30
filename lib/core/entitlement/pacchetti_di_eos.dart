/// I PACCHETTI DI EOS. Ordine CE voce 09.
///
/// **Le parole del fondatore, verbatim:** "i pacchetti EOS sono previsti dai
/// briefing, ma probabilmente mai definiti. fai scegliere a Code io numero di
/// pacchetti ideali e l'entita' di ognuno." E' una delega esplicita: quanti,
/// quanto grandi e a che prezzo li scelgo io, e li motivo qui.
///
/// **TRE PACCHETTI, e non due ne' cinque.** Con due la scelta e' "poco o
/// tanto", e chi ha un bisogno medio prende il grande per sicurezza o il
/// piccolo per prudenza: in tutti e due i casi si pente. Con cinque il listino
/// diventa un problema da risolvere, e chi deve solo finire una lettura
/// abbandona. Tre e' la forma che regge da sola: uno che tappa un buco, uno che
/// copre una settimana, uno che non si pensa piu'.
///
/// **LE ENTITA', commisurate al conio del cammino.** Il Cerchio intero conia
/// **2.010 Eos per sentiero e 6.030 in tutto**: e' la scala contro cui un
/// pacchetto va misurato, altrimenti o e' briciole o svaluta il cammino.
///
/// - **300**, che sono da due a sei voci del listino: e' il tappabuchi, quello
///   che si compra quando manca una cosa sola.
/// - **900**, tre volte il primo: copre una settimana di extra senza pensarci.
/// - **2.500**, che sta appena sotto il conio di un sentiero intero: e' molto,
///   e resta sotto la soglia in cui comprare varrebbe piu' del camminare.
///   **Nessun pacchetto arriva ai 6.030 del cammino completo**, ed e' una
///   scelta: il cammino deve restare la via piu' ricca.
///
/// **I PREZZI, e perche' non fanno concorrenza all'abbonamento.** Il piu'
/// conveniente costa 0,0080 euro per Eos e il piu' caro 0,0100: la scala c'e'
/// ed e' mite, perche' uno sconto forte sul grande spingerebbe a comprare
/// scorte invece di abbonarsi. **Il pacchetto e' una comodita', l'abbonamento
/// e' la strada**: con 19,99 euro di Eos si comprano 2.500 Eos una volta sola,
/// mentre con 19,90 euro al mese l'Adepto ha ogni giorno budget che a listino
/// varrebbero molto di piu'.
///
/// **QUESTO ELENCO E' LA SOLA DICHIARAZIONE, e il client non decide prezzi.**
/// Il giorno che gli acquisti veri arrivano, il negozio dira' il prezzo in
/// valuta locale e il server accreditera' gli Eos: questi numeri restano la
/// verita' del progetto, non l'autorita' sul pagamento.
class PacchettoDiEos {
  const PacchettoDiEos({
    required this.id,
    required this.nome,
    required this.eos,
    required this.prezzo,
    required this.perche,
  });

  /// L'identificativo che il negozio e il server useranno.
  final String id;

  /// Come si chiama per una persona.
  final String nome;

  /// Quanti Eos accredita.
  final int eos;

  /// Il prezzo dichiarato, nella forma che si mostra.
  final String prezzo;

  /// Una riga che dice a cosa serve: senza, tre numeri sono tre numeri.
  final String perche;

  /// Quanto costa un Eos in questo pacchetto, per confrontarli fra loro.
  /// Si ricava dal prezzo e non si scrive a mano.
  double get perEos => _euro / eos;

  double get _euro =>
      double.parse(prezzo.replaceAll('€', '').trim().replaceAll(',', '.'));
}

/// I tre pacchetti, dal piu' piccolo al piu' grande.
const List<PacchettoDiEos> pacchettiDiEos = [
  PacchettoDiEos(
    id: 'eos_300',
    nome: 'Manciata di Eos',
    eos: 300,
    prezzo: '2,99 €',
    perche: 'Quando ne manca una manciata per finire quello che hai aperto.',
  ),
  PacchettoDiEos(
    id: 'eos_900',
    nome: 'Borsa di Eos',
    eos: 900,
    prezzo: '7,99 €',
    perche: 'Una settimana di letture in più, senza pensarci ogni volta.',
  ),
  PacchettoDiEos(
    id: 'eos_2500',
    nome: 'Scrigno di Eos',
    eos: 2500,
    prezzo: '19,99 €',
    perche: 'Quasi quanto ne conia un sentiero intero del Cammino.',
  ),
];

/// **GLI ACQUISTI VERI NON SONO ANCORA COLLEGATI A NESSUN NEGOZIO.**
///
/// Ordine CE voce 09, vincolo del fondatore: "se questa voce arriva fino al
/// punto in cui servirebbe il pagamento, si ferma li' e lo DICHIARA a schermo
/// invece di promettere un acquisto che non avviene."
///
/// Questa costante e' quella dichiarazione, e vive qui perche' il giorno che il
/// negozio esiste si spenga in un punto solo.
const bool acquistiCollegatiAUnNegozio = false;

/// La frase che si mostra al posto dell'acquisto, finche' il negozio non c'e'.
/// **Dice cosa manca e non da' la colpa a chi tocca.**
const String pacchettiNonAncoraInVendita =
    'I pacchetti di Eos arrivano con la pubblicazione dell\'app: qui trovi '
    'quali saranno e quanto danno. Intanto gli Eos si guadagnano ogni giorno '
    'lungo il Cammino.';
