import 'maestro.dart';
import 'voce_del_maestro.dart';

/// Le venti domande NEUTRE con cui si misura se i tre Maestri sono davvero tre.
///
/// Neutre vuol dire che nessuno dei tre puo' rivendicarle per dominio: non
/// nominano il cielo, il respiro ne' le rune, quindi la differenza fra le tre
/// risposte non puo' venire dall'argomento. Se le voci si distinguono su
/// queste, si distinguono davvero; se si distinguessero solo su "che dice la
/// mia carta natale", staremmo misurando il tema e non la voce.
///
/// Vivono qui e non dentro lo strumento in `tool/` per una ragione precisa: una
/// prova della suite le setaccia a ogni giro e cade se una si corrompe. Un
/// corpus che nessuno sorveglia si sporca da solo, una domanda alla volta, e
/// il giorno che serve non misura piu' niente.
class CorpusNeutro {
  const CorpusNeutro._();

  /// Le venti domande. Sono il genere di cosa che una persona scrive davvero
  /// alle due di notte, non esempi da manuale.
  static const List<String> domande = [
    'ho paura di sbagliare',
    'oggi mi sento fermo',
    'cosa mi manca',
    'non so se restare',
    'mi sento invisibile',
    'ho perso la direzione',
    'sono stanco di aspettare',
    'non mi fido di me',
    'perché rimando sempre tutto',
    'mi sembra di essere in ritardo su tutto',
    'non riesco a dire di no',
    'vorrei ricominciare ma non so da dove',
    'mi sento distante da chi amo',
    'non so cosa voglio davvero',
    'temo di deludere chi mi vuole bene',
    'mi manca il coraggio',
    'mi sento diviso in due',
    'non riesco a lasciare andare',
    'come faccio a fidarmi di nuovo',
    'ho la testa piena e le mani vuote',
  ];

  /// Le parole che rendono una domanda NON neutra.
  ///
  /// Si RICAVANO dalle tre voci invece di essere scritte a mano: le nove arti
  /// piu' i lessici di firma. Cosi' se domani un Maestro cambia una parola di
  /// firma, il corpus viene risetacciato contro la parola nuova senza che
  /// nessuno debba ricordarsene.
  static Set<String> get paroleDiDominio => {
        for (final maestro in Maestro.values) ...[
          for (final arte in VoceDelMaestro.artiDi(maestro)) arte.toLowerCase(),
          for (final parola in VoceDelMaestro.di(maestro).lessicoDiFirma)
            parola.toLowerCase(),
        ],
      };

  /// La parola di dominio che [domanda] contiene, se ce n'e' una.
  ///
  /// Confronta parole intere: "mi sento" contiene "sent" ma non la parola
  /// "sentire", e una ricerca per sottostringa boccerebbe mezzo corpus per
  /// nulla.
  static String? paroleDiDominioIn(String domanda) {
    final parole = domanda
        .toLowerCase()
        .split(RegExp(r'[^a-zàèéìòùç]+'))
        .where((p) => p.isNotEmpty)
        .toSet();
    for (final dominio in paroleDiDominio) {
      if (parole.contains(dominio)) return dominio;
    }
    return null;
  }
}
