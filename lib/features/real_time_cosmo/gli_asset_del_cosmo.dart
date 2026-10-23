/// GLI ASSET DEL COSMO, ordine FH parte 0.
///
/// I dieci asset consegnati dall'Architetto il 9 ottobre 2026 in
/// `assets/img/cosmo/` (802.958 byte), e il file delle linee delle figure in
/// `assets/astro/`. Un elenco solo, letto dalla schermata e dalla guardia
/// `test/real_time_cosmo_ogni_asset_ha_il_suo_file_test.dart`.
library;

/// Il file delle 187 linee delle 24 figure, scritte dall'Architetto sul
/// catalogo HYG: forme classiche degli atlanti, nessuna riga da Stellarium.
const String kLineeDelleFigure = 'assets/astro/linee_delle_figure.json';

enum AssetDelCosmo {
  viaLattea('via_lattea'),
  orizzonte('orizzonte'),
  luna('luna'),
  giove('giove'),
  saturno('saturno'),
  orione('orione'),
  andromeda('andromeda'),
  pleiadi('pleiadi'),
  laguna('laguna'),
  doppioAmmasso('doppio_ammasso');

  const AssetDelCosmo(this.nome);
  final String nome;

  String get percorso => 'assets/img/cosmo/$nome.webp';
}
