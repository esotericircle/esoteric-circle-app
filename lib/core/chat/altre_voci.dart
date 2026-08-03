import '../maestro/maestro.dart';
import '../maestro/maestro_reply.dart';
import 'chat_message.dart';

/// LE ALTRE VOCI DEL CERCHIO, dentro la stessa conversazione.
///
/// **Il dato che ha fatto nascere questo file.** Nell'intestazione della chat
/// c'era un'icona a bilancia, dorata, che in una schermata di astrologia si
/// legge come il SEGNO della Bilancia. E portava a una schermata nuova dove la
/// conversazione ricominciava da zero: la domanda era gia' stata fatta, e per
/// sentire gli altri due Maestri bisognava riscriverla.
///
/// Adesso le altre voci arrivano dove sta gia' guardando la persona: bolle
/// nuove sotto quella che ha appena letto, ognuna col colore e il volto del suo
/// Maestro, ognuna con la sua lente e la sua chiusura.
///
/// Funzioni pure: si provano senza montare uno schermo e senza rete.
class AltreVoci {
  const AltreVoci._();

  /// Gli altri due Maestri, nell'ordine fisso del cerchio.
  ///
  /// Si RICAVA da [Maestro.fixedOrder], non si scrive: se domani nascesse un
  /// quarto Maestro entrerebbe da solo, e un elenco copiato a mano no. E'
  /// la stessa regola di `VoceDelMaestro.artiDegliAltri`.
  static List<Maestro> altriDi(Maestro maestro) =>
      [for (final m in Maestro.fixedOrder) if (m != maestro) m];

  /// Quali voci hanno gia' risposto in questa conversazione, nell'ordine fisso.
  ///
  /// Conta solo le risposte COMPIUTE: un ripiego non e' la voce di un Maestro,
  /// e lo dichiara da se'. La regola non e' nuova, e' [ChatMessage.portaUnResponso].
  static List<Maestro> vociNella(
    List<ChatMessage> messaggi,
    Maestro predefinito,
  ) {
    final trovate = <Maestro>{
      for (final m in messaggi)
        if (m.isMaestro && m.portaUnResponso) m.autoreEffettivo(predefinito),
    };
    return [for (final m in Maestro.fixedOrder) if (trovate.contains(m)) m];
  }

  /// Da quante voci in su ha senso una sintesi.
  ///
  /// Due: mettere a confronto una voce sola con se stessa non e' un confronto,
  /// e la schermata che lo fa esisteva gia' e si raggiungeva sempre, anche
  /// quando non c'era niente da confrontare.
  static const int vociPerLaSintesi = 2;

  /// Vero se in questa conversazione c'e' abbastanza da mettere a confronto.
  static bool siPuoSintetizzare(
    List<ChatMessage> messaggi,
    Maestro predefinito,
  ) =>
      vociNella(messaggi, predefinito).length >= vociPerLaSintesi;

  /// La risposta di chat di [maestro] letta nei TRE STRATI della sintesi.
  ///
  /// **Non e' un'invenzione, e' una lettura.** La persona di ogni Maestro gli
  /// chiede gia' esattamente questa forma: una frase di sintesi in apertura, il
  /// testo narrato, e in fondo la SUA chiusura, che per Medora e' una direzione
  /// nel tempo, per Aura un gesto del corpo, per Caligo un segno da portare.
  /// Qui quella forma si riconosce invece di essere ricostruita: la prima frase
  /// e' il colpo d'occhio, l'ultima e' l'invito, il resto e' la lettura.
  ///
  /// Con un testo troppo corto per avere tre parti non si spezza niente: tutto
  /// resta nella lettura, che e' l'unico strato che non puo' mancare.
  static MaestroReply treStratiDa(String testo) {
    final pulito = testo.trim();
    final frasi = frasiDi(pulito);
    // **Uno strato vuoto e' peggio di uno strato in meno.** Con meno di tre
    // frasi non si spreme il testo per riempire tre caselle: la lettura tiene
    // tutto, e chi mostra la lente non disegna cio' che non c'e'. La prima
    // stesura tornava glance vuoto e invite vuoto, e a video si vedevano una
    // riga bianca e una freccia senza niente accanto.
    if (frasi.isEmpty) {
      return MaestroReply(glance: '', reading: pulito, invite: '');
    }
    if (frasi.length == 1) {
      return MaestroReply(glance: '', reading: frasi.first, invite: '');
    }
    if (frasi.length == 2) {
      return MaestroReply(glance: frasi.first, reading: frasi.last, invite: '');
    }
    return MaestroReply(
      glance: frasi.first,
      reading: frasi.sublist(1, frasi.length - 1).join(' ').trim(),
      invite: frasi.last,
    );
  }

  /// LA CHIUSURA di una risposta, cioe' la sua ULTIMA FRASE.
  ///
  /// **Non si prende da `treStratiDa().invite`**, e la differenza costa: quel
  /// campo resta vuoto quando le frasi sono meno di tre, perche' li' si sta
  /// dividendo un testo in tre parti e con due frasi la terza non esiste. La
  /// chiusura invece esiste sempre finche' esiste una frase: e' l'ultima, e
  /// basta. Se ne e' accorta la prova dell'Eco su una risposta di due frasi.
  static String chiusuraDi(String testo) {
    final frasi = frasiDi(testo);
    return frasi.isEmpty ? '' : frasi.last;
  }

  /// Le frasi di un testo, tenendo la punteggiatura che le chiude.
  ///
  /// Pubblica perche' la serve anche l'Eco, e due modi di spezzare un testo in
  /// frasi darebbero due chiusure diverse per la stessa risposta.
  static List<String> frasiDi(String testo) {
    final frasi = <String>[];
    final buffer = StringBuffer();
    for (final rune in testo.runes) {
      final c = String.fromCharCode(rune);
      if (c == '\n') {
        if (buffer.isNotEmpty) {
          frasi.add(buffer.toString().trim());
          buffer.clear();
        }
        continue;
      }
      buffer.write(c);
      if (c == '.' || c == '?' || c == '!') {
        frasi.add(buffer.toString().trim());
        buffer.clear();
      }
    }
    if (buffer.toString().trim().isNotEmpty) {
      frasi.add(buffer.toString().trim());
    }
    return [for (final f in frasi) if (f.isNotEmpty) f];
  }
}
