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
  String? get voce => switch (this) {
        ReadingKey.predittiva => null,
        ReadingKey.riflessione => 'LA CHIAVE DI LETTURA: Riflessione, nella '
            'tradizione della Tarologia di Alejandro Jodorowsky e Marianne '
            'Costa. Questa lettura non predice: ogni carta è uno specchio di '
            'come la persona vive la situazione e delle scelte che ha davanti. '
            'Anche la carta del futuro si legge come una tendenza da '
            'riconoscere, mai come un annuncio: di\' che cosa la persona può '
            'osservare o cambiare, non che cosa le accadrà. Non nominare '
            'Jodorowsky.',
        ReadingKey.esoterica => "LA CHIAVE DI LETTURA: Esoterica, nella "
            "tradizione di Arthur Edward Waite e dell'Ordine Ermetico "
            "dell'Alba Dorata. Leggi i simboli della carta come li descrive "
            "quella tradizione e, quando li conosci con certezza, la sua "
            "corrispondenza con un elemento, un pianeta o un segno; non "
            "inventare corrispondenze. Il simbolo serve a rispondere alla "
            "domanda, non a fare lezione.",
        ReadingKey.archetipica => 'LA CHIAVE DI LETTURA: Archetipica, nella '
            'lettura di Sallie Nichols e di Rachel Pollack. Ogni carta è un '
            'archetipo, una figura che vive in ognuno: la stesa racconta un '
            'passaggio del cammino interiore della persona rispetto alla sua '
            'domanda. Niente linguaggio clinico e niente diagnosi.',
      };
}
