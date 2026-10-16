/// **IL FILO CON CUI OGNI ARTE SCEGLIE LE SUE FORME, e ne esiste uno solo.**
/// Ordine DF voce 02, 11 settembre 2026.
///
/// **CHE COSA RISOLVE.** Il fondatore: *"voglio la sicurezza che su 100 domande
/// uguali, nemmeno una sia uguale o simile"*. Prima di quest'ordine ogni arte
/// componeva il suo testo con **uno stampo fisso**: cento consultazioni davano
/// cento volte la stessa frase con dentro nomi diversi, e la persona lo
/// riconosce alla seconda.
///
/// **IL FILO NASCE DA CIO' CHE E' APPENA USCITO**, e questa e' la scelta che
/// decide tutto: dalle tre carte e dai loro versi, dalle rune cadute, dai pezzi
/// della scena. **Mai dall'orologio, mai dall'utente, mai da un contatore.**
/// Due conseguenze, tutte e due volute:
///
/// **Uno, cento estrazioni diverse danno cento forme diverse**, e siccome
/// l'estrazione e' casuale davvero, due consultazioni consecutive non hanno
/// nessuna ragione di somigliarsi.
///
/// **Due, resta deterministico.** Le stesse carte, le stesse rune, la stessa
/// discesa danno sempre lo stesso testo: i testi restano cacheabili, il Diario
/// puo' rimettere insieme una scena vecchia dai suoi id, e le prove restano
/// ripetibili. **La casualita' sta nell'estrazione, dove deve stare, e non nel
/// testo.**
///
/// **IL MESCOLATORE E' UN VERO MESCOLATORE, e la prima stesura non lo era.**
/// Sceglieva con `(seme ~/ passo) % lunghezza`, e coi passi grandi il quoziente
/// aveva pochissimi valori distinti: la misura C dell'ordine e' salita a
/// **88,1 per cento** perche' due estrazioni diverse cadevano sulle stesse
/// quattro forme su cinque. Adesso il seme si rimescola a ogni pescata con due
/// giri di moltiplicazione e scorrimento, che e' il mestiere di un hash e non
/// di una divisione.
class FiloDellaVoce {
  FiloDellaVoce(this.seme);

  /// **UN FILO DA UNA MANCIATA DI COSE USCITE.** Il modo normale di
  /// costruirlo: si passano i nomi, gli id, i versi, e l'ordine conta.
  factory FiloDellaVoce.da(Iterable<Object?> cose) {
    var h = 2166136261;
    for (final c in cose) {
      final testo = '$c';
      for (var i = 0; i < testo.length; i++) {
        h = (h ^ testo.codeUnitAt(i)) * 16777619 & 0x7FFFFFFF;
      }
      h = (h ^ 0x5F5F) * 16777619 & 0x7FFFFFFF;
    }
    return FiloDellaVoce(h);
  }

  final int seme;

  /// Quante volte si e' gia' pescato: ogni fessura rimescola il filo con un
  /// numero suo, altrimenti due elenchi della stessa lunghezza uscirebbero
  /// sempre allineati e le forme si muoverebbero in blocco.
  int _quante = 0;

  /// Una voce dall'elenco, scelta dal filo.
  T scegli<T>(List<T> elenco) {
    if (elenco.isEmpty) throw StateError('elenco vuoto');
    _quante++;
    var x = (seme ^ (_quante * 0x9E3779B1)) & 0x7FFFFFFF;
    x = ((x ^ (x >> 15)) * 0x2C1B3C6D) & 0x7FFFFFFF;
    x = ((x ^ (x >> 13)) * 0x297A2D39) & 0x7FFFFFFF;
    x = (x ^ (x >> 16)) & 0x7FFFFFFF;
    return elenco[x % elenco.length];
  }

  /// Un filo nuovo che parte da questo piu' uno scarto: serve a chi deve
  /// scegliere forme per piu' oggetti dello stesso genere, per esempio le tre
  /// posizioni di una stesa, senza che escano tutte uguali.
  FiloDellaVoce piu(int scarto) =>
      FiloDellaVoce((seme + scarto * 2654435761) & 0x7FFFFFFF);
}
