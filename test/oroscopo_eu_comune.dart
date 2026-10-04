import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/l_anno_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/l_annuale.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_cinese.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/horoscope/la_rivoluzione_solare.dart';
import 'package:esoteric_circle/core/horoscope/la_settimana_del_cielo.dart';
import 'package:esoteric_circle/core/astro/il_segno_del_cielo.dart';

/// **LE PERSONE E LE SCHEDE DELLE PROVE DELL'ORDINE EU** (voci 01, 14, 16
/// e 17): dodici nascite di segni e anni diversi, con la carta natale vera
/// (le posizioni di nascita dal motore delle effemeridi dell'app) o senza, e
/// le schede di un giorno in ogni tradizione e periodo, composte con le
/// porte dell'app.
class PersonaDiProva {
  PersonaDiProva(this.nascita, {required this.conCarta, this.ascendente = 0});

  /// Il momento di nascita, locale (Europa/Roma).
  final DateTime nascita;
  final bool conCarta;
  final double ascendente;

  late final NatalChart? carta = conCarta ? _carta() : null;
  late final Zodiac segno = IlSegnoDelCielo.diNascita(nascita, oraNota: false);
  late final NascitaDeiSegni nascitaDeiSegni =
      NascitaDeiSegni(locale: nascita, oraNota: conCarta, fuso: 'Europe/Rome');
  late final int animale =
      ISegniDelleTradizioni.cinese(nascitaDeiSegni).animale!;
  late final int? rashi = LaLetturaVedica.lunaDiNascita(nascitaDeiSegni)?.$1;

  /// Se la persona legge la tradizione [t]: la Vedica vuole la Luna di
  /// nascita, che senza l'ora si sa solo quando non cambia segno quel giorno.
  bool legge(TradizioneEu t) => t != TradizioneEu.vedica || rashi != null;

  String get nome => '${nascita.day}/${nascita.month}/${nascita.year} '
      '(${segno.italianName}${conCarta ? ', con la carta' : ', senza carta'})';

  NatalChart _carta() {
    final jd = Celestial.julianDay(nascita.toUtc());
    final pianeti = [
      for (final c in CorpoCeleste.values)
        () {
          final l = Effemeridi.longitudineEclittica(c, jd);
          return PlanetPosition(
              id: c.id,
              name: c.nome,
              glyph: c.glifo,
              longitude: l,
              sign: Zodiac.values[(l ~/ 30) % 12]);
        }(),
    ];
    return NatalChart(
      sunSign: pianeti.first.sign,
      planets: pianeti,
      ascendantLongitude: ascendente,
      midheavenLongitude: (ascendente + 270) % 360,
      houses: [
        for (var n = 1; n <= 12; n++)
          HouseCusp(
              number: n, longitude: (ascendente + (n - 1) * 30.0) % 360.0),
      ],
      hasTime: true,
    );
  }

  Map<HoroscopeDomain, bool> _tutte(bool lunga) =>
      {for (final d in HoroscopeDomain.values) d: lunga};

  /// Le quattro schede del Giorno nella tradizione [t].
  List<HoroscopeCard> giorno(TradizioneEu t, DateTime oggi,
      {bool lunga = true}) {
    switch (t) {
      case TradizioneEu.occidentale:
        final m = DateTime.utc(oggi.year, oggi.month, oggi.day, 12);
        return Horoscope.forSign(
            sign: segno,
            dayOfYear: Horoscope.dayOfYear(oggi),
            year: oggi.year,
            cielo: CieloDiOggi.perIlGiorno(adesso: m, carta: carta),
            nascita: nascita,
            profonde: _tutte(lunga));
      case TradizioneEu.vedica:
        return LaLetturaVedica.schede(
            adesso: DateTime(oggi.year, oggi.month, oggi.day, 12),
            nascita: nascitaDeiSegni,
            forma: CourtesyForm.unknown,
            approfondite: _tutte(lunga))!;
      case TradizioneEu.cinese:
        return LaLetturaCinese.schede(
            oggi: oggi,
            nascita: nascita,
            animale: animale,
            forma: CourtesyForm.unknown,
            approfondite: _tutte(lunga))!;
    }
  }

  /// La Settimana o il Mese nella tradizione [t].
  IlPeriodoDelCielo periodo(TradizioneEu t, DateTime oggi,
      {required bool mese}) {
    final giorni = mese ? 30 : 7;
    if (t == TradizioneEu.occidentale) {
      return LaSettimanaDelCielo.per(
          segno: segno,
          carta: carta,
          oggi: oggi,
          giorni: giorni,
          nascita: nascita);
    }
    return LaSettimanaDelCielo.dalleSchede(
        oggi: oggi,
        giorni: giorni,
        tradizione: t,
        scarto: ITestiEu.scarto(nascita),
        schedeDi: (g) => giorno(t, g, lunga: false))!;
  }

  /// Le quattro schede dell'Anno nella tradizione [t].
  List<HoroscopeCard> anno(TradizioneEu t, DateTime oggi, {bool lunga = true}) {
    final approfondite = lunga ? null : _tutte(false);
    switch (t) {
      case TradizioneEu.occidentale:
        final ritorno = LaRivoluzioneSolare.ritornoInCorso(
            nascita.toUtc(), DateTime(oggi.year, oggi.month, oggi.day, 12));
        return LAnnuale.schede(LaRivoluzioneSolare.tema(ritorno, 41.9, 12.5),
            nascita: nascita, approfondite: approfondite);
      case TradizioneEu.vedica:
        return LAnnoDelleTradizioni.schede(
            t, LAnnoDelleTradizioni.vedico(oggi, nascita, rashi!),
            scarto: ITestiEu.scarto(nascita), approfondite: approfondite);
      case TradizioneEu.cinese:
        return LAnnoDelleTradizioni.schede(
            t,
            LAnnoDelleTradizioni.cinese(oggi, animale,
                annoDiNascita: nascita.year)!,
            scarto: ITestiEu.scarto(nascita),
            approfondite: approfondite);
    }
  }
}

/// Dodici persone di segni diversi, sei con la carta e sei senza.
final List<PersonaDiProva> dodiciPersone = [
  for (var i = 0; i < 12; i++)
    PersonaDiProva(
      DateTime(1958 + i * 4, 1 + i, 4 + i * 2, 5 + i, 20),
      conCarta: i.isEven,
      ascendente: (i * 37.0) % 360,
    ),
];

/// Le frasi di un testo: si taglia dopo il punto, il punto esclamativo e
/// quello interrogativo, e ogni paragrafo e' a se'.
List<String> frasiDelTesto(String testo) => [
      for (final p in testo.split('\n\n'))
        for (final f in p.split(RegExp(r'(?<=[.!?])\s+')))
          if (f.trim().length > 12) f.trim(),
    ];

/// La voce del corpus da cui viene una scheda: cercata col titolo e il
/// testo, in ogni fascia. Null se non viene dal corpus.
(FasciaEu, int)? voceDellaScheda(TradizioneEu t, PeriodoEu p, HoroscopeDomain d,
    String titolo, String testo) {
  for (final f in FasciaEu.values) {
    final voci = ITestiEu.fascia(t, p, d, f);
    for (var i = 0; i < voci.length; i++) {
      final v = voci[i];
      if (v.titolo == titolo &&
          (testo == v.testo(lunga: false) || testo == v.testo(lunga: true))) {
        return (f, i);
      }
    }
  }
  return null;
}
