/// LA CHIAVE CON CUI SI LEGGE LA STESA. Ordine FI voci 06, 07 e 08, 10 ottobre
/// 2026.
///
/// Quattro chiavi, ognuna con la sua tradizione documentata (il fondatore:
/// "eliminerei quella di Caligo e inserirei tradizione e fonti reali" e
/// "confermo che voglio la quarta"). La chiave non moltiplica il corpus:
/// cambia il registro con cui il modello racconta lo scheletro della carta
/// nella sua posizione, come prescrive il Master Briefing Tecnico, ed entra
/// nell'istruzione come voce ([voce]). La Predittiva e' la lettura di sempre e
/// non aggiunge niente all'istruzione: la stesa a tre carte che il fondatore
/// ha approvato resta la stessa.
///
/// Quale piano apre quale chiave lo dice la matrice dei piani (ordine FI voce
/// 32), non questo file.
library;

import '../entitlement/plan_catalog.dart';
import '../entitlement/tier.dart';

enum ReadingKey {
  predittiva(
    'Predittiva di Medora',
    tradizione: 'La cartomanzia divinatoria di Etteilla, pseudonimo di '
        'Jean-Baptiste Alliette, primo cartomante professionista a pubblicare '
        'metodi di lettura, anni 1780.',
  ),
  riflessione(
    'Riflessione',
    tradizione: 'La Tarologia di Alejandro Jodorowsky e Marianne Costa, La '
        'Voie du Tarot, 2004: una lettura dichiaratamente non predittiva.',
    nota: 'Ispirata al lavoro di Alejandro Jodorowsky, senza rapporto '
        'ufficiale.',
    riga: RigaDelPiano.chiaveRiflessione,
  ),
  esoterica(
    'Esoterica',
    tradizione: 'Arthur Edward Waite (The Pictorial Key to the Tarot, 1911) e '
        "l'Ordine Ermetico dell'Alba Dorata.",
    riga: RigaDelPiano.chiaviEsotericaEArchetipica,
  ),
  archetipica(
    'Archetipica',
    tradizione: 'Sallie Nichols (Jung and Tarot, 1980) e Rachel Pollack '
        '(Seventy-Eight Degrees of Wisdom, 1980).',
    riga: RigaDelPiano.chiaviEsotericaEArchetipica,
  );

  const ReadingKey(this.label,
      {required this.tradizione, this.nota, this.riga});

  /// Il nome nel selettore.
  final String label;

  /// La tradizione da cui viene la chiave, per il Foglio delle Fonti.
  final String tradizione;

  /// La nota etica sotto la voce, quando serve: la Riflessione e'
  /// un'ispirazione dichiarata, mai un marchio.
  final String? nota;

  /// La riga della matrice dei piani che la apre; nessuna per la Predittiva,
  /// che e' di tutti.
  final RigaDelPiano? riga;

  /// Nota da mostrare sotto la voce, quando serve.
  String? get note => nota;

  /// Esiste nell'app: tutte e quattro, dall'ordine FI. Chi la puo' scegliere
  /// lo dice [apribileDa].
  bool get available => true;

  /// **SE QUESTO PIANO PUO' SCEGLIERE QUESTA CHIAVE.** Ordine FI voce 32: la
  /// Predittiva a tutti, la Riflessione dall'Iniziato, Esoterica e
  /// Archetipica dall'Adepto.
  bool apribileDa(Tier tier) {
    final r = riga;
    return r == null || PlanCatalog.apre(r, tier);
  }

  /// **LA LETTURA DI CASA SI DICHIARA** (voce 08): quando il modello non
  /// risponde parla la lettura di casa, che e' nella chiave Predittiva, e chi
  /// ha scelto un'altra chiave lo legge invece di credere che sia la sua.
  String get rigaDellaLetturaDiCasa => 'Questa è la lettura di casa, nella '
      'chiave Predittiva di Medora, non nella chiave $label.';

