// GLI AVVISI DEL RESPIRO. Ordine FX voce FX.08, 16 ottobre 2026.
//
// La levata della Luna non si riverifica qui (la prova esiste altrove, per
// la porta `prossimoSorgere`, ordine FX voce 2): qui si prova che
// `GliAvvisiDelRespiro.programma` chiami quella porta bene, rispetti la
// fascia di quiete e nomini la citta', confrontando ogni risultato con un
// calcolo fatto in proprio nella prova, con la stessa porta pubblica.
//
// **AGGIORNATA DA `quandoSorgeIlBersaglio` A `prossimoSorgere`.** La
// produzione (`gli_avvisi_del_respiro.dart`) e' passata alla soglia di
// Meeus 15.1 con la parallasse vera della Luna (ordine FX voce 2), piu'
// precisa della soglia generica del Real Time Cosmo: il calcolo fatto in
// proprio qui deve restare la STESSA porta della produzione, altrimenti la
// prova confronta due formule diverse e non la produzione con se stessa.

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/luogo_attuale.dart';
import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'package:esoteric_circle/core/lunario/il_motore_lunare.dart';
import 'package:esoteric_circle/core/lunario/il_sorgere_della_luna.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/features/respiro_della_luna/gli_avvisi_del_respiro.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Telefono extends ServizioAvvisi {
  final Map<int, ({DateTime quando, String titolo, String testo, String canale, String carico})>
      programmati = {};
  final List<int> annullati = [];

  @override
  bool get disponibile => true;
  @override
  Future<bool> chiediPermesso() async => true;
  @override
  Future<bool> permessoConcesso() async => true;
  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {
    programmati[id] =
        (quando: quando, titolo: titolo, testo: testo, canale: canale, carico: carico);
  }

  @override
  Future<void> annulla(int id) async {
    annullati.add(id);
    programmati.remove(id);
  }

  @override
  Future<List<int>> inAttesa() async => programmati.keys.toList();

  @override
  Future<void> mostraAdesso({required String titolo, required String testo}) async {}
}

bool _dentroLaQuiete(DateTime t) {
  final ora = t.toLocal().hour;
  return ora >= GliAvvisiDelRespiro.oraInizioQuiete ||
      ora < GliAvvisiDelRespiro.oraFineQuiete;
}

