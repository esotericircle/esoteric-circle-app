import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/amici/amici_offline.dart';
import '../../core/brand/brand.dart';
import '../../core/astro/zodiac.dart';
import '../../core/chat/user_profile.dart';
import '../../core/horoscope/i_segni_delle_tradizioni.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/astro/natal_chart.dart';
import '../../core/horoscope/horoscope.dart';
import 'oroscopo_share_card.dart';

/// **DI CHI E' LA LETTURA. Ordine FC voce 02, 4 ottobre 2026.**
///
/// L'Oroscopo e' una schermata sola, e riceve di chi e' la lettura: di chi usa
/// l'app ([IlSoggettoDellOroscopo.io]) oppure di un amico
/// ([IlSoggettoDellOroscopo.amico]). Fondale, gesto, riflessione, corsa
/// dello zodiaco, infografiche, periodi, profondita', tradizioni e card valgono
/// per tutti e due senza che nessuno debba ricordarsi di copiarli.
///
/// **PERCHE' ESISTE.** L'ordine ES voce 12 aveva fatto nascere una SECONDA
/// schermata dell'oroscopo (`LOroscopoDellAmicoScreen`) invece di far passare
/// questa per un soggetto diverso: nera invece che sul cosmo, senza la scena
/// del gesto, con una sola infografica e senza i periodi. E' la ventiduesima
/// occorrenza della famiglia delle due porte in questo progetto. Quella
/// schermata non c'e' piu'.
///
/// **TUTTO CIO' CHE CAMBIA COL SOGGETTO STA QUI, ed e' poco.** Chi domani
/// aggiungera' una differenza fra la lettura propria e quella di un amico la
/// mette in questa classe, col perche'; la schermata chiede qui e non legge
/// i dati di nascita da sola (`il_soggetto_dell_oroscopo_test.dart` lo
/// pretende). L'elenco:
///
/// 1. **IL NOME NEL TITOLO**: la riga "Oroscopo per" porta il nome
///    dell'amico scelto, e il nome di chi guarda riporta alla sua lettura
///    ([nomeAmico]).
/// 2. **I DATI DI NASCITA** da cui si legge: il segno, la data, l'ora, il
///    luogo e il fuso dell'amico, cosi' come l'amico e' stato salvato
///    ([segno], [nascitaDeiSegni], [dataDiNascita], [luogoDiNascita]).
/// 3. **LA LETTURA STA SUL SEGNO SOLARE, NON SULLA CARTA**: di un amico l'app
///    non ha la carta natale, quindi il cielo personale non c'e' e la nota lo
///    dice al posto dell'invito a completare i propri dati ([carta],
///    [notaDelSegnoSolare]).
/// 4. **IL NEUTRO**: il genere dell'amico non si sa, quindi i testi si
///    compongono al neutro e senza vocativo ([forma], [vocativo],
///    [alNeutro]).
/// 5. **LA CARD E' UN REGALO**: "Il tuo oroscopo", "Te lo manda", e il testo
///    che la accompagna e' rivolto all'amico ([perUnAmico]).
/// 6. **CIO' CHE E' SOLO DI CHI GUARDA NON SI TOCCA leggendo un amico**: il
///    Sigillo dei Tre Cieli (e' la pratica quotidiana della persona) e
///    l'avviso del prossimo compleanno solare (e' il suo), e il gesto del
///    Cammino, che segnala al server il rito compiuto: prima dell'ordine FC
///    la lettura di un amico non ci passava, e farcela passare sarebbe una
///    chiamata in piu' per ogni lettura, contro la regola R14 ([eUnAmico]).
///    I limiti del piano, gli Eos e i contatori invece sono di chi guarda
///    anche quando legge un amico: e' lui che usa l'app.
/// 7. **I DATI CHE MANCANO**: per sé l'invito porta ai propri dati di
///    nascita; per un amico la riga dice che cosa manca e di chi
///    ([perTeOPerLui]).
/// 8. **L'ANNO DI UN AMICO** si calcola sul suo luogo di nascita: dove vive
///    adesso non si sa ([luogoDellAnno]).
/// 9. **IL CIELO DEL FONDALE**: lo stesso cosmo in parallasse, col seme del
///    soggetto ([semeDelCielo]).
@immutable
class IlSoggettoDellOroscopo {
  const IlSoggettoDellOroscopo.io(this._segnoTuo) : amico = null;

