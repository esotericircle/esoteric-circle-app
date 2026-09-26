import '../lang/euphonic.dart';
import '../chat/maestro_memory.dart';
import '../chat/user_profile.dart';
import 'maestro.dart';
import 'natal_context.dart';
import 'voce_del_maestro.dart';

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

  /// **LE DUE LISTE CONDIVISE SONO USCITE. Ordine EB voce 08, 21 settembre
  /// 2026.** Qui vivevano dodici aperture e sei domande **uguali per tutti e
  /// tre i Maestri**, e questa funzione prendeva il Maestro fra i suoi
  /// parametri senza usarlo per loro. Adesso stanno in `VoceDelMaestro`,
  /// `saluti` e `inviti`, accanto al resto della persona di ciascuno.
  ///
  /// **Il pool composto non si e\' accorciato**: sei saluti e quattro inviti
  /// danno dodici benvenuti diversi prima di ripetersi, esattamente come le
  /// dodici aperture e le sei domande di prima.

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
    // **IL SALUTO E' DI CHI SALUTA. Ordine EB voce 08, 21 settembre 2026.**
    //
    // Questa funzione prendeva il Maestro fra i suoi parametri e lo usava
    // solo per il contesto: l'apertura e la domanda erano le stesse per tutti
    // e tre, ed e' la prima cosa che una persona legge aprendo una chat.
    // **Ed era peggio che uguale**: quelle frasi condivise contenevano le
    // parole di firma di tutti e tre, quindi ognuno diceva *soglia*,
    // *respiro* e *cielo*. Adesso saluti e inviti vivono nella voce di
    // ciascuno, accanto al resto della sua persona.
    final voce = VoceDelMaestro.di(maestro);
    final r = rotation.abs();
    final voc = vocative(profile);
    final opening =
        voce.saluti[r % voce.saluti.length].replaceAll('{voc}', voc);
    final action = voce.inviti[r % voce.inviti.length];

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
    // **UNA MARCA**, ordine DL voce 06, risolta prima di attaccare il nome.
    return '${profile.courtesyForm.risolvi('[Caro|Cara|Ciao]')} $name';
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
      // LA PREPOSIZIONE SI FONDE COL SUO ARTICOLO.
      //
      // I titoli del numero della vita arrivano gia' articolati, "il Creativo",
      // "l'Iniziatore": incollandoci davanti "di" veniva fuori "il tuo cammino
      // di il Creativo ti accompagna". La fusione vive in `euphonic`, insieme
      // alla "d" eufonica e alla preposizione dei piani, e vale per tutte e
      // sette le preposizioni che si articolano in italiano.
      final delCammino =
          life == null ? null : preposizioneArticolata('di', life);
      if (sun != null &&
          sun.isNotEmpty &&
          delCammino != null &&
          life!.isNotEmpty) {
        return 'Il tuo Sole in $sun e il tuo cammino $delCammino ti accompagnano.';
      }
      if (sun != null && sun.isNotEmpty) {
        return 'Il tuo Sole in $sun ti accompagna.';
      }
      if (delCammino != null && life!.isNotEmpty) {
        return 'Il tuo cammino $delCammino ti accompagna.';
      }
    }
    return '';
  }

  static String _stripEnd(String s) =>
      s.endsWith('.') ? s.substring(0, s.length - 1) : s;
}
