import '../astro/zodiac.dart';
import 'cielo_della_sinastria.dart';
import 'gemello_astrale.dart';
import 'synastry_report.dart';

/// PERCHE' PROPRIO LUI E' IL TUO GEMELLO.
///
/// **Richiesta del fondatore del 31 agosto 2026, verbatim**: "la principale
/// domanda a cui vorra' l'utente sara': 'perche' proprio questo Vip e' il mio
/// gemello?' e vorra' una risposta tecnica che riguarda le stelle, ma
/// soprattutto una risposta evocativa legata alla personalita' della persona".
///
/// **Due risposte e non una, perche' sono due domande.** La tecnica dice
/// COS'E' successo nel cielo, e si legge nei fili degli aspetti; l'evocativa
/// dice COSA VUOL DIRE per chi la legge, e parla di come si sta al mondo. Una
/// sola delle due lascia insoddisfatti in due modi diversi: la tecnica da
/// sola sembra un referto, l'evocativa da sola sembra un oroscopo da rivista.
///
/// **TUTTI I TESTI DI QUESTO FILE SONO PROVVISORI.** Nascono qui perche' il
/// fondatore ha chiesto una risposta che prima non c'era: le parole
/// definitive le approva lui, e finche' non lo fa questo commento resta.
///
/// **Nessuna affermazione sulla vita privata di una persona reale.** Regola
/// del fondatore del 28 agosto 2026, che vale per sempre: qui si parla dei due
/// SEGNI e di come si sta al mondo, mai di cio' che una persona vera fa o
/// prova. Il nome del VIP compare come nome, e nient'altro.
class PercheProprioLui {
  const PercheProprioLui._();

  /// La risposta tecnica: cosa dicono le stelle, coi fili veri.
  ///
  /// **Non si inventa nessun aspetto**: si nominano quelli che il rapporto ha
  /// gia' trovato, che sono gli stessi che la Sinastria rende toccabili.
  static String tecnica(SynastryReport rapporto, Zodiac tuo, Zodiac suo) {
    final fili = rapporto.aspettiPiuForti;
    final elementi = _elementi(tuo, suo);
    if (fili.isEmpty) {
      return 'Fra i vostri due cieli non c\'è nessun aspetto stretto. '
          'A tenervi insieme resta l\'elemento: $elementi È il legame '
          'più largo che ci sia. Anche il più antico.';
    }
    final nomi = fili.take(3).map((a) => a.titolo).toList();
    final elenco = nomi.length == 1
        ? nomi.first
        : '${nomi.take(nomi.length - 1).join(', ')} e ${nomi.last}';
    return 'Fra i cinquanta, il suo cielo è quello che tocca il tuo nei '
        'punti più stretti: $elenco. $elementi';
  }

  /// La risposta evocativa: cosa vuol dire, detta sulla personalita'.
  ///
  /// **Parla dei due segni e non della persona reale**: e' la regola, ed e'
  /// anche l'unica cosa onesta, perche' di una persona vera il Cerchio conosce
  /// il giorno di nascita e nient'altro.
  static String evocativa(Zodiac tuo, Zodiac suo, int percento) {
    final tuoModo = _comeStaAlMondo[tuo.element]!;
    // **DI LUI SI PARLA IN TERZA PERSONA, guardata l'anteprima.** A video si
    // leggeva "Lui, o lei, senti l'aria di una stanza": la stessa frase
    // scritta per il TU, riusata per un altro. Le due voci sono due, e vanno
    // scritte due volte.
    final suoModo = _comeStaAlMondoLui[suo.element]!;
    final quanto = percento >= 85
        ? 'Non è una somiglianza: è la stessa frase detta da due voci.'
        : percento >= 70
            ? 'Non siete uguali. Per questo funziona: vi somigliate dove '
                'conta e vi completate dove serve.'
            : 'Vi somigliate meno di quanto il titolo prometta. La parte '
                'interessante è proprio quella che non combacia.';
    if (tuo.element == suo.element) {
      return 'Tutti e due $tuoModo. Chi vi guarda da fuori vede due persone '
          'diverse che però prendono le decisioni nello stesso modo. '
          'Quella è la cosa che non si impara. $quanto';
    }
    return 'Tu $tuoModo. Chi hai davanti $suoModo. $quanto';
  }

