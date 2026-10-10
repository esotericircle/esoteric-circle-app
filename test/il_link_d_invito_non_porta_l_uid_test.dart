// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/brand/brand.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/condivisione/porta_della_condivisione.dart';
import 'package:esoteric_circle/features/account/riscatta_l_invito.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **IL CODICE DELL'INVITO E' OPACO, ordine EY voce 17, e IL LINK STA DENTRO
/// LA PORTA, voce 15.**
///
/// Il difetto, misurato: `codiceDellInvito` componeva `<uid>.<maestro>` e i
/// testi lo mettevano dentro `${Brand.url}?invito=...`, cosi' l'identificativo
/// stabile di una persona viaggiava in chiaro su WhatsApp e sui social, per
/// sempre e senza revoca.
///
/// La guardia ENUMERA, non visita un caso: ogni punto di `lib` che compone un
/// testo d'invito o chiama la porta della condivisione, e cade se un uid ci
/// entra. Domani nascera' un quarto testo: passera' di qui.
void main() {
  /// Il testo di una chiamata, dalla parentesi aperta a quella che la chiude.
  String argomenti(String s, int apre) {
    var profondita = 0;
    for (var i = apre; i < s.length; i++) {
      if (s[i] == '(') profondita++;
      if (s[i] == ')') {
        profondita--;
        if (profondita == 0) return s.substring(apre, i + 1);
      }
    }
    return s.substring(apre);
  }

  test('GUARDIA EY.17: nessun testo o link condiviso porta un uid', () {
    final chiamate = RegExp(
        r'(TestoDellaCondivisione\.(perIlTraguardo|invitoLibero)|PortaDellaCondivisione\.(testo|daFile|immagine|piuFile))\(');
    var punti = 0;
    var file = 0;
    final colpevoli = <String>[];
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll('\\', '/');
      final s = f.readAsStringSync();
      var qui = 0;
      for (final m in chiamate.allMatches(s)) {
        qui++;
        final args = argomenti(s, m.end - 1);
        if (RegExp(r'\buid\b|\.uid\b|codiceDellInvito').hasMatch(args)) {
          colpevoli.add('$percorso: ${args.split('\n').first}');
        }
      }
      // Nessuno compone piu' a mano il link vecchio con l'identificativo.
      if (RegExp(r'invito=\$').hasMatch(s)) {
        colpevoli.add('$percorso: compone ancora ?invito= con un valore');
      }
      if (qui > 0) file++;
      punti += qui;
    }
    print('EY.17 PUNTI CHE CONDIVIDONO O COMPONGONO UN INVITO: $punti in '
        '$file file, con un uid ${colpevoli.length}');
    expect(punti, greaterThanOrEqualTo(20),
        reason: 'la prova non trova piu\' i punti che condividono');
    expect(colpevoli, isEmpty);
  });

  group('GUARDIA EY.15: il link d\'invito lo mette la porta', () {
    tearDown(() => PortaDellaCondivisione.codiceDellInvito = null);

    test(
        'dove il testo nomina il Cerchio, il link col codice ne prende il '
        'posto', () async {
      PortaDellaCondivisione.codiceDellInvito = () async => 'AB12CD34';
      final con =
          await PortaDellaCondivisione.conIlLink('Scopri il tuo: ${Brand.url}');
      expect(con, 'Scopri il tuo: ${Brand.urlDegliInviti}/i/AB12CD34');
      final porta = await PortaDellaCondivisione.conIlLink(
          'Vieni: ${PortaDellaCondivisione.segnoDellaPorta('aura')}');
      expect(porta, 'Vieni: ${Brand.urlDegliInviti}/i/AB12CD34.aura');
      final senza = await PortaDellaCondivisione.conIlLink('Guarda che carta');
      expect(senza, 'Guarda che carta\n${Brand.urlDegliInviti}/i/AB12CD34');
      final nulla = await PortaDellaCondivisione.conIlLink(null);
      expect(nulla, '${Brand.urlDegliInviti}/i/AB12CD34');
      print('EY.15 LINK NELLA CARD: "$con"');
    });

    test('senza codice il testo parte com\'e\': il ripiego e\' dichiarato',
        () async {
      PortaDellaCondivisione.codiceDellInvito = () async => null;
      expect(await PortaDellaCondivisione.conIlLink('Ciao ${Brand.url}'),
          'Ciao ${Brand.url}');
      PortaDellaCondivisione.codiceDellInvito =
          () async => throw StateError('rete giu');
      expect(await PortaDellaCondivisione.conIlLink('Ciao'), 'Ciao');
    });

    test('il link porta solo il codice opaco, e il codice torna indietro', () {
      final link = IlCerchioSociale.linkDi('AB12CD34');
      expect(link, '${Brand.urlDegliInviti}/i/AB12CD34');
      expect(IlCerchioSociale.codiceDaUnLink(link), 'AB12CD34');
      expect(IlCerchioSociale.codiceDaUnLink('esotericircle://i/K7Q2M9'),
          'K7Q2M9');
      expect(IlCerchioSociale.codiceDaUnLink('$link.aura'), 'AB12CD34');
      // Il link vecchio con l'uid non apre un legame.
      expect(
          IlCerchioSociale.codiceDaUnLink(
              '${Brand.url}?invito=kJ3nX9aQ2bYt7Lm4Pq8Rs1Uv0WxZ.aura'),
          isNull);
      // Il riscatto lo capisce, nelle due forme.
      expect(
          codiceDaCioCheEStatoIncollato('Ciao! $link.aura'), 'AB12CD34.aura');
    });
  });
}
