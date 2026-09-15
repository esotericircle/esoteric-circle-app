import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_elements.dart';
import '../tokens/color_tokens.dart';
import '../tokens/regime_chiaro.dart';
import 'accento_del_maestro.dart';

/// L'ABITO DEL RESPONSO, uno per famiglia di Dono. Ordine BB voce 09.
///
/// **Il fatto del fondatore**: il responso del Soffio del Destino somiglia a
/// quello del Rito dell'Alba.
///
/// **Aveva ragione, e il difetto era piu' largo della voce.** I Doni sono
/// CINQUE, e portavano tutti la stessa identica scheda, dallo stesso file, con
/// lo stesso vetro crema e lo stesso inchiostro scuro. Non si somigliavano il
/// Soffio e l'Alba: si somigliavano tutti e cinque, e curare la sola coppia
/// che il fondatore ha guardato sarebbe stato un tampone.
///
/// **UN TENTATIVO E' STATO FATTO E BUTTATO, ed e' quello che ha portato alla
/// risposta giusta.** L'idea era dare a ogni Dono una tinta diversa dello
/// stesso vetro chiaro: crema all'alba, azzurro al soffio, indaco
/// all'oracolo, rame alle rune, viola alla notte. Non funziona, e il conto lo
/// dice senza appello: gli inchiostri del regime chiaro discendono dal fondo
/// peggiore misurato, quindi nessuna di quelle tinte poteva scurirsi molto, e
/// **cinque tinte chiare gravitano tutte verso il bianco**. Misurata, la
/// coppia piu' vicina distava 7 punti su 255, e allentando il vincolo fino a
/// far perdere il 12 per cento di luce si arrivava a 21: un cambiamento che
/// nessuno nota, pagato con testo meno leggibile ovunque.
///
/// **La risposta era gia' scritta nel codice, in [RegimeChiaro].** Il regime
/// chiaro esiste perche' "l'alba e' l'unico momento in cui il buio finisce":
/// una ragione narrativa **che nessun altro rito ha**. Il Soffio del Destino
/// e' un rito della sera, l'app e' notturna, e la scheda chiara era arrivata
/// agli altri quattro Doni per eredita', non per una scelta.
///
/// Quindi gli abiti sono **due**, e sono opposti: l'Alba resta di giorno, gli
/// altri quattro tornano di notte. Fra chiaro e scuro non c'e' bisogno di
/// misurare la distanza per sapere che si distinguono.
class AbitoDelResponso {
  const AbitoDelResponso._({
    required this.velatura,
    required this.bordo,
    required this.inchiostro,
    required this.inchiostroMuto,
    required this.incasso,
    required this.superficiePeggiore,
    required this.diGiorno,
  });

  /// Il vetro come viene dipinto, semitrasparente e sfocato.
  final Color velatura;
  final Color bordo;

  /// L'inchiostro forte e quello muto, gia' scelti per reggere su
  /// [superficiePeggiore].
  final Color inchiostro;
  final Color inchiostroMuto;

  /// La superficie interna, dove la scheda incassa qualcosa.
  final Color incasso;

  /// **IL FONDO PEGGIORE CHE UNA LETTERA TROVA DAVVERO**, non il colore del
  /// vetro. E' da qui che discendono inchiostri e accenti: un regime che non
  /// sa su cosa poggia non e' governato, e' sperato. La lezione e' dell'ordine
  /// P voce 12, e vale anche per l'abito di notte.
  final Color superficiePeggiore;

  /// Vero per il solo Rito dell'Alba.
  final bool diGiorno;

  /// L'accento del Maestro del giorno, portato dove si legge **su questo
  /// abito**. Passa dalla porta unica di [AccentoDelMaestro], che scurisce o
  /// schiarisce il colore finche' il contrasto non basta: lo stesso oro che si
  /// legge sul vetro crema sparirebbe sul vetro di notte, e viceversa.
  Color accentoDi(Maestro maestro) =>
      AccentoDelMaestro.su(maestro, superficie: superficiePeggiore);

  /// **L'ABITO DI GIORNO, che e' quello di prima e non e' cambiato.** Era il
  /// pezzo giusto da tenere fermo: ha la sua ragione narrativa, e il suo
  /// contrasto e' gia' misurato a video dall'ordine P.
  static final AbitoDelResponso _diGiorno = AbitoDelResponso._(
    velatura: RegimeChiaro.velatura,
    bordo: RegimeChiaro.bordoDellaVelatura,
    inchiostro: RegimeChiaro.testoSuChiaro,
    inchiostroMuto: _mutoDiGiorno,
    incasso: RegimeChiaro.incassoSuChiaro,
    superficiePeggiore: RegimeChiaro.superficieChiara,
    diGiorno: true,
  );

  /// **IL VETRO DI NOTTE E' PIU' OPACO DI QUELLO DI GIORNO, e non e' un
  /// dettaglio.** Il vetro chiaro sta al 78 per cento sopra una scena di sole
  /// che sale, e cio' che una lettera trova sotto di se' e' la composizione,
  /// non il vetro: e' esattamente il difetto che l'ordine P voce 12 ha dovuto
  /// misurare a video. Portandolo al 92 per cento, quello che passa da sotto
  /// pesa otto parti su cento, e il fondo diventa **prevedibile invece che
  /// sperato**.
  static const Color _vetroDiNotte = Color(0xEB1C1338);

  /// Il caso peggiore per un testo CHIARO e' un fondo chiaro, cioe' il vetro
  /// di notte con sotto la luce piena. Composto: 0,92 del vetro piu' 0,08 di
  /// bianco. Che regga davvero lo misura
  /// `test/il_soffio_non_somiglia_all_alba_test.dart` sul fotogramma vero, e
  /// non su questo conto.
  static const Color _peggioreDiNotte = Color(0xFF2E2548);

  static const AbitoDelResponso _diNotte = AbitoDelResponso._(
    velatura: _vetroDiNotte,
    bordo: Color(0x33FFFFFF),
    inchiostro: ColorTokens.textPrimary,
    inchiostroMuto: ColorTokens.textSecondary,
    incasso: Color(0x1AFFFFFF),
    superficiePeggiore: _peggioreDiNotte,
    diGiorno: false,
  );

  /// L'inchiostro muto del giorno non e' una costante: passa dalla porta del
  /// contrasto. Si copia qui il riferimento perche' un campo `const` non puo'
  /// leggere un getter.
  static final Color _mutoDiGiorno = RegimeChiaro.testoMutoSuChiaro;

  /// **L'unico punto che decide che abito porta un responso.**
  static AbitoDelResponso di(DailyElement dono) =>
      dono == DailyElement.dawn ? _diGiorno : _diNotte;
}
