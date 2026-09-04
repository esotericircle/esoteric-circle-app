import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/core/sigilli/traguardo.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **NESSUN TRAGUARDO RESTA INDIETRO PERCHE' UN ALTRO L'HA SUPERATO.**
/// Ordine CQ voce 2.12, 3 settembre 2026.
///
/// **L'ordine chiede di PROVARE IL DIFETTO PRIMA DI CURARLO**, e questa e' la
/// prova. La scala dell'ordine CP voce 01 fa maturare, da ogni sentiero, solo
/// il gradino che chi cammina sta per prendere: e' cio' che ha portato le
/// feste del giorno peggiore da tredici a tre. **Il rischio dichiarato di
/// quella scala e' che un gradino fermo blocchi tutti quelli dietro di lui**,
/// e il fondatore chiede che non succeda.
///
/// **La grandezza misurata e' il RITARDO, non il conto.** Un gradino
/// soddisfatto che si accende dieci minuti dopo non e' un difetto: e' la coda
/// che il fondatore ha voluto. Un gradino soddisfatto che alla fine della
/// simulazione non si e' ancora acceso, mentre uno piu' avanti del suo stesso
/// sentiero si e' acceso, quello si': vuol dire che qualcuno lo ha
/// scavalcato, e la scala si e' rotta nel verso in cui non doveva.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('chi soddisfa una condizione si accende, prima o poi', () async {
    SharedPreferences.setMockInitialValues(const {});
    var adesso = DateTime(2026, 1, 1, 9);
    final diario = DiarioDelCammino(orologio: () => adesso);
    await diario.carica();

    // **UNA GIORNATA ONESTA, RIPETUTA PER UN ANNO.** Sette arti diverse, una
    // volta al giorno ciascuna, come farebbe chi usa l'app davvero. Non e' un
    // abuso: e' il caso in cui il Cammino DEVE avanzare.
    // **I NOMI SONO QUELLI VERI, e la prima stesura ne aveva sbagliato uno.**
    // Chiamare 'arcano' il gesto che l'app registra come 'oracolo' bloccava il
    // sentiero di Medora al quarto gradino e faceva sembrare la scala un muro:
    // era la prova a essere sbagliata, non il Cammino. I nomi si leggono da
    // `GestiDelleArti`, che e' la porta unica.
    const giornata = <({String gesto, Map<String, Object?> dettagli})>[
      (gesto: 'alba', dettagli: {}),
      (gesto: 'soffio', dettagli: {}),
      (gesto: 'oroscopo', dettagli: {'orizzonte': 'giorno'}),
      (gesto: 'oracolo', dettagli: {}),
      (gesto: 'tramonto', dettagli: {}),
      (gesto: 'gettata', dettagli: {}),
      (gesto: 'stesa', dettagli: {}),
      (gesto: 'sogno', dettagli: {}),
      (gesto: 'viso', dettagli: {}),
      (gesto: 'animale_guida', dettagli: {}),
      (gesto: 'meditazione', dettagli: {}),
      (gesto: 'sigillo', dettagli: {}),
    ];

    final soddisfattoIl = <String, int>{};
    final accesoIl = <String, int>{};
    const giorni = 400;
    for (var g = 0; g < giorni; g++) {
      adesso = DateTime(2026, 1, 1, 9).add(Duration(days: g));
      for (final gesto in giornata) {
        adesso = adesso.add(const Duration(minutes: 20));
        await diario.segna(gesto.gesto, dettagli: gesto.dettagli);
      }
      final stato = diario.statoDelCammino(
          pezziDellIdentita:
              RegiaDelCammino.pezziDellIdentitaMaturi(diario, true));
      // Chi e' soddisfatto OGGI, senza il filtro della scala: e' la domanda
      // "questa persona ha fatto quello che il gradino chiede".
      for (final t in Sentieri.tuttiITraguardi) {
        if (t.dormiente) continue;
        if (diario.accesi.contains(t.id)) continue;
        if (!t.condizione.raggiunto(stato)) continue;
        soddisfattoIl.putIfAbsent(t.id, () => g);
      }
      // E chi si accende davvero, dalla porta vera.
      for (final t in await diario.quelliCheSiAccendono(stato)) {
        accesoIl.putIfAbsent(t.id, () => g);
        await diario.accendi(t.id);
        await diario.congeda(t.id);
      }
    }

    final maiAccesi = soddisfattoIl.keys
        .where((id) => !accesoIl.containsKey(id))
        .toList()
      ..sort();
    final ritardi = <int>[
      for (final voce in accesoIl.entries)
        if (soddisfattoIl.containsKey(voce.key))
          voce.value - soddisfattoIl[voce.key]!,
    ]..sort();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.12: su $giorni giorni di uso onesto, traguardi '
        'soddisfatti ${soddisfattoIl.length}, accesi ${accesoIl.length}, '
        'soddisfatti e mai accesi ${maiAccesi.length}. Ritardo massimo fra '
        'soddisfazione e accensione ${ritardi.isEmpty ? "nessuno" : "${ritardi.last} giorni"}');

    // **DOVE SI E' FERMATA LA SCALA, sentiero per sentiero.** Senza questa
    // riga il rapporto direbbe "sessantadue in attesa" e non direbbe dietro a
    // CHI: un numero senza il nome del gradino che blocca non si puo' curare.
    for (final s in Sentiero.values) {
      final prossimo = diario.prossimoDi(s);
      final accesiQui =
          Sentieri.di(s).where((t) => diario.accesi.contains(t.id)).length;
      // ignore: avoid_print
      print('ORDINE CQ VOCE 2.12: sentiero ${s.name}, accesi $accesiQui su '
          '${Sentieri.di(s).length}, fermo su "${prossimo?.nome}" '
          '(${prossimo?.id})');
    }
    cardinaleMinimo(accesoIl.length, 20,
        cosa: 'traguardi accesi in un anno di uso onesto',
        perche: 'Se non se ne accendesse nessuno la prova sarebbe verde '
            'perche non c e niente in ritardo, e sarebbe il difetto peggiore '
            'di tutti.');
    expect(maiAccesi, isEmpty,
        reason: 'questi traguardi sono stati soddisfatti e non si sono mai '
            'accesi in $giorni giorni: la scala li ha lasciati indietro. '
            '${maiAccesi.take(6).join(", ")}');
  });

  test('e la scala non salta nessun gradino di un sentiero', () async {
    // **L'ALTRA META' DELLA STESSA LEGGE.** Non basta che tutti si accendano:
    // devono accendersi IN ORDINE dentro il loro sentiero, o la scala non e'
    // una scala. Un gradino saltato e' un gradino che nessuno riprendera'.
    SharedPreferences.setMockInitialValues(const {});
    var adesso = DateTime(2026, 1, 1, 9);
    final diario = DiarioDelCammino(orologio: () => adesso);
    await diario.carica();
    final ordineDiAccensione = <String>[];
    for (var g = 0; g < 200; g++) {
      adesso = DateTime(2026, 1, 1, 9).add(Duration(days: g));
      for (final gesto in const [
        'alba', 'oroscopo', 'oracolo', 'gettata', 'stesa', 'viso',
        'animale_guida',
      ]) {
        adesso = adesso.add(const Duration(minutes: 20));
        await diario.segna(gesto);
      }
      final stato = diario.statoDelCammino(
          pezziDellIdentita:
              RegiaDelCammino.pezziDellIdentitaMaturi(diario, true));
      for (final t in await diario.quelliCheSiAccendono(stato)) {
        ordineDiAccensione.add(t.id);
        await diario.accendi(t.id);
        await diario.congeda(t.id);
      }
    }
    final fuoriOrdine = <String>[];
    for (final sentiero in Sentiero.values) {
      final elenco = Sentieri.di(sentiero).map((t) => t.id).toList();
      var ultimo = -1;
      for (final id in ordineDiAccensione) {
        final posto = elenco.indexOf(id);
        if (posto < 0) continue;
        if (posto < ultimo) fuoriOrdine.add('$id dopo il numero $ultimo');
        ultimo = posto;
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.12: accensioni osservate '
        '${ordineDiAccensione.length}, fuori ordine ${fuoriOrdine.length}');
    cardinaleMinimo(ordineDiAccensione.length, 10,
        cosa: 'accensioni osservate nella simulazione',
        perche: 'Senza accensioni non ci sarebbe nessun ordine da guardare.');
    expect(fuoriOrdine, isEmpty,
        reason: 'questi gradini si sono accesi scavalcandone uno che stava '
            'prima nel loro sentiero: ${fuoriOrdine.take(5).join(", ")}');
  });
}
