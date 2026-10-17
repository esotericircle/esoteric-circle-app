import '../rituals/animal_catalog.dart';
import 'i_quattro_viaggi.dart';

/// **LE OMBRE CHE RITORNANO: LA LOGICA PURA DEL RICONOSCIMENTO.** Ordine FZ
/// voce 01, 17 ottobre 2026.
///
/// Funzioni pure, senza Diario e senza `SharedPreferences`, apposta: la prova
/// a cento persone (FZ.01) le misura senza montare nessun archivio, solo con
/// liste di nomi. Vivono in un file loro, separato da `AnimaleDiPotere`
/// (`l_animale_di_potere.dart`), per non chiudere un cerchio di importazioni:
/// `AnimaleDiPotere` ha bisogno di `DiarioDeiViaggi` per leggere e migrare
/// l'archivio, e `DiarioDeiViaggi` ha bisogno di queste funzioni pure per
/// calcolare le sue `apparizioni` e le sue impronte. Se stessero nello stesso
/// file, i due file si importerebbero a vicenda.
abstract final class LeOmbreCheRitornano {
  const LeOmbreCheRitornano._();

  /// **FUNZIONE PURA: TROVA IL NOME RICONOSCIUTO IN UNA SEQUENZA DI SCELTE.**
  ///
  /// [scelteInOrdine] sono i nomi delle ombre seguite, dalla prima discesa
  /// alla piu' recente. Torna il nome della prima ombra che arriva a
  /// [IQuattroViaggi.quanteDiscese] volte, o nullo se nessuna ancora ci
  /// arriva.
  static String? trovaIlRiconosciuto(List<String> scelteInOrdine) {
    final conto = <String, int>{};
    for (final s in scelteInOrdine) {
      if (s.isEmpty) continue;
      final n = (conto[s] ?? 0) + 1;
      conto[s] = n;
      if (n >= IQuattroViaggi.quanteDiscese) return s;
    }
    return null;
  }

  /// **L'OMBRA CHE OGGI GUIDA**: quella riconosciuta, o quella piu' seguita
  /// finora (a parita' la piu' recente), o nulla se non si e' mai scesi.
  static String? ombraCheGuida(List<String> scelteInOrdine) {
    final gia = trovaIlRiconosciuto(scelteInOrdine);
    if (gia != null) return gia;
    if (scelteInOrdine.isEmpty) return null;
    final conto = <String, int>{};
    final ultima = <String, int>{};
    for (var i = 0; i < scelteInOrdine.length; i++) {
      final s = scelteInOrdine[i];
      if (s.isEmpty) continue;
      conto.update(s, (n) => n + 1, ifAbsent: () => 1);
      ultima[s] = i;
    }
    if (conto.isEmpty) return null;
    var migliore = conto.keys.first;
    for (final nome in conto.keys) {
      final meglio = conto[nome]! > conto[migliore]! ||
          (conto[nome]! == conto[migliore]! &&
              ultima[nome]! > ultima[migliore]!);
      if (meglio) migliore = nome;
    }
    return migliore;
  }

  /// **LE IMPRONTE DEL CAMMINO** (FZ.03): le volte, in ordine, in cui
  /// [ombraCheGuida] e' stata seguita, fino a [IQuattroViaggi.quanteDiscese].
  /// Quando arrivano a quattro, il cammino e' arrivato all'animale.
  static List<String> improteDelCammino(List<String> scelteInOrdine) {
    final nome = ombraCheGuida(scelteInOrdine);
    if (nome == null) return const [];
    return [
      for (final s in scelteInOrdine)
        if (s == nome) s,
    ].take(IQuattroViaggi.quanteDiscese).toList();
  }

  /// **LE TRE OMBRE DA PROPORRE ALLA PROSSIMA DISCESA** (FZ.01).
  ///
  /// Le ombre gia' seguite tornano sempre (le piu' seguite, a parita' le piu'
  /// recenti); le ombre mai viste, nell'ordine del catalogo, completano il
  /// gruppo fino a tre. Deterministico: a parita' di scelte fatte finora, le
  /// stesse tre ombre, cosi' una prova puo' misurarle senza il caso di mezzo.
  static List<String> treOmbreProposte({
    required List<String> scelteInOrdine,
    List<GuideAnimal> catalogo = AnimalCatalog.animals,
  }) {
    final nomi = [for (final a in catalogo) a.name];
    final conto = <String, int>{};
    final ultima = <String, int>{};
    for (var i = 0; i < scelteInOrdine.length; i++) {
      final s = scelteInOrdine[i];
      if (s.isEmpty || !nomi.contains(s)) continue;
      conto.update(s, (n) => n + 1, ifAbsent: () => 1);
      ultima[s] = i;
    }
    final gia = conto.keys.toList()
      ..sort((a, b) {
        final c = conto[b]!.compareTo(conto[a]!);
        if (c != 0) return c;
        return ultima[b]!.compareTo(ultima[a]!);
      });
    final scelte = <String>[...gia.take(3)];
    if (scelte.length < 3) {
      for (final nome in nomi) {
        if (scelte.length >= 3) break;
        if (!scelte.contains(nome)) scelte.add(nome);
      }
    }
    return scelte;
  }
}
