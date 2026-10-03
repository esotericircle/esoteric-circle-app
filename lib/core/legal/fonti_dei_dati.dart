/// LE FONTI DEI DATI, e la licenza di ognuna. Ordine CC voce 07.
///
/// **Perche' esiste questo file.** Il vincolo della voce dice: "la licenza
/// della fonte va letta e dichiarata prima di importare qualunque dato. L'app
/// e' commerciale a sorgente chiuso". Il catalogo dei luoghi di nascita viene
/// dai dump pubblici di GeoNames, che stanno sotto **Creative Commons
/// Attribution 4.0**: quella licenza consente l'uso commerciale e non
/// pretende che il codice si apra, ma **pretende l'attribuzione**. Fino a
/// oggi l'attribuzione viveva soltanto in un commento del generatore, cioe'
/// in un posto che nessuno di fuori puo' leggere: un obbligo assolto dentro
/// casa non e' assolto.
///
/// **Non e' una pagina di ringraziamenti.** E' l'elenco di cosa l'app sa e da
/// dove lo sa, e serve a due persone diverse: a chi ci tiene, che vuole sapere
/// se i numeri vengono da qualche parte o dal nulla, e a noi, perche' una
/// licenza si rispetta a schermo.
class FonteDeiDati {
  const FonteDeiDati({
    required this.cosa,
    required this.chi,
    required this.licenza,
    required this.dove,
  });

  /// Cosa l'app prende da questa fonte, con le parole di chi legge.
  final String cosa;

  /// Chi la pubblica.
  final String chi;

  /// La licenza, col suo nome esatto: un nome approssimato non serve a nulla.
  final String licenza;

  /// Dove sta, perche' chi vuole controllare deve poterci arrivare.
  final String dove;
}

/// **LE FONTI, una per una.**
///
/// L'elenco e' il dato: la schermata lo mostra e basta, e una prova pretende
/// che ogni voce abbia tutte e quattro le sue parti. Una fonte senza licenza
/// scritta e' esattamente il difetto che questo elenco esiste per impedire.
const List<FonteDeiDati> fontiDeiDati = <FonteDeiDati>[
  FonteDeiDati(
    cosa: 'I luoghi di nascita, con le loro coordinate e il loro fuso',
    chi: 'GeoNames',
    licenza: 'Creative Commons Attribution 4.0',
    dove: 'geonames.org',
  ),
  FonteDeiDati(
    cosa: 'Le posizioni dei pianeti, da cui nasce ogni carta natale',
    chi: 'FreeAstroAPI, che calcola sulle effemeridi svizzere di Astrodienst',
    licenza: 'Servizio esterno, interrogato a ogni carta',
    dove: 'astro.com/swisseph',
  ),
  FonteDeiDati(
    cosa: 'Le stelle del cielo di sfondo e le costellazioni',
    chi: 'Catalogo Hipparcos, edizione pubblica ESA 1997',
    licenza: 'Dato pubblico dell\'ESA',
    dove: 'cosmos.esa.int/web/hipparcos',
  ),
];
