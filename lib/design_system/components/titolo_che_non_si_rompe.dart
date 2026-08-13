import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/typography_tokens.dart';


/// UN TITOLO CHE VA A CAPO FRA LE PAROLE, NON DENTRO UNA PAROLA.
///
/// **Il difetto, visto nell'anteprima della voce S.05.** Il titolo della barra
/// del sentiero si leggeva "Costellazio ne persona...": non e' un titolo su due
/// righe, e' un titolo ROTTO, e si legge come una schermata non finita. Prima
/// ancora si leggeva "Costellazione pers...", cioe' troncato coi puntini, ed e'
/// gia' costato una voce nell'ordine P.
///
/// **Il nome non si accorcia.** "Costellazione personale" vive nel briefing, nel
/// Cosmic Passport e nella schermata: cambiarlo qui creerebbe due nomi per la
/// stessa cosa, che e' la famiglia delle due porte. Quindi si adatta la MISURA
/// del testo, non il testo.
///
/// **La regola, in quest'ordine.**
///
///   1. si va a capo fra le parole, mai dentro una parola;
///   2. se la parola piu' lunga non entra nella larghezza disponibile, il titolo
///      si rimpicciolisce fino a entrare, entro un minimo dichiarato che rispetta
///      il pavimento tipografico dell'app;
///   3. non si tronca e non si mettono i puntini.
///
/// **Perche' basta guardare la parola piu' lunga.** Un motore di testo spezza una
/// parola solo quando quella parola, da sola, non sta in una riga. Se la piu'
/// lunga entra, nessuna si spezza: la condizione da cercare e' una, e non serve
/// ispezionare le righe rese.
class TitoloCheNonSiRompe extends StatelessWidget {
  const TitoloCheNonSiRompe({
    super.key,
    required this.testo,
    required this.stile,
    this.righe = 2,
    this.chiaveDelTesto,
  });

  final String testo;

  /// Lo stile del ruolo, da cui si parte: la misura puo' solo SCENDERE.
  final TextStyle stile;

  /// Quante righe il titolo puo' occupare.
  final int righe;

  /// LA CHIAVE DEL TESTO, e non del componente.
  ///
  /// Alcune prove cercano il titolo di una barra per chiave e ne leggono il
  /// `Text`: dando quella chiave al componente troverebbero questo widget e non
  /// il testo, quindi il titolo si porta dietro la sua chiave e la mette dove
  /// stava prima, sul `Text`.
  final Key? chiaveDelTesto;

  /// IL MINIMO PREFERITO DEL TITOLO DI UNA BARRA.
  ///
  /// Quattordici punti: sta sopra il pavimento assoluto dell'app, che vale dodici,
  /// e sopra il minimo della famiglia delle etichette, che vale undici. Sotto
  /// questa misura un titolo di barra comincia a non sembrare piu' un titolo.
  static const double minimo = TypographyTokens.pavimento + 2;

  /// IL PAVIMENTO ASSOLUTO, e serve per un caso che si e' visto DAVVERO.
  ///
  /// **Il difetto, nell'anteprima delle rune.** Con tre azioni a destra (le fonti,
  /// il borsellino e il cuore) al titolo restano circa novanta punti, e a
  /// quattordici la parola "Estrazione" ne chiede novantacinque: il motore di
  /// testo ha fatto l'unica cosa che sapeva fare, l'ha spezzata, e si leggeva
  /// "Estrazion / e Rune". Un titolo rotto, esattamente cio' che la regola vieta.
  ///
  /// **La regola di Mauro ha un ordine, e l'ordine decide qui.** Prima viene "a
  /// capo fra le parole, mai dentro una parola"; poi "la misura scende fino a
  /// entrare, entro un minimo dichiarato". Quando i due si scontrano vince il
  /// primo, quindi la misura scende di altri due punti fino al pavimento
  /// dell'app: dodici. Non un punto sotto, perche' quello e' il pavimento di
  /// TUTTO il testo dell'app e non lo si tocca per un titolo.
  static const double pavimentoAssoluto = TypographyTokens.pavimento;