  IlSoggettoDellOroscopo.amico(Amico this.amico) : _segnoTuo = amico.segno;

  /// L'amico di cui si legge; nullo per la lettura propria.
  final Amico? amico;

  final Zodiac _segnoTuo;

  bool get eUnAmico => amico != null;

  /// 1. Il nome dell'amico senza cognome; nullo per la lettura propria.
  String? get nomeAmico => amico == null
      ? null
      : OroscopoShareCard.soloIlNome(amico!.nome) ?? amico!.nome;

  /// 2. Il segno solare del soggetto.
  Zodiac get segno => _segnoTuo;

  /// 1. Il titolo della schermata: per sé nessuno (l'emblema e' il tuo
  /// segno); per un amico di chi e' la lettura, come diceva la sua
  /// schermata.
  String? get titolo => amico == null ? null : 'L\'oroscopo di ${amico!.nome}';

  /// 1. Il segno detto di chi e': "Il tuo segno e' Capricorno" per sé, "Il
  /// segno di Lucia e' Capricorno" per un amico (visto sul Realme il 30
  /// settembre 2026, ordine ES voce 12: diceva "Il tuo").
  SegnoDellaTradizione detto(SegnoDellaTradizione s) =>
      amico == null ? s : s.dettoDi(nomeAmico!);

  /// 2. La nascita del soggetto per i segni delle tre tradizioni.
  /// [ascolta] falso fuori dal `build` (un tocco, un callback).
  NascitaDeiSegni? nascitaDeiSegni(BuildContext context,
      {bool ascolta = true}) {
    final a = amico;
    if (a != null) {
      return NascitaDeiSegni(
          locale: a.momento, oraNota: a.oraNota, fuso: a.fuso);
    }
    return NascitaDeiSegni.daiDati(
        Provider.of<BirthIdentityController>(context, listen: ascolta).details,
        Provider.of<ProfileController>(context, listen: ascolta).identity);
  }

  /// Il segno solare di chi guarda, per tornare alla propria lettura dalla
  /// lettura di un amico; nullo se la sua nascita e' quella d'esempio.
  static Zodiac? segnoDiChiGuarda(BuildContext context) {
    final io = context.read<ProfileController>().identity;
    return io.sunSign;
  }

  /// 2. La data di nascita, per lo scarto della scelta delle voci e il giorno
  /// personale del numero fortunato; nulla se e' quella d'esempio.
  DateTime? dataDiNascita(BuildContext context) {
    final a = amico;
    if (a != null) return a.nascita;
    final io = context.read<ProfileController>().identity;
    return io.isExample ? null : io.birthDate;
  }

  /// 2. Il luogo di nascita: latitudine, longitudine e nome.
  (double, double, String)? luogoDiNascita(BuildContext context) {
    final a = amico;
    if (a != null) {
      return a.lat == null || a.lon == null
          ? null
          : (a.lat!, a.lon!, a.luogo ?? 'il luogo di nascita');
    }
    final p = context.read<BirthIdentityController>().details?.place;
    return p == null ? null : (p.latitude, p.longitude, p.label);
  }

  /// 8. Dove si calcola l'anno e le ore del giorno: per sé dove si vive
  /// adesso, altrimenti il luogo di nascita; per un amico il suo luogo di
  /// nascita, perche' dove vive adesso non si sa.
  (double, double, String)? luogoDellAnno(BuildContext context,
      {double? latDiOggi, double? lonDiOggi, String? cittaDiOggi}) {
    if (!eUnAmico && latDiOggi != null && lonDiOggi != null) {
      return (latDiOggi, lonDiOggi, cittaDiOggi ?? 'il tuo luogo');
    }
    return luogoDiNascita(context);
  }

  /// 3. La carta natale completa: di un amico non c'e'.
  NatalChart? carta(BuildContext context, {bool ascolta = true}) =>
      amico != null
          ? null
          : Provider.of<BirthIdentityController>(context, listen: ascolta)
              .cartaCompleta;

  /// 3. La nota che dichiara la lettura sul segno solare; nulla per sé.
  String? get notaDelSegnoSolare => amico == null
      ? null
      : 'Letto sul segno solare di ${amico!.nome}: con la sua carta natale '
          'la lettura sarebbe più sua.';

