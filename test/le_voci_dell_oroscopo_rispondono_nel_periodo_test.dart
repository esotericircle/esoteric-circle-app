// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **LE VOCI DELL'OROSCOPO RISPONDONO, NEL LORO PERIODO E NEL LORO DOMINIO.**
/// Ordine GA voce GA.06, 21 ottobre 2026.
///
/// Il fondatore, 19 ottobre 2026: *"risposte dirette immediatamente [...]
/// senza fronzoli o criptiche o includenti o sibilline [...] E ogni risposta
/// deve essere coerente con i simboli o carte o segni altro da interpretare e
/// coerente con la domanda posta dall'utente."*; 21 ottobre: *"mi raccomando
/// le risposte dei responsi che devono essere assolutamente coerenti e
/// professionali, tutto deve essere perfetto."*
///
/// I difetti di sistema che il lettore cieco ha trovato nel campione di 48
/// responsi (docs/collaudo/GA/lettori_ciechi/esiti/esito_tre_domande_oroscopo.md)
/// e che una macchina sa misurare sui dodici corpora:
/// 1. **la prima frase della risposta dice com'e' il periodo**: nomina il
///    periodo e porta una parola di giudizio della fascia della voce
///    (oroscopo-33, "Oggi la sera ha un passo morbido" su un livello 5;
///    oroscopo-40, "Settimana in cui la risorsa da proteggere è il tuo
///    tempo" sotto la Fortuna);
/// 2. **il tempo sta dentro il periodo**: il Giorno e' oggi, la Settimana i
///    sette giorni da oggi (che comincia in qualunque giorno: niente nomi dei
///    giorni), il Mese i trenta giorni da oggi, l'Anno vale in qualunque punto
///    dell'anno (oroscopo-45, "Entro la primavera", "Dopo sei mesi"; 48,
///    "Verso metà anno"; 16, "la prima domenica di ogni mese" con l'anno che
///    finisce fra un mese);
/// 3. **l'Amore e' l'amore**: la risposta non parla di amicizia o di famiglia
///    (oroscopo-26, 42), e vale per chi ha un legame e per chi non lo ha
///    (oroscopo-10, 14, 30, 38, 46).
/// La vita inventata e la coerenza fine non si misurano a macchina: le
/// guardano i lettori ciechi.
void main() {
  // Il confine di parola che vede anche le lettere accentate (\b non le
  // vede: memoria "Dart: \b non vede gli accenti").
  const a = r'(?<![A-Za-zÀ-ÿ])';
  const z = r'(?![A-Za-zÀ-ÿ])';
  // E \w non prende le lettere accentate: "generosità" non finirebbe mai.
  RegExp parole(String alternative) => RegExp(
      '$a(${alternative.replaceAll(r'\w', '[A-Za-zÀ-ÿ]')})$z',
      caseSensitive: false);

  const giorni = r'luned[iì]|marted[iì]|mercoled[iì]|gioved[iì]|venerd[iì]|'
      r'sabato|domenica|sabati|domeniche';
  const stagioni = r'primavera|estate|autunno|inverno|stagion\w*';
  const mesi = r'gennaio|febbraio|marzo|aprile|maggio|giugno|luglio|agosto|'
      r'settembre|ottobre|novembre|dicembre';
  final tempo = {
    // Il Giorno si legge a qualunque ora: "stamattina", letto la sera, e'
    // gia' passato.
    'giorno': parole('$giorni|domani|dopodomani|ieri|stamattina|'
        r'prossimi giorni|settiman\w*|mese'),
    'settimana': parole('$giorni|met[àa] (della )?settimana|mese|'
        'prossima settimana|settimana prossima|$mesi|$stagioni'),
    'mese': parole(r'met[àa] (del )?mese|inizio (del )?mese|prossimo mese|'
        'mese prossimo|fra un mese|tra un mese|ogni mese|mesi|$mesi|$stagioni'),
    'anno': parole('$mesi|$stagioni|met[àa] (dell.)?anno|mesi|ogni mese|'
        r"all.inizio|questo inizio|anno comincia|anno inizia|fine dell.anno|"
        r"inizio dell.anno|anno prossimo|prossimo anno|anno dopo|un anno di|"
        r"anno intero|tutto l.anno|lungo l.anno"),
  };
  final periodo = {
    'giorno': parole('oggi|giornata|giorno'),
    'settimana': parole(r'settiman\w*'),
    'mese': parole('mese'),
    'anno': parole('anno'),
  };
  final fascia = {
    'favorevole': parole(r'favorevol\w*|propizi\w*|buon\w*|fortunat\w*|'
        // "Aperta" e' un giudizio ("Giornata aperta agli incontri"), "stare
        // all'aperto" no: con "apert-" senza distinzione la prima frase
        // bocciata di oroscopo-33 passava (Regola A, 21 ottobre 2026).
        r"facil\w*|adatt\w*|giust\w*|sorrid\w*|lucid\w*|generos\w*|"
        r"(?<!all.)apert\w*|"
        r'fertil\w*|luminos\w*|ricc\w*|prosper\w*|vivac\w*|felic\w*|'
        r'limpid\w*|chiar\w*|scorrevol\w*|legger\w*|caloros\w*|tener\w*|'
        r'dolc\w*|fluid\w*|brillant\w*|gener\w*|piena|pieno|slancio'),
    'equilibrio': parole(r'equilibr\w*|tranquill\w*|stabil\w*|calm\w*|'
        r'ordinari\w*|misurat\w*|quiet\w*|regolar\w*|pacat\w*|seren\w*|'
        r'pian[oa]|gestibil\w*|neutr\w*|senza scosse|né|ferm[oa]|costant\w*|'
        r'lineare|medi[oa]|normale|quotidian\w*|sobri\w*'),
    'salita': parole(r'salita|faticos\w*|fatica|lent\w*|delicat\w*|'
        r'difficil\w*|impegnativ\w*|pesant\w*|strett\w*|tes[oa]|tension\w*|'
        r'ostacol\w*|frenat\w*|complicat\w*|dur[oa]|ardu\w*|incert\w*|'
        r'nervos\w*|stancant\w*|costa|in ritardo|controvento|spigolos\w*|'
        r'fragil\w*|in affanno|ingannevol\w*|rallent\w*|in bilico|'
        r'insidios\w*|irrequiet\w*|stanc\w*|sottotono|opac\w*|esigent\w*|'
        r'attrit\w*'),
  };
  final fuoriDallAmore = parole(r'amicizi\w*|amic[oaie]|famiglia|fratell\w*|'
      r'sorell\w*|cugin\w*|genitor\w*|madre|padre|nonn\w*|figli\w*|'
      r'parent\w*|collegh\w*');
  final soloCoppia = RegExp(
      r"(per la coppia|nella coppia|in coppia|con chi ami|chi ti sta accanto|"
      r"la persona amata|il partner|la partner|(?<![A-Za-zÀ-ÿ])vostr\w*|"
      r"(?<![A-Za-zÀ-ÿ])voi(?![A-Za-zÀ-ÿ])|(?<![A-Za-zÀ-ÿ])(avete|siete|"
      r"parlate|scegliete|fissate|andate|sedetevi|cercate|coltivate|potete|"
      r"fate|prendete|dedicate|tenete)(?![A-Za-zÀ-ÿ]))",
      caseSensitive: false);
  final ancheSenzaLegame = RegExp(
      r'(senza legame|senza una relazione|non hai un legame|'
      r'non hai una relazione|single|se cerchi|chi cerca|se vivi una relazione|'
      r'se hai una relazione|se hai un legame|se sei in coppia|'
      r'chi vive una relazione|chi ha un legame|chi è in coppia|in coppia o|'
      r'o da chi|o a chi|o chi)',
      caseSensitive: false);
  final intestazione =
      RegExp(r'^#### (Generale|Amore|Carriera|Fortuna), (favorevole|'
          r'equilibrio|salita), voce (\d+): (.+)$');
  final campo = RegExp(r'^- (Risposta|Che cosa fare|Risposta, Lunga): (.*)$');

  test('nei dodici corpora: la prima frase, il tempo, l\'Amore', () {
    final primaFrase = <String>[];
    final fuoriTempo = <String>[];
    final amore = <String>[];
    var voci = 0;
    for (final t in TradizioneEu.values) {
      for (final p in PeriodoEu.values) {
        final f = File('docs/corpus/eu/oroscopo_eu_${t.name}_${p.name}.md');
        String? dove;
        String? dominio;
        String? laFascia;
        final campi = <String, String>{};
        void chiudi() {
          if (dove == null) return;
          voci++;
          final risposta = campi['Risposta'] ?? '';
          final tutto = campi.values.join(' ');
          final prima =
              risposta.split(RegExp(r'(?<=[.?;:])\s+')).first;
          if (!periodo[p.name]!.hasMatch(prima) ||
              !fascia[laFascia]!.hasMatch(prima)) {
            primaFrase.add('$dove: «$prima»');
          }
          final m = tempo[p.name]!.firstMatch(tutto);
          if (m != null) fuoriTempo.add('$dove: «${m.group(0)}»');
          if (dominio == 'Amore') {
            final due = risposta
                .split(RegExp(r'(?<=[.?;:])\s+'))
                .take(2)
                .join(' ');
            final fuori = fuoriDallAmore.firstMatch(due);
            if (fuori != null) {
              amore.add('$dove: parla d\'altro «${fuori.group(0)}»');
            }
            if (soloCoppia.hasMatch(tutto) &&
                !ancheSenzaLegame.hasMatch(tutto)) {
              amore.add('$dove: parla solo a chi ha un legame');
            }
          }
          campi.clear();
        }

        for (final riga in f.readAsLinesSync()) {
          final i = intestazione.firstMatch(riga);
          if (i != null) {
            chiudi();
            dominio = i.group(1);
            laFascia = i.group(2);
            dove = '${t.name} ${p.name} | ${i.group(1)}, ${i.group(2)}, voce '
                '${i.group(3)}: ${i.group(4)}';
            continue;
          }
          final c = campo.firstMatch(riga);
          if (c != null) campi[c.group(1)!] = c.group(2)!;
        }
        chiudi();
      }
    }
    cardinaleMinimo(voci, 1548,
        cosa: 'voci dei dodici corpora',
        perche: 'tre tradizioni; Giorno 276, Settimana 168, Mese 48, '
            'Anno 24 voci per tradizione');
    print('ORDINE GA VOCE GA.06: voci $voci; prima frase che non dice il '
        'periodo e la fascia ${primaFrase.length}; tempo fuori dal periodo '
        '${fuoriTempo.length}; Amore fuori dominio o solo per la coppia '
        '${amore.length}');
    expect(primaFrase, isEmpty, reason: primaFrase.take(8).join('\n'));
    expect(fuoriTempo, isEmpty, reason: fuoriTempo.take(8).join('\n'));
    expect(amore, isEmpty, reason: amore.take(8).join('\n'));
  });

  test('a video, il "Da dove viene" non rimanda e non ripete', () {
    // I rimandi a parti che il responso non ha (oroscopo-22, 24, 25, 27,
    // 37, 39, 42, 44: "i tre migliori, qui sopra"), le righe del dio che
    // dicono il simbolo senza spiegarlo ("Per il lavoro: doma
    // l'Ufficiale.", oroscopo-34, 35, 36, 38, 40) e la spiegazione dello
    // stesso dio due volte di fila (oroscopo-34, 36).
    final rimando = RegExp(r'(qui sopra|qui sotto|più sopra|più sotto|'
        r'vedi sopra|vedi sotto|leggi sopra)', caseSensitive: false);
    final criptica = RegExp(
        r'(Per il (lavoro|legame|denaro|giorno): |è la Sade Sati\.|'
        r'Il guardiano di oggi è [A-Z]|è di turno, come pressione)');
    final colpe = <String>[];
    var righe = 0;
    void guarda(String dove, String? daDove) {
      if (daDove == null) return;
      righe++;
      final m = rimando.firstMatch(daDove) ?? criptica.firstMatch(daDove);
      if (m != null) colpe.add('$dove: «${m.group(0)}» in «$daDove»');
      // Lo stesso dio del BaZi nominato due volte nella stessa riga: e' la
      // sua spiegazione ripetuta.
      for (final dio in const [
        'Compagno', 'Rivale', 'Nutrimento', 'Ufficiale Ferito', //
        'Ricchezza indiretta', 'Ricchezza diretta', 'Sette Uccisioni',
        'Ufficiale diretto', 'Sigillo indiretto', 'Sigillo diretto',
      ]) {
        if (dio.allMatches(daDove).length > 1) {
          colpe.add('$dove: $dio spiegato due volte «$daDove»');
        }
      }
    }

    final giorni = [DateTime(2026, 10, 20), DateTime(2026, 10, 25)];
    for (final persona in dodiciPersone.take(6)) {
      for (final oggi in giorni) {
        for (final t in TradizioneEu.values) {
          if (!persona.legge(t)) continue;
          for (final lunga in const [false, true]) {
            final nome = '${persona.nome} ${oggi.day}/${oggi.month} ${t.name} '
                '${lunga ? 'Lunga' : 'Breve'}';
            for (final c in persona.giorno(t, oggi, lunga: lunga)) {
              guarda('$nome Giorno ${c.domain.label}',
                  c.responso?.daDoveViene);
            }
            for (final mese in const [false, true]) {
              for (final d in persona.periodo(t, oggi, mese: mese).domini) {
                guarda(
                    '$nome ${mese ? 'Mese' : 'Settimana'} ${d.dominio.label}',
                    d.responso(t, mese: mese, lunga: lunga).daDoveViene);
              }
            }
            for (final c in persona.anno(t, oggi, lunga: lunga)) {
              guarda('$nome Anno ${c.domain.label}', c.responso?.daDoveViene);
            }
          }
        }
      }
    }
    cardinaleMinimo(righe, 6 * 2 * 2 * 2 * 16,
        cosa: 'righe "Da dove viene" a video',
        perche: 'sei persone, due giorni, almeno due tradizioni, Breve e '
            'Lunga, quattro periodi per quattro domini');
    print('ORDINE GA VOCE GA.06: righe "Da dove viene" $righe, con un '
        'rimando, una riga criptica o il dio spiegato due volte '
        '${colpe.length}');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });
}
