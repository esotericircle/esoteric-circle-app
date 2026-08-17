library;

/// I PEZZI DELL'IDENTITA', IN UN PUNTO SOLO. Ordine U voce 01, coda.
///
/// **Perche' questa lista si e' spostata qui.** Viveva scritta a mano dentro
/// `lib/features/sigilli/regia_del_cammino.dart`, ed era l'unico posto che
/// sapesse quali gesti completano un pezzo dell'identita'. La prova che
/// sorveglia "un gesto, una festa, un pagamento" ha bisogno dello stesso legame:
/// **ricopiarlo dentro la prova avrebbe aperto la seconda porta sullo stesso
/// dato**, e da domani i due elenchi sarebbero divergiuti senza che nessuno se
/// ne accorgesse. Adesso e' un dato solo, e lo leggono tutti e due.
///
/// **Cosa e' un pezzo dell'identita'.** Una cosa che una persona ha UNA volta e
/// per sempre: la carta natale, il proprio Angelo, il proprio archetipo. Non e'
/// un'abitudine e non si ripete, ed e' la ragione per cui un pezzo puo' essere
/// nominato da un traguardo solo in tutto il cammino: tre traguardi sullo stesso
/// pezzo non sono tre traguardi, sono lo stesso pagato tre volte.
class PezziDellIdentita {
  const PezziDellIdentita._();

  /// I NOVE PEZZI, e il gesto che li completa porta lo stesso nome.
  ///
  /// La carta natale sta qui come gli altri: la regia la conosce anche per
  /// un'altra via, perche' puo' arrivare dal profilo invece che da un gesto, ma
  /// il NOME del pezzo e' questo e non un altro.
  static const List<String> tutti = [
    'carta_natale',
    'passaporto',
    'angelo_custode',
    'animale_guida',
    'archetipo',
    'viso',
    'numero_della_vita',
    'ora_di_nascita',
    'luogo_di_nascita',
  ];

  /// Gli otto che si completano SOLO con un gesto.
  ///
  /// La carta natale resta fuori perche' la regia la ricava anche dal profilo:
  /// li' la condizione non e' "hai fatto il gesto" ma "la carta esiste".
  static const List<String> daSoloGesto = [
    'passaporto',
    'angelo_custode',
    'animale_guida',
    'archetipo',
    'viso',
    'numero_della_vita',
    'ora_di_nascita',
    'luogo_di_nascita',
  ];

  static bool eUnPezzo(String gesto) => tutti.contains(gesto);

  /// LE TESSERE DEL PASSAPORTO, ordine AL voce 03.
  ///
  /// Il pezzo 'passaporto' e' COMPOSTO: il suo gesto dice soltanto "ho aperto
  /// il documento", perche' scatta a ogni visita della schermata, e da solo
  /// faceva maturare med_27 con l'archetipo ancora da fare (il telefono di
  /// Mauro, collaudo del 17 agosto 2026). Il Passaporto pieno matura SOLO
  /// quando ogni tessera del documento e' viva.
  ///
  /// **Cosa conta OGGI**, tessera per tessera del documento reale:
  /// la carta natale (il portale del cielo di nascita e la sua card), il
  /// numero della vita, l'ora e il luogo di nascita (i dati del documento,
  /// vivi solo con l'identita' reale), i tre Angeli, l'animale guida e
  /// l'archetipo. Le tessere deterministiche, il Sigillo del Cerchio e la
  /// fase lunare di nascita, sono vive per costruzione dalla sola data e non
  /// hanno un gesto da contare; lo Specchio dei Dati non e' una tessera
  /// dell'identita'.
  ///
  /// **Cosa conta DOPO**: l'elenco delle tessere in arrivo del documento,
  /// `_passportEntries`, oggi e' vuoto; quando una tessera nuova entra nel
  /// documento va aggiunta QUI, cosi' il Passaporto pieno resta pieno
  /// davvero. La Costellazione del Viso non e' una tessera del documento
  /// oggi: se un giorno vi entra, entra anche in questo elenco.
  static const List<String> tessereDelPassaporto = [
    'carta_natale',
    'numero_della_vita',
    'ora_di_nascita',
    'luogo_di_nascita',
    'angelo_custode',
    'animale_guida',
    'archetipo',
  ];
}