  /// 4. La forma di cortesia dei testi: per un amico il neutro.
  CourtesyForm forma(BuildContext context, {bool ascolta = true}) =>
      amico != null
          ? CourtesyForm.unknown
          : Provider.of<ProfileController>(context, listen: ascolta).courtesy;

  /// 4. Il nome con cui Medora apre la lettura: per un amico nessuno.
  String? vocativo(BuildContext context) {
    if (amico != null) return null;
    final p = context.watch<ProfileController>();
    return Horoscope.vocativeFor(p.vocative, p.courtesy);
  }

  /// 4. Compone [f] al neutro quando il soggetto e' un amico: le marche del
  /// genere dei corpora si risolvono con la forma corrente, che e' quella di
  /// chi usa l'app. Si torna alla forma di prima subito dopo.
  T alNeutro<T>(T Function() f) {
    if (amico == null) return f();
    final prima = LaMarcaDelGenere.formaCorrente;
    LaMarcaDelGenere.formaCorrente = CourtesyForm.unknown;
    try {
      return f();
    } finally {
      LaMarcaDelGenere.formaCorrente = prima;
    }
  }

  /// 5. La card e' un regalo all'amico.
  bool get perUnAmico => amico != null;

  /// 5. I dati di nascita scritti sulla card: del soggetto.
  String? nascitaScritta(BuildContext context) {
    final a = amico;
    if (a != null) {
      final ora = a.ora?.split(':');
      return OroscopoShareCard.laNascitaScritta(a.nascita,
          ora: ora == null ? null : int.tryParse(ora[0]),
          minuto: ora == null ? null : int.tryParse(ora[1]) ?? 0,
          luogo: a.luogo);
    }
    final io = context.read<ProfileController>().identity;
    return io.isExample
        ? null
        : OroscopoShareCard.laNascitaScritta(io.birthDate,
            ora: io.hasBirthTime ? io.birthMoment.hour : null,
            minuto: io.birthMoment.minute,
            luogo: io.birthPlace?.city);
  }

  /// 5. Il testo che accompagna la card: per sé "Il mio oroscopo"; per un
  /// amico e' un regalo, "Il tuo oroscopo", con chi lo manda.
  String testoDellaCondivisione(BuildContext context,
      {required String periodo, required String segno}) {
    final a = amico;
    if (a == null) {
      return 'Il mio oroscopo $periodo, $segno. Scopri il tuo: ${Brand.url}';
    }
    String? chi;
    try {
      final p = context.read<ProfileController>().profile;
      chi = p.hasName ? OroscopoShareCard.soloIlNome(p.displayName) : null;
    } catch (errore) {
      debugPrint('La card per un amico: il profilo non si legge. $errore');
    }
    return 'Il tuo oroscopo $periodo, ${a.nome}: $segno.'
        '${chi == null ? '' : ' Te lo manda $chi.'}'
        ' Il tuo cielo ogni giorno: ${Brand.url}';
  }

  /// 7. Le parole di una riga che cambia col soggetto: per sé [perTe], per un
  /// amico [perLui] col suo nome.
  String perTeOPerLui(String perTe, String Function(String nome) perLui) =>
      amico == null ? perTe : perLui(nomeAmico!);

  /// 9. **IL CIELO DEL FONDALE**: stesso motore e stessa parallasse, ma il
  /// seme del cielo e' del soggetto (ordine FC voce 04): la propria lettura
  /// ha il cielo dell'Oroscopo, il 5; ogni amico ha il suo, deterministico
  /// dall'identificativo, uguale fra un'apertura e l'altra.
  int get semeDelCielo {
    final a = amico;
    if (a == null) return 5;
    var somma = 0;
    for (final c in a.id.codeUnits) {
      somma = (somma * 31 + c) % 100000;
    }
    return 500 + somma % 400;
  }

  /// La chiave di cio' che si ricorda per soggetto (gli anni aperti con gli
  /// Eos, le teste rivelate): per un amico porta il suo identificativo, cosi'
  /// aprire l'anno di Lucia non apre il proprio.
  String chiave(String cosa) =>
      amico == null ? cosa : 'amico|${amico!.id}|$cosa';
}
