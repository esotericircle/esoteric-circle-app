import 'dart:io';

import 'package:esoteric_circle/design_system/components/icona_degli_eos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// GLI EOS HANNO UN NOME E UNA LORO ICONA. Ordine S voce 05.
///
/// **Il difetto: in barra il saldo era `Icons.auto_awesome`**, la scintilla di
/// serie di Android, con accanto un numero e nessuna parola. Nessuno capisce che
/// sono Eos, e chi ci prova legge "stelle". Peggio: quella scintilla e' l'icona
/// che il framework mette su mezza app, quindi il denaro del Cerchio portava lo
/// stesso segno di un effetto speciale qualunque.
///
/// **La prova ENUMERA i punti che mostrano un saldo o un premio in Eos.** Visitarne
/// uno non basta: il difetto nasce quando una schermata nuova disegna il suo
/// numero con l'icona che le viene piu' comoda, e allora il saldo in barra e il
/// premio nella celebrazione smettono di somigliarsi.
void main() {
  /// I PUNTI DELL'APP CHE MOSTRANO EOS, enumerati.
  ///
  /// Se ne nasce uno nuovo va aggiunto qui, e la prova dice come accorgersene: il
  /// controllo di sotto cerca la parola Eos in tutto `lib/features` e cade se
  /// trova un file che la mostra e non e' in questo elenco.
  const puntiCheMostranoEos = [
    // **IL SALDO IN BARRA HA CAMBIATO CASA, ordine S voce 06.** Era disegnato
    // dentro `sentiero_screen.dart`, e per questo esisteva in quella schermata
    // sola: adesso e' il segno unico del borsellino, nel design system, e lo
    // monta la barra delle arti. L'elenco segue il codice, non il contrario.
    'lib/design_system/components/borsellino.dart',
    'lib/features/sigilli/card_del_traguardo.dart',
    'lib/features/sigilli/celebrazione.dart',
    // **IL RITROVAMENTO DICE ANCHE GLI EOS, ordine AP voce 05.** E' il punto
    // in cui il Cerchio dimostra a chi rientra che la promessa e' stata
    // mantenuta: proprio li' un numero senza il suo segno sarebbe un numero
    // qualunque, e la prova lo sorveglia come gli altri tre.
    'lib/features/onboarding/scena_del_ritrovamento.dart',
    // **L'INVITO DEL RISCATTO, ordine BG voce 05.** La riga che offre di
    // ricomprare il giorno scrive un prezzo in Eos sul pulsante: da quando
    // esiste, anche lei porta il segno del denaro del Cerchio, non un
    // gettone di serie.
    'lib/features/pricing/upgrade_invite.dart',
    // **LA FESTA DELLA REGISTRAZIONE, ordine BH voce 02**: mostra il
    // premio in grande, col segno del denaro del Cerchio accanto.
    'lib/features/account/festa_della_registrazione.dart',
  ];

  String sorgente(String p) => File(p).readAsStringSync();

  test('ogni punto che mostra Eos usa l\'icona del design system', () {
    final senzaIcona = <String>[];
    for (final punto in puntiCheMostranoEos) {
      final s = sorgente(punto);
      if (!s.contains('IconaDegliEos')) senzaIcona.add(punto);
    }
    expect(senzaIcona, isEmpty,
        reason: 'questi punti mostrano Eos senza l\'icona del design system, '
            'quindi il denaro del Cerchio non ha un segno suo:\n'
            '${senzaIcona.join("\n")}');
  });

  test('nessun numero in Eos ha accanto un\'icona di serie', () {
    // **LA GRANDEZZA MISURATA E' CAMBIATA UNA VOLTA, e sta scritto qui.** La
    // prima stesura cercava la scintilla in TUTTO il file e accusava
    // `sentiero_screen.dart` per un'icona che non e' quella del saldo: il segno
    // del Sigillo acceso nelle righe dell'elenco, che e' un'altra cosa e che
    // questa voce non riguarda. Una prova che accusa il falso insegna a
    // ignorarla, quindi si guarda la VICINANZA: se un'icona di serie compare a
    // meno di sei righe da un numero in Eos, quel numero ha accanto un'icona
    // che non e' la sua.
    const raggioInRighe = 6;
    final colpevoli = <String>[];
    for (final punto in puntiCheMostranoEos) {
      final r = sorgente(punto).split('\n');
      for (var i = 0; i < r.length; i++) {
        if (!r[i].contains("Eos'")) continue;
        final da = (i - raggioInRighe).clamp(0, r.length - 1);
        final a = (i + raggioInRighe).clamp(0, r.length - 1);
        for (var k = da; k <= a; k++) {
          // **UN COMMENTO NON DISEGNA NIENTE.** La riga che spiega quale icona
          // c'era prima nomina per forza la scintilla, e la prima stesura di
          // questa misura accusava se stessa: si salta cio' che comincia con la
          // doppia barra.
          if (r[k].trimLeft().startsWith('//')) continue;
          if (r[k].contains('Icons.')) {
            colpevoli.add('$punto riga ${k + 1}');
          }
        }
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'accanto a un numero in Eos c\'e\' un\'icona di '
            'serie: e\' l\'icona che il framework mette su mezza app, e '
            'accanto a un numero si legge "stelle". $colpevoli');
  });

  test('l\'elenco dei punti e\' completo, e la prova se ne accorge', () {
    // **Il presidio contro la schermata nuova.** Se un file mostra Eos e non e'
    // nell'elenco, questa prova cade col suo nome: e' il solo modo in cui
    // l'enumerazione resta vera nel tempo invece di invecchiare in silenzio.
    final fuoriElenco = <String>[];
    for (final voce in fileScoperti('lib/features',
        minimo: quantiFileHannoLeFunzioni, estensione: '.dart')) {
      final percorso = voce.path.replaceAll('\\', '/');
      final s = voce.readAsStringSync();
      // **LA GRANDEZZA MISURATA SI E' STRETTA UNA VOLTA, E STA SCRITTA QUI.**
      //
      // La prima stesura cercava la parola Eos in qualunque stringa, e con
      // l'ordine BN voce 09 ha accusato la schermata della stesa, che la
      // parola la scrive in una frase ("La stesa completa si apre con gli
      // Eos") e non accanto a nessun numero. Il difetto che questa voce
      // difende e' un altro, e il suo stesso motivo lo dice: "il loro NUMERO
      // puo' nascere con un'icona qualunque". Dove non c'e' nessun numero non
      // c'e' niente da vestire, e pretendere l'icona accanto a una frase
      // vorrebbe dire mettere il segno del denaro dentro un discorso.
      //
      // Quindi si guarda la parola Eos in una stringa mostrata INSIEME a una
      // cifra o a un valore interpolato sulla stessa riga: e' esattamente il
      // caso in cui un numero in Eos prende vita, ed e' quello che la prova
      // sorveglia. Il rosso e' dimostrato: scritta una riga con un prezzo in
      // Eos dentro la schermata della stesa, questa prova cade col suo nome.
      final righe = s.split('\n');
      final mostraUnNumeroInEos = righe.any((r) {
        if (r.trimLeft().startsWith('//')) return false;
        if (!r.contains("Eos'") &&
            !r.contains('Eos "') &&
            !r.contains('Eos ')) {
          return false;
        }
        if (!r.contains("'") && !r.contains('"')) return false;
        return r.contains(RegExp(r'\$\{?\w')) || r.contains(RegExp(r'\d'));
      });
      if (mostraUnNumeroInEos && !puntiCheMostranoEos.contains(percorso)) {
        fuoriElenco.add(percorso);
      }
    }
    expect(fuoriElenco, isEmpty,
        reason: 'questi file mostrano Eos e non sono nell\'elenco della prova: '
            'aggiungili, altrimenti il loro numero puo\' nascere con un\'icona '
            'qualunque e nessuno se ne accorge:\n${fuoriElenco.join("\n")}');
  });

  test('la parola Eos sta accanto al saldo, non solo il numero', () {
    final s = sorgente('lib/design_system/components/borsellino.dart');
    expect(s, contains(r"'${borsa.saldoEos} Eos'"),
        reason: 'il saldo in barra e\' tornato un numero nudo: senza la parola '
            'nessuno impara come si chiama cio\' che sta guadagnando');
  });

  testWidgets('l\'icona si disegna, e a sedici punti lascia un segno leggibile',
      (tester) async {
    // **Non si misura che il widget esista, si misura che DIPINGA.** Un'icona
    // vuota passerebbe qualunque prova strutturale, e a sedici punti il difetto
    // sarebbe invisibile anche a occhio.
    final chiave = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: RepaintBoundary(
          key: chiave,
          child: const ColoredBox(
            color: Colors.black,
            child: IconaDegliEos(misura: 16, colore: Color(0xFFD9B866)),
          ),
        ),
      ),
    ));
    await tester.pump();

    final immagine = await tester.runAsync(() async {
      final confine =
          chiave.currentContext!.findRenderObject() as RenderRepaintBoundary;
      return confine.toImage(pixelRatio: 3);
    });
    final dati = await tester.runAsync(() => immagine!.toByteData());
    final byte = dati!.buffer.asUint8List();
    var dipinti = 0;
    for (var i = 0; i < byte.length; i += 4) {
      // L'oro ha il rosso alto e il blu basso: si contano i pixel dell'icona e
      // non il fondo nero.
      if (byte[i] > 120 && byte[i + 2] < 160) dipinti++;
    }
    final quanti = byte.length ~/ 4;
    final quota = dipinti / quanti;
    // A sedici punti per tre di rapporto sono 48 per 48 pixel: un'icona con
    // quattro tratti ne accende una frazione piccola ma non nulla. La soglia sta
    // in mezzo fra zero e il pieno.
    expect(quota, greaterThan(0.04),
        reason: 'l\'icona dipinge il ${(quota * 100).toStringAsFixed(1)} per '
            'cento dei pixel: a sedici punti non si vede, ed e\' la misura a cui '
            'vive in barra');
    expect(quota, lessThan(0.55),
        reason:
            'l\'icona e\' una macchia piena: a sedici punti i tratti si sono '
            'toccati e non si legge piu\' un\'alba');
  });
}
