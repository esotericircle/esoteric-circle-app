import 'dart:io';

/// **IL LETTORE DEI MANIFESTI, CHE CONOSCE TUTTI I LORO FORMATI.** Ordine DS
/// voce 01, 17 settembre 2026.
///
/// **Perche' esiste.** Il sigillo dell'ordine CQ contava le voci in una forma
/// sola, `- **XX.NN**`, e guardava sei manifesti scritti a mano. I manifesti
/// dopo CQ usano anche le intestazioni, `## XX.NN`, e quel sigillo avrebbe
/// contato zero voci. **Un manifesto chiuso non si riscrive per farsi leggere:
/// si impara il suo formato.**
///
/// **Cosa conta come voce.** Solo un numero in una **posizione che dichiara**:
///
/// 1. all'inizio di una riga d'elenco, `- **XX.NN**` (anche `*` o `1.`);
/// 2. in un'intestazione, `## XX.NN`, **con tutti i numeri della riga**, perche'
///    `## DI.11, DI.12, DI.13 e DI.14` sono quattro voci;
/// 3. nella prima cella di una tabella, `| **XX.NN** |`;
/// 4. in testa a un paragrafo in grassetto, `**XX.NN, titolo`.
///
/// **Una menzione nella prosa non e' una voce**: *"la voce DD.04 aveva torto"*
/// cita una voce, non la dichiara. Contarla sarebbe l'errore contro cui l'ordine
/// mette in guardia, contare i commenti insieme al codice.
///
/// **E LA VOCE ZERO E' UNA VOCE.** `AT.00`, `U.00` e `DL.00` sono contate nel
/// totale dei loro manifesti, e `DN.00` e' scritta nella stessa forma. La
/// prima stesura di questo lettore la escludeva perche' il suo titolo sembrava
/// una regola: era leggere il contenuto per far tornare un conto, cioe' proprio
/// cio' che un lettore di formati non deve fare. Tolta l'esclusione, il
/// manifesto DN nomina undici voci e ne dichiara dieci, e si riporta.
class ManifestoLetto {
  ManifestoLetto({
    required this.file,
    required this.sigla,
    required this.voci,
    required this.marcatori,
  });

  final String file;
  final String sigla;

  /// I numeri delle voci dichiarate, senza la sigla: `01`, `1.04`.
  final Set<String> voci;

  /// I marcatori a macchina, `VOCI_TOTALI` compreso.
  final Map<String, int> marcatori;

  int? get totali => marcatori['VOCI_TOTALI'];

  /// I marcatori che dicono uno STATO. Gli attributi, come
  /// `VOCI_SENZA_GUARDIA_PROPRIA`, contano voci che hanno gia' uno stato.
  Map<String, int> get stati => {
        for (final m in marcatori.entries)
          if (m.key != 'VOCI_TOTALI' && !attributi.contains(m.key))
            m.key: m.value,
      };

  static const attributi = {'VOCI_SENZA_GUARDIA_PROPRIA'};
}

/// La sigla dell'ordine dal nome del file: `ORDINE_CODEMAGIC1_MANIFESTO.md`
/// da' `CODEMAGIC1`.
String siglaDi(String nomeDelFile) {
  final m = RegExp(r'^ORDINE_([A-Z0-9]+)_').firstMatch(nomeDelFile);
  return m == null ? nomeDelFile : m.group(1)!;
}

/// Legge le voci e i marcatori di un testo di manifesto.
ManifestoLetto leggiManifesto(String nomeDelFile, String testo) {
  final sigla = siglaDi(nomeDelFile);
  final s = RegExp.escape(sigla);
  final numero = RegExp('\\b$s\\.(\\d+(?:\\.\\d+)?)\\b');
  Iterable<String> numeriIn(String riga) =>
      numero.allMatches(riga).map((m) => m.group(1)!);

  final voci = <String>{};
  for (final grezza in testo.split('\n')) {
    final r = grezza.trimRight();
    if (RegExp('^\\s*(?:[-*]|\\d+\\.)\\s+\\*\\*$s\\.\\d').hasMatch(r)) {
      voci.addAll(numeriIn(r.split('**')[1]));
    } else if (RegExp('^#{1,6}\\s+.*\\b$s\\.\\d').hasMatch(r)) {
      // Tutti i numeri dell'intestazione, fino alla prima parola che non e'
      // un elenco di voci.
      final testa = r.split(RegExp(r'[,.]\s+[A-Z]{3,}')).first;
      voci.addAll(numeriIn(testa));
    } else if (RegExp('^\\|\\s*\\*\\*$s\\.\\d').hasMatch(r)) {
      voci.addAll(numeriIn(r.split('|')[1]));
    } else if (RegExp('^\\*\\*$s\\.\\d').hasMatch(r)) {
      voci.addAll(numeriIn(r.split(',').first));
    }
  }

  final marcatori = <String, int>{
    for (final m in RegExp(r'^(VOCI_[A-Z_]+):\s*(\d+)', multiLine: true)
        .allMatches(testo))
      m.group(1)!: int.parse(m.group(2)!),
  };
  return ManifestoLetto(
      file: nomeDelFile, sigla: sigla, voci: voci, marcatori: marcatori);
}

/// **I MANIFESTI DEL REPOSITORY, scoperti a esecuzione.** Un manifesto e' un
/// file `ORDINE_*_MANIFESTO.md` in `docs/ordini`. Nessun elenco scritto a mano:
/// e' esattamente l'elenco scritto a mano che ha lasciato fuori dal sigillo
/// ogni ordine dopo CQ.
List<File> manifestiDelRepository() {
  final cartella = Directory('docs/ordini');
  return cartella
      .listSync()
      .whereType<File>()
      .where((f) => RegExp(r'ORDINE_[A-Z0-9]+_MANIFESTO\.md$')
          .hasMatch(f.path.replaceAll(r'\', '/')))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

String nomeDi(File f) => f.path.replaceAll(r'\', '/').split('/').last;
