/// L'ARTWORK DI UN RICORDO CUSTODITO. Ordine CG voce 07, seconda stesura.
///
/// **Perche' esiste una seconda stesura.** La prima griglia delle carte
/// custodite disegnava riquadri di testo: data, titolo, un estratto. Le parole
/// dell'ordine erano "la ricerca delle card generate e condivise", e una card
/// generata e' un'immagine, non un paragrafo. Il fondatore lo ha detto
/// guardando la schermata, il 31 agosto 2026: "sarebbe l'ideale che al click si
/// potesse rivedere l'artwork che hai gia' creato a suo tempo".
///
/// **Il custodito conserva i DATI PER RIDISEGNARE, non l'immagine**, ed e' una
/// scelta gia' presa e scritta in `RicordoCustodito`: un'immagine per responso
/// riempirebbe il telefono, i dati pesano poche decine di byte, e l'arte sta
/// gia' tutta nel bundle. Questo file e' il pezzo che mancava: da quei dati ai
/// file dell'arte.
///
/// **UNA PORTA SOLA, e non e' un vezzo.** Otto arti su tredici hanno un
/// artwork, e ognuna lo indirizza col proprio catalogo. Se la griglia
/// componesse i percorsi da se', la convenzione dei nomi dei file vivrebbe in
/// due punti: e' esattamente la ragione per cui esiste `FamilyImage`, un piano
/// piu' sotto. Le cinque arti senza artwork stanno dichiarate qui col loro
/// motivo, non sono assenze silenziose.
///
/// **Cosa fa questo file quando non riconosce un dato.** Torna una lista
/// vuota, e la griglia disegna il riquadro di testo di prima. Un custodito
/// vecchio, salvato prima che l'arte avesse il suo stem, non fa cadere niente
/// e non mostra un buco: mostra cio' che mostrava ieri.
library;

import '../archetypes/archetype.dart';
import '../astro/zodiac.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../rituals/animal_catalog.dart';
import '../rituals/runes.dart';
import '../synastry/vip_catalog.dart';
import '../tarot/tarot_card.dart';
import 'ricordo_custodito.dart';

/// Un'immagine da rimettere a schermo, con tutti e due i tagli.
class ImmagineDelRicordo {
  const ImmagineDelRicordo({
    required this.nome,
    required this.miniatura,
    required this.piena,
    this.carta,
    this.rovesciata = false,
  });

  /// Come si chiama, per la didascalia e per chi legge a voce lo schermo.
  final String nome;

  /// Il file piccolo, per la griglia.
  final String miniatura;

  /// Il file grande, per il ricordo aperto.
  final String piena;

  /// **LA CARTA VERA, quando l'immagine e' un tarocco.**
  ///
  /// I tarocchi non si disegnano col percorso nudo: gli artwork hanno i
  /// cartigli VUOTI, e il nome e il numero della carta si sovrappongono a
  /// runtime, cosi' un solo mazzo vale per tutte le lingue. Chi mette a
  /// schermo questa immagine, se la carta c'e', passa dal pezzo che i cartigli
  /// li sa scrivere.
  final TarotCard? carta;

  /// Vero per una runa uscita in ombra, cioe' capovolta.
  final bool rovesciata;
}

class ArtworkDelRicordo {
  const ArtworkDelRicordo._();

  /// **LE CHIAVI CHE OGNI ARTE SCRIVE NEI SUOI DATI.**
  ///
  /// Sta qui perche' una guardia possa aprire la schermata del responso e
  /// verificare che scriva davvero queste chiavi. Senza, una schermata che
  /// domani scrivesse `carta` dove qui si legge `carte` smetterebbe di
  /// mostrare l'artwork in silenzio, e nessuno se ne accorgerebbe fino a
  /// quando qualcuno non aprisse i propri custoditi.
  static const Map<String, List<String>> chiaviLette = {
    'stesa': ['carte'],
    'oracolo': ['carta'],
    'gettata': ['rune'],
    'tramonto': ['runa', 'verso'],
    'animale_guida': ['animale'],
    'sinastria': ['vip'],
    'archetipo': ['archetipo'],
    'oroscopo': ['segno'],
  };

  /// **LE ARTI CHE UN ARTWORK NON CE L'HANNO, e perche'.**
  ///
  /// Non e' un elenco di cose da fare: sono cinque no motivati. Se un giorno
  /// una di queste avesse la sua arte, la riga si toglie da qui e si aggiunge
  /// sopra, e la guardia pretende che la somma resti tredici.
  static const Map<String, String> senzaArtwork = {
    'viso': 'la Costellazione del Viso disegna i suoi punti sul volto della '
        'persona. Quel volto il Cerchio non lo conserva: la foto resta sul '
        'dispositivo e non viene caricata da nessuna parte. Non c\'è nessuna '
        'arte da ripescare, quindi rifare il disegno vorrebbe dire chiedere '
        'di nuovo la fotografia.',
    'sigillo': 'il Sigillo dell\'Intenzione è un segno tracciato col dito, '
        'diverso ogni volta: non è arte del Cerchio, è un gesto della '
        'persona. I dati custoditi ne conservano la via, non il tratto.',
    'alba': 'il Rito dell\'Alba consegna una parola: una parola si legge, '
        'non si guarda.',
    'soffio': 'il Soffio del Destino è un\'esperienza di respiro: quello che '
        'resta quando finisce è il testo, non una figura.',
    'sogno': 'il Rito della Notte raccoglie un sogno raccontato dalla '
        'persona. Un\'immagine ci sarebbe solo inventandola: un\'immagine '
        'inventata non è un ricordo di niente.',
  };

