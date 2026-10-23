// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/la_lettura_del_giorno.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA LETTURA RIDETTA HA LA VOCE DI CHI LA RIDICE.** Ordine EC voce 03, 21
/// settembre 2026.
///
/// **COME E' STATO TROVATO, e conta.** Non da un innesto: dal collaudo con
/// Gemini vero della voce EC.01, al primo giro. La mossa 10 del catalogo
/// dell'ordine EB, *"ripete la stessa richiesta uguale"*, fatta ad Aura: al
/// secondo invio della stessa domanda il Maestro ridice la lettura del
/// giorno, e la premessa che la introduce diceva **"Il cielo di oggi non e'
/// cambiato"**. *Cielo* e' una parola di firma di Medora
/// (`VoceDelMaestro.perMaestro[Maestro.medora].lessicoDiFirma`), e quella
/// premessa era **una frase sola per tutti e tre**.
///
/// **E' lo stesso difetto della voce EB.08**, il benvenuto uguale per i tre
/// col lessico di tutti e tre, in un secondo punto che quell'ordine non
/// aveva guardato. **Padre: PROVENIENZA IGNOTA**, la premessa nasce col file
/// `la_lettura_del_giorno.dart` come costante unica.
///
/// **Perche' pesa piu' di quanto sembri.** E' una delle pochissime frasi che
/// il Maestro dice **senza passare dal modello**: qui non c'e' nessuna
/// istruzione che possa correggerla, e quello che e' scritto e' quello che la
/// persona legge.
void main() {
  test('i tre non ridicono la lettura con le stesse parole', () {
    const maestri = Maestro.values;
    cardinaleMinimo(maestri.length, 3,
        cosa: 'Maestri del cerchio',
        perche: 'Se l\'elenco si svuotasse, questa prova non confronterebbe '
            'niente.');
    final premesse = {
      for (final m in maestri) m: LaLetturaDelGiorno.premessaDi(m).trim()
    };
    print('ORDINE EC VOCE 03, le premesse:'
        '${premesse.entries.map((e) => "\n  ${e.key.id}: ${e.value}").join()}');
    for (final m in maestri) {
      expect(premesse[m], isNotEmpty,
          reason: '${m.id} non ha una premessa: ridirebbe la lettura senza '
              'dire che la sta ridicendo');
    }
    expect(premesse.values.toSet(), hasLength(maestri.length),
        reason: 'due o piu\' Maestri ridicono la lettura con la stessa '
            'identica frase: e\' una risposta preconfezionata uguale per '
            'tutti, e l\'ordine EB voce 08 dice di toglierle dove si trovano');
  });

  test('e nessuno la ridice con le parole di firma degli altri due', () {
    final storti = <String>[];
    for (final m in Maestro.values) {
      final vietate = VoceDelMaestro.lessicoDegliAltri(m);
      cardinaleMinimo(vietate.length, 10,
          cosa: 'parole di firma degli altri due rispetto a ${m.id}',
          perche: 'Senza l\'elenco il divieto non guarderebbe niente.');
      final basso = LaLetturaDelGiorno.premessaDi(m).toLowerCase();
      for (final parola in vietate) {
        if (RegExp('\\b${RegExp.escape(parola.toLowerCase())}\\b')
            .hasMatch(basso)) {
          storti.add('${m.id} dice "$parola" nella premessa della lettura '
              'ridetta: "${LaLetturaDelGiorno.premessaDi(m)}"');
        }
      }
    }
    print('ORDINE EC VOCE 03: premesse col lessico altrui ${storti.length}');
    expect(storti, isEmpty, reason: storti.join('\n'));
  });

  test('la lettura ridetta porta la premessa e poi la lettura', () {
    // La forma non cambia: prima si dichiara che si sta ridicendo, poi si
    // ridice. Senza la premessa la persona leggerebbe due volte la stessa
    // cosa senza sapere perche'.
    const lettura = 'La lettura di prima, parola per parola.';
    for (final m in Maestro.values) {
      final ridetta = LaLetturaDelGiorno.ridetta(lettura, m);
      expect(ridetta, startsWith(LaLetturaDelGiorno.premessaDi(m)),
          reason: '${m.id} ridice la lettura senza dichiararlo');
      expect(ridetta, endsWith(lettura),
          reason: '${m.id} ha perso la lettura che doveva ridire');
    }
  });
}
