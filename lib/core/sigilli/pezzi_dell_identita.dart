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
}
