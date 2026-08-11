import 'dart:ui';

import '../../design_system/components/stelle_da_unire.dart';

/// LE COSTELLAZIONI DEI DODICI ANIMALI GUIDA, ordine L voce 3d.
///
/// Ogni animale ha la PROPRIA costellazione: l'insieme dei suoi punti
/// cardinali presi dalla SUA sagoma (testa, garrese, ali, zampe, coda), non
/// un disegno generico ripetuto dodici volte. I dodici blocchi vivono qui,
/// in un file di dati solo, cosi' si confrontano fra loro e si correggono in
/// un posto solo.
///
/// Le coordinate sono normalizzate 0..1 sulla tela della figura (origine in
/// alto a sinistra); l'ORDINE dei punti e' l'ordine del tocco, e i fili
/// dicono quali segmenti si accendono. La guardia
/// `test/le_costellazioni_degli_animali_test.dart` pretende dodici insiemi
/// tutti diversi fra loro.
class CostellazioneAnimale {
  const CostellazioneAnimale({required this.animale, required this.figura});

  /// Il nome dell'animale, identico a quello del catalogo.
  final String animale;

  final FiguraDaUnire figura;
}

const List<CostellazioneAnimale> kCostellazioniAnimali = [
  // L'AQUILA ad ali spiegate, vista frontale: becco in alto, le due ali
  // larghe, il corpo che scende alla coda aperta.
  CostellazioneAnimale(
    animale: 'Aquila',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('becco', Offset(0.50, 0.06)),
      PuntoDaUnire('capo', Offset(0.44, 0.14)),
      PuntoDaUnire('ala sinistra', Offset(0.06, 0.26)),
      PuntoDaUnire('remigante sinistra', Offset(0.16, 0.44)),
      PuntoDaUnire('petto', Offset(0.50, 0.48)),
      PuntoDaUnire('remigante destra', Offset(0.84, 0.44)),
      PuntoDaUnire('ala destra', Offset(0.94, 0.26)),
      PuntoDaUnire('coda', Offset(0.50, 0.88)),
    ], fili: [
      (0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 1), (4, 7),
    ]),
  ),
  // IL CAVALLO in corsa, di profilo: muso proteso, criniera, garrese, la
  // groppa e le zampe distese nel galoppo.
  CostellazioneAnimale(
    animale: 'Cavallo',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('muso', Offset(0.90, 0.30)),
      PuntoDaUnire('fronte', Offset(0.80, 0.18)),
      PuntoDaUnire('garrese', Offset(0.58, 0.24)),
      PuntoDaUnire('groppa', Offset(0.34, 0.28)),
      PuntoDaUnire('coda', Offset(0.10, 0.34)),
      PuntoDaUnire('zampa posteriore', Offset(0.24, 0.78)),
      PuntoDaUnire('ventre', Offset(0.52, 0.55)),
      PuntoDaUnire('zampa anteriore', Offset(0.76, 0.82)),
    ], fili: [
      (0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 0),
    ]),
  ),
  // IL CERVO a testa alta: i palchi ramificati sopra il capo, il collo
  // nobile, il dorso e le zampe sottili.
  CostellazioneAnimale(
    animale: 'Cervo',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('palco sinistro', Offset(0.30, 0.08)),
      PuntoDaUnire('palco destro', Offset(0.58, 0.06)),
      PuntoDaUnire('capo', Offset(0.46, 0.22)),
      PuntoDaUnire('collo', Offset(0.42, 0.38)),
      PuntoDaUnire('garrese', Offset(0.34, 0.50)),
      PuntoDaUnire('groppa', Offset(0.16, 0.56)),
      PuntoDaUnire('zampa posteriore', Offset(0.20, 0.90)),
      PuntoDaUnire('zampa anteriore', Offset(0.52, 0.92)),
    ], fili: [
      (0, 2), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (4, 7),
    ]),
  ),
  // IL CORVO posato che volge il capo: becco forte, ala raccolta, la coda
  // lunga e le zampe sul ramo.
  CostellazioneAnimale(
    animale: 'Corvo',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('becco', Offset(0.78, 0.16)),
      PuntoDaUnire('capo', Offset(0.62, 0.12)),
      PuntoDaUnire('dorso', Offset(0.46, 0.30)),
      PuntoDaUnire('ala', Offset(0.34, 0.48)),
      PuntoDaUnire('coda', Offset(0.12, 0.80)),
      PuntoDaUnire('petto', Offset(0.58, 0.52)),
      PuntoDaUnire('zampe', Offset(0.54, 0.78)),
    ], fili: [
      (0, 1), (1, 2), (2, 3), (3, 4), (3, 5), (5, 6),
    ]),
  ),
  // IL FALCO in picchiata: ali a freccia strette al corpo, il capo puntato
  // verso il basso.
  CostellazioneAnimale(
    animale: 'Falco',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('capo', Offset(0.50, 0.86)),
      PuntoDaUnire('petto', Offset(0.50, 0.62)),
      PuntoDaUnire('ala sinistra', Offset(0.18, 0.22)),
      PuntoDaUnire('punta sinistra', Offset(0.10, 0.06)),
      PuntoDaUnire('ala destra', Offset(0.82, 0.22)),
      PuntoDaUnire('punta destra', Offset(0.90, 0.06)),
      PuntoDaUnire('coda', Offset(0.50, 0.40)),
    ], fili: [
      (0, 1), (1, 2), (2, 3), (1, 4), (4, 5), (1, 6),
    ]),
  ),
  // IL GUFO frontale: i due grandi occhi, i ciuffi come corna, il corpo a
  // campana posato.
  CostellazioneAnimale(
    animale: 'Gufo',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('ciuffo sinistro', Offset(0.30, 0.10)),
      PuntoDaUnire('ciuffo destro', Offset(0.70, 0.10)),
      PuntoDaUnire('occhio sinistro', Offset(0.38, 0.26)),
      PuntoDaUnire('occhio destro', Offset(0.62, 0.26)),
      PuntoDaUnire('becco', Offset(0.50, 0.38)),
      PuntoDaUnire('fianco sinistro', Offset(0.26, 0.62)),
      PuntoDaUnire('fianco destro', Offset(0.74, 0.62)),
      PuntoDaUnire('zampe', Offset(0.50, 0.90)),
    ], fili: [
      (0, 2), (1, 3), (2, 4), (3, 4), (2, 5), (3, 6), (5, 7), (6, 7),
    ]),
  ),
  // LA LINCE accovacciata pronta al balzo: orecchie a pennello, il dorso
  // raccolto, la zampa avanzata.
  CostellazioneAnimale(
    animale: 'Lince',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('pennello sinistro', Offset(0.20, 0.10)),
      PuntoDaUnire('pennello destro', Offset(0.40, 0.06)),
      PuntoDaUnire('muso', Offset(0.26, 0.28)),
      PuntoDaUnire('spalla', Offset(0.46, 0.42)),
      PuntoDaUnire('dorso raccolto', Offset(0.70, 0.34)),
      PuntoDaUnire('anca', Offset(0.88, 0.52)),
      PuntoDaUnire('zampa avanzata', Offset(0.30, 0.84)),
    ], fili: [
      (0, 2), (1, 2), (2, 3), (3, 4), (4, 5), (3, 6),
    ]),
  ),
  // IL LUPO che ulula alla luna: muso al cielo, la gola tesa, la schiena in
  // discesa e la coda bassa.
  CostellazioneAnimale(
    animale: 'Lupo',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('muso al cielo', Offset(0.24, 0.06)),
      PuntoDaUnire('orecchio', Offset(0.36, 0.18)),
      PuntoDaUnire('gola', Offset(0.28, 0.30)),
      PuntoDaUnire('garrese', Offset(0.48, 0.40)),
      PuntoDaUnire('schiena', Offset(0.66, 0.52)),
      PuntoDaUnire('coda bassa', Offset(0.88, 0.72)),
      PuntoDaUnire('zampe', Offset(0.44, 0.88)),
    ], fili: [
      (0, 1), (0, 2), (1, 3), (3, 4), (4, 5), (3, 6),
    ]),
  ),
  // L'ORSO eretto: la mole, il capo piccolo sulla massa, le zampe larghe.
  CostellazioneAnimale(
    animale: 'Orso',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('capo', Offset(0.50, 0.08)),
      PuntoDaUnire('spalla sinistra', Offset(0.28, 0.24)),
      PuntoDaUnire('spalla destra', Offset(0.72, 0.24)),
      PuntoDaUnire('zampa alzata', Offset(0.88, 0.40)),
      PuntoDaUnire('fianco sinistro', Offset(0.24, 0.58)),
      PuntoDaUnire('fianco destro', Offset(0.74, 0.60)),
      PuntoDaUnire('piede sinistro', Offset(0.36, 0.92)),
      PuntoDaUnire('piede destro', Offset(0.62, 0.92)),
    ], fili: [
      (0, 1), (0, 2), (2, 3), (1, 4), (2, 5), (4, 6), (5, 7), (6, 7),
    ]),
  ),
  // IL SERPENTE in onda: la testa a lancia e le spire che si susseguono.
  CostellazioneAnimale(
    animale: 'Serpente',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('testa a lancia', Offset(0.88, 0.16)),
      PuntoDaUnire('collo', Offset(0.72, 0.30)),
      PuntoDaUnire('prima spira', Offset(0.52, 0.22)),
      PuntoDaUnire('seconda spira', Offset(0.34, 0.44)),
      PuntoDaUnire('terza spira', Offset(0.52, 0.64)),
      PuntoDaUnire('quarta spira', Offset(0.30, 0.80)),
      PuntoDaUnire('coda', Offset(0.10, 0.90)),
    ], fili: [
      (0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6),
    ]),
  ),
  // LA TARTARUGA dall'alto: il carapace largo, la testa che sporge e le
  // quattro zampe agli angoli.
  CostellazioneAnimale(
    animale: 'Tartaruga',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('testa', Offset(0.50, 0.06)),
      PuntoDaUnire('zampa anteriore sinistra', Offset(0.20, 0.28)),
      PuntoDaUnire('zampa anteriore destra', Offset(0.80, 0.28)),
      PuntoDaUnire('centro del carapace', Offset(0.50, 0.50)),
      PuntoDaUnire('zampa posteriore sinistra', Offset(0.22, 0.74)),
      PuntoDaUnire('zampa posteriore destra', Offset(0.78, 0.74)),
      PuntoDaUnire('coda', Offset(0.50, 0.92)),
    ], fili: [
      (0, 1), (0, 2), (1, 3), (2, 3), (3, 4), (3, 5), (4, 6), (5, 6),
    ]),
  ),
  // LA VOLPE seduta con la coda avvolta: orecchie alte, il muso sottile, la
  // coda che gira attorno alle zampe.
  CostellazioneAnimale(
    animale: 'Volpe',
    figura: FiguraDaUnire(punti: [
      PuntoDaUnire('orecchio sinistro', Offset(0.36, 0.08)),
      PuntoDaUnire('orecchio destro', Offset(0.56, 0.08)),
      PuntoDaUnire('muso sottile', Offset(0.46, 0.26)),
      PuntoDaUnire('petto', Offset(0.44, 0.46)),
      PuntoDaUnire('zampe raccolte', Offset(0.42, 0.74)),
      PuntoDaUnire('ansa della coda', Offset(0.70, 0.86)),
      PuntoDaUnire('punta della coda', Offset(0.84, 0.62)),
    ], fili: [
      (0, 2), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6),
    ]),
  ),
];

/// La costellazione di un animale, per nome. Cade subito se il nome non
/// esiste: un animale senza costellazione e' un dato rotto, non un ripiego.
CostellazioneAnimale costellazioneDi(String animale) =>
    kCostellazioniAnimali.firstWhere((c) => c.animale == animale);