void main() {
  const luogo = LuogoAttuale(
      lat: 45.0526, lon: 9.6930, citta: 'Piacenza', origine: OrigineDelLuogo.scelto);
  final adesso = DateTime(2026, 10, 16, 8, 0);

  test('senza nessun interruttore acceso non programma e non annulla nulla '
      'oltre il giro di pulizia', () async {
    final servizio = _Telefono();
    final fatti = await GliAvvisiDelRespiro.programma(
      servizio: servizio,
      adesso: adesso,
      luogo: luogo,
      lunaCheSorge: false,
      luneNuoveEPiene: false,
    );
    expect(fatti, isEmpty);
    expect(servizio.programmati, isEmpty);
    // Il giro di pulizia annulla sempre tutti gli id, cosi' un avviso di
    // ieri non resta orfano quando oggi l'interruttore e' spento.
    expect(servizio.annullati.toSet(), GliAvvisiDelRespiro.tuttiGliId.toSet());
  });

  test('la luna che sorge nomina la città e rispetta la fascia di quiete '
      'esattamente come il calcolo fatto in proprio', () async {
    final servizio = _Telefono();
    await GliAvvisiDelRespiro.programma(
      servizio: servizio,
      adesso: adesso,
      luogo: luogo,
      lunaCheSorge: true,
      luneNuoveEPiene: false,
    );
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    var almenoUnGiornoVero = false;
    for (var i = 0; i < GliAvvisiDelRespiro.giorni; i++) {
      final giorno = DateTime(oggi.year, oggi.month, oggi.day + i);
      final sorge = prossimoSorgere(giorno, luogo.lat, luogo.lon);
      final id = GliAvvisiDelRespiro.primoIdDellaLunaCheSorge + i;
      if (sorge == null) {
        expect(servizio.programmati.containsKey(id), isFalse,
            reason: 'giorno $i: la Luna non sorge, non deve avvisare');
        continue;
      }
      final quando = sorge.toLocal();
      final atteso = quando.isAfter(adesso) && !_dentroLaQuiete(quando);
      almenoUnGiornoVero = true;
      expect(servizio.programmati.containsKey(id), atteso,
          reason: 'giorno $i, sorge alle $quando');
      if (atteso) {
        final p = servizio.programmati[id]!;
        expect(p.testo, contains('Piacenza'));
        expect(p.testo, contains('sorge adesso'));
        expect(p.canale, GliAvvisiDelRespiro.canale);
        expect(p.quando, quando);
      }
    }
    expect(almenoUnGiornoVero, isTrue,
        reason: 'in sette giorni la Luna sorge almeno una volta');
  });

  test('senza luogo, la luna che sorge non programma nulla', () async {
    final servizio = _Telefono();
    await GliAvvisiDelRespiro.programma(
      servizio: servizio,
      adesso: adesso,
      luogo: null,
      lunaCheSorge: true,
      luneNuoveEPiene: false,
    );
    expect(servizio.programmati, isEmpty);
  });

  test('la luna nuova e la luna piena arrivano con l\'orario vero del '
      'motore, la piena con la distanza vera', () async {
    final servizio = _Telefono();
    await GliAvvisiDelRespiro.programma(
      servizio: servizio,
      adesso: adesso,
      luogo: luogo,
      lunaCheSorge: false,
      luneNuoveEPiene: true,
    );
    final fine = adesso.add(const Duration(days: 36));
    final nuove = IlMotoreLunare.luneNuoveFra(adesso, fine);
    final piene = IlMotoreLunare.lunePieneFra(adesso, fine);
    expect(nuove, isNotEmpty);
    expect(piene, isNotEmpty);

    final nuova = nuove.first;
    final attesaNuova = nuova.isAfter(adesso) && !_dentroLaQuiete(nuova);
    expect(servizio.programmati.containsKey(GliAvvisiDelRespiro.idDellaLunaNuova),
        attesaNuova);
    if (attesaNuova) {
      final p = servizio.programmati[GliAvvisiDelRespiro.idDellaLunaNuova]!;
      expect(p.quando, nuova);
      expect(p.testo, contains('nuova'));
    }

    final piena = piene.first;
    final attesaPiena = piena.isAfter(adesso) && !_dentroLaQuiete(piena);
    expect(servizio.programmati.containsKey(GliAvvisiDelRespiro.idDellaLunaPiena),
        attesaPiena);
    if (attesaPiena) {
      final jd = Celestial.julianDay(piena.toUtc());
      final distanza = IlCieloDiMeeus.distanzaInKm(jd);
      final p = servizio.programmati[GliAvvisiDelRespiro.idDellaLunaPiena]!;
      expect(p.quando, piena);
      expect(p.testo, GliAvvisiDelRespiro.testoDellaLunaPiena(distanza));
    }
  });

  group('il testo della Luna piena, alla soglia della Superluna (361885 km, '
      'Richard Nolle 1979)', () {
    test('appena sotto la soglia, è una Superluna', () {
      expect(GliAvvisiDelRespiro.testoDellaLunaPiena(361884),
          contains('Superluna'));
    });
    test('appena sopra la soglia, è solo piena', () {
      final testo = GliAvvisiDelRespiro.testoDellaLunaPiena(361886);
      expect(testo, isNot(contains('Superluna')));
      expect(testo, contains('piena'));
    });
    test('esattamente alla soglia conta come Superluna (<=)', () {
      expect(
          GliAvvisiDelRespiro.testoDellaLunaPiena(
              GliAvvisiDelRespiro.sogliaSuperlunaKm),
          contains('Superluna'));
    });
  });

  group('i due interruttori persistiti', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('senza nulla scritto, i due avvisi partono spenti', () async {
      final i = IGliAvvisiDelRespiro(avvisi: _Telefono());
      await i.leggi();
      expect(i.lunaCheSorge, isFalse);
      expect(i.luneNuoveEPiene, isFalse);
      expect(i.letto, isTrue);
    });

    test('accendere la luna che sorge si ricorda e riprogramma', () async {
      final servizio = _Telefono();
      final i = IGliAvvisiDelRespiro(avvisi: servizio);
      await i.leggi();
      await i.impostaLunaCheSorge(true, luogo: luogo, adesso: adesso);
      expect(i.lunaCheSorge, isTrue);
      // Il giro di pulizia e' sempre passato di qui: la riprogrammazione e'
      // davvero partita (quale giorno abbia un avviso lo prova il test
      // dedicato sopra, con lo stesso calcolo fatto in proprio).
      expect(servizio.annullati.toSet(), GliAvvisiDelRespiro.tuttiGliId.toSet());

      final j = IGliAvvisiDelRespiro(avvisi: _Telefono());
      await j.leggi();
      expect(j.lunaCheSorge, isTrue,
          reason: 'la scelta deve sopravvivere a una nuova lettura');
    });
  });
}
