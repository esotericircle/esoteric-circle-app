import '../responsi/la_forma_del_responso.dart';
import 'l_oggetto_della_domanda.dart';
import 'la_risposta_della_gettata.dart';

/// **LE RISPOSTE DIRETTE DELLE RUNE, SCRITTE PER PIETRA E PER TIPO DI
/// DOMANDA.** Ordine GA voce GA.06, il secondo giro della cura delle Rune di
/// Caligo, 21 ottobre 2026.
///
/// Il corpus sta in `docs/corpus/rune/diretta.md` (il paragrafo della
/// risposta) e `azione.md` (il riquadro "Cosa fare adesso"), un gruppo per
/// runa, verso e tipo di domanda; lo controlla e lo porta nel codice
/// `tool/controlla_le_risposte_dirette_delle_rune.py` (le regole) e
/// `tool/genera_le_risposte_dirette_delle_rune.py` (il generato
/// `le_risposte_dirette.g.dart`). Ogni voce ha uno spazio solo: `{azione}`
/// nelle decisioni ("prima di {azione}"), `{cosa}` negli altri tipi ("per
/// {cosa}"). Qui si decide quale tipo del corpus serve a una domanda e con
/// che cosa si riempie lo spazio.
abstract final class LeRisposteDirette {
  /// I sette tipi del corpus.
  static const List<String> tipi = [
    'decisione', 'scelta', 'come', 'quando', 'previsione', 'altrui', 'vaga', //
  ];

  /// Il tipo del corpus per una domanda letta; null quando la domanda ha un
  /// altro responso: salute, legge e denaro (il limite composto), la
  /// giornata senza domanda e le domande aperte del Cerchio.
  static String? tipoDelCorpus(LaDomandaLetta q, String domanda) {
    if (q.delicato != null) return null;
    return switch (q.tipo) {
      TipoDiDomanda.decisione => 'decisione',
      TipoDiDomanda.scelta => 'scelta',
      TipoDiDomanda.come => 'come',
      TipoDiDomanda.quando => 'quando',
      TipoDiDomanda.previsione => 'previsione',
      TipoDiDomanda.altrui => 'altrui',
      TipoDiDomanda.tuttoBene || TipoDiDomanda.futuro => 'vaga',
      TipoDiDomanda.aperta =>
        LaDomandaLetta.eVaga(LaDomandaLetta.normalizza(domanda))
            ? 'vaga'
            : null,
      TipoDiDomanda.giornata => null,
    };
  }

  /// I valori dello spazio, dal piu' fedele alle parole di chi chiede al
  /// tema: il compositore prende il primo che fa stare il paragrafo fra 40
  /// e 50 parole.
  static List<String> valori(LaDomandaLetta q, String domanda, String tipo) {
    if (tipo == 'decisione') return LOggettoDellaDomanda.azioni(q.azione);
    // Le vaghe non nominano una cosa: "ciò che ti sta a cuore" si legge
    // dentro ogni voce ("Stasera prenditi dieci minuti per ciò che ti sta a
    // cuore"); "il tuo momento", piu' corto, solo dove l'altro non sta.
    if (tipo == 'vaga') {
      return const ['ciò che ti sta a cuore', 'il tuo momento'];
    }
    final fuori = <String>[];
    for (final v in [
      ...LOggettoDellaDomanda.di(domanda, q.tipo, strade: q.strade),
      q.tema,
    ]) {
      if (!fuori.contains(v)) fuori.add(v);
    }
    return fuori;
  }

  /// I valori in ordine, prima quelli la cui ultima parola la voce non dice
  /// gia' da sola.
  static List<String> senzaRipetizioni(String voce, List<String> valori) {
    final minuscola = voce.toLowerCase();
    bool ripete(String v) {
      final ultima = v.toLowerCase().split(' ').last;
      return ultima.length > 3 &&
          LaDomandaLetta.parola(RegExp.escape(ultima)).hasMatch(minuscola);
    }

    return [...valori.where((v) => !ripete(v)), ...valori.where(ripete)];
  }

  /// La voce con lo spazio riempito (e la nota della domanda doppia, se
  /// c'e'), fra 40 e 50 parole; null se nessun valore la fa stare.
  static String? riempi(String voce, List<String> valori,
      {List<String> note = const ['']}) {
    final spazio = voce.contains('{azione}') ? '{azione}' : '{cosa}';
    // Prima i valori che la voce non ripete gia' con parole sue ("Restringi
    // la domanda a ciò che ti sta più a cuore" con "per ciò che ti sta a
    // cuore" dentro), poi, se nessuno sta nella misura, anche quelli.
    final ordinati = senzaRipetizioni(voce, valori);
    for (final n in note) {
      for (final v in ordinati) {
        final t = [voce.replaceAll(spazio, v), n]
            .where((x) => x.isNotEmpty)
            .join(' ');
        if (LaFormaDelResponso.aMisura(t)) return t;
      }
    }
    return null;
  }
}
