import '../maestro/maestro.dart';

/// Il formato di una scheda: ognuno ha il suo sfondo, disegnato per quella
/// misura e non ritagliato da un altro.
enum FormatoDellaScheda {
  /// 800 per 1000, 4:5.
  verticale('Vert', 4 / 5),

  /// 800 per 800.
  quadrata('Square', 1),

  /// 1280 per 720, 16:9.
  orizzontale('Oriz', 16 / 9);

  const FormatoDellaScheda(this.nelNome, this.proporzione);

  /// La parte del nome del file che dice il formato.
  final String nelNome;

  /// Larghezza su altezza.
  final double proporzione;
}

/// **GLI SFONDI DELLE SCHEDE.** Ordine EO voce 01, 26 settembre 2026.
///
/// Il fondatore: *"Allora, iniziamo a fare tutte le schede dell'ultimo
/// elenco, 10 per ogni maestro. Poi deciderò quali inserire in MVP."* Gli
/// sfondi li ha generati lui, tre formati per arte, e stanno in
/// `assets/schede/` col nome `<Nome>-<Vert|Square|Oriz>-1.webp`: 99 file,
/// trenta arti e i tre sfondi dei Maestri senza emblema (voce EO.13).
///
/// **Un'arte si lega al suo sfondo per identificativo del catalogo**, qui e
/// in nessun altro posto: la scheda chiede [perArte] e non compone nomi di
/// file da se'. Le fasi del catalogo non cambiano: quali arti entrano in MVP
/// lo decide il fondatore dopo.
abstract final class GliSfondiDelleSchede {
  static const String cartella = 'assets/schede';

  /// Il nome di ogni arte nei file, per identificativo del catalogo, nell'ordine
  /// dell'ordine EO: dieci per Maestro.
  static const Map<String, String> nomi = {
    // Medora
    'horoscope': 'Oroscopo',
    'tarot_spread_three': 'Tarocchi',
    'angels_oracle': 'Oracolo-Angeli',
    'lunology': 'Respiro-Luna',
    'synastry_vip': 'Sinastria-Vip',
    'lunar_affinity': 'Affinita-Lunare',
    'synastry_depth': 'Sinastria-Approfondita',
    'friends_compatibility': 'Compatibilita-Amici',
    'pet_astrology': 'Pet-Astrology',
    'narrative_destiny': 'Destino-Narrativo',
    // Aura
    'meditation': 'Meditazione',
    'sleep_stories': 'Sleep-Stories',
    'daily_affirmations': 'Affermazioni',
    'mood_tracker': 'Mood-Tracker',
    'chakra_scan': 'Scan-Chakra',
    'crystal_oracle': 'Oracolo-Cristalli',
    'energy_cleansing': 'Purificazione',
    'face_constellation': 'Mappa-Viso',
    'aura_analysis': 'Analisi-Aura',
    'biorhythm': 'Bioritmo',
    // Caligo
    'rune_draw': 'Rune',
    'guide_animal': 'Viaggio-Sciamano',
    'micro_rituals': 'Micro-Rituali',
    'magic_sigil': 'Sigillo-Intenzione',
    'angel_numbers': 'Numeri-Ricorrenti',
    'coffee_reading': 'Fondi-Caffe',
    'dream_reading': 'Interpretazione-Sogni',
    'pendulum': 'Pendolo',
    'i_ching': 'I-Ching',
    'numerology': 'Numerologia-Destino',
  };

  /// Lo sfondo di ogni Maestro senza emblema, per la riga "In arrivo".
  static const Map<Maestro, String> deiMaestri = {
    Maestro.medora: 'Sfondo-Medora',
    Maestro.aura: 'Sfondo-Aura',
    Maestro.caligo: 'Sfondo-Caligo',
  };

  /// **LA SCHEDA "CONSULTA" DI OGNI MAESTRO.** Ordine EP voce 12, 26
  /// settembre 2026. Il fondatore: *"Nel dominio di ogni maestro serve anche
  /// fare la scheda "Consulta [nome Maestro]"."* **Entra solo il formato
  /// orizzontale**, sulla correzione del fondatore a ordine aperto: *"in
  /// ogni dominio, in alto ci devi mettere la scheda della chat orizzontale e
  /// non quadrata."* L'ordine diceva verticale; i quadrati e i verticali
  /// della sua cartella restano fuori.
  static const Map<Maestro, String> consultaDei = {
    Maestro.medora: 'Consulta-Medora',
    Maestro.aura: 'Consulta-Aura',
    Maestro.caligo: 'Consulta-Caligo',
  };

  /// Lo sfondo orizzontale della scheda "Consulta" di [maestro].
  static String consultaDi(Maestro maestro) =>
      _file(consultaDei[maestro]!, FormatoDellaScheda.orizzontale);

  static String _file(String nome, FormatoDellaScheda formato) =>
      '$cartella/$nome-${formato.nelNome}-1.webp';

  /// Lo sfondo dell'arte [id] nel [formato], o null se l'arte non ne ha.
  static String? perArte(String id, FormatoDellaScheda formato) {
    final nome = nomi[id];
    return nome == null ? null : _file(nome, formato);
  }

  /// Lo sfondo senza emblema di [maestro] nel [formato].
  static String delMaestro(Maestro maestro, FormatoDellaScheda formato) =>
      _file(deiMaestri[maestro]!, formato);

  /// Tutti i file che le schede usano: 102, i 99 dell'ordine EO e i tre
  /// orizzontali di "Consulta" dell'ordine EP.
  static List<String> tutti() => [
        for (final nome in [...nomi.values, ...deiMaestri.values])
          for (final f in FormatoDellaScheda.values) _file(nome, f),
        for (final m in Maestro.values) consultaDi(m),
      ];
}
