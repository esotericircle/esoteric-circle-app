import '../maestro/maestro.dart';
import '../maestro/voce_del_maestro.dart';
import 'chat_message.dart';

/// **CIO' CHE LA PERSONA HA DETTO AGLI ALTRI DUE MAESTRI.** Ordine EN voce
/// 09, 25 settembre 2026.
///
/// Il fondatore: *"Inoltre siamo sicuri che i maestri sia live che non,
/// accedano alle memorie dell'utente."*
///
/// **Con lo stesso Maestro si', con un altro no, ed e' il fatto 3 del
/// manifesto EN.** La memoria calda e la cronologia stanno sotto il Maestro
/// (`users/{uid}/maestri/{maestro}`), e la chat carica soltanto quelle del
/// proprio: un fatto detto a Medora non arrivava ad Aura mai, nemmeno dopo
/// la sfocatura settimanale, che scrive una sintesi per Maestro. Eppure
/// l'istruzione di sistema diceva al modello *"La memoria è una sola,
/// condivisa fra i tre Maestri"*.
///
/// **Si porta la voce della persona, non quella degli altri Maestri.** Le
/// risposte di Medora dentro il contesto di Calìgo gli insegnerebbero parole
/// che non sono sue, cioe' il difetto che il divieto incrociato dei lessici
/// esiste per impedire. Le frasi della persona sono i fatti: il nome della
/// moglie, il lavoro, la paura.
///
/// **Dentro la finestra di [giorni]**, gli stessi quattordici giorni in cui
/// la sfocatura lascia intere le conversazioni: oltre, i fatti li porta la
/// sintesi.
abstract final class IRicordiDegliAltri {
  /// Quanti giorni indietro si guarda.
  static const int giorni = 14;

  /// Quante frasi per Maestro, le piu' recenti.
  ///
  /// **Dodici, e sei non bastavano: misurato sul Realme.** Nel LIVE di Aura
  /// la persona ha detto *"Il mio cane si chiama Argo"* come seconda frase di
  /// otto, poi ha fatto sei domande e una in chat; chiesto a Medora, il nome
  /// non c'era: le ultime sei frasi erano tutte domande venute dopo. Dodici
  /// righe sono circa quattrocento token in ingresso per ciascuno degli altri
  /// due Maestri, un centesimo di centesimo per turno.
  static const int perMaestro = 12;

  /// Quanti messaggi si leggono per ciascuno degli altri due, domande e
  /// risposte insieme: il doppio delle frasi che servono.
  static const int messaggiDaLeggere = 40;

  /// Quanto e' lunga al massimo una frase riportata.
  static const int lunghezzaMassima = 220;

  /// L'intestazione di ogni riga, per chi deve riconoscerla nel contesto.
  static String intestazione(Maestro altro) {
    final nome = VoceDelMaestro.nomeDetto(altro);
    final a = RegExp(r'^[AEIOU]').hasMatch(nome) ? 'ad' : 'a';
    return 'Detto $a $nome';
  }

  /// Le righe da aggiungere ai fatti, dai messaggi salvati sotto [altro].
  static List<String> righe(
    Maestro altro,
    List<ChatMessage> messaggi, {
    required DateTime adesso,
  }) {
    final limite = adesso.subtract(const Duration(days: giorni));
    final dette = [
      for (final m in messaggi)
        if (m.isUser &&
            m.text.trim().isNotEmpty &&
            (m.at == null || m.at!.isAfter(limite)))
          m
    ];
    final ultime = dette.length > perMaestro
        ? dette.sublist(dette.length - perMaestro)
        : dette;
    return [
      for (final m in ultime)
        '${intestazione(altro)}${_quando(m.at)}: '
            '"${_taglia(m.text.trim().replaceAll(RegExp(r'\s+'), ' '))}"',
    ];
  }

  static String _quando(DateTime? at) =>
      at == null ? '' : ' il ${at.day}/${at.month}';

  static String _taglia(String t) => t.length <= lunghezzaMassima
      ? t
      : '${t.substring(0, lunghezzaMassima).trimRight()}...';
}