  /// **LA VOCE DELLA CHIAVE, detta al modello** (voce 07). Nulla per la
  /// Predittiva: la sua istruzione e' quella di sempre. Con la Riflessione il
  /// futuro si legge come tendenza e mai come annuncio, perche' quella scuola
  /// non predice.
  ///
  /// **OGNI VOCE DICE CHE COSA CAMBIA, e sta in cima. Ordine FS, 13 ottobre
  /// 2026.** Le voci di prima descrivevano la tradizione e stavano in fondo
  /// all'istruzione: misurate con sedici letture vere (due stese, quattro
  /// chiavi, due giri ciascuna, `docs/collaudo/FS/le_chiavi_dal_modello.txt`)
  /// nessuna chiave si distingueva dalle altre, e due chiavi diverse si
  /// somigliavano quanto due giri della stessa. Adesso ogni voce dice che
  /// cosa cambia nella RISPOSTA e in ogni carta, e che prevale su quelle due
  /// regole; le regole di prudenza (niente futuro dato per certo, il
  /// confine, il genere) restano sopra tutte.
  String? get voce => switch (this) {
        ReadingKey.predittiva => null,
        ReadingKey.riflessione => 'LA CHIAVE DI LETTURA, che prevale sulle '
            'regole della RISPOSTA e delle CARTE qui sotto: Riflessione, '
            'nella tradizione della Tarologia di Alejandro Jodorowsky e '
            'Marianne Costa. Questa lettura non predice. La RISPOSTA non dice '
            'sì, no né se la cosa accadrà: la prima frase dice che cosa la '
            'stesa mostra di come la persona vive la sua domanda, la seconda '
            'quale scelta ha davanti, partendo dalla carta chiave. In ogni '
            'carta scrivi che cosa la carta rispecchia della persona davanti '
            'alla sua domanda, e chiudi con una domanda che la persona può '
            'farsi. Anche la carta del futuro si legge come una tendenza da '
            'riconoscere, mai come un annuncio. Non nominare Jodorowsky.',
        ReadingKey.esoterica => "LA CHIAVE DI LETTURA, che prevale sulle "
            "regole della RISPOSTA e delle CARTE qui sotto: Esoterica, nella "
            "tradizione di Arthur Edward Waite e dell'Ordine Ermetico "
            "dell'Alba Dorata. In ogni carta nomina almeno un simbolo "
            "dell'immagine di Waite (una figura, un oggetto, un colore) e che "
            "cosa significa in quella tradizione; la corrispondenza della "
            "carta con un elemento, un pianeta o un segno nominala solo "
            "quando la conosci con certezza, e non inventarla. La seconda "
            "frase della RISPOSTA parte dal simbolo della carta chiave. Il "
            "simbolo serve a rispondere alla domanda, non a fare lezione.",
        ReadingKey.archetipica => 'LA CHIAVE DI LETTURA, che prevale sulle '
            'regole della RISPOSTA e delle CARTE qui sotto: Archetipica, nella '
            'lettura di Sallie Nichols e di Rachel Pollack. In ogni carta '
            'nomina l\'archetipo che la carta incarna (il Viandante, il '
            'Mago, la Madre, il Guerriero, l\'Eremita e cosi\' via) e quale '
            'passaggio del cammino interiore della persona rappresenta '
            'rispetto alla sua domanda. La RISPOSTA dice in quale passaggio '
            'del suo cammino si trova la persona e che cosa quel passaggio le '
            'chiede. Niente linguaggio clinico e niente diagnosi.',
      };

  /// **IL PROMEMORIA DELLA CHIAVE, in fondo alla richiesta**, ordine FS:
  /// una riga sola che ripete che cosa cambia, letta dove il modello sta per
  /// scrivere. Nulla per la Predittiva.
  String? get promemoria => switch (this) {
        ReadingKey.predittiva => null,
        ReadingKey.riflessione => 'Chiave di lettura: Riflessione. La '
            'RISPOSTA non dice sì, no né se la cosa accadrà: dice come la '
            'persona vive la sua domanda e quale scelta ha davanti. Ogni '
            'carta chiude con una domanda che la persona può farsi.',
        ReadingKey.esoterica => "Chiave di lettura: Esoterica. In ogni carta "
            "nomina almeno un simbolo dell'immagine di Waite e che cosa "
            "significa in quella tradizione.",
        ReadingKey.archetipica => "Chiave di lettura: Archetipica. In ogni "
            "carta nomina l'archetipo che la carta incarna e il passaggio "
            "del cammino interiore che rappresenta per la persona.",
      };
}
