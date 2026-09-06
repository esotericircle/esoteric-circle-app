/// **IL MIAN XIANG, LA FISIOGNOMICA CINESE.** Ordine CR voce 06, 6 settembre
/// 2026.
///
/// **LE FONTI, E IL LIMITE DICHIARATO.** Tutto quello che sta in questo file
/// poggia su `docs/viso/mian_xiang_fonti.md`, che dice anche cosa NON e' stato
/// verificato. In breve: i due testi classici sono il **神相全編 Shenxiang
/// quanbian** (Ming) e il **麻衣神相 Mayi shenxiang** (Song, scuola di Ma Yi,
/// compilato da Chen Tuan); la fonte accademica e' Livia Kohn, *A Textbook of
/// Physiognomy: The Tradition of the "Shenxiang quanbian"*, Asian Folklore
/// Studies 45/2 (1986), pp. 227-258, di cui **ho verificato i dati
/// bibliografici ma non ho potuto leggere il testo**.
///
/// **PER QUESTO I DODICI PALAZZI NON CI SONO.** L'elenco preciso delle dodici
/// zone e degli ambiti che governano non l'ho trovato su nessuna fonte
/// verificabile, e le fonti divulgative non concordano nemmeno sui nomi.
/// Scriverli lo stesso vorrebbe dire fare la cosa che questo ordine nasce per
/// togliere: dare a chi legge qualcosa che **sembra** documentato.
///
/// **E GLI UFFICIALI SONO QUATTRO, NON CINQUE.** La tradizione ne conta cinque,
/// e il quinto sono le orecchie. MediaPipe Face Mesh non le restituisce, e una
/// fotocamera frontale davanti al viso spesso non le inquadra: **un ufficiale
/// che non si vede non si legge**.
library;

import 'face_trait.dart';

/// I quattro ufficiali che questa app puo' davvero osservare.
///
/// Nella tradizione sono cinque e governano ciascuno un periodo della vita e
/// una qualita'. Qui si legge la qualita', non il periodo: il periodo dipende
/// dall'eta' e da altri conti che questa funzione non fa e non finge di fare.
enum UfficialeDelVolto {
  sopracciglia('Il Palazzo della Longevità', 'sopracciglia'),
  occhi('Il Palazzo dello Spirito', 'occhi'),
  naso('Il Palazzo della Ricchezza', 'naso'),
  bocca('Il Palazzo delle Acque', 'bocca');

  const UfficialeDelVolto(this.nome, this.parte);

  /// Come la tradizione chiama questa zona. **E' un nome, non una promessa**:
  /// il Palazzo della Ricchezza non predice denaro, e il testo che la persona
  /// legge non lo lascia mai intendere.
  final String nome;

  /// La parte del volto, detta in una parola.
  final String parte;
}

/// I cinque elementi, applicati alla forma dominante del volto.
///
/// **E' l'aspetto piu' stabile della materia**, quello su cui le fonti
/// concordano di piu', ed e' anche l'unico che si appoggia a una misura che
/// gia' facciamo: la forma del volto nasce da rapporti veri fra larghezze e
/// altezze, non da un giudizio.
enum ElementoDelVolto {
  legno(
    'Legno',
    'volto lungo e stretto, lineamenti verticali',
    'Cresci per direzione, non per accumulo: quando sai dove stai andando, '
        'ci arrivi prima degli altri.',
  ),
  fuoco(
    'Fuoco',
    'fronte larga e mento affilato, forma a triangolo',
    'Ti accendi in fretta e illumini chi ti sta intorno: la tua forza è '
        'l’inizio, e il tuo esercizio è restare.',
  ),
  terra(
    'Terra',
    'volto pieno e squadrato, base solida',
    'Sei il punto fermo a cui gli altri tornano: costruisci lentamente cose '
        'che durano più di te.',
  ),
  metallo(
    'Metallo',
    'lineamenti netti, proporzioni regolari',
    'Tagli il superfluo senza rimpianto: la tua chiarezza è una forma di '
        'rispetto, anche quando sembra durezza.',
  ),
  acqua(
    'Acqua',
    'volto tondo e morbido, contorni fluidi',
    'Prendi la forma di ciò che incontri senza perderti: la tua è '
        'l’intelligenza che aggira invece di urtare.',
  );

  const ElementoDelVolto(this.nome, this.comeSiRiconosce, this.lettura);

  /// Il nome dell'elemento.
  final String nome;

  /// Da cosa si riconosce, in una riga. **E' una descrizione della FORMA**, non
  /// del carattere: il carattere viene dopo, e la persona deve poter vedere da
  /// se' che la forma corrisponde.
  final String comeSiRiconosce;

  /// La lettura simbolica. Parla di come uno funziona, mai di cosa gli
  /// succedera'.
  final String lettura;
}

/// La corrispondenza fra le forme del volto che il classificatore misura e i
/// cinque elementi.
///
/// **QUESTA MAPPA E' IL PUNTO PIU' DELICATO DEL FILE**, e va detto: il
/// classificatore conosce quattro forme, gli elementi sono cinque. Il Metallo
/// non ha una forma sua nel nostro impianto, e **non gliene inventiamo una**:
/// si raggiunge dalla regolarita', che e' una misura diversa dalla forma, e
/// finche' non la misuriamo il Metallo non esce. Meglio quattro elementi veri
/// che cinque di cui uno assegnato a caso.
class MianXiang {
  const MianXiang._();

  static const Map<FaceTrait, ElementoDelVolto> _daForma = {
    FaceTrait.voltoOvale: ElementoDelVolto.legno,
    FaceTrait.voltoTriangolare: ElementoDelVolto.fuoco,
    FaceTrait.voltoQuadrato: ElementoDelVolto.terra,
    FaceTrait.voltoTondo: ElementoDelVolto.acqua,
  };

  /// L'elemento dominante, dalla forma misurata. Nullo se la forma non e' fra
  /// quelle che sappiamo tradurre: **il nulla e' una risposta onesta**, e la
  /// schermata sa cosa farne.
  static ElementoDelVolto? elementoDa(FaceTrait forma) => _daForma[forma];

  /// Gli elementi che questa app puo' davvero assegnare oggi.
  static Set<ElementoDelVolto> get elementiRaggiungibili =>
      _daForma.values.toSet();
}
