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

  /// IL MINIMO DEL TITOLO DI UNA BARRA.
  ///
  /// Quattordici punti: sta sopra il pavimento assoluto dell'app, che vale dodici,
  /// e sopra il minimo della famiglia delle etichette, che vale undici. Sotto
  /// questa misura un titolo di barra non e' piu' un titolo, e allora il problema
  /// non e' la tipografia ma il nome, e il nome e' materiale di Mauro.
  static const double minimo = TypographyTokens.pavimento + 2;

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
    for (var misura = base; misura >= minimo; misura -= 0.5) {
      final scala = stile.copyWith(fontSize: misura);
      if (_larghezza(parolaPiuLunga, scala, textScaler) > larghezza) continue;
      final pittore = TextPainter(
        text: TextSpan(text: testo, style: scala),
        textDirection: TextDirection.ltr,
        maxLines: righe,
        textScaler: TextScaler.linear(textScaler),
      )..layout(maxWidth: larghezza);
      if (!pittore.didExceedMaxLines) return misura;
    }
    return minimo;
  }

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
