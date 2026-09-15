import 'face_classifier.dart';
import 'face_trait.dart';

/// **QUANTE COSTELLAZIONI DEL VISO ESISTONO, E PERCHE' LA TUA E' TUA.**
/// Ordine CX voci 05 e 06, 8 settembre 2026.
///
/// **Le due domande del fondatore**: *"perche' l'utente dovrebbe condividere e
/// perche' un amico dovrebbe sentirsi spinto a scaricare l'app per avere la
/// stessa esperienza?"*
///
/// **La risposta non e' una frase, e' un numero.** Una card si condivide
/// quando dice qualcosa che **soltanto chi la manda ha**, e un amico la scarica
/// quando capisce che ne esiste una sua e che non sara' uguale. Un titolo
/// evocativo non basta: due persone che ricevono lo stesso titolo capiscono
/// subito che l'app parla a tutti allo stesso modo, ed e' esattamente il
/// difetto che il fondatore ha trovato nel responso prima della taratura.
///
/// **IL NUMERO SI CONTA, non si sceglie.** Le combinazioni possibili sono il
/// prodotto delle varianti di ogni categoria, lette dal catalogo vero: se
/// domani nasce una variante nuova, il numero cresce da solo. **Un numero
/// scritto a mano diventerebbe falso al primo tratto aggiunto**, ed e' la
/// famiglia delle due verita' sullo stesso fatto.
///
/// **E' un fatto, non una promessa.** Dire quante combinazioni esistono non
/// promette niente a nessuno: dice quanto e' fine la lettura, e questo si
/// puo' dire senza vantare effetti.
class QuantoETua {
  const QuantoETua._();

  /// **QUANTE COSTELLAZIONI DIVERSE IL CATALOGO PUO' PRODURRE.**
  ///
  /// Il prodotto delle varianti per categoria. Le categorie senza varianti
  /// non moltiplicano niente e non azzerano il conto.
  static int quanteNeEsistono() {
    var totale = 1;
    for (final c in FaceCategory.values) {
      final quante = FaceTrait.perCategoria(c).length;
      if (quante > 0) totale *= quante;
    }
    return totale;
  }

  /// Il numero con i punti delle migliaia, come lo si legge in italiano.
  static String colPunto(int n) {
    final cifre = n.toString();
    final pezzi = <String>[];
    for (var i = cifre.length; i > 0; i -= 3) {
      final da = i - 3 < 0 ? 0 : i - 3;
      pezzi.insert(0, cifre.substring(da, i));
    }
    return pezzi.join('.');
  }

  /// **LA RIGA DELLA CARD**, quella che dice perche' vale la pena mandarla.
  ///
  /// **LA PRIMA STESURA DICEVA UNA COSA CHE NON REGGE, e il numero era
  /// giusto.** Diceva *"una costellazione su 104.976 possibili"*, e chi legge
  /// capisce **unica**. Centomila combinazioni pero' sono poche: misurato col
  /// conto esatto, **a 382 utenti e' piu' probabile che due card siano
  /// identiche che il contrario**, e a 793 e' quasi certo. Al lancio, con
  /// qualche migliaio di iscritti, esisterebbero gruppi di persone con la
  /// stessa costellazione a parole, e basterebbe che due amici confrontassero
  /// le card perche' l'effetto diventasse il sospetto che sia finto.
  ///
  /// **Non era un errore di calcolo: era il significato implicito.** Il numero
  /// resta e resta vero; cambia cio' che di lui si lascia capire. Adesso la
  /// riga dice **quanto e' fine la lettura**, che e' un fatto sulla misura,
  /// invece di **quanto e' raro chi la riceve**, che e' un vanto sulla persona
  /// e a 382 utenti sarebbe falso.
  ///
  /// **E cio' che e' davvero irripetibile e' la FIGURA, non le parole.** La
  /// costellazione nasce dai punti misurati del volto, non dalle undici
  /// caselle: due persone che ricevono gli stessi undici tratti hanno stelle
  /// in posizioni diverse, misurato. Quella promessa la card la puo' reggere,
  /// e la riga sotto la dice.
  static String laRiga() =>
      '${colPunto(quanteNeEsistono())} combinazioni distinte di tratti.';

  /// **LA RIGA DELLA FIGURA**, quella che si puo' promettere davvero.
  ///
  /// Le stelle stanno dove le mette il volto, e due volti non hanno mai le
  /// stesse proporzioni a quattro decimali: **questa figura non e' di nessun
  /// altro**, e non e' un vanto, e' come e' costruita.
  static String laRigaDellaFigura() =>
      'Le stelle stanno dove le mette il tuo volto.';

  /// **QUANTI TRATTI HA LETTO DAVVERO**, che e' l'altra meta' dell'onesta'.
  ///
  /// Quando una zona era coperta il responso ne perde una, e la card non deve
  /// vantare undici letture se ne ha fatte nove: chi la riceve conta le righe
  /// e vede la differenza.
  static String quantiTratti(FaceReading lettura) {
    final quanti = lettura.letture.length;
    final tutte = FaceCategory.values.length;
    if (quanti >= tutte) return '$tutte tratti letti';
    return '$quanti tratti letti su $tutte';
  }
}
