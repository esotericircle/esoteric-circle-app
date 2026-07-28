import '../chat/maestro_memory.dart';
import '../chat/user_profile.dart';
import 'maestro.dart';
import 'natal_context.dart';

/// Compone il benvenuto della conversazione in modo DETERMINISTICO, senza una
/// chiamata a Gemini: nome e vocativo dell'onboarding, un contesto (i dati natali
/// nel Free, la sintesi di memoria distillata nel Premium) e una formula di
/// apertura pescata a rotazione da un pool di dodici varianti, piu' una domanda
/// che spinge all'azione, anch'essa variata.
///
/// La rotazione arriva da un contatore persistito: due aperture vicine non
/// ripetono la stessa formula, perche' indici consecutivi cadono su varianti
/// diverse. Ripiego col solo nome, o neutro, se l'onboarding manca.
class MaestroWelcome {
  const MaestroWelcome._();

  /// Il pool delle aperture, dodici varianti. Il segnaposto `{voc}` porta il
  /// vocativo (per esempio "Cara Sofia" o "Anima del Cerchio").
  static const List<String> openings = [
    '{voc}, il cerchio ti riconosce.',
    '{voc}, sono qui con te, senza fretta.',
    '{voc}, mi fa piacere ritrovarti.',
    '{voc}, prenditi un respiro: cominciamo quando vuoi.',
    '{voc}, la soglia e\' aperta, entra pure.',
    '{voc}, ti ascolto con attenzione.',
    '{voc}, il cerchio ti riaccoglie, comunque tu arrivi.',
    '{voc}, oggi le voci del cielo sono limpide.',
    '{voc}, ogni domanda che porti ha il suo posto qui.',
    '{voc}, resto accanto a te per questo tratto di strada.',
    '{voc}, il momento giusto per parlare e\' sempre adesso.',
    '{voc}, apriamo insieme questo spazio.',
  ];

  /// Le domande che spingono all'azione, variate a rotazione.
  static const List<String> actions = [
    'Da dove vuoi cominciare?',
    'Qual e\' la prima cosa che senti di voler capire?',
    'Cosa ti sta piu\' a cuore oggi?',
    'Su quale nodo vuoi che portiamo luce?',
    'Che passo stai cercando di fare?',
    'Cosa vuoi mettere al centro, adesso?',
  ];

  /// Compone il benvenuto. [rotation] e' il contatore delle aperture; [premium]
  /// sceglie se il contesto viene dalla memoria distillata o dai dati natali.
  static String compose({
    required Maestro maestro,
    required UserProfile profile,
    NatalContext? natal,
    MaestroMemory memory = MaestroMemory.empty,
    required bool premium,
    required int rotation,
  }) {
    final r = rotation.abs();
    final voc = vocative(profile);
    final opening = openings[r % openings.length].replaceAll('{voc}', voc);
    final action = actions[r % actions.length];

    final context = _context(
      maestro: maestro,
      natal: natal,
      memory: memory,
      premium: premium,
    );

    final parts = <String>[
      opening,
      if (context.isNotEmpty) context,
      action,
    ];
    return parts.join(' ');
  }

  /// Il nome con l'iniziale maiuscola, qualunque cosa abbia scritto la persona.
  ///
  /// Chi digita in fretta scrive "mauro", e un Maestro che risponde "Caro
  /// mauro" sembra sciatto: il nome di una persona si scrive con la maiuscola.
  /// Vale su ogni parola, cosi' anche i nomi composti restano a posto, e non si
  /// tocca il resto delle lettere, perche' De Luca non deve diventare De luca.
  static String capitalizza(String nome) {
    if (nome.isEmpty) return nome;
    return nome
        .split(' ')
        .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }

  /// Il vocativo dell'onboarding: "Caro"/"Cara" col nome, altrimenti "Ciao" col
  /// nome; un vocativo neutro di brand quando il nome non c'e'.
  static String vocative(UserProfile profile) {
    if (!profile.hasName) return 'Anima del Cerchio';
    final name = capitalizza(profile.displayName!.trim());
    return profile.courtesyForm.agree(
      masculine: 'Caro $name',
      feminine: 'Cara $name',
      neutral: 'Ciao $name',
    );
  }

  /// Il contesto del benvenuto: nel Premium riprende dalla sintesi di memoria
  /// quando c'e'; altrimenti, o nel Free, si appoggia a un dato natale reale.
  /// Mai un dato inventato: se non c'e' nulla, resta vuoto.
  static String _context({
    required Maestro maestro,
    NatalContext? natal,
    required MaestroMemory memory,
    required bool premium,
  }) {
    if (premium && memory.sessionSummary.trim().isNotEmpty) {
      return 'Riprendo da dove eravamo: ${_stripEnd(memory.sessionSummary.trim())}.';
    }
    if (natal != null && !natal.isEmpty) {
      final sun = natal.sunSign?.trim();
      final life = natal.lifeNumberTitle?.trim();
      if (sun != null && sun.isNotEmpty && life != null && life.isNotEmpty) {
        return 'Il tuo Sole in $sun e il tuo cammino di $life ti accompagnano.';
      }
      if (sun != null && sun.isNotEmpty) {
        return 'Il tuo Sole in $sun ti accompagna.';
      }
      if (life != null && life.isNotEmpty) {
        return 'Il tuo cammino di $life ti accompagna.';
      }
    }
    return '';
  }

  static String _stripEnd(String s) =>
      s.endsWith('.') ? s.substring(0, s.length - 1) : s;
}
