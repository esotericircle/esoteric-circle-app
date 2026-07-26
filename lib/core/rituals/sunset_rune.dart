import '../astro/moon_phase.dart';
import '../astro/zodiac.dart';
import 'rune_cast.dart' show RuneVerso, kRuneSimmetriche;
import 'runes.dart';

/// L'estrazione della Runa del Tramonto: runa, verso, fase lunare e segno, tutti
/// reali e deterministici dal giorno rituale incrociato con la carta di nascita.
class EstrazioneTramonto {
  const EstrazioneTramonto({
    required this.giornoRituale,
    required this.rune,
    required this.verso,
    required this.fase,
    required this.segno,
  });

  /// La data del giorno rituale, alla mezzanotte.
  final DateTime giornoRituale;

  final Rune rune;
  final RuneVerso verso;
  final MoonPhase fase;
  final Zodiac segno;

  /// Vero se la runa e' simmetrica, senza verso d'ombra.
  bool get simmetrica => kRuneSimmetriche.contains(rune.name);

  /// Vero se la runa e' uscita in merkstave, il verso d'ombra.
  bool get inOmbra => verso == RuneVerso.merkstave;

  /// La riga semantica dal corpus di runes.dart, secondo l'orientamento.
  String get riga => inOmbra ? rune.shadow : rune.upright;

  /// La data del giorno rituale in ISO, per la chiave e la memoria.
  String get giornoIso => SunsetRune.iso(giornoRituale);
}

/// Il motore deterministico della Runa del Tramonto. Nessuna AI, nessuna rete.
///
/// Il Dono appartiene al tramonto, non alla data di calendario: il giorno
/// rituale ha confine a mezzogiorno locale. La runa nasce da un hash FNV-1a a 64
/// bit sulla data del tramonto incrociata con la nascita e col segno, cosi' non
/// e' piu' la stessa per tutti ne ciclica. Il set delle rune simmetriche e' quello
/// dell'Estrazione Rune, riusato, non duplicato.
class SunsetRune {
  const SunsetRune._();

  /// La soglia del verso d'ombra, su cento. Non cinquanta: un dono quotidiano
  /// cupo una volta su due logora.
  static const int kSogliaOmbra = 35;

  /// Il giorno rituale per un'ora locale: prima di mezzogiorno e' quello di ieri,
  /// cosi' chi apre all'una di notte vede ancora la runa della sera passata.
  static DateTime giornoRituale(DateTime ora) {
    final oggi = DateTime(ora.year, ora.month, ora.day);
    return ora.hour < 12 ? oggi.subtract(const Duration(days: 1)) : oggi;
  }

  /// Estrae la runa del tramonto per [ora] locale, con la [dataNascita] se nota
  /// e il [segno] solare del profilo. Deterministica e offline.
  static EstrazioneTramonto estrai(
    DateTime ora, {
    DateTime? dataNascita,
    Zodiac? segno,
  }) {
    final giorno = giornoRituale(ora);
    final segnoUtente = segno ??
        (dataNascita != null ? Zodiac.fromDate(dataNascita) : Zodiac.aries);
    final chiave = _chiave(giorno, dataNascita, segnoUtente);

    final indice = _fnv1a(chiave) % kElderFuthark.length;
    final rune = kElderFuthark[indice];

    final simmetrica = kRuneSimmetriche.contains(rune.name);
    final ombra =
        !simmetrica && (_fnv1a("$chiave|verso") % 100) < kSogliaOmbra;
    final verso = ombra ? RuneVerso.merkstave : RuneVerso.dritto;

    // La fase lunare vera della sera del giorno rituale.
    final fase = MoonPhase.forDate(giorno.add(const Duration(hours: 18)));

    return EstrazioneTramonto(
      giornoRituale: giorno,
      rune: rune,
      verso: verso,
      fase: fase,
      segno: segnoUtente,
    );
  }

  /// L'indice deterministico di insistenza, da 0 a 3, per la clausola del
  /// ritorno quando la runa e' gia' uscita negli ultimi sette giorni rituali.
  static int indiceInsistenza(EstrazioneTramonto e, DateTime? dataNascita) {
    final chiave = _chiave(e.giornoRituale, dataNascita, e.segno);
    return _fnv1a("$chiave|insistenza") % 4;
  }

  /// La chiave della cerniera col Rito del Sogno.
  static const String chiaveCerniera = "sunset_rune_last";

  /// La data in ISO yyyy-MM-dd.
  static String iso(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.day.toString().padLeft(2, '0')}";

  static String _chiave(DateTime giorno, DateTime? nascita, Zodiac segno) {
    final n = nascita != null ? iso(nascita) : "anon";
    return "sunset_rune|${iso(giorno)}|$n|${segno.id}";
  }

  /// FNV-1a a 64 bit. Su interi nativi a 64 bit l'overflow avvolge, quindi e'
  /// il vero FNV-1a; il modulo con divisore positivo torna sempre non negativo.
  static int _fnv1a(String s) {
    var h = 0xcbf29ce484222325; // offset basis, avvolto in signed 64 bit
    const prime = 0x100000001b3;
    for (final c in s.codeUnits) {
      h ^= c;
      h *= prime;
    }
    return h;
  }
}
