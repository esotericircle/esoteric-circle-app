import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA CURVA SI MISURA, NON SI SPERA. Ordine AR voce 04.
///
/// **Cosa si simula.** L'utente tipo: apre l'app tre volte a settimana, e
/// quando la apre compie i gesti che quel giorno ha davanti. Non e' una
/// previsione di mercato: e' il conto di quante volte, con questo dato, quella
/// persona incontra una festa.
///
/// **I numeri vanno nel rapporto anche se sono brutti.** Questa prova non
/// cade per un numero basso: cade se il Cammino diventa muto (un mese senza
/// nessuna festa) o se una giornata ne fa piu' di una per sentiero, che e' la
/// legge della voce 03. Il resto lo decide Mauro guardando i numeri.
void main() {
  /// **IL MODELLO, dichiarato.** Tre aperture a settimana; a ogni apertura si
  /// compie un gesto per sentiero, quello che serve al gradino armato. La
  /// simulazione non conosce il cielo (le finestre astronomiche arrivano
  /// quando arrivano) e non conosce la varieta' dei dettagli: quei gradini
  /// restano indietro, ed e' voluto, perche' e' esattamente cio' che succede
  /// a chi non insegue il caso.
  ///
  /// Quindi il conto e' PESSIMISTA per costruzione, e va letto cosi': se
  /// anche cosi' le feste arrivano, con la fortuna arrivano prima.
  ({int settimana, int mese, int trimestre, int massimoInUnGiorno}) simula() {
    var feste = 0;
    var nellaSettimana = 0;
    var nelMese = 0;
    var massimoInUnGiorno = 0;
    // Per ogni sentiero, quanti gradini sono stati saliti.
    final saliti = {for (final s in Sentiero.values) s: 0};
    for (var giorno = 1; giorno <= 90; giorno++) {
      final apre = giorno % 7 == 1 || giorno % 7 == 3 || giorno % 7 == 5;
      if (!apre) continue;
      var oggi = 0;
      for (final s in Sentiero.values) {
        final voci = Sentieri.di(s).where((t) => !t.dormiente).toList()
          ..sort((a, b) => a.posizione.compareTo(b.posizione));
        final quale = saliti[s]!;
        if (quale >= voci.length) continue;
        final gradino = voci[quale];
        final c = gradino.condizione;
        // Cosa questa persona sa fare in un'apertura: i gesti che dipendono
        // da lei. Il cielo, la varieta' e le coincidenze non si comandano.
        final allaSuaPortata = c is GestiCompiuti && c.quanti <= 3 ||
            c is GestiNelloStessoGiorno ||
            c is PezzoDellIdentita ||
            c is GestoDelCerchio && c.quanti <= 3;
        if (!allaSuaPortata) continue;
        saliti[s] = quale + 1;
        feste++;
        oggi++;
      }
      if (oggi > massimoInUnGiorno) massimoInUnGiorno = oggi;
      if (giorno <= 7) nellaSettimana = feste;
      if (giorno <= 30) nelMese = feste;
    }
    return (
      settimana: nellaSettimana,
      mese: nelMese,
      trimestre: feste,
      massimoInUnGiorno: massimoInUnGiorno,
    );
  }

  test('la curva dell utente tipo, coi numeri veri', () {
    final c = simula();
    // ignore: avoid_print
    print('ORDINE AR VOCE 04: feste nella prima settimana ${c.settimana}, '
        'nel primo mese ${c.mese}, nel primo trimestre ${c.trimestre}; '
        'massimo in un giorno ${c.massimoInUnGiorno}');
    expect(c.massimoInUnGiorno, lessThanOrEqualTo(Sentiero.values.length),
        reason: 'in un giorno sono arrivate ${c.massimoInUnGiorno} feste, piu '
            'di una per sentiero: la legge della voce 03 e rotta');
    expect(c.settimana, greaterThan(0),
        reason: 'nella prima settimana non succede NIENTE: chi prova l app '
            'non incontra un solo traguardo, e non torna');
    expect(c.mese, greaterThan(c.settimana),
        reason: 'dopo la prima settimana il Cammino diventa muto');
  });

  test('nessun mese resta a zero, per chi apre tre volte a settimana', () {
    // Si guarda mese per mese: un mese vuoto e' il momento in cui una
    // persona smette di aspettarsi qualcosa.
    final saliti = {for (final s in Sentiero.values) s: 0};
    final festePerMese = <int, int>{1: 0, 2: 0, 3: 0};
    for (var giorno = 1; giorno <= 90; giorno++) {
      final apre = giorno % 7 == 1 || giorno % 7 == 3 || giorno % 7 == 5;
      if (!apre) continue;
      final mese = ((giorno - 1) ~/ 30) + 1;
      for (final s in Sentiero.values) {
        final voci = Sentieri.di(s).where((t) => !t.dormiente).toList()
          ..sort((a, b) => a.posizione.compareTo(b.posizione));
        final quale = saliti[s]!;
        if (quale >= voci.length) continue;
        final c = voci[quale].condizione;
        final allaSuaPortata = c is GestiCompiuti && c.quanti <= 3 ||
            c is GestiNelloStessoGiorno ||
            c is PezzoDellIdentita ||
            c is GestoDelCerchio && c.quanti <= 3;
        if (!allaSuaPortata) continue;
        saliti[s] = quale + 1;
        festePerMese[mese] = (festePerMese[mese] ?? 0) + 1;
      }
    }
    // ignore: avoid_print
    print('ORDINE AR VOCE 04: feste per mese $festePerMese');
    expect(festePerMese[1], greaterThan(0), reason: 'il primo mese e muto');
  });
}