  /// LA MISURA A CUI IL TITOLO ENTRA SENZA ROMPERSI.
  ///
  /// Funzione pura, e per questo la prova la interroga direttamente invece di
  /// dedurre la misura dai pixel: si scende di mezzo punto alla volta dalla
  /// misura del ruolo fino al [minimo].
  static double misuraChePermetteDiLeggere({
    required String testo,
    required TextStyle stile,
    required double larghezza,
    int righe = 2,
    double textScaler = 1.0,
  }) {
    final base = stile.fontSize ?? 18;
    final parolaPiuLunga = testo
        .split(RegExp(r'\s+'))
        .fold<String>('', (a, b) => b.length > a.length ? b : a);
    // PRIMO GIRO: fino al minimo preferito, cercando la misura che tiene il
    // titolo intero dentro le righe concesse.
    for (var misura = base; misura >= minimo; misura -= 0.5) {
      final scala = stile.copyWith(fontSize: misura);
      if (_larghezza(parolaPiuLunga, scala, textScaler) >
          larghezza - margineDellaScatola) {
        continue;
      }
      final pittore = TextPainter(
        text: TextSpan(text: testo, style: scala),
        textDirection: TextDirection.ltr,
        maxLines: righe,
        textScaler: TextScaler.linear(textScaler),
      )..layout(maxWidth: larghezza);
      if (!pittore.didExceedMaxLines) return misura;
    }
    // SECONDO GIRO: la parola piu' lunga non entra nemmeno al minimo preferito, e
    // allora comanda la prima regola, quella che vieta di spezzare una parola. Si
    // scende fino al pavimento dell'app, e non oltre.
    for (var misura = minimo - 0.5;
        misura >= pavimentoAssoluto;
        misura -= 0.5) {
      final scala = stile.copyWith(fontSize: misura);
      if (_larghezza(parolaPiuLunga, scala, textScaler) <=
          larghezza - margineDellaScatola) {
        return misura;
      }
    }
    return pavimentoAssoluto;
  }

  /// IL MARGINE FRA LA SCATOLA MISURATA E QUELLA DIPINTA.
  ///
  /// **Quattro punti, e non e' una precauzione generica.** Nell'anteprima delle
  /// rune il titolo si spezzava mentre la misura diceva che entrava: la parola
  /// "Estrazione" chiedeva 90,8 punti in una scatola di 92,7, cioe' entrava per
  /// meno di due. Una scatola calcolata durante il layout e una dipinta a tre
  /// pixel per punto non coincidono al decimo, e un titolo che entra per due punti
  /// e' un titolo che si spezza sull'anteprima e sul telefono. Il margine si prende
  /// prima, e la misura scende di mezzo punto.
  static const double margineDellaScatola = 4;

  static double _larghezza(String parola, TextStyle stile, double scaler) {
    final pittore = TextPainter(
      text: TextSpan(text: parola, style: stile),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.linear(scaler),
    )..layout();
    return pittore.width;
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling;
    return LayoutBuilder(builder: (context, vincoli) {
      // Senza una larghezza finita non c'e' niente da adattare: si dipinge col
      // ruolo, che e' cio' che si vuole nel caso normale.
      final larghezza = vincoli.maxWidth.isFinite
          ? vincoli.maxWidth
          : MediaQuery.sizeOf(context).width;
      final misura = misuraChePermetteDiLeggere(
        testo: testo,
        stile: stile,
        larghezza: math.max(1, larghezza),
        righe: righe,
        textScaler: scaler.scale(1),
      );
      return Text(
        testo,
        key: chiaveDelTesto,
        maxLines: righe,
        // **SOFTWRAP DICHIARATO, e questo era il difetto vero.** L'AppBar avvolge
        // il titolo in un `DefaultTextStyle` con `softWrap: false`: un `Text` che
        // non lo dichiara EREDITA quel no, resta su una riga sola e, con
        // `overflow: visible`, dipinge fuori dalla propria scatola passando sopra
        // le azioni. Nell'anteprima si vedeva "Costellazione personale" sopra
        // l'icona degli Eos e il cuore, e nessuna misura sulle righe poteva
        // accorgersene, perche' una riga non supera mai il tetto di due.
        softWrap: true,
        // **NIENTE PUNTINI.** Se il titolo non entrasse comunque, si vede che non
        // entra: un'ellissi nasconde il difetto invece di mostrarlo, ed e' il
        // modo in cui "Costellazione pers..." e' vissuto per settimane.
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
        style: stile.copyWith(fontSize: misura),
      );
    });
  }
}
