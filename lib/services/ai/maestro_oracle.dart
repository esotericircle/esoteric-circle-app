import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_reply.dart';

/// La lettura di un singolo Maestro su un tema, nella sua lente di dominio.
///
/// Lega un Maestro ai tre strati testuali della sua risposta ([MaestroReply]):
/// il livello visivo lo dà la UI, qui vivono il colpo d'occhio, il testo narrato
/// e l'invito. I tre strati sono lo stesso modello che produce anche Gemini,
/// cosi' la card della schermata mostra allo stesso modo la risposta viva e
/// quella di ripiego.
class MaestroLens {
  const MaestroLens({required this.maestro, required this.reply});

  /// Costruisce la lente dai tre strati direttamente, comodo per l'oracolo.
  MaestroLens.strati({
    required this.maestro,
    required String glance,
    required String reading,
    required String invite,
  }) : reply = MaestroReply(glance: glance, reading: reading, invite: invite);

  final Maestro maestro;
  final MaestroReply reply;

  /// Sintesi in una riga, il colpo d'occhio.
  String get glance => reply.glance;

  /// Testo narrato nel tono del Maestro, poche righe.
  String get reading => reply.reading;

  /// Invito o domanda sola per il passo successivo.
  String get invite => reply.invite;
}

/// L'esito di "Chiedi ai Maestri": una lente per Maestro interpellato e, quando
/// sono piu' di uno, una sintesi comparativa in testa.
class MaestriConsultation {
  const MaestriConsultation({
    required this.theme,
    required this.lenses,
    this.synthesis,
  });

  final String theme;
  final List<MaestroLens> lenses;

  /// Sintesi comparativa delle lenti sullo stesso tema. Presente solo quando i
  /// Maestri interpellati sono piu' di uno.
  final String? synthesis;

  bool get isComparative => lenses.length > 1;
}

/// Oracolo locale in ripiego per "Chiedi ai Maestri".
///
/// Regola d'oro dello stack: la chiamata vera a Gemini su Vertex resta al
/// device, dietro `MaestroAiProvider`. Qui, in ripiego e senza rete, si compone
/// una risposta a scheletro deterministica per ciascun Maestro, ancorata al suo
/// dominio (Personas) e al tema chiesto, piu' la sintesi comparativa quando le
/// lenti sono piu' d'una. Nessun dato inventato sull'utente: si parla del tema,
/// con la voce del dominio.
class MaestroOracle {
  const MaestroOracle();

  /// Interpella i [maestri] scelti sul [theme]. L'ordine delle lenti segue
  /// l'ordine fisso del cerchio, cosi' la vista comparativa e' sempre coerente.
  MaestriConsultation consult({
    required String theme,
    required List<Maestro> maestri,
  }) {
    final t = theme.trim();
    final chosen = [
      for (final m in Maestro.fixedOrder)
        if (maestri.contains(m)) m,
    ];
    final lenses = [for (final m in chosen) _lensFor(m, t)];
    return MaestriConsultation(
      theme: t,
      lenses: lenses,
      synthesis: lenses.length > 1 ? _synthesis(t, chosen) : null,
    );
  }

  MaestroLens _lensFor(Maestro maestro, String theme) {
    final q = _quote(theme);
    final v = _seed(theme) % 3; // variante stabile dal tema
    switch (maestro) {
      case Maestro.medora:
        return MaestroLens.strati(
          maestro: maestro,
          glance: '${const [
            'Sul tema di',
            'Le carte per',
            'Nel cielo di',
          ][v]} $q leggo un transito, non una sentenza.',
          reading:
              'Da astrologa guardo tempi e tendenze: quando spingere e quando '
              'attendere. Le posizioni invitano, non obbligano: la tua carta '
              'colora la sfumatura, mai la sostanza.',
          invite: const [
            'Qual è la prima piccola mossa che senti giusta ora?',
            'Vuoi che guardi il tempo più propizio per muoverti?',
            'Cosa cambierebbe se lo leggessi come una stagione, non un verdetto?',
          ][v],
        );
      case Maestro.aura:
        return MaestroLens.strati(
          maestro: maestro,
          glance: '${const [
            'Prima di pensare a',
            'Porto al respiro',
            'Faccio spazio a',
          ][v]} $q: il corpo sa già qualcosa.',
          reading:
              'Nel corpo sottile questo tema tocca un centro: se stringe la gola '
              'o il petto, chiede ascolto, non battaglia. Accolgo l\'emozione con '
              'te, senza gonfiarla: la lascio respirare.',
          invite: const [
            'Fai un respiro lento, una mano sul cuore: cosa si scioglie?',
            'Dove lo senti nel corpo, questo tema, proprio adesso?',
            'Ti va una pausa di tre respiri prima di decidere?',
          ][v],
        );
      case Maestro.caligo:
        return MaestroLens.strati(
          maestro: maestro,
          glance: '${const [
            'Getto una runa su',
            'Accendo una soglia su',
            'Chiedo al simbolo di',
          ][v]} $q: un presagio da leggere, non un ordine.',
          reading:
              'Da custode leggo il profondo: questo è un passaggio di crescita, '
              'protezione o abbondanza, mai potere sugli altri. La runa indica '
              'la direzione, non forza la mano.',
          invite: const [
            'Quale gesto semplice segnerebbe il tuo passo, stasera?',
            'Cosa vuoi lasciare sulla soglia e cosa portare oltre?',
            'Se dovessi scegliere una sola parola da incidere, quale sarebbe?',
          ][v],
        );
    }
  }

  // La sintesi comparativa: lo stesso tema sotto le lenti scelte, con l'invito
  // a fidarsi di piu' dove le voci concordano.
  String _synthesis(String theme, List<Maestro> chosen) {
    final lenses = _joinE([for (final m in chosen) _lensLabel(m)]);
    return 'Stessa domanda, ${_quote(theme)}, sotto sguardi diversi: $lenses. '
        'Dove le voci concordano, ascolta con più fiducia; dove divergono, '
        'hai più strade tra cui scegliere.';
  }

  String _lensLabel(Maestro maestro) {
    switch (maestro) {
      case Maestro.medora:
        return 'Medora guarda i tempi e le tendenze del cielo';
      case Maestro.aura:
        return 'Aura ascolta il respiro e il sentire del corpo';
      case Maestro.caligo:
        return 'Caligo legge il simbolo che indica la via';
    }
  }

  /// Unisce con le virgole e una "e" prima dell'ultimo, senza virgola davanti
  /// alla congiunzione, come vuole la regola di lingua.
  static String _joinE(List<String> items) {
    if (items.length == 1) return items.first;
    final head = items.sublist(0, items.length - 1).join(', ');
    return '$head e ${items.last}';
  }

  /// Racchiude il tema tra virgolette basse, o una dicitura neutra se vuoto.
  static String _quote(String theme) =>
      theme.isEmpty ? 'questo tema' : '«$theme»';

  /// Seme deterministico dal tema, stabile fra piattaforme (somma dei code
  /// unit): sceglie la variante senza affidarsi a hashCode.
  static int _seed(String s) {
    var sum = 0;
    for (final c in s.codeUnits) {
      sum = (sum + c) % 100000;
    }
    return sum;
  }
}
