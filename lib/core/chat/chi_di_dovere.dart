import '../maestro/consiglio_finale.dart';
import '../maestro/maestro.dart';

/// **SULLE QUESTIONI LEGALI, MEDICHE O DI DENARO SI INDIRIZZA A CHI DI
/// DOVERE, SEMPRE.** Ordine EN voce 08, 25 settembre 2026.
///
/// L'ordine: *"sulle questioni legali indirizza a chi di dovere"*, dal
/// Briefing Operativo MVP e Demo V9 e dalla mossa 12 del catalogo dell'ordine
/// EB. La regola sta nell'istruzione di sistema, e **il collaudo con Gemini
/// vero l'ha misurata**: nella prima risposta alla domanda sulla moglie
/// andata dall'avvocato, l'avvocato compariva 0 volte su 6 prima della cura,
/// 5 su 6 e poi 4 su 6 con la regola scritta (`docs/collaudo/EN/risposte/`).
/// Una regola che dipende dal modello regge quasi sempre; questa deve reggere
/// sempre, perche' e' la frase che protegge chi scrive.
///
/// **Qui la si guarda a valle, e non si chiede di nuovo**: se la persona ha
/// nominato un avvocato, un medico o il denaro e la risposta non indica a chi
/// rivolgersi, la frase si aggiunge in fondo al testo, prima della riga
/// d'oro, con la voce del Maestro che parla. Nessuna seconda chiamata: nel
/// LIVE sarebbe attesa pura.
abstract final class ChiDiDovere {
  /// I temi, con le radici che li riconoscono nella domanda e chi li segue.
  static const List<({String tema, List<String> radici, String chi})> temi = [
    (
      tema: 'legale',
      radici: [
        'avvocat',
        'separazion',
        'divorzi',
        'tribunal',
        'giudice',
        'causa legale',
        'affidamento',
        'denuncia',
      ],
      chi: 'avvocato',
    ),
    (
      tema: 'medica',
      radici: [
        'medic',
        'malatt',
        'diagnosi',
        'farmac',
        'ospedal',
        'terapia',
      ],
      chi: 'medico',
    ),
    (
      tema: 'economica',
      radici: [
        'debit',
        'mutuo',
        'prestit',
        'investiment',
        'fallimento',
      ],
      chi: 'consulente',
    ),
  ];

  /// Le parole che dicono gia' a chi rivolgersi, in una risposta.
  static final RegExp gliIndirizza = RegExp(
      r'avvocat|legale|medic|dottor|specialist|professionist|consulent|'
      r'commercialist|notai',
      caseSensitive: false);

  /// Il tema che la persona ha toccato, o null.
  static ({String tema, List<String> radici, String chi})? temaDi(
      String domanda) {
    final d = domanda.toLowerCase();
    for (final t in temi) {
      if (t.radici.any(d.contains)) return t;
    }
    return null;
  }

  /// La frase, detta dal Maestro che parla. Nessuna parola di firma degli
  /// altri due, e nessuna proposizione dopo la virgola che cominci con "e".
  static String frase(Maestro maestro, String chi) {
    final a = switch (chi) {
      'avvocato' => 'a un avvocato tuo',
      'medico' => 'a un medico',
      _ => 'a un consulente di fiducia',
    };
    final parte = switch (chi) {
      'avvocato' => 'la parte legale',
      'medico' => 'la salute',
      _ => 'il denaro',
    };
    // **Medora legge il tempo**, ed e' con quello che si fa da parte. La
    // prima stesura diceva "il suo tempo e il tuo non sono lo stesso": sul
    // Realme, sotto la domanda sulla moglie, "il suo" si leggeva come la
    // moglie e non come l'avvocato.
    final carte = switch (chi) {
      'avvocato' => 'le carte bollate',
      'medico' => 'le analisi',
      _ => 'i conti',
    };
    return switch (maestro) {
      Maestro.medora => 'Per $parte affidati $a: io leggo il tempo, non '
          '$carte.',
      Maestro.aura => 'Per $parte affidati $a: a te resta lo spazio per '
          'stare bene.',
      Maestro.caligo => 'Per $parte non guardare a me. Affidati $a.',
    };
  }

  /// La risposta con la frase, se la domanda la chiede e la risposta non
  /// l'ha gia'; altrimenti la risposta com'e'.
  static String conLaFrase({
    required Maestro maestro,
    required String domanda,
    required String risposta,
  }) {
    final tema = temaDi(domanda);
    if (tema == null) return risposta;
    final corpo = ConsiglioFinale.corpoDa(risposta);
    if (gliIndirizza.hasMatch(corpo)) return risposta;
    final aggiunta = frase(maestro, tema.chi);
    final righe = risposta.split('\n');
    final stella = righe
        .lastIndexWhere((r) => r.trim().startsWith(ConsiglioFinale.stella));
    if (stella < 0) return '${risposta.trimRight()}\n\n$aggiunta';
    final prima = righe.sublist(0, stella).join('\n').trimRight();
    final dopo = righe.sublist(stella).join('\n');
    return '$prima\n\n$aggiunta\n\n$dopo';
  }
}
