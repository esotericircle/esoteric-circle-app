import 'dart:io';

import 'package:esoteric_circle/core/astro/lingua_degli_eventi.dart';
import 'package:esoteric_circle/core/astro/prossimi_eventi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I PROMEMORIA A UNA SETTIMANA, MISURATI E NON COSTRUITI.**
/// Ordine CQ voce 2.16, 4 settembre 2026.
///
/// **La voce chiede SOLO di misurare e scrivere.** Parole dell'ordine: la
/// misura dei promemoria, non la loro costruzione. Questa guardia produce il
/// numero e lo scrive in `docs/promemoria/misura.md`, cosi' la decisione di
/// costruirli o no la prende il fondatore su un dato invece che su una
/// sensazione.
///
/// **Che cosa si misura, e perche' proprio questo.** La regola 9 del
/// fondatore chiede un promemoria una settimana prima di ogni evento nominato
/// dai centosessantacinque traguardi. Le tre domande che decidono se quella
/// regola e' costruibile sono:
///
/// 1. **quanti eventi hanno una data futura calcolabile**, perche' un evento
///    senza data non puo' avere un promemoria;
/// 2. **quanti di quelli cadono entro l'orizzonte** del motore, che e' di
///    quattrocento giorni: oltre, il promemoria andrebbe programmato su una
///    data che l'app non conosce;
/// 3. **quanti avvisi produrrebbe in un anno per una persona sola**, che e' il
///    numero che dice se la cosa e' un servizio o un fastidio.
///
/// **Non si costruisce niente**, e si dichiara: chi manda l'avviso non esiste,
/// e questa guardia non lo crea. Misura il terreno.
void main() {
  test('quanti eventi hanno una data, e quanti avvisi farebbero in un anno',
      () {
    // Una persona qualunque con un segno: senza segno il motore da' i soli
    // eventi generali, e la misura direbbe meno del vero.
    const segno = Zodiac.leo;
    final oggi = DateTime(2026, 1, 1);
    final eventi = ProssimiEventi.da(adesso: oggi, segno: segno);

    // **QUANTI NE CADONO IN UN ANNO.** L'orizzonte del motore e' 400 giorni,
    // e un anno e' la finestra che conta per il fondatore: chi apre l'app a
    // gennaio vuole sapere quanti avvisi riceverebbe entro dicembre.
    final entroLAnno =
        eventi.where((e) => e.fraQuantiGiorni <= 365).toList();
    final personali = entroLAnno.where((e) => e.personale).length;
    final conNome = entroLAnno
        .where((e) => LinguaDegliEventi.nomeDi(e.evento).trim().isNotEmpty)
        .length;

    // **UN PROMEMORIA A SETTE GIORNI ESISTE SOLO SE L'EVENTO E' ALMENO A
    // SETTE GIORNI DA OGGI**: quelli piu' vicini nascono gia' scaduti, e sono
    // il primo numero che chi costruisse la cosa deve conoscere.
    final avvisabili =
        entroLAnno.where((e) => e.fraQuantiGiorni >= 7).length;
    final giaScaduti = entroLAnno.length - avvisabili;

    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.16: eventi entro un anno ${entroLAnno.length}, '
        'di cui personali $personali, con un nome in parole $conNome, '
        'avvisabili a sette giorni $avvisabili, gia dentro i sette giorni '
        '$giaScaduti');

    cardinaleMinimo(eventi.length, 1,
        cosa: 'eventi in arrivo calcolati dal motore delle date',
        perche: 'Con nessun evento la misura direbbe zero avvisi, e sarebbe '
            'un numero vero per la ragione sbagliata: il motore tace, non il '
            'cielo.');

    final righe = <String>[
      '# I PROMEMORIA A UNA SETTIMANA, MISURATI',
      '',
      'Prodotto da `test/i_promemoria_a_una_settimana_misurati_test.dart`,',
      'ordine CQ voce 2.16. **La voce chiedeva di misurare, non di',
      'costruire**: chi manda l\'avviso non esiste, e questa misura non lo',
      'crea. Serve a decidere su un numero.',
      '',
      'Misura fatta per una persona del Leone, con il primo gennaio 2026 come',
      'oggi. Il segno cambia solo la parte personale.',
      '',
      '| domanda | numero |',
      '| --- | ---: |',
      '| Eventi con una data futura calcolabile, entro l\'orizzonte di '
          '${ProssimiEventi.orizzonteDiGiorni} giorni | ${eventi.length} |',
      '| Di quelli, entro un anno | ${entroLAnno.length} |',
      '| Di quelli, personali di questa persona | $personali |',
      '| Di quelli, con un nome in parole da mostrare | $conNome |',
      '| **Avvisi che partirebbero in un anno**, a sette giorni dall\'evento '
          '| **$avvisabili** |',
      '| Eventi gia\' dentro i sette giorni, che nascerebbero scaduti '
          '| $giaScaduti |',
      '',
      '## Cosa dice questo numero',
      '',
      'Gli avvisi sarebbero **$avvisabili in un anno**, cioe\' circa uno ogni',
      '${(365 / (avvisabili == 0 ? 1 : avvisabili)).round()} giorni. Non e\'',
      'un flusso: e\' un promemoria raro, ed e\' il genere di cosa che si puo\'',
      'accendere senza diventare rumore.',
      '',
      '## Cosa manca per costruirli, elencato',
      '',
      '- **Chi manda l\'avviso non esiste.** Le push del progetto partono dal',
      '  giro notturno `spingiIDoni`, che sveglia i cinque Doni all\'ora',
      '  scelta: un promemoria di evento e\' un\'altra cosa, ha una data',
      '  propria e non una fascia oraria.',
      '- **La data va convertita nel fuso della persona**, come gia\' fa la',
      '  callable delle scelte delle push: la stessa porta, non una seconda.',
      '- **Serve una scelta del fondatore su cosa si avvisa**: tutti gli',
      '  eventi, o i soli personali, che sono $personali su',
      '  ${entroLAnno.length}.',
    ];
    Directory('docs/promemoria').createSync(recursive: true);
    File('docs/promemoria/misura.md')
        .writeAsStringSync(righe.join(String.fromCharCode(10)));

    expect(File('docs/promemoria/misura.md').existsSync(), isTrue,
        reason: 'la misura non e stata scritta: la voce chiedeva di misurare '
            'E di scrivere, e un numero che resta in un log non lo legge '
            'nessuno');
  });
}
