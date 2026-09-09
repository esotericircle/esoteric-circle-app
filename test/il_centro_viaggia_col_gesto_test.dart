import 'dart:io';

import 'package:esoteric_circle/core/maestro/chakra_del_giorno.dart';
import 'package:esoteric_circle/core/maestro/frequenza_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL CENTRO VIAGGIA COL GESTO, e i traguardi proposti sono misurati.**
/// Ordine DB voce 06, 9 settembre 2026.
///
/// **DA DOVE NASCE.** La voce 06 chiede di proporre tre traguardi *"con la
/// condizione gia' misurata contro il catalogo dei 165"*. Misurarli ha trovato
/// due cose che nessuno sapeva:
///
/// 1. **Il gesto della meditazione partiva senza dettagli**, quindi il diario
///    non poteva sapere QUALE centro era stato respirato: la condizione
///    `VarietaDelDettaglio` esisteva gia' e sapeva gia' guardare i dettagli,
///    ma da qui non ne arrivava nessuno. Il traguardo dei sette centri era
///    impossibile per mancanza di un dato, non di codice.
/// 2. **Il traguardo "tre giorni di seguito sullo stesso centro" non si
///    accendera' mai per nessuno**, perche' il centro segue il giorno della
///    settimana con una mappa biiettiva.
///
/// **QUESTA GUARDIA TIENE VERE ENTRAMBE LE COSE**, e la seconda serve a
/// impedire che quel traguardo venga scritto per distrazione domani.
///
/// **REGOLA A, com'e' nata rossa.** Tolto `dettagli:` dalla chiamata di
/// `meditation_screen.dart`, verificato col grep che la riga fosse davvero
/// tornata nuda, la prima prova e' caduta con *"il gesto della meditazione
/// parte senza il centro"*. Rimesso, e' tornata verde.
void main() {
  test('IL GESTO DELLA MEDITAZIONE PORTA IL CENTRO', () {
    final sorgente = File(
            'lib/features/maestri/aura/meditation/meditation_screen.dart')
        .readAsStringSync();
    // **SI GUARDA IL CODICE, NON I COMMENTI.** E' la famiglia di difetti piu'
    // frequente di questo progetto: l'asserzione che pesca il proprio
    // commento. Qui i commenti spiegano proprio il dettaglio che si cerca, e
    // senza questa riga la guardia sarebbe verde leggendo se stessa.
    final righe = [
      for (final r in sorgente.split('\n'))
        if (!r.trimLeft().startsWith('//')) r,
    ];
    final codice = righe.join('\n');
    expect(codice.contains("dopoUnGesto(context, 'meditazione'"), isTrue,
        reason: 'la schermata non manda piu il gesto della meditazione');
    // Il pezzo che conta: **il dettaglio del centro parte insieme al gesto**.
    final conIlCentro = RegExp(
            r"dopoUnGesto\(context,\s*'meditazione'[^;]*dettagli:\s*\{'centro'")
        .hasMatch(codice);
    expect(conIlCentro, isTrue,
        reason: 'il gesto della meditazione parte senza il centro: il diario '
            'non puo sapere quale centro e stato respirato, e il traguardo '
            'dei sette centri non si accendera mai');
    // ignore: avoid_print
    print('ORDINE DB VOCE 06: righe di codice guardate ${righe.length}, il '
        'centro viaggia col gesto');
  });

  test('IN SETTE GIORNI SI TOCCANO SETTE CENTRI DISTINTI', () {
    // E' cio' che rende raggiungibile il primo traguardo proposto,
    // `VarietaDelDettaglio('meditazione', 'centro', 7)`.
    final visti = <String>{};
    for (var g = 0; g < 7; g++) {
      final giorno = DateTime(2026, 9, 7).add(Duration(days: g));
      visti.add(FrequenzaDelGiorno.centroDi(giorno).nome);
    }
    // ignore: avoid_print
    print('ORDINE DB VOCE 06: in sette giorni consecutivi i centri distinti '
        'sono ${visti.length} su ${ChakraDelGiorno.tutti.length}');
    expect(visti.length, ChakraDelGiorno.tutti.length,
        reason: 'in una settimana non si toccano tutti i centri: il traguardo '
            'dei sette centri costerebbe piu di quanto dichiarato');
  });

  test('TRE GIORNI DI SEGUITO NON DANNO MAI LO STESSO CENTRO', () {
    // **QUESTA E LA PROVA CHE UN TRAGUARDO NON VA SCRITTO.** Il terzo
    // traguardo che la voce 06 propone, *"tre giorni di seguito sullo stesso
    // centro"*, non si accenderebbe mai: nel catalogo starebbe come un
    // gradino che nessuno vede mai acceso.
    //
    // Si guarda un anno intero invece di una settimana, perche' una mappa
    // rotta potrebbe ripetersi solo a cavallo di un mese o di un anno
    // bisestile: su sette giorni la guardia sarebbe verde per non aver
    // guardato abbastanza.
    var coppieUguali = 0;
    var quantiGiorni = 0;
    var giorno = DateTime(2026, 1, 1);
    final fine = DateTime(2027, 1, 1);
    String? precedente;
    while (giorno.isBefore(fine)) {
      final centro = FrequenzaDelGiorno.centroDi(giorno).nome;
      if (precedente != null && precedente == centro) coppieUguali++;
      precedente = centro;
      quantiGiorni++;
      giorno = giorno.add(const Duration(days: 1));
    }
    // ignore: avoid_print
    print('ORDINE DB VOCE 06: giorni guardati $quantiGiorni, giorni '
        'consecutivi con lo stesso centro $coppieUguali');
    expect(quantiGiorni, greaterThanOrEqualTo(365),
        reason: 'la guardia ha guardato meno di un anno: su pochi giorni una '
            'ripetizione rara le sfuggirebbe');
    expect(coppieUguali, 0,
        reason: 'due giorni consecutivi portano lo stesso centro: allora il '
            'terzo traguardo proposto sarebbe possibile, e la proposta al '
            'fondatore va riscritta');
  });

  test('IL CENTRO DEL GIORNO E UNO SOLO, e viene da una porta sola', () {
    // Ordine CZ voce 06: *"una sorgente sola per il centro, come per il
    // numero"*. Se due porte dicessero centri diversi, il dettaglio mandato
    // al diario e il petalo acceso nel fiore direbbero cose diverse sullo
    // stesso giorno, che e' la famiglia "due verita sullo stesso fatto".
    for (var g = 0; g < 14; g++) {
      final giorno = DateTime(2026, 9, 7).add(Duration(days: g));
      final dallaFrequenza = FrequenzaDelGiorno.centroDi(giorno).nome;
      final dalGiorno =
          ChakraDelGiorno.tutti[(giorno.weekday - 1) % ChakraDelGiorno.tutti.length]
              .nome;
      expect(dallaFrequenza, dalGiorno,
          reason: 'il ${giorno.day}/${giorno.month} la frequenza dice '
              '"$dallaFrequenza" e il giorno della settimana dice "$dalGiorno": '
              'sono due verita sullo stesso fatto');
    }
  });
}
