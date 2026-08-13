import 'dart:math';

import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL PRESAGIO PRENDE LA FORMA DELL'ANATOMIA E RISPONDE ALLA DOMANDA.
/// Ordine S voce 19, la parte che aspettava la decisione D4.
///
/// **Perche' aspettava.** Il presagio deve rispondere alla domanda posta, e la
/// domanda non esisteva: nasce con la voce S.21. Scriverlo prima voleva dire
/// scriverlo due volte, e la seconda sarebbe stata quella vera.
///
/// **Il difetto che queste prove chiudono.** Il presagio era un paragrafo unico
/// che apriva col nome della gettata e nominava una runa per posizione: il
/// SIMBOLO veniva prima della risposta, e dopo averlo letto non c'era niente da
/// fare. Adesso e' un `Responso` a tre parti, il nome della runa compare solo
/// nella terza, e la seconda e' una cosa che si puo' fare oggi.
void main() {
  /// Tutte le gettate, con abbastanza semi per vedere ogni combinazione di luce,
  /// ombra e famiglia dominante. ENUMERA: una gettata sola non dice niente delle
  /// altre, e il getto libero compone per conto suo.
  const semi = 60;

  test('il presagio e\' un responso intero, in tutte le gettate', () {
    final rotti = <String>[];
    for (final g in gettate) {
      for (var seme = 0; seme < semi; seme++) {
        final r = RunePresagio.componiIlResponso(
            RuneCast.getta(g, random: Random(seme)));
        if (!r.eIntero) rotti.add('${g.id} seme $seme');
      }
    }
    expect(rotti, isEmpty,
        reason: 'questi presagi non hanno tutte e tre le parti dell\'anatomia, '
            'e un responso a cui manca una parte non e\' un responso:\n'
            '${rotti.take(10).join("\n")}');
  });

  test('il simbolo NON compare prima della risposta', () {
    // **LA GRANDEZZA MISURATA E' IL NOME DELLA RUNA dentro le prime due parti.**
    // L'anatomia dice che il simbolo compare in "da dove viene" e non prima: e'
    // la differenza fra un responso che ti risponde e una scheda che ti chiede di
    // sapere cosa vuol dire Perthro prima di ricevere qualcosa.
    final nomi = kElderFuthark.map((r) => r.name).toList();
    final colpe = <String>[];
    for (final g in gettate) {
      for (var seme = 0; seme < semi; seme++) {
        final r = RunePresagio.componiIlResponso(
            RuneCast.getta(g, random: Random(seme)));
        for (final nome in nomi) {
          if (r.risposta.contains(nome)) {
            colpe.add('${g.id} seme $seme: "$nome" nella risposta');
          }
          if (r.cosaPuoiFare.contains(nome)) {
            colpe.add('${g.id} seme $seme: "$nome" in cosa puoi fare');
          }
        }
      }
    }
    expect(colpe, isEmpty,
        reason: 'il nome di una runa compare prima della terza parte:\n'
            '${colpe.take(10).join("\n")}');
  });

  test('la terza parte nomina le rune uscite, tutte', () {
    // Il presidio opposto: togliere il simbolo dalla prima parte non vuol dire
    // buttarlo. Se sparisse anche dalla terza, la lettura non sarebbe piu'
    // verificabile da chi conosce le rune.
    final mancanti = <String>[];
    for (final g in gettate) {
      for (var seme = 0; seme < semi; seme++) {
        final esito = RuneCast.getta(g, random: Random(seme));
        final r = RunePresagio.componiIlResponso(esito);
        for (final runa in esito.rune) {
          if (!r.daDoveViene.contains(runa.rune.name)) {
            mancanti.add('${g.id} seme $seme: manca ${runa.rune.name}');
          }
        }
      }
    }
    expect(mancanti, isEmpty, reason: mancanti.take(10).join('\n'));
  });

  test('nessuna posizione si annuncia due volte nella stessa risposta', () {
    // **QUESTO DIFETTO E' NATO CON LA VOCE, e l'ha trovato l'anteprima del getto
    // sul telo.** Sul telo la posizione si legge per prossimita' al centro,
    // quindi cinque rune su sei stanno "verso i margini della luce": la prima
    // parte diventava sei righe di fila che cominciavano con le stesse cinque
    // parole. Prima non si notava perche' ogni riga portava anche il nome della
    // runa, e il nome adesso e' scesso nella terza parte.
    //
    // La grandezza misurata e' quante volte compare "Per <glossa>," dentro la
    // prima parte: mai piu' di una.
    final litanie = <String>[];
    for (final g in gettate) {
      for (var seme = 0; seme < semi; seme++) {
        final esito = RuneCast.getta(g, random: Random(seme));
        final risposta = RunePresagio.componiIlResponso(esito).risposta;
        final viste = <String>{};
        for (final r in esito.rune) {
          final apertura = 'Per ${r.posizione.glossa},';
          if (!viste.add(apertura)) continue;
          final quante = risposta.split(apertura).length - 1;
          if (quante > 1) {
            litanie.add('${g.id} seme $seme: "$apertura" $quante volte');
          }
        }
      }
    }
    expect(litanie, isEmpty,
        reason: 'la stessa posizione si annuncia piu\' di una volta, e la '
            'lettura diventa una litania:\n${litanie.take(8).join("\n")}');
  });

  test('ogni runa uscita porta la sua lettura nella prima parte', () {
    // **QUESTO PRESIDIO ESISTE PERCHE' UNA PROVA DEL ROSSO E' FALLITA.** Per
    // verificare la guardia della litania ho disattivato il raccoglimento delle
    // glosse, aspettandomi che la litania tornasse: invece le rune SPARIVANO,
    // perche' senza raccoglimento il ciclo emetteva la prima runa del gruppo e
    // saltava le altre. La litania non tornava e la prova restava verde, cioe'
    // il rosso non era rosso.
    //
    // Nessuna prova guardava che TUTTE le rune uscite avessero la loro lettura
    // dentro la prima parte: si potevano perdere tre rune su sei senza che la
    // suite dicesse niente. Adesso questa lo guarda, ed e' la misura che al
    // primo tentativo mancava.
    final perse = <String>[];
    for (final g in gettate) {
      for (var seme = 0; seme < semi; seme++) {
        final esito = RuneCast.getta(g, random: Random(seme));
        final risposta = RunePresagio.componiIlResponso(esito).risposta;
        for (final r in esito.rune) {
          final frase = RunePresagio.primaFraseDiProva(r.riga);
          if (!risposta.toLowerCase().contains(frase.toLowerCase())) {
            perse.add('${g.id} seme $seme: manca la lettura di '
                '${r.rune.name} ("$frase")');
          }
        }
      }
    }
    expect(perse, isEmpty,
        reason: 'una runa e\' uscita e la sua lettura non e\' nel presagio:\n'
            '${perse.take(8).join("\n")}');
  });

  test('la domanda cambia il presagio, e senza domanda parla alla giornata', () {
    // **SE LA DOMANDA SI PERDE, QUESTA PROVA CADE.** E' la ragione per cui la
    // voce S.19 aspettava la S.21: un presagio che riceve la domanda e la ignora
    // e' indistinguibile da uno che non la riceve, quindi la misura e' che i due
    // testi siano DIVERSI.
    for (final g in gettate) {
      final esito = RuneCast.getta(g, random: Random(7));
      final senza = RunePresagio.componiIlResponso(esito);
      final con = RunePresagio.componiIlResponso(esito,
          domanda: 'Nel lavoro, quale passo fare?');
      expect(senza.risposta, isNot(con.risposta),
          reason: '${g.id}: la domanda non cambia niente nel presagio, quindi '
              'il presagio non le sta rispondendo');
      expect(senza.risposta, contains('giornata'),
          reason: '${g.id}: senza domanda il presagio deve parlare alla '
              'giornata, come dice la legge del responso');
      expect(con.risposta, contains('domanda'),
          reason: '${g.id}: con una domanda il presagio non dichiara di stare '
              'rispondendo a quella');
      // Le altre due parti NON dipendono dalla domanda, e va detto: la cosa da
      // fare nasce dalla famiglia e dall'equilibrio, il simbolo dalle rune
      // uscite. Se un giorno dipenderanno, questa riga cadra' e sara' giusto
      // riscriverla di proposito.
      expect(senza.cosaPuoiFare, con.cosaPuoiFare);
      expect(senza.daDoveViene, con.daDoveViene);
    }
  });

  test('la domanda NON si ripete a parole sue dentro il presagio', () {
    // La domanda sta gia' a schermo, nella sua scatola, subito sopra il
    // presagio: citarla dentro sarebbe leggerla due volte. E soprattutto una
    // domanda scritta dalla persona puo' contenere qualunque cosa, e ricopiarla
    // dentro il responso farebbe entrare nel responso testo che non e' nostro.
    const domanda = 'Nel lavoro, quale passo fare?';
    for (final g in gettate) {
      final r = RunePresagio.componiIlResponso(
          RuneCast.getta(g, random: Random(3)),
          domanda: domanda);
      expect(r.inParole.contains(domanda), isFalse,
          reason: '${g.id}: il presagio ricopia la domanda dentro di se\'');
    }
  });

  test('cosa puoi fare e\' una cosa che si puo\' davvero fare', () {
    // **NON "ascolta te stesso", e la regola sta scritta nell'anatomia.** Le
    // formule che non si possono compiere sono la via facile di ogni oracolo, e
    // questa prova le nomina una per una perche' rientrino solo di proposito.
    const vuote = [
      'ascolta te stesso',
      'ascoltati',
      'segui il tuo cuore',
      'fidati del tuo istinto',
      'sii te stesso',
      'apriti all\'universo',
      'lascia andare',
    ];
    final colpe = <String>{};
    final azioni = <String>{};
    for (final g in gettate) {
      for (var seme = 0; seme < semi; seme++) {
        final testo = RunePresagio.componiIlResponso(
                RuneCast.getta(g, random: Random(seme)))
            .cosaPuoiFare;
        azioni.add(testo);
        final basso = testo.toLowerCase();
        for (final v in vuote) {
          if (basso.contains(v)) colpe.add('"$v" in: $testo');
        }
        // Ogni indicazione dichiara un tempo: oggi, stasera, domani. Senza un
        // quando, "fai una cosa concreta" e' un consiglio che non scade mai e
        // quindi non si compie mai.
        if (!basso.contains('oggi') &&
            !basso.contains('stasera') &&
            !basso.contains('domani')) {
          colpe.add('senza un quando: $testo');
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
    // **PIU' DI UNA, e il numero e' dichiarato: nove.** Tre famiglie per tre
    // equilibri di luce e ombra. Una sola indicazione per tutte le gettate si
    // riconoscerebbe alla seconda lettura e smetterebbe di essere un consiglio.
    expect(azioni.length, greaterThanOrEqualTo(6),
        reason: 'le indicazioni distinte sono ${azioni.length}: troppo poche '
            'perche\' la seconda lettura non le riconosca');
  });

  test('la parte quattro resta fuori, dove l\'anatomia la manda', () {
    // La tradizione non sta nel responso: vive nel pannello delle fonti, che per
    // le rune esiste e cita l'Edda poetica e l'Havamal. Se un giorno qualcuno la
    // scrivesse dentro il presagio, il responso diventerebbe una scheda.
    final r = RunePresagio.componiIlResponso(
        RuneCast.getta(gettataNorne, random: Random(1)));
    expect(r.parte(ParteDelResponso.tradizione), isEmpty);
    for (final fonte in const ['Edda', 'Havamal', 'Tacito', 'Snorri']) {
      // Il telo di Tacito e' l'unica eccezione dichiarata: nel getto libero non
      // e' una fonte citata ma il nome della scena, il panno su cui le rune
      // cadono.
      if (fonte == 'Tacito') continue;
      expect(r.inParole.contains(fonte), isFalse,
          reason: 'la fonte "$fonte" e\' finita dentro il presagio');
    }
  });
}