  /// **IL TITOLO, e il fondatore lo vuole memorabile.** Verbatim: "come
  /// attrattiva principale un titolo accattivante e anche un po' meme, che
  /// spinga alla condivisione, qualcosa di memorabile."
  ///
  /// **E' costruito e non pescato**: nasce dai due elementi e dal punteggio,
  /// quindi due persone diverse leggono due titoli diversi, ed e' quello che
  /// rende una cosa condivisibile. **Testi provvisori**, come tutto qui.
  static String titolo(Zodiac tuo, Zodiac suo, int percento, String nome) {
    // **IL NOME NON SI RIPETE, guardata l'anteprima.** Il titolo sta
    // sotto il nome grande, e a video si leggeva "Ariana Grande" e subito
    // dopo "Tu e Ariana Grande siete la stessa persona": due volte lo
    // stesso nome in tre righe. Il titolo dice cosa siete, chi e' lo
    // ha gia' detto la riga sopra.
    if (percento >= 90) {
      return 'Siete la stessa persona in due corpi';
    }
    if (percento >= 80) {
      return tuo.element == suo.element
          ? 'Stesso elemento, stesso guaio'
          : 'Il cielo vi ha fatti a coppia e non ve lo ha detto';
    }
    if (percento >= 70) {
      return 'C\'è un motivo se ti è sempre stato simpatico';
    }
    return 'Il cielo ha scelto lui. Adesso devi conviverci';
  }

  static String _elementi(Zodiac tuo, Zodiac suo) {
    if (tuo.element == suo.element) {
      return 'Siete tutti e due ${_nomeElemento[tuo.element]}, che nello '
          'zodiaco è il legame più diretto che ci sia.';
    }
    return '${_nomeElemento[tuo.element]!.substring(0, 1).toUpperCase()}'
        '${_nomeElemento[tuo.element]!.substring(1)} contro '
        '${_nomeElemento[suo.element]}: due modi diversi di stare nella stessa '
        'stanza.';
  }

  /// I quattro elementi col loro nome, in italiano e al plurale.
  static const Map<ZodiacElement, String> _nomeElemento = {
    ZodiacElement.fire: 'fuoco',
    ZodiacElement.earth: 'terra',
    ZodiacElement.air: 'aria',
    ZodiacElement.water: 'acqua',
  };

  /// Come sta al mondo chi ha quell'elemento: e' la parte evocativa, e parla
  /// del SEGNO, mai della persona.
  static const Map<ZodiacElement, String> _comeStaAlMondo = {
    ZodiacElement.fire: 'decidi prima di aver finito di pensare: quasi '
        'sempre ci azzecchi',
    ZodiacElement.earth: 'non ti fidi di niente che non si possa toccare: '
        'costruisci cose che restano',
    ZodiacElement.air: 'capisci le persone prima che finiscano la frase: poi '
        'ti annoi appena la conversazione si ripete',
    ZodiacElement.water: 'senti l\'aria di una stanza appena entri: ti costa '
        'più di quanto ammetti',
  };

  /// **LO STESSO, DETTO DI LUI.** Ordine CF voce 14, aggiunta del 31 agosto
  /// 2026: la mappa qui sopra e' scritta per il TU, e riusarla per un altro
  /// dava "Lui, o lei, senti l'aria di una stanza". Due voci, due frasi.
  ///
  /// **Parla del SEGNO e non della persona reale**, come l'altra: la regola
  /// del fondatore del 28 agosto 2026 vale per tutte e due.
  static const Map<ZodiacElement, String> _comeStaAlMondoLui = {
    ZodiacElement.fire: 'decide prima di aver finito di pensare: quasi '
        'sempre ci azzecca',
    ZodiacElement.earth: 'non si fida di niente che non si possa toccare: '
        'costruisce cose che restano',
    ZodiacElement.air: 'capisce le persone prima che finiscano la frase: poi '
        'si annoia appena la conversazione si ripete',
    ZodiacElement.water: 'sente l\'aria di una stanza appena entra: gli costa '
        'più di quanto ammetta',
  };

  /// Tutte e tre le parti insieme, per chi le vuole come un blocco solo.
  static ({String titolo, String tecnica, String evocativa}) perIlGemello(
    GemelloAstrale gemello,
    CieloDiSinastria tuoCielo,
    SynastryReport rapporto,
  ) {
    final tuo = tuoCielo.segnoSolare;
    final suo = gemello.vip.sign;
    return (
      titolo: titolo(tuo, suo, gemello.punteggio, gemello.vip.name),
      tecnica: tecnica(rapporto, tuo, suo),
      evocativa: evocativa(tuo, suo, gemello.punteggio),
    );
  }
}
