import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/onboarding/primo_approdo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **DUE SEZIONI CAMBIANO NOME.** Ordine EO voce 11, 26 settembre 2026.
///
/// *"La sezione "Rune" di Calìgo si chiama "Divinazione". La sezione
/// "Archetipi" di Aura si chiama "Fisiognomica". Ovunque a video compare
/// l'elenco delle sezioni di un Maestro, i nomi e l'ordine seguono EO.10 e
/// questa voce."*
///
/// **Si contano le righe a video coi nomi vecchi**, raccolte dai punti da cui
/// ogni schermata prende l'elenco delle sezioni: i titoli del catalogo (il
/// dominio), le arti del Maestro (la riga sotto i Maestri in home, i
/// pilastri, il sottotitolo della chat, la persona dei Maestri), la parola
/// sotto i due Maestri di lato, e il fumetto del primo approdo.
void main() {
  /// L'ordine del fondatore, alla lettera dalla voce EO.10.
  const ordine = <Maestro, List<String>>{
    Maestro.medora: [
      'Astrologia',
      'Cartomanzia',
      'Compatibilità',
      'Lunologia',
      'Destino'
    ],
    Maestro.aura: ['Energia', 'Chakra', 'Fisiognomica'],
    Maestro.caligo: ['Divinazione', 'Rituali', 'Magia', 'Numerologia'],
  };

  /// Le righe a video che portano un elenco di sezioni, per Maestro.
  List<(String, String)> righeAVideo() => [
        for (final m in Maestro.values) ...[
          for (final s in ArtCatalog.forMaestro(m))
            ('titolo di sezione nel dominio di ${m.id}', s.title),
          ('arti del dominio di ${m.id} (home, pilastri)', m.domainArts),
          ('arti in frase di ${m.id} (chat, persona)', m.domainArtsPhrase),
          ('parola sotto ${m.id} di lato in home', m.domainArtiBrevi),
        ],
        for (final f in cinqueFumetti)
          for (final r in f.testo.split('\n')) ('fumetto del primo approdo', r),
      ];

  final nomeVecchio = RegExp(r'\b(Archetipi|Rune)\b');

  test('EO.11: nessuna riga a video coi nomi vecchi delle due sezioni', () {
    final righe = righeAVideo();
    cardinaleMinimo(righe.length, 30,
        cosa: 'righe a video con un elenco di sezioni',
        perche: 'oggi sono 12 titoli, 9 righe dei Maestri e le righe dei '
            'fumetti.');
    final vecchie = [
      for (final (dove, r) in righe)
        // "Estrazione Rune" e' il nome di un'arte, non di una sezione.
        if (nomeVecchio.hasMatch(r.replaceAll('Estrazione Rune', '')))
          '$dove: $r',
    ];
    // ignore: avoid_print
    print('EO.11 MISURA: righe a video coi nomi vecchi ${vecchie.length} su '
        '${righe.length}${vecchie.isEmpty ? '' : '\n  ${vecchie.join('\n  ')}'}');
    expect(vecchie, isEmpty);
  });

  test(
      'EO.10 e EO.11: le sezioni di ogni Maestro, coi nomi e nell\'ordine del '
      'fondatore', () {
    for (final m in Maestro.values) {
      expect([for (final s in ArtCatalog.forMaestro(m)) s.title], ordine[m],
          reason: 'le sezioni di ${m.id} nel catalogo');
      // Le arti del Maestro nominano tre sezioni: devono essere sezioni vere
      // e nell'ordine del fondatore.
      final tre = m.domainArts.split(',').map((s) => s.trim()).toList();
      final posti = [for (final t in tre) ordine[m]!.indexOf(t)];
      expect(posti.every((p) => p >= 0), isTrue,
          reason: '${m.id} dichiara sezioni che non esistono: $tre');
      expect(posti, [...posti]..sort(),
          reason: '${m.id} dichiara le sezioni fuori dall\'ordine: $tre');
    }
    expect(Maestro.aura.domainArtsPhrase, 'Energia, Chakra e Fisiognomica',
        reason: 'il sottotitolo sotto il nome di Aura nella chat');
  });
}
