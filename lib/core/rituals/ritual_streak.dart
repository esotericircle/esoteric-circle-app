import 'package:shared_preferences/shared_preferences.dart';

/// Continuita' di un rito: i giorni consecutivi in cui e' stato compiuto,
/// salvati in locale.
///
/// La persistenza e' best effort, come gli altri store dell'app: se
/// `SharedPreferences` non e' disponibile, per esempio in un test headless senza
/// mock, tutto degrada a zero senza mai sollevare un errore. La meccanica piena
/// di gamification vivra' altrove; qui basta il primo filo di continuita'.
class RitualStreak {
  const RitualStreak({this.id = 'dawn'});

  /// Identificatore del rito, cosi' riti diversi tengono continuita' separate.
  final String id;

  String get _lastKey => 'ritual.$id.lastDay';
  String get _countKey => 'ritual.$id.streak';

  static String _stamp(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// La continuita' corrente, senza modificarla. Zero se sconosciuta o
  /// interrotta: vale solo se l'ultimo giorno compiuto e' oggi o ieri.
  Future<int> current(DateTime now) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getString(_lastKey);
      if (last == null) return 0;
      final today = _stamp(now);
      final yesterday = _stamp(now.subtract(const Duration(days: 1)));
      if (last == today || last == yesterday) {
        return prefs.getInt(_countKey) ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// SE IL RITO E' GIA' STATO COMPIUTO OGGI.
  ///
  /// Legge la stessa chiave che scrive [recordToday], quindi non c'e' un
  /// secondo posto che sappia se il rito di oggi e' stato aperto. Serve
  /// all'avviso del mattino: avvisare di fare una cosa gia' fatta e' rumore.
  ///
  /// Falso anche quando la memoria non e' disponibile: nel dubbio si avvisa,
  /// perche' un avviso di troppo e' meno grave di un rito dimenticato.
  Future<bool> fattoOggi(DateTime now) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastKey) == _stamp(now);
    } catch (errore) {
      // L'errore si IGNORA, e si dichiara perche'. L'unica cosa che puo'
      // fallire qui e' l'apertura della memoria locale, e l'unico effetto e'
      // che non sappiamo se il rito e' gia' stato compiuto. Rispondere falso
      // significa avvisare comunque: un avviso di troppo e' meno grave di un
      // rito dimenticato, e non c'e' niente da mostrare alla persona.
      assert(() {
        // ignore: avoid_print
        print('RitualStreak.fattoOggi: memoria non leggibile ($errore)');
        return true;
      }());
      return false;
    }
  }

  /// Registra il rito compiuto oggi e ritorna la nuova continuita'. Ripetere nel
  /// medesimo giorno non la aumenta; un giorno saltato la riparte da uno.
  Future<int> recordToday(DateTime now) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getString(_lastKey);
      final count = prefs.getInt(_countKey) ?? 0;
      final today = _stamp(now);
      final yesterday = _stamp(now.subtract(const Duration(days: 1)));

      final int next;
      if (last == today) {
        next = count < 1 ? 1 : count;
      } else if (last == yesterday) {
        next = count + 1;
      } else {
        next = 1;
      }

      await prefs.setString(_lastKey, today);
      await prefs.setInt(_countKey, next);
      return next;
    } catch (_) {
      return 0;
    }
  }
}
