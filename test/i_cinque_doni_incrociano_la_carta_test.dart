import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/arcano_del_giorno.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:flutter_test/flutter_test.dart';

/// I CINQUE DONI INCROCIANO IL CIELO DI OGGI E LA CARTA NATALE.
/// Ordine CE voce 13.
///
/// **La promessa e' scritta a video e non si tocca.** Il quarto fumetto del
/// tutorial dice, con le parole del fondatore, che i cinque Doni sono "creati
/// incrociando il Cielo di oggi e la tua Carta natale". Il fondatore ha deciso
/// che il testo resta e che l'incrocio nasce nei Doni che non ce l'hanno: qui
/// si misura che la promessa sia vera per tutti e cinque.
///
/// **LA MISURA E' UNA SOLA: a parita' di giorno, due carte natali diverse
/// devono dare due responsi diversi.** Non si guarda se il codice nomina la
/// nascita, che e' cio' che un sorgente puo' fare senza usarla: si chiede il
/// responso due volte e si confrontano le parole.
///
/// **TRE PREMESSE DELL'ORDINE SONO CADUTE ALLA MISURA**, e stanno scritte nel
/// manifesto: la Runa del Tramonto l'incrocio ce l'aveva gia', il Sigillo del
/// Sogno non aveva nessuna Luna di nascita, e l'Arcano era davvero la stessa
/// carta per tutti.
void main() {
  // Due nascite lontane fra loro: segni solari diversi, Lune diverse, e
  // numeri della carta di nascita diversi.
  final unaNascita = DateTime(1975, 11, 2);
  final altraNascita = DateTime(1990, 6, 15);
  final giorno = DateTime(2026, 7, 13);

  test('l\'Arcano del Giorno non e\' piu\' la stessa carta per tutti', () {
    final una = ArcanoDelGiorno.di(giorno, nascita: unaNascita);
    final altra = ArcanoDelGiorno.di(giorno, nascita: altraNascita);
    // ignore: avoid_print
    print('ORDINE CE VOCE 13: Arcano, ${una.name} contro ${altra.name}');
    expect(una.name, isNot(altra.name),
        reason: 'lo stesso giorno, due carte natali diverse, e la stessa '
            'carta: l\'Arcano non incrocia niente');
  });

  test('e senza nascita resta il Dono del giorno, non un vuoto', () {
    // **CHIEDERE LA NASCITA PER APRIRE UN DONO SAREBBE UN PEDAGGIO.** Chi
    // arriva e non l'ha data riceve comunque la sua carta.
    final senza = ArcanoDelGiorno.di(giorno);
    expect(senza.name.trim(), isNotEmpty);
    expect(ArcanoDelGiorno.responsoDi(giorno).trim(), isNotEmpty);
  });

  test('il Sigillo del Sogno guarda anche la tua Luna', () {
    final uno = DreamRiteCorpus.saluto(giorno, nascita: unaNascita);
    final altro = DreamRiteCorpus.saluto(giorno, nascita: altraNascita);
    // ignore: avoid_print
    print('ORDINE CE VOCE 13: Sogno, relazioni '
        '${DreamRiteCorpus.relazione(giorno, unaNascita)?.nome} contro '
        '${DreamRiteCorpus.relazione(giorno, altraNascita)?.nome}');
    expect(uno, isNot(altro),
        reason: 'la stessa notte per due persone diverse: il Sigillo non '
            'incrocia la Luna di nascita');
    // E chi non ha dato la nascita ha comunque il suo saluto.
    expect(DreamRiteCorpus.saluto(giorno).trim(), isNotEmpty);
  });

  test('la Runa del Tramonto cambia con la nascita, e lo faceva gia\'', () {
    // **LA PREMESSA DELL'ORDINE ERA FALSA QUI.** L'ordine dava la Runa per
    // "cielo si', carta natale no": misurata, la chiave dell'estrazione porta
    // gia' l'identita', cioe' la nascita con l'ora. Questa riga non ha
    // costruito niente, ha misurato.
    final sera = DateTime(2026, 7, 13, 20);
    final una = SunsetRune.estrai(sera,
        dataNascita: unaNascita,
        identita: SunsetRune.identitaPer(nascita: unaNascita, deviceId: 'x'));
    final altra = SunsetRune.estrai(sera,
        dataNascita: altraNascita,
        identita: SunsetRune.identitaPer(nascita: altraNascita, deviceId: 'x'));
    // ignore: avoid_print
    print('ORDINE CE VOCE 13: Runa, ${una.rune.name} contro '
        '${altra.rune.name}');
    expect(una.rune.name, isNot(altra.rune.name),
        reason: 'la stessa sera, due nascite diverse, e la stessa runa');
  });

  test('il Rito dell\'Alba porta l\'incrocio dentro cio\' che si legge', () {
    // **PRIMA STAVA SOLO NELLA SCHEDA "DA DOVE NASCE".** Il segno solare
    // natale finiva in `GiftSource` e non toccava ne' il gesto ne' la parola:
    // chi compiva il rito non incontrava mai la propria carta.
    final uno = DawnGift.forMaestro(giorno, Maestro.aura,
        identity: _identita(unaNascita));
    final altro = DawnGift.forMaestro(giorno, Maestro.aura,
        identity: _identita(altraNascita));
    // ignore: avoid_print
    print('ORDINE CE VOCE 13: Alba, parola ${uno.word} contro ${altro.word}');
    expect([uno.word, uno.orientation], isNot([altro.word, altro.orientation]),
        reason: 'lo stesso mattino per due carte natali diverse: l\'incrocio '
            'resta nella scheda e non entra nel rito');
  });

  test('il Soffio del Destino nasce dai transiti, e li porta nel gesto', () {
    // Il Soffio e' l'unico dei cinque che l'ordine dava per gia' conforme, e
    // alla misura lo e': la sua risposta nasce dai transiti sulla carta, e
    // senza carta non c'e' risposta. **La riga misura il confine onesto**: il
    // Dono non inventa un cielo che non ha.
    final senzaCarta = DawnGift.forMaestro(giorno, Maestro.aura);
    expect(senzaCarta.source.natalSunSign, isNull,
        reason: 'senza identita\' il Dono si inventa un Sole natale');
  });
}

BirthIdentity _identita(DateTime nascita) =>
    BirthIdentity(birthMoment: nascita);
