// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/cerchio/i_segni_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I DICIOTTO SEGNI DEL CERCHIO HANNO I TESTI VERI, ordine EZ voce 08.**
///
/// I testi sono dell'Architetto, scritti il 4 ottobre 2026; gli
/// identificativi sono quelli che il server conosce. La prova pretende:
/// diciotto segni con titolo, riga di chi riceve e almeno due risposte; sei,
/// sei e sei per categoria; gli stessi identificativi e lo stesso numero di
/// risposte del server; nessuna riga segnaposto; nessun nome dentro le righe;
/// e nessuna riga astrale che AFFERMI un fatto del cielo.
///
/// **LE FORME VIETATE**, dichiarate perche' la lista e' piu' larga di quella
/// dell'ordine ("è", "sta", "entra" seguite da un corpo celeste): un corpo
/// celeste (Sole, Luna, Mercurio, Venere, Marte, Giove, Saturno, Urano,
/// Nettuno, Plutone, le stelle, un pianeta) nella stessa frase di "è", "sta",
/// "entra", "transita", "passa", "si trova", "ti guarda", "ti cerca", "dice",
/// in un verso o nell'altro. Le quattro righe astrali dell'ordine EY ("La Luna
/// stanotte è per te", "Venere oggi ti guarda", "Il Sole oggi ti cerca",
/// "Guarda cosa dice Marte per te") cadrebbero tutte.
void main() {
  const corpi =
      r'(Sole|Luna|Mercurio|Venere|Marte|Giove|Saturno|Urano|Nettuno|Plutone|stelle|pianet[aie])';
  const verbi =
      r'(è|sta|entra|transita|passa|si trova|ti guarda|ti cerca|dice)';
  // I confini di parola a mano: `\b` di Dart non conta le lettere accentate
  // come lettere, e "è" non veniva mai preso (l'ha mostrato la prova stessa,
  // con tre righe di prima prese su quattro).
  const prima = r'(?<![A-Za-zÀ-ÿ])';
  const dopo = r'(?![A-Za-zÀ-ÿ])';
  final affermaIlCielo = [
    RegExp('$prima$corpi$dopo[^.?!]*$prima$verbi$dopo', caseSensitive: false),
    RegExp('$prima$verbi$dopo[^.?!]*$prima$corpi$dopo', caseSensitive: false),
  ];
  bool afferma(String riga) => affermaIlCielo.any((r) => r.hasMatch(riga));

  test(
      'EZ.08: diciotto segni, sei per categoria, ognuno con titolo, riga e '
      'risposte', () {
    const tutti = ISegniDelCerchio.tutti;
    cardinaleMinimo(tutti.length, 18,
        cosa: 'segni del Cerchio', perche: 'L\'Architetto ne ha scritti 18.');
    final perCategoria = {
      for (final c in CategoriaDelSegno.values)
        c.name: ISegniDelCerchio.di(c).length,
    };
    final incompleti = [
      for (final s in tutti)
        if (s.testo.trim().isEmpty ||
            s.rigaDiChiRiceve.trim().isEmpty ||
            s.risposte.length < 2)
          s.id,
    ];
    final richiesteSenzaArte = [
      for (final s in ISegniDelCerchio.di(CategoriaDelSegno.richieste))
        if (s.apre == null) s.id,
    ];
    print('EZ.08 I SEGNI: ${tutti.length}, per categoria $perCategoria, '
        'incompleti $incompleti, richieste che non aprono niente '
        '$richiesteSenzaArte');
    expect(tutti.length, 18);
    expect(perCategoria.values, everyElement(6));
    expect(incompleti, isEmpty);
    expect(richiesteSenzaArte, isEmpty);
    expect({for (final s in tutti) s.apre}.whereType<ArteDellaRichiesta>(),
        hasLength(6),
        reason: 'ogni richiesta apre una cosa diversa');
  });

  test('EZ.08: gli identificativi e le risposte sono quelli del server', () {
    final server = File('functions/src/sociale.ts').readAsStringSync();
    final blocco =
        RegExp(r'RISPOSTE_PER_SEGNO: Record<string, number> = \{([^}]*)\}')
            .firstMatch(server)!
            .group(1)!;
    final delServer = {
      for (final m in RegExp(r'(\w+): (\d+)').allMatches(blocco))
        m.group(1)!: int.parse(m.group(2)!),
    };
    final delTelefono = {
      for (final s in ISegniDelCerchio.tutti) s.id: s.risposte.length,
    };
    print('EZ.08 IL SERVER: ${delServer.length} segni; diversi '
        '${delTelefono.entries.where((e) => delServer[e.key] != e.value).map((e) => e.key).toList()}');
    expect(delTelefono, delServer);
  });

  test(
      'EZ.08: nessun segnaposto, nessun nome dentro le righe, e nessuna riga '
      'astrale afferma un fatto del cielo', () {
    final sorgente =
        File('lib/core/cerchio/i_segni_del_cerchio.dart').readAsStringSync();
    final astrali = ISegniDelCerchio.di(CategoriaDelSegno.astrali);
    final righeAstrali = [
      for (final s in astrali) ...[s.testo, s.rigaDiChiRiceve, ...s.risposte],
    ];
    cardinaleMinimo(righeAstrali.length, 24,
        cosa: 'righe astrali',
        perche: 'Sei segni con titolo, riga e due risposte ciascuno.');
    final affermano = [
      for (final r in righeAstrali)
        if (afferma(r)) r
    ];
    // Le forme vietate prendono davvero le righe di prima: una prova che non
    // le vedesse non guarderebbe niente.
    final diPrima = [
      'La Luna stanotte è per te',
      'Venere oggi ti guarda',
      'Il Sole oggi ti cerca',
      'Guarda cosa dice Marte per te',
    ];
    final tutte = [
      for (final s in ISegniDelCerchio.tutti) ...[
        s.testo,
        s.rigaDiChiRiceve,
        ...s.risposte
      ],
    ];
    final conUnNome = [
      for (final r in tutte)
        if (RegExp(r'\$|\{|Stella|Lunaria|Medora|Aura|Caligo').hasMatch(r)) r
    ];
    final senzaAccenti = [
      for (final r in tutte)
        if (r.contains("'") || r.contains('—')) r
    ];
    print('EZ.08 LE RIGHE ASTRALI: ${righeAstrali.length}, che affermano un '
        'fatto del cielo ${affermano.length} $affermano; le righe di prima '
        'prese ${diPrima.where(afferma).length} su ${diPrima.length}; righe '
        'con un nome ${conUnNome.length}, con apostrofi dritti o trattini '
        'lunghi ${senzaAccenti.length}');
    expect(diPrima.where(afferma), hasLength(diPrima.length));
    expect(affermano, isEmpty);
    expect(conUnNome, isEmpty);
    expect(senzaAccenti, isEmpty);
    expect(sorgente.contains('SEGNAPOSTO DICHIARATI'), isFalse,
        reason: 'il file dichiara ancora i testi segnaposto');
    for (final vecchia in diPrima) {
      expect(tutte.contains(vecchia), isFalse,
          reason: 'resta un testo provvisorio di Code: $vecchia');
    }
  });
}
