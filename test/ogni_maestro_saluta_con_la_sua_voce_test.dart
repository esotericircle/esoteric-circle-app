// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_welcome.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **OGNI MAESTRO SALUTA CON LA SUA VOCE.** Ordine EB voce 08, 21 settembre
/// 2026.
///
/// **Le parole del fondatore**: *"ogni maestro ha la sua personalità AI e
/// ognuno risponde in modo diverso secondo personalità e competenze, ma
/// soprattutto l'utente deve avere l'illusione di parlare con una persona
/// vera"*. E, sulle frasi fatte: *"ogni risposta preconfezionata uguale per
/// tutti, ogni frase fatta e ogni ripetizione lavorano contro questo
/// risultato: dove le trovi, le togli"*.
///
/// **Il fatto, misurato.** Il benvenuto della chat prendeva il Maestro fra i
/// suoi parametri e **non lo usava**: le dodici aperture e le sei domande
/// erano le stesse per Medora, Aura e Caligo. E' la prima cosa che una
/// persona legge aprendo una chat.
///
/// **Ed era peggio che uguale.** Quelle frasi condivise contenevano le parole
/// di firma di tutti e tre: *"la soglia è aperta"* e' di Caligo, *"prenditi
/// un respiro"* e' di Aura, *"le voci del cielo"* e' di Medora. Ognuno dei
/// tre le diceva tutte, cioe' **il saluto violava il divieto incrociato del
/// lessico** che l'ordine BP aveva imposto al modello, proprio nel punto in
/// cui il modello non c'entra niente.
void main() {
  final profilo = UserProfile(displayName: 'Mauro');

  /// Il benvenuto di un Maestro, in tutte le sue rotazioni.
  List<String> benvenutiDi(Maestro m) => [
        for (var r = 0; r < 24; r++)
          MaestroWelcome.compose(
            maestro: m,
            profile: profilo,
            premium: false,
            rotation: r,
          ),
      ];

  test('i tre non si salutano con le stesse parole', () {
    const maestri = Maestro.values;
    cardinaleMinimo(maestri.length, 3,
        cosa: 'Maestri del cerchio',
        perche: 'Se l\'elenco si svuotasse, questa prova non confronterebbe '
            'niente.');
    final perMaestro = {for (final m in maestri) m: benvenutiDi(m).toSet()};
    for (final m in maestri) {
      cardinaleMinimo(perMaestro[m]!.length, 4,
          cosa: 'benvenuti diversi di ${m.name}',
          perche: 'Un solo benvenuto ripetuto e\' gia\' una frase fatta.');
    }
    final condivisi = perMaestro[Maestro.medora]!
        .intersection(perMaestro[Maestro.aura]!)
        .intersection(perMaestro[Maestro.caligo]!);
    print('ORDINE EB VOCE 08: benvenuti per Maestro '
        '${perMaestro.map((k, v) => MapEntry(k.name, v.length))}, '
        'condivisi da tutti e tre ${condivisi.length}');
    expect(condivisi, isEmpty,
        reason: 'questi benvenuti sono identici per tutti e tre i Maestri, ed '
            'e\' la prima cosa che una persona legge: '
            '${condivisi.take(3).toList()}');
  });

  test('e nessuno saluta con le parole di firma degli altri due', () {
    // **IL DIVIETO INCROCIATO, che l'ordine BP ha imposto al modello, vale
    // anche per le frasi che scriviamo noi.** Un Maestro che usa le parole
    // di un altro non e' piu' riconoscibile, ed e' il difetto che l'ordine BP
    // ha misurato sul modello: Caligo scambiato per Aura fino al 60 per
    // cento.
    final storti = <String>[];
    for (final m in Maestro.values) {
      final vietate = VoceDelMaestro.lessicoDegliAltri(m);
      cardinaleMinimo(vietate.length, 10,
          cosa: 'parole di firma degli altri due rispetto a ${m.name}',
          perche: 'Senza l\'elenco il divieto non guarderebbe niente.');
      for (final frase in benvenutiDi(m)) {
        final basso = frase.toLowerCase();
        for (final parola in vietate) {
          if (RegExp('\\b${RegExp.escape(parola.toLowerCase())}')
              .hasMatch(basso)) {
            storti.add('${m.name} dice "$parola": "$frase"');
          }
        }
      }
    }
    print('ORDINE EB VOCE 08: saluti col lessico altrui ${storti.length}');
    expect(storti, isEmpty,
        reason: 'questi saluti usano le parole di firma di un altro Maestro:\n'
            '${storti.take(5).join("\n")}');
  });
}
