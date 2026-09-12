/// Risolve i percorsi bundlati delle sei famiglie esoteriche, in WebP a due
/// misure.
///
/// La piena si usa quando la carta e' a fuoco o ingrandita; la miniatura nelle
/// viste con piu' carte (stese, griglie, picker). I file vivono in
/// `assets/img/<famiglia>/<nome>.webp` (piena) e
/// `assets/img_thumb/<famiglia>/<nome>.webp` (miniatura). I conteggi sono sotto
/// il lucchetto della CI: `docs/stato_asset.json`, verificato da
/// `test/stato_asset_test.dart`.
///
/// Questa e' l'unica sorgente dei percorsi: modelli e widget la usano invece di
/// comporre stringhe a mano, cosi' la convenzione si cambia in un punto solo.
enum AssetFamily {
  tarocchi('mazzo-tarocchi'),
  angeli('angeli'),
  vip('ritratti-vip'),
  rune('rune_bone'),
  animali('animali'),
  cristalli('cristalli');

  const AssetFamily(this.folder);

  /// Nome della cartella della famiglia, uguale sotto `assets/img` e
  /// `assets/img_thumb`, e uguale alla sorgente in `output/`.
  final String folder;
}

/// Costruttore dei percorsi asset delle famiglie.
class FamilyImage {
  const FamilyImage._();

  static const String _full = 'assets/img';
  static const String _thumb = 'assets/img_thumb';

  /// Percorso della piena. [stem] e' il nome del file senza estensione, in
  /// minuscolo, per esempio `tar_rw_00_il-matto_v1`.
  static String full(AssetFamily family, String stem) =>
      '$_full/${family.folder}/$stem.webp';

  /// Percorso della miniatura, stessa nomenclatura della piena.
  static String thumb(AssetFamily family, String stem) =>
      '$_thumb/${family.folder}/$stem.webp';
}
