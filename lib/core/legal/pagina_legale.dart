/// LA PAGINA LEGALE, UNA SOLA. Ordine EA voce 18.
///
/// **Il fatto, dal fondatore**: *"ok per l'unione delle tre pagine"*.
/// Privacy policy, condizioni d'uso e disclaimer stavano in tre posti
/// diversi: la policy in una schermata sua, il disclaimer stampato dentro
/// Privacy e permessi, e le condizioni da nessuna parte, perche' non
/// esistevano. Adesso sono tre sezioni di una pagina sola, ognuna col suo
/// titolo, e nessun contenuto e' andato perso.
///
/// **Le tre parti restano tre dati distinti**, e questa e' la casa che le
/// mette in fila: la policy in `privacy_policy.dart`, le condizioni in
/// `condizioni_uso.dart`, il disclaimer in `ArtCatalog.disclaimerCornice`,
/// che e' lo stesso testo che le arti mostrano. Copiarlo qui avrebbe creato
/// una seconda verita'.
library;

import '../arts/art_catalog.dart';
import 'condizioni_uso.dart';
import 'privacy_policy.dart';

/// Le tre parti della pagina, nell'ordine in cui si leggono.
enum ParteLegale {
  /// L'informativa privacy. **E' la prima** perche' e' quella che gli store
  /// chiedono e quella che le persone cercano.
  privacy('privacy', 'Privacy policy'),

  condizioni('condizioni', 'Condizioni d\'uso'),

  disclaimer('disclaimer', 'Disclaimer');

  const ParteLegale(this.ancora, this.titolo);

  /// Il nome corto con cui si apre la pagina su questa parte, in app e nella
  /// pagina web: `.../legale#privacy`.
  final String ancora;

  /// Il titolo a video.
  final String titolo;
}

/// Il contenuto di una parte: la data della sua ultima revisione, una riga
/// che apre e le sezioni.
class ContenutoLegale {
  const ContenutoLegale({
    required this.parte,
    required this.data,
    required this.apertura,
    required this.sezioni,
  });

  final ParteLegale parte;
  final String data;
  final String apertura;
  final List<SezioneDellaPolicy> sezioni;
}

/// **IL DISCLAIMER E' UNA SEZIONE SOLA**, ed e' giusto: sono due frasi, e
/// spezzarle in sottosezioni vorrebbe dire gonfiarle.
const List<SezioneDellaPolicy> sezioniDelDisclaimer = [
  SezioneDellaPolicy(
    titolo: 'La cornice delle arti',
    corpo: ArtCatalog.disclaimerCornice,
  ),
  SezioneDellaPolicy(
    titolo: 'Che cosa vuol dire, in pratica',
    corpo: 'I responsi del Cerchio accompagnano il respiro, l\'umore, il '
        'presagio e il simbolo come cammino di consapevolezza. Non '
        'sostituiscono un medico, uno psicologo, un avvocato o un '
        'consulente, e non predicono il futuro. Il cielo, quando entra in un '
        'responso, e\' calcolato davvero, e l\'app dice sempre da dove viene '
        'il dato: l\'interpretazione, invece, e\' lettura simbolica.',
  ),
];

/// Le tre parti, in fila.
List<ContenutoLegale> get paginaLegale => const [
      ContenutoLegale(
        parte: ParteLegale.privacy,
        data: dataDellaPolicy,
        apertura: titolareDellaPolicy,
        sezioni: sezioniDellaPolicy,
      ),
      ContenutoLegale(
        parte: ParteLegale.condizioni,
        data: dataDelleCondizioni,
        apertura: 'Queste condizioni valgono fra te ed Esoteric Circle '
            '(esotericircle.app) ogni volta che usi l\'app.',
        sezioni: sezioniDelleCondizioni,
      ),
      ContenutoLegale(
        parte: ParteLegale.disclaimer,
        data: dataDelleCondizioni,
        apertura: 'Il Cerchio lo dice una volta all\'ingresso e lo tiene '
            'scritto qui, per chi vuole rileggerlo.',
        sezioni: sezioniDelDisclaimer,
      ),
    ];

/// La parte che risponde a un'ancora, oppure la privacy: un indirizzo
/// sbagliato non deve aprire il vuoto.
ParteLegale parteDallAncora(String? ancora) => ParteLegale.values.firstWhere(
      (p) => p.ancora == ancora,
      orElse: () => ParteLegale.privacy,
    );
