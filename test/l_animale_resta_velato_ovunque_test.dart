import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **CHI MOSTRA L'ANIMALE SA CHE PUO' NON POTERLO MOSTRARE.**
/// Ordine DG voce 02, 12 settembre 2026.
///
/// **Parole del fondatore, 11 settembre 2026:** *"nel Passport mi fa gia'
/// vedere il lupo. il mio animale"*, e prima ancora *"all'onboarding mi dice
/// che l'animale non puo' essere svelato, ma mi fa vedere la figura
/// chiaramente"*.
///
/// **IL DIFETTO NON ERA UNA SCHERMATA, ERA UNA REGOLA SENZA CASA.** Il
/// Passaporto sapeva che il nome si dice dopo quattro discese e lo sapeva da
/// solo, dentro il suo `build`. La carta natale non lo sapeva e scriveva
/// *Lupo* a lettere intere. Il simbolo dell'attesa di Caligo non lo sapeva e
/// mostrava il totem. Cinque copie di una regola, e una sola applicata.
///
/// **COSA MISURA QUESTA GUARDIA.** Scorre `lib`, trova **ogni file che deriva
/// l'animale dal segno** con `GuideAnimalDerivation.forSign`, e pretende che
/// ognuno **sappia della soglia**: o chiede a `IlNomeSiPuoDire`, o chiede a
/// `IQuattroViaggi.nomeDopoLeQuattroDiscese`, che e' la stessa regola letta
/// dal suo fornitore.
///
/// **PERCHE' PROPRIO `forSign` E NON IL NOME A SCHERMO.** Perche' e' **l'unica
/// porta** da cui l'animale di questa persona puo' uscire: l'ordine DG voce 01
/// ha chiuso la seconda, e una guardia ci gira sopra. Chi non passa di li' non
/// ha niente da nascondere; chi ci passa ha in mano il segreto, e deve sapere
/// quando tacerlo.
///
/// **LE DUE ESENZIONI, DICHIARATE PER NOME E PER RAGIONE.** Non sono una
/// scappatoia: sono i due file dove la regola **nasce**, e pretendere che
/// chiedano a se stessi sarebbe una circolarita', non una difesa.
///
/// **VISTA ROSSA** togliendo la domanda dalla tessera della carta natale: la
/// prova ha nominato `birth_companions.dart` e ha detto quale riga deriva
/// l'animale.
void main() {
  /// I due file in cui la regola nasce, e che quindi non la chiedono a
  /// nessuno.
  const dovLaRegolaNasce = {
    'lib/core/viaggio/i_quattro_viaggi.dart',
    'lib/core/viaggio/il_nome_si_puo_dire.dart',
  };

  /// **DOVE L'ANIMALE E' VELATO PER COSTRUZIONE, e quindi non chiede niente
  /// a nessuno.**
  ///
  /// Il Risveglio monta `TrionfoAnimale`, che e' **la scheda che promette la
  /// rivelazione**: mostra l'ombra e la nebbia, dice che il nome arrivera'
  /// scendendo, e **non ha nessun ramo in cui riveli**. Chiedergli se oggi si
  /// puo' dire il nome sarebbe una domanda a cui non saprebbe cosa fare della
  /// risposta.
  ///
  /// **L'esenzione e' per nome e per ragione, e la ragione e' verificabile:**
  /// la prova qui sotto controlla che quella scheda **non scriva mai** il nome
  /// dell'animale. Il giorno che lo scrivesse, l'esenzione cade da sola.
  const dovESempreVelato = {
    'lib/features/onboarding/risveglio_journey.dart',
  };

  /// **QUANTI POSTI DERIVANO L'ANIMALE, contati il 12 settembre 2026.**
  ///
  /// Sono sette: il Passaporto, la carta natale, la lettura dell'animale, il
  /// bosco, il simbolo dell'attesa di Caligo, il Risveglio, il Viaggio, la
  /// Home. Il minimo dichiarato e' **cinque**, con un margine di tre: se
  /// domani ne restassero meno, questa guardia sarebbe verde per essersi
  /// svuotata, non perche' il segreto e' custodito.
  const quantiLoDerivano = 5;

  /// La domanda che rende legittimo avere in mano l'animale.
  const sannoDellaSoglia = [
    'IlNomeSiPuoDire',
    'nomeDopoLeQuattroDiscese',
  ];

  test('chi deriva l\'animale dal segno sa che puo\' doverlo tacere', () {
    final colpevoli = <String, String>{};
    var quanti = 0;

    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(Platform.pathSeparator, '/');
      final da = percorso.contains('lib/') ? percorso.indexOf('lib/') : 0;
      final normalizzato = percorso.substring(da);
      final codice = senzaCommenti(f.readAsStringSync());
      if (!codice.contains('GuideAnimalDerivation.forSign')) continue;
      quanti++;
      if (dovLaRegolaNasce.contains(normalizzato)) continue;
      if (dovESempreVelato.contains(normalizzato)) continue;
      if (sannoDellaSoglia.any(codice.contains)) continue;
      // La riga che lo deriva, per chi legge la caduta.
      final riga = codice
          .split('\n')
          .firstWhere((r) => r.contains('GuideAnimalDerivation.forSign'))
          .trim();
      colpevoli[normalizzato] = riga;
    }

    cardinaleMinimo(
      quanti,
      quantiLoDerivano,
      cosa: 'file che derivano l\'animale guida dal segno',
      perche: 'Se nessuno lo deriva piu\', o la porta unica dell\'ordine DG '
          'voce 01 e\' stata spostata, e questa guardia sta sorvegliando un '
          'passaggio che non esiste piu\'.',
    );

    expect(
      colpevoli,
      isEmpty,
      reason: 'QUESTI FILE HANNO IN MANO L\'ANIMALE DI QUESTA PERSONA E NON '
          'SANNO CHE PUO\' ESSERE ANCORA SEGRETO.\n'
          '${colpevoli.entries.map((e) => '  ${e.key}\n    ${e.value}').join('\n')}\n\n'
          'L\'animale guida si dice dopo quattro discese nel Mondo di Sotto, '
          'e prima di allora se ne mostra la sola ombra. Chi lo deriva da '
          '`GuideAnimalDerivation.forSign` ha in mano il finale della storia: '
          'deve chiedere a `IlNomeSiPuoDire` se oggi si puo\' raccontare.\n'
          'Il fondatore lo ha visto due volte, l\'11 settembre 2026: una nel '
          'Passaporto e una nella carta natale, a due schermate di distanza '
          'dalla scheda che gli prometteva di non svelarlo.',
    );
  });

  /// **L'ESENZIONE SI PAGA.** Il trionfo dell'animale e' esente dalla domanda
  /// **perche' non rivela mai**: qui si verifica che sia ancora vero.
  ///
  /// **VISTA ROSSA** scrivendo `Text(widget.animale.name)` dentro il trionfo:
  /// la prova ha nominato il file e la riga.
  test('il trionfo dell\'animale non scrive mai il suo nome', () {
    final f = File('lib/features/onboarding/trionfi_screen.dart');
    expect(f.existsSync(), isTrue,
        reason: 'IL TRIONFO DELL\'ANIMALE E\' STATO SPOSTATO, e con lui '
            'l\'esenzione che questa guardia concede al Risveglio.');
    final codice = senzaCommenti(f.readAsStringSync());
    final righe = codice.split('\n');
    final accusate = [
      for (var i = 0; i < righe.length; i++)
        if (righe[i].contains('animale.name') ||
            righe[i].contains('animal.name'))
          '  riga ${i + 1}: ${righe[i].trim()}',
    ];
    expect(
      accusate,
      isEmpty,
      reason: 'IL TRIONFO DELL\'ANIMALE SCRIVE IL NOME DELL\'ANIMALE.\n'
          '${accusate.join('\n')}\n\n'
          'Quella scheda e\' esente dalla domanda di `IlNomeSiPuoDire` '
          'proprio perche\' non rivela mai: mostra l\'ombra e promette che '
          'il nome arrivera\' scendendo. Se adesso lo scrive, l\'esenzione '
          'non vale piu\', e o si toglie il nome o si aggiunge la domanda.',
    );
  });
}