  /// Le immagini di questo custodito, in ordine. Vuota quando non ce ne sono.
  static List<ImmagineDelRicordo> di(RicordoCustodito ricordo) =>
      perArte(ricordo.arte, ricordo.dati);

  /// Lo stesso, dai due dati nudi: e' la forma che le prove usano.
  static List<ImmagineDelRicordo> perArte(
      String arte, Map<String, String> dati) {
    switch (arte) {
      case 'stesa':
        return _tarocchi(dati['carte']);
      case 'oracolo':
        return _tarocchi(dati['carta']);
      case 'gettata':
        return _rune(dati['rune']);
      case 'tramonto':
        return _rune(dati['runa'], inOmbra: dati['verso'] == 'ombra');
      case 'animale_guida':
        return _animale(dati['animale']);
      case 'sinastria':
        return _vip(dati['vip']);
      case 'archetipo':
        return _archetipo(dati['archetipo']);
      case 'oroscopo':
        return _segno(dati['segno']);
      default:
        return const [];
    }
  }

  /// Vero quando quest'arte, in linea di principio, un artwork ce l'ha.
  static bool haUnArtwork(String arte) => chiaviLette.containsKey(arte);

  // --- I RICONOSCITORI, uno per famiglia -----------------------------------

  /// I nomi arrivano dai dati custoditi, cioe' da una versione dell'app che
  /// puo' essere piu' vecchia di questa. Si confronta senza guardare
  /// maiuscole e spazi: un confronto rigido trasformerebbe una svista di
  /// scrittura in un artwork che sparisce.
  static bool _stessoNome(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  static List<String> _pezzi(String? grezzo) => (grezzo ?? '')
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList(growable: false);

  static List<ImmagineDelRicordo> _tarocchi(String? nomi) {
    final fuori = <ImmagineDelRicordo>[];
    for (final nome in _pezzi(nomi)) {
      for (final c in TarotDeck.cards) {
        if (!_stessoNome(c.name, nome)) continue;
        fuori.add(ImmagineDelRicordo(
          nome: c.name,
          miniatura: c.thumbPath,
          piena: c.fullPath,
          carta: c,
        ));
        break;
      }
    }
    return fuori;
  }

  static List<ImmagineDelRicordo> _rune(String? nomi, {bool inOmbra = false}) {
    final fuori = <ImmagineDelRicordo>[];
    for (final nome in _pezzi(nomi)) {
      for (final r in kElderFuthark) {
        if (!_stessoNome(r.name, nome)) continue;
        // Le rune senza arte agganciata restano fuori: un percorso composto su
        // uno stem che non c'e' darebbe un riquadro rotto.
        final piena = r.fullPath;
        final mini = r.thumbPath;
        if (piena == null || mini == null) break;
        fuori.add(ImmagineDelRicordo(
          nome: r.name,
          miniatura: mini,
          piena: piena,
          rovesciata: inOmbra,
        ));
        break;
      }
    }
    return fuori;
  }

  static List<ImmagineDelRicordo> _animale(String? nome) {
    if (nome == null) return const [];
    for (final a in AnimalCatalog.animals) {
      if (!_stessoNome(a.name, nome)) continue;
      return [
        ImmagineDelRicordo(
            nome: a.name, miniatura: a.thumbPath, piena: a.fullPath),
      ];
    }
    return const [];
  }

  static List<ImmagineDelRicordo> _vip(String? nome) {
    if (nome == null) return const [];
    for (final v in VipCatalog.vips) {
      if (!_stessoNome(v.name, nome)) continue;
      final mini = v.thumbPath;
      final piena = v.fullPath;
      if (mini == null || piena == null) return const [];
      return [ImmagineDelRicordo(nome: v.name, miniatura: mini, piena: piena)];
    }
    return const [];
  }

  static List<ImmagineDelRicordo> _archetipo(String? nome) {
    if (nome == null) return const [];
    for (final a in Archetype.values) {
      // L'archetipo si custodisce col nome dell'enumerazione, non col nome a
      // video: si accettano tutti e due, perche' l'uno o l'altro dipende da
      // quale versione dell'app ha scritto quel custodito.
      if (!_stessoNome(a.name, nome) && !_stessoNome(a.nome, nome)) continue;
      return [
        ImmagineDelRicordo(
            nome: a.conArticolo, miniatura: a.arteThumb, piena: a.artePiena),
      ];
    }
    return const [];
  }

  static List<ImmagineDelRicordo> _segno(String? nome) {
    if (nome == null) return const [];
    for (final z in Zodiac.values) {
      if (!_stessoNome(z.italianName, nome) &&
          !_stessoNome(z.id, nome) &&
          !_stessoNome(z.name, nome)) {
        continue;
      }
      // **I DUE TAGLI DELLO ZODIACO NON SONO LA STESSA IMMAGINE RIDOTTA**, ed
      // e' scritto in `ZodiacArt`: la miniatura e' il simbolo, la piena e'
      // l'emblema. Si prendono i due file veri, come fa il resto dell'app.
      return [
        ImmagineDelRicordo(
          nome: z.italianName,
          miniatura: ZodiacArt.symbolPath(z),
          piena: ZodiacArt.emblemPath(z),
        ),
      ];
    }
    return const [];
  }
}
