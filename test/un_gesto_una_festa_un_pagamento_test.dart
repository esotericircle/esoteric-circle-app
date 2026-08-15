import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// UN GESTO, UNA FESTA, UN PAGAMENTO. Ordine U voce 01.
///
/// **Il difetto, con le parole di Mauro:** non ha senso che la creazione della
/// carta natale sia un traguardo per tutti e tre i Maestri, perche' significa
/// vedere tre volte di seguito la stessa animazione e ricevere tre volte gli Eos
/// per lo stesso motivo. Oltre a essere sbagliato, innervosisce.
///
/// **Si enumera sui gesti e non su un caso scelto.** Un traguardo si accende
/// quando la sua CONDIZIONE e' soddisfatta: se due traguardi di sentieri diversi
/// portano la stessa identica condizione, lo stesso gesto li accende tutti e due
/// nello stesso istante, e allora partono due feste e due accrediti.
///
/// **Questa prova nasce ROSSA il 15 agosto 2026 ed e' giusto cosi': dice il
/// vero.** Oggi tre condizioni sono ripetute su tutti e tre i sentieri, quindi
/// tre gesti producono tre feste e tre pagamenti ciascuno. Torna verde quando i
/// sei traguardi sostitutivi dell'Allegato D sono montati, **e non prima**: non
/// si porta a verde allentando cio' che chiede.
void main() {
  test('nessuna condizione accende piu di un traguardo alla volta', () {
    // La FIRMA di una condizione e' il suo dato, non il suo testo: due
    // traguardi con la stessa firma si accendono insieme, sempre.
    final perFirma = <String, List<String>>{};
    var osservati = 0;
    for (final sentiero in Sentieri.tutti) {
      for (final t in Sentieri.di(sentiero)) {
        osservati++;
        (perFirma[t.condizione.firma] ??= <String>[])
            .add('${sentiero.name}:${t.id}');
      }
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE U VOCE 01: traguardi osservati $osservati');
    expect(osservati, greaterThan(0),
        reason: 'la prova non ha guardato nessun traguardo: gira a vuoto');

    final doppie = <String>[];
    for (final voce in perFirma.entries) {
      if (voce.value.length > 1) {
        doppie.add('${voce.key} -> ${voce.value.join(", ")}');
      }
    }
    // ignore: avoid_print
    print('ORDINE U VOCE 01: condizioni ripetute ${doppie.length}');
    expect(doppie, isEmpty,
        reason: 'queste condizioni sono scritte su piu\' di un traguardo, '
            'quindi UN gesto ne accende piu\' di uno: partono piu\' feste e '
            'piu\' accrediti per lo stesso motivo. Vanno sostituite coi '
            'traguardi dell\'Allegato D, non tolte. ${doppie.join(" | ")}');
  });

  test('MISURA: quante feste e quanti pagamenti produce il gesto peggiore', () {
    // **NON E' UNA SOGLIA, E' UN NUMERO**, e serve a dire quanto e' grave oggi.
    final perFirma = <String, int>{};
    for (final sentiero in Sentieri.tutti) {
      for (final t in Sentieri.di(sentiero)) {
        perFirma[t.condizione.firma] = (perFirma[t.condizione.firma] ?? 0) + 1;
      }
    }
    var peggiore = 0;
    var quale = '';
    var eosDelPeggiore = 0;
    for (final voce in perFirma.entries) {
      if (voce.value > peggiore) {
        peggiore = voce.value;
        quale = voce.key;
      }
    }
    for (final sentiero in Sentieri.tutti) {
      for (final t in Sentieri.di(sentiero)) {
        if (t.condizione.firma == quale) eosDelPeggiore += t.eos;
      }
    }
    // ignore: avoid_print
    print('ORDINE U VOCE 01: la condizione ripetuta di piu\' e\' "$quale", '
        'su $peggiore traguardi, per $eosDelPeggiore Eos in un gesto solo');
    expect(peggiore, greaterThan(0));
  });
}
