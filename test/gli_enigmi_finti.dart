/// **GLI ENIGMI FINTI**, ordine FF: le risposte delle porte degli Enigmi
/// con la stessa forma del server (`functions/src/il_cerchio_sociale.ts`,
/// parte E), per le prove delle schermate e per le anteprime. Nomi di
/// persone inventati, nessun dato vero.
abstract final class GliEnigmiFinti {
  static const List<Map<String, Object?>> facce = [
    {'uid': 'u-stella', 'nome': 'Stella Lieve', 'icona': 'animale:6'},
    {'uid': 'u-orione', 'nome': 'Orione', 'icona': 'archetipo:3'},
    {'uid': 'u-selene', 'nome': 'Selene', 'icona': 'animale:2'},
    {'uid': 'u-dario', 'nome': 'Dario', 'icona': null},
  ];

  /// Un indovinello appena aperto: chi di loro perde le chiavi.
  static Map<String, Object?> partita({List<Map<String, Object?>>? indizi}) => {
        'ok': true,
        'partita': 'partita-prova-0001',
        'facce': facce,
        'domanda': {'tipo': 'tratto', 'valore': '51'},
        'indizi': indizi ?? const [],
        'costoProssimo': switch ((indizi ?? const []).length) {
          0 => 0,
          1 || 2 => 5,
          _ => null,
        },
        'chiusa': false,
      };

  static const List<Map<String, Object?>> dueIndizi = [
    {'fonte': 'elemento', 'valore': 'aria'},
    {'fonte': 'ritratto', 'valore': '17'},
  ];

  /// La vista d'insieme, coi giochi aperti.
  static Map<String, Object?> vista({
    bool ritrattoCompilato = true,
    bool provaFatta = false,
    bool conPellegrinaggio = true,
    bool conSfida = true,
    DateTime? adesso,
  }) {
    final ora = adesso ?? DateTime(2026, 10, 22, 18);
    return {
      'ritrattoCompilato': ritrattoCompilato,
      'piano': 'tier1',
      'oggi': {
        'indovinelli': 4,
        'indovinelliAlGiorno': 10,
        'scommesse': 1,
        'scommesseAlGiorno': 3,
      },
      'ritorno': [
        {
          'chiave': 'archetipo:mago',
          'quanti': 2,
          'segni': ['leo'],
          'daScoprire': 1,
        },
        {
          'chiave': 'tratto:51',
          'quanti': 1,
          'segni': const <String>[],
          'daScoprire': 1,
        },
      ],
      'prova': {
        'settimana': '2026-10-19',
        'tema': 1,
        'fatta': provaFatta,
        'punteggio': provaFatta ? 63 : null,
        'figura': provaFatta ? 'Il Ponte' : null,
        'amici': [
          {
            'uid': 'u-stella',
            'nome': 'Stella Lieve',
            'fatta': true,
            'punteggio': 71,
            'scommessa': null,
          },
          {
            'uid': 'u-orione',
            'nome': 'Orione',
            'fatta': false,
            'punteggio': null,
            'scommessa': {'valore': 40, 'vinta': null},
          },
          {
            'uid': 'u-selene',
            'nome': 'Selene',
            'fatta': false,
            'punteggio': null,
            'scommessa': null,
          },
        ],
      },
      'sfide': {
        'aperte': [
          if (conSfida)
            {
              'id': 'sfida-prova-0001',
              'da': 'u-io',
              'a': 'u-selene',
              'scade':
                  ora.add(const Duration(hours: 17)).millisecondsSinceEpoch,
              'tua': true,
              'haiStimato': true,
            },
        ],
        'puoiSfidare': true,
      },
      'pellegrinaggio': conPellegrinaggio
          ? {
              'luna': '2026-10-26',
              'meta': 20,
              'totale': 10,
              'arrivato': false,
              'passi': [
                {'uid': 'u-io', 'nome': 'Lunaria', 'tu': true, 'passi': 4},
                {
                  'uid': 'u-stella',
                  'nome': 'Stella Lieve',
                  'tu': false,
                  'passi': 3
                },
                {'uid': 'u-orione', 'nome': 'Orione', 'tu': false, 'passi': 2},
                {'uid': 'u-selene', 'nome': 'Selene', 'tu': false, 'passi': 1},
                {'uid': 'u-dario', 'nome': 'Dario', 'tu': false, 'passi': 0},
              ],
            }
          : null,
      'classifica': [
        {
          'uid': 'u-stella',
          'nome': 'Stella Lieve',
          'tu': false,
          'indovinati': 9
        },
        {'uid': 'u-io', 'nome': 'Lunaria', 'tu': true, 'indovinati': 6},
        {'uid': 'u-orione', 'nome': 'Orione', 'tu': false, 'indovinati': 2},
      ],
    };
  }
}
