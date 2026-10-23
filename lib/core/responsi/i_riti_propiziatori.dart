import 'i_riti_propiziatori_dati.dart';

/// **I RITI PROPIZIATORI**, il quarto paragrafo della Lunga. Ordine GA voce
/// GA.04, 20 ottobre 2026. Il fondatore, 20 ottobre 2026 alle 00:10: *"porta
/// il titolo 'il mantra propiziatorio' che conterrà un mantra semplice da
/// effettuare per propiziare e aiutare il responso"*; alle 00:16, *"scegli
/// tu su tutto"*.
///
/// I testi stanno in `docs/corpus/riti/*.md`, ognuno con la sua fonte
/// documentata, e arrivano qui da `tool/genera_i_riti.py`. Ogni rito ha da 40
/// a 50 parole, formula compresa, e non promette niente: accompagna. Le
/// chiavi sono quelle delle intestazioni delle raccolte.
abstract final class IRitiPropiziatori {
  /// Le raccolte, coi nomi dei file.
  static const String inniOrfici = 'inni_orfici';
  static const String mantraNavagraha = 'mantra_navagraha';
  static const String gestiTongShu = 'gesti_tong_shu';
  static const String salmiMartini = 'salmi_martini';
  static const String galdr = 'galdr_delle_rune';
  static const String contemplazione = 'contemplazione_dei_tarocchi';

  static String _k(String raccolta, List<String> chiave) =>
      [raccolta, ...chiave].join('|');

  /// Il rito della raccolta per [chiave] (per esempio `['Marte', 'Amore',
  /// 'giorno']`), o null se la raccolta non lo ha.
  static String? rito(String raccolta, List<String> chiave) =>
      IRitiPropiziatoriDati.riti[_k(raccolta, chiave)];

  /// La riga del "Da dove viene" del rito: quella della sua sezione, se c'e'
  /// (i salmi), poi quella del pianeta, del graha o dell'ufficiale (la prima
  /// parte della chiave), poi quella della raccolta intera.
  static String? fonte(String raccolta, List<String> chiave) =>
      IRitiPropiziatoriDati.fonti[_k(raccolta, chiave)] ??
      (chiave.isEmpty
          ? null
          : IRitiPropiziatoriDati.fonti[_k(raccolta, [chiave.first])]) ??
      IRitiPropiziatoriDati.fonti[raccolta];
}
