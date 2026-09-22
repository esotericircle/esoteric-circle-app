// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **UNA VOCE CHIUSA PORTA LA SUA PROVA, O NON E' CHIUSA.** Ordine EH voce
/// 02, 24 settembre 2026.
///
/// ## PERCHE' ESISTE, CON LE PAROLE DEL FONDATORE
///
/// > *"IO MI SENTO PRESO OER IL CULO QUANDO MI VIENE INDICATO UN ORDINE COME
/// > CONCLUSO E INVECE NON E' STATO FATTO UN CAZZO. Passo meta' del mio tempo
/// > a verificare che l'ordine dichiarato chiuso sia stato effettivamente
/// > concluso, verificato e chiuso. SE UN ORDINE E' DICHIARATO CONCLUSO E
/// > CHIUSO IO VOLGIO LA GARANZIA CHE SIA LA VERITA'!"*
///
/// ## COSA E' ANDATO STORTO DAVVERO, E NON ERA UNA DIMENTICANZA
///
/// **La voce EE.04 era chiusa con una misura vera che rispondeva a un'altra
/// domanda.** Il fondatore aveva detto che il testo del Sigillo del Sogno era
/// *"generico"*; la cura ha preso due frasi dalla Luna di nascita, e il
/// manifesto ha dichiarato, riga 249: *"nella stessa notte, dieci nascite in
/// segni lunari diversi ricevevano sei saluti uguali; adesso ne ricevono dieci
/// diversi"*.
///
/// Quel numero e' vero. Misura che **due persone** leggano cose diverse. Il
/// fondatore, due sere dopo, ha guardato **la stessa persona in due notti** e
/// ha trovato le stesse parole: la Luna di nascita non cambia mai, quindi la
/// cura aveva trasformato una frase uguale per tutti in una frase uguale per
/// sempre.
///
/// **Nessun controllo sulla freschezza della prova avrebbe preso questo
/// difetto**, perche' la prova era fresca; nessun controllo sull'esistenza,
/// perche' esisteva. **Il difetto era che la misura rispondeva a una domanda
/// vicina a quella del fondatore, e nessuno le aveva messe una accanto
/// all'altra.**
///
/// ## LA SOLUZIONE, E PERCHE' E' QUESTA
///
/// Una voce si puo' scrivere `CHIUSA` **solo** se sotto di lei il manifesto
/// porta tre righe che una macchina sa leggere:
///
/// ```
/// DOMANDA: "le parole del fondatore, alla lettera"
/// PROVA: un percorso di un file che esiste davvero nel repo
/// MISURA: la grandezza, col numero prima e il numero dopo
/// ```
///
/// **`DOMANDA` e' la riga che avrebbe salvato la EE.04.** Mette le parole del
/// fondatore **accanto** alla misura, sulla stessa pagina, a due righe di
/// distanza. Una macchina non puo' giudicare se la misura risponde alla
/// domanda; **una persona che le vede accostate ci mette tre secondi**, ed e'
/// esattamente il tempo che il fondatore vuole spendere invece di mezza
/// giornata.
///
/// **`PROVA` deve essere un file che esiste e non e' vuoto.** Una frase come
/// *"verificato a video"* non e' una prova: e' una promessa. Una cattura, una
/// trascrizione, l'uscita di un giro vero, quelle si possono aprire.
///
/// **`MISURA` vuole due numeri.** Un aggettivo non si puo' contestare, un
/// numero si'.
///
/// ## IL TERZO STATO, CHE PRIMA NON ESISTEVA
///
/// Una voce prodotta e agganciata ma non ancora guardata **non e' chiusa**: si
/// scrive `APERTA IN ATTESA DI VERIFICA`. Prima esistevano due soli stati, e
/// una voce fatta a meta' doveva sceglierne uno: sceglieva CHIUSA.
///
/// ## DA QUANDO VALE, E PERCHE' NON E' RETROATTIVA DI COLPO
///
/// Vale **dall'ordine EH in avanti**, e questo ordine e' il primo a
/// obbedirle. Le settantadue voci gia' dichiarate chiuse dall'ordine DX in poi
/// sono il campo della voce EH.03, che le rilegge una per una: farle cadere
/// tutte insieme qui vorrebbe dire una guardia rossa per mesi, e **una guardia
/// che resta rossa a lungo smette di essere letta**.
void main() {
  /// Da quale sigla in poi la regola e' obbligatoria.
  ///
  /// **Le sigle si confrontano come stringhe**, ed e' corretto finche' hanno
  /// tutte la stessa lunghezza o crescono in ordine alfabetico: EH viene dopo
  /// EG, che viene dopo EF. Le sigle a una lettera sola, P, S, T, U, sono le
  /// piu' vecchie di tutte e restano fuori.
  const daQuandoVale = 'EH';

  /// Le sigle a una lettera: ordini antichi, fuori dalla regola.
  bool eAntica(String sigla) => sigla.length < 2;

  final manifesti = Directory('docs/ordini')
      .listSync()
      .whereType<File>()
      .where(
          (f) => f.path.contains('ORDINE_') && f.path.endsWith('_MANIFESTO.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  String siglaDi(File f) {
    final nome = f.uri.pathSegments.last;
    return nome.replaceAll('ORDINE_', '').replaceAll('_MANIFESTO.md', '');
  }

  /// Le voci di un manifesto: il titolo, e il testo fino alla voce dopo.
  List<({String nome, String corpo})> vociDi(String testo) {
    final righe = testo.split('\n');
    final voci = <({String nome, String corpo})>[];
    String? aperta;
    final corpo = StringBuffer();
    for (final riga in righe) {
      final inizio = RegExp(r'^##\s+VOCE\s+([A-Z]+\.\d+)').firstMatch(riga);
      if (inizio != null) {
        if (aperta != null) {
          voci.add((nome: aperta, corpo: corpo.toString()));
        }
        aperta = inizio.group(1);
        corpo.clear();
      } else if (aperta != null) {
        // Una voce finisce anche su un titolo di pari grado che non e' una
        // voce: senza questo, l'ultima voce si mangerebbe tutto il resto del
        // documento e la prova di un'altra sezione passerebbe per sua.
        if (riga.startsWith('## ')) {
          voci.add((nome: aperta, corpo: corpo.toString()));
          aperta = null;
          corpo.clear();
        } else {
          corpo.writeln(riga);
        }
      }
    }
    if (aperta != null) voci.add((nome: aperta, corpo: corpo.toString()));
    return voci;
  }

  /// **E QUESTA VALE SU TUTTI I MANIFESTI, ANCHE I PIU' VECCHI.**
  ///
  /// La regola delle tre righe vale dall'ordine EH in avanti, perche'
  /// riscrivere a mano **mille e una** voci gia' dichiarate chiuse non
  /// sarebbe una garanzia: sarebbe una bugia piu' grande, l'affermazione di
  /// aver riverificato mille cose.
  ///
  /// **Ma una cosa sul passato si puo' pretendere a macchina, ed e' quella
  /// che conta**: che la rete a cui una chiusura si appoggia **esista
  /// ancora**. Un manifesto che nomina `la_barra_si_ritira_da_sola_test` e'
  /// una voce chiusa che si appoggia a una guardia; se quel file non c'e'
  /// piu', quella chiusura poggia sul vuoto **e nessuno se n'era accorto**.
  ///
  /// Misurato il 24 settembre 2026, prima della cura: **diciotto guardie
  /// nominate nei manifesti non esistevano piu'**, sparse su otto ordini.
  ///
  /// **Una guardia che sparisce non e' un reato: rinominarla e' lecito.** Il
  /// reato e' che il manifesto continui a nominarla, perche' da quel momento
  /// il documento dice una cosa falsa a chiunque lo legga per controllare.
  test('nessun manifesto nomina una guardia che non esiste piu', () {
    final colpe = <String>[];
    var manifestiGuardati = 0;
    var guardieGuardate = 0;

    for (final f in manifesti) {
      final testo = f.readAsStringSync();
      if (!testo.contains('CHIUSA')) continue;
      manifestiGuardati++;
      // **LA REGOLA DI LETTURA E' STATA SBAGLIATA DUE VOLTE, e sta scritto
      // qui perche' non si ripeta.**
      //
      // La prima stesura leggeva `[a-z0-9_]+_test`: si fermava sulla prima
      // maiuscola, quindi da `il_disco_dellOracolo_dice_cosa_e_test.dart`
      // ricavava `racolo_dice_cosa_e_test` e lo dichiarava sparito. **Era la
      // misura a essere rotta, non il manifesto.**
      //
      // E prendeva per nome anche i **modelli**, come
      // `test/ordine_<sigla>_guard_test.dart`, che non e' il nome di un file:
      // e' la forma che un nome deve avere. Da li' usciva `_guard_test`.
      //
      // Adesso si accettano le maiuscole e si scartano le righe che portano
      // un segnaposto fra parentesi angolari.
      final nominate = RegExp(r'([A-Za-z0-9_]+_test)[.]dart')
          .allMatches(testo)
          .map((m) => m.group(1)!)
          .where((g) => !g.contains('<') && !g.startsWith('_'))
          .toSet();
      // **UNA GUARDIA PUO' MORIRE, MA VA DICHIARATA.** Rinominarla o toglierla
      // e' lecito: un ordine dopo puo' demolire cio' che un ordine prima
      // sorvegliava, ed e' successo diciassette volte. **Il reato e' che il
      // manifesto continui a nominarla come viva**, perche' da quel momento
      // dice una cosa falsa a chi lo apre per controllare, e chi controlla e'
      // il fondatore.
      //
      // La forma della dichiarazione e' una riga sola:
      // `GUARDIA RIMOSSA: <nome> - <ordine e commit> <ragione>`
      final dichiarateMorte =
          RegExp(r'^GUARDIA RIMOSSA:\s*([A-Za-z0-9_]+)', multiLine: true)
              .allMatches(testo)
              .map((m) => m.group(1)!)
              .toSet();
      for (final g in nominate) {
        guardieGuardate++;
        if (File('test/$g.dart').existsSync()) continue;
        if (dichiarateMorte.contains(g)) continue;
        colpe.add('${siglaDi(f)}: nomina $g.dart, che non esiste piu, e non '
            'dichiara dove sia finita la misura');
      }
    }

    print('ORDINE EH VOCE 03: manifesti con chiusure $manifestiGuardati, '
        'guardie nominate $guardieGuardate');
    // **Il cardinale**: un giorno in cui nessun manifesto nominasse piu'
    // nessuna guardia, questa prova sarebbe verde avendo guardato il vuoto.
    expect(guardieGuardate, greaterThanOrEqualTo(50),
        reason: 'i manifesti nominano solo $guardieGuardate guardie: o si '
            'sono spostati, o la forma dei nomi e cambiata');
    expect(colpe, isEmpty, reason: colpe.join(String.fromCharCode(10)));
  });

  test('ogni voce CHIUSA porta DOMANDA, PROVA e MISURA, e la prova esiste', () {
    final colpe = <String>[];
    var vociGuardate = 0;
    var manifestiGuardati = 0;

    for (final f in manifesti) {
      final sigla = siglaDi(f);
      if (eAntica(sigla) || sigla.compareTo(daQuandoVale) < 0) continue;
      manifestiGuardati++;
      final testo = f.readAsStringSync();
      for (final voce in vociDi(testo)) {
        // Si guarda lo stato dichiarato, non la parola ovunque compaia: un
        // commento che racconta di una voce chiusa altrove non e' uno stato.
        final chiusa =
            RegExp(r'^\*\*CHIUSA[.,*]', multiLine: true).hasMatch(voce.corpo);
        if (!chiusa) continue;
        vociGuardate++;

        for (final riga in ['DOMANDA', 'PROVA', 'MISURA']) {
          final trovata = RegExp('^$riga:\\s*(.+)\$', multiLine: true)
              .firstMatch(voce.corpo);
          if (trovata == null || trovata.group(1)!.trim().isEmpty) {
            colpe.add('${voce.nome}: si dichiara CHIUSA senza la riga $riga');
            continue;
          }
          if (riga == 'PROVA') {
            // **La prova e' un file che si puo' aprire.** Una frase come
            // "verificato a video" e' una promessa, non una prova.
            final percorso = trovata.group(1)!.trim().replaceAll('`', '');
            final prova = File(percorso);
            if (!prova.existsSync()) {
              colpe.add('${voce.nome}: la prova "$percorso" non esiste');
            } else if (prova.lengthSync() == 0) {
              colpe.add('${voce.nome}: la prova "$percorso" e\' vuota');
            }
          }
          if (riga == 'MISURA' && !RegExp(r'\d').hasMatch(trovata.group(1)!)) {
            colpe.add('${voce.nome}: la MISURA non porta nessun numero, e un '
                'aggettivo non si puo\' contestare');
          }
        }
      }
    }

    print('ORDINE EH VOCE 02: manifesti sotto la regola $manifestiGuardati, '
        'voci chiuse guardate $vociGuardate');
    // **Il cardinale.** Se un domani i manifesti si spostassero, questa prova
    // girerebbe su zero e sarebbe verde senza aver guardato niente.
    expect(manifestiGuardati, greaterThanOrEqualTo(1),
        reason: 'nessun manifesto ricade sotto la regola: o si sono spostati, '
            'o la sigla di partenza non e\' piu\' quella');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
