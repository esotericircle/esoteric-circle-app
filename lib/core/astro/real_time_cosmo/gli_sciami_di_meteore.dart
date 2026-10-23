/// GLI SCIAMI DI METEORE. Ordine FH parte 12, voci 12.1 e 12.2.
///
/// I sette sciami dell'ordine con la data di massimo che l'ordine scrive, e
/// col radiante (ascensione retta e declinazione J2000, in gradi) e la
/// frequenza oraria zenitale del calendario dell'International Meteor
/// Organization (IMO, Meteor Shower Calendar): quante meteore vedrebbe in
/// un'ora una persona sotto un cielo perfetto col radiante allo zenit.
///
/// **La frequenza cala allontanandosi dalla notte di massimo** (voce 12.2):
/// e' la frequenza al massimo per e alla meno la distanza in giorni divisa per
/// la [SciameDiMeteore.larghezzaGiorni] dello sciame, stretta per le
/// Quadrantidi, larga per le Eta Aquaridi e le Orionidi. Fuori dagli sciami
/// restano le meteore sporadiche, [kSporadicheAllOra] all'ora sull'intero
/// cielo: nel riquadro del telefono, una ogni tre quarti d'ora circa.
library;

import 'dart:math' as math;

class SciameDiMeteore {
  const SciameDiMeteore({
    required this.nome,
    required this.mese,
    required this.giorno,
    required this.raGradi,
    required this.decGradi,
    required this.frequenzaZenitale,
    required this.larghezzaGiorni,
  });

  final String nome;

  /// Il giorno di massimo, ogni anno.
  final int mese, giorno;

  /// Il radiante J2000, in gradi.
  final double raGradi, decGradi;

  /// Le meteore all'ora al massimo, col radiante allo zenit (IMO).
  final double frequenzaZenitale;

  /// In quanti giorni la frequenza scende di e volte.
  final double larghezzaGiorni;

  /// La frequenza oraria zenitale il giorno [quando], tenendo conto della
  /// distanza dal massimo dell'anno piu' vicino.
  double frequenzaIl(DateTime quando) {
    final giorni = _distanzaDalMassimo(quando).abs();
    return frequenzaZenitale * math.exp(-giorni / larghezzaGiorni);
  }

  double _distanzaDalMassimo(DateTime quando) {
    double da(int anno) =>
        quando.difference(DateTime.utc(anno, mese, giorno)).inMinutes / 1440;
    final d = [da(quando.year - 1), da(quando.year), da(quando.year + 1)];
    d.sort((a, b) => a.abs().compareTo(b.abs()));
    return d.first;
  }
}

const List<SciameDiMeteore> kSciamiDiMeteore = [
  SciameDiMeteore(
      nome: 'Quadrantidi',
      mese: 1,
      giorno: 3,
      raGradi: 230,
      decGradi: 49,
      frequenzaZenitale: 80,
      larghezzaGiorni: 0.6),
  SciameDiMeteore(
      nome: 'Liridi',
      mese: 4,
      giorno: 22,
      raGradi: 271,
      decGradi: 34,
      frequenzaZenitale: 18,
      larghezzaGiorni: 1.3),
  SciameDiMeteore(
      nome: 'Eta Aquaridi',
      mese: 5,
      giorno: 6,
      raGradi: 338,
      decGradi: -1,
      frequenzaZenitale: 50,
      larghezzaGiorni: 4),
  SciameDiMeteore(
      nome: 'Perseidi',
      mese: 8,
      giorno: 12,
      raGradi: 48,
      decGradi: 58,
      frequenzaZenitale: 100,
      larghezzaGiorni: 2.5),
  SciameDiMeteore(
      nome: 'Orionidi',
      mese: 10,
      giorno: 21,
      raGradi: 95,
      decGradi: 16,
      frequenzaZenitale: 20,
      larghezzaGiorni: 4),
  SciameDiMeteore(
      nome: 'Leonidi',
      mese: 11,
      giorno: 17,
      raGradi: 152,
      decGradi: 22,
      frequenzaZenitale: 15,
      larghezzaGiorni: 1.5),
  SciameDiMeteore(
      nome: 'Geminidi',
      mese: 12,
      giorno: 13,
      raGradi: 112,
      decGradi: 33,
      frequenzaZenitale: 150,
      larghezzaGiorni: 1.5),
];

/// Le meteore sporadiche all'ora sull'intero cielo (voce 12.2).
const double kSporadicheAllOra = 5;

/// Lo sciame piu' attivo il giorno [quando], con la sua frequenza oraria
/// zenitale; nessuno se tutti stanno sotto le sporadiche.
({SciameDiMeteore sciame, double frequenza})? sciameDelGiorno(DateTime quando) {
  SciameDiMeteore? migliore;
  var frequenza = kSporadicheAllOra;
  for (final s in kSciamiDiMeteore) {
    final f = s.frequenzaIl(quando);
    if (f > frequenza) {
      frequenza = f;
      migliore = s;
    }
  }
  return migliore == null ? null : (sciame: migliore, frequenza: frequenza);
}
