/// LO STILE DEL CIELO DEL REAL TIME COSMO. Ordine FG parte 2, voci 2.3-2.5.
///
/// Le regole del disegno stanno qui, come dati, e le leggono la scena e le
/// prove: nessun numero del colore o del raggio vive dentro il pittore.
library;

import 'dart:math' as math;
import 'dart:ui';

/// Il fondo del cielo, 9, 13, 32 (voce 2.5): il blu notte del riferimento
/// del fondatore (docs/collaudo/FG/catture_del_fondatore/).
const Color kFondoDelCielo = Color.fromARGB(255, 9, 13, 32);

/// Il colore di una stella dal suo indice di colore B-V, cinque fasce (voce
/// 2.3). `NaN`, cioe' il valore sentinella del catalogo, da' il bianco.
Color coloreDellaStella(double ci) {
  if (ci.isNaN) return const Color.fromARGB(255, 255, 255, 255);
  if (ci < 0.0) return const Color.fromARGB(255, 185, 212, 255);
  if (ci < 0.3) return const Color.fromARGB(255, 224, 234, 255);
  if (ci < 0.6) return const Color.fromARGB(255, 255, 251, 243);
  if (ci < 1.0) return const Color.fromARGB(255, 255, 236, 200);
  return const Color.fromARGB(255, 255, 200, 158);
}

/// Il raggio dello sprite di una stella in punti logici (voce 2.4): il
/// massimo fra 1,1 e (5,7 meno la magnitudine) alla 1,9, per 0,85. Lo sprite
/// porta l'alone dentro la texture, quindi il raggio e' quello dell'alone.
double raggioDellaStella(double magnitudine) {
  final base = 5.7 - magnitudine;
  final r = base > 0 ? math.pow(base, 1.9).toDouble() * 0.85 : 0.0;
  return math.max(1.1, r);
}

/// LA MAGNITUDINE LIMITE PER CAMPO VISIVO, cioe' quante stelle si accendono.
///
/// La densita' bersaglio a settanta gradi e' fra 158 e 218 punti luminosi a
/// schermo (voce 2.5, misurata sull'app di riferimento). Il catalogo arriva
/// alla sesta magnitudine, che a settanta gradi in verticale sul telefono
/// accenderebbe oltre mille stelle: un cielo da deserto, non quello che una
/// persona vede in citta' e nemmeno quello del riferimento. Per questo il
/// limite scende quando il campo si allarga e sale fino alla sesta quando si
/// stringe, come in un binocolo. I due capi sono tarati sulla densita'
/// misurata in tre inquadrature, in
/// `test/real_time_cosmo_la_densita_del_cielo_test.dart`. Il primo capo largo
/// provato era 4,15, e la misura l'ha bocciato: 145, 149 e 151 punti, sotto
/// il bersaglio. Con 4,55 erano 191, 194 e 211 (limite a settanta gradi 5,08).
/// Dall'ordine FH parte 11 le stelle basse perdono luce con l'estinzione, e
/// con 4,55 i punti sono scesi a 143, 143 e 176: ritarato su 4,75, che da'
/// 170, 169 e 210 (con 4,85 il nord sale a 228, fuori dal bersaglio).
const double kLimiteCampoStretto = 6.0;
const double kLimiteCampoLargo = 4.75;

/// La magnitudine limite al campo [campoGradi] (fra 18 e 100), lineare fra i
/// due capi.
double magnitudineLimite(double campoGradi) {
  final c = campoGradi.clamp(18.0, 100.0);
  final t = (c - 18.0) / (100.0 - 18.0);
  return kLimiteCampoStretto + (kLimiteCampoLargo - kLimiteCampoStretto) * t;
}

/// Le stelle a meno di questa distanza dal limite non si accendono di colpo:
/// salgono di luce, cosi' il pizzico non fa scattare le stelle.
const double kSfumaturaDelLimite = 0.6;

/// La luce di una stella da 0 a 1, data la magnitudine e il limite.
double luceDellaStella(double magnitudine, double limite) {
  if (magnitudine > limite) return 0;
  final d = limite - magnitudine;
  if (d >= kSfumaturaDelLimite) return 1;
  return d / kSfumaturaDelLimite;
}

/// L'ARIA FRA NOI E LE STELLE (ordine FH parte 11).
///
/// **L'estinzione (voce 11.1).** Vicino all'orizzonte la luce di una stella
/// attraversa piu' aria: la magnitudine apparente cresce di 0,28 per la massa
/// d'aria meno uno. La massa d'aria e' uno diviso il seno dell'altezza,
/// limitata a [kMassaDAriaMassima] verso l'orizzonte. Sotto l'orizzonte, dove
/// il cielo si vede attraverso il velo del terreno, la legge si legge allo
/// specchio, cosi' sulla linea dell'orizzonte non c'e' un gradino.
const double kCoefficienteDiEstinzione = 0.28;
const double kMassaDAriaMassima = 38;

/// Di quante magnitudini si indebolisce una stella col seno dell'altezza [z].
double estinzione(double z) {
  final s = z.abs();
  final massa = s <= 1 / kMassaDAriaMassima ? kMassaDAriaMassima : 1 / s;
  return kCoefficienteDiEstinzione * (massa - 1);
}

/// L'ambra verso cui scivola il colore di una stella bassa.
const Color kAmbraDellOrizzonte = Color.fromARGB(255, 255, 178, 110);

/// Quanto del colore e' ambra, con la stessa legge (voce 11.1): niente in
/// alto, la meta' a tre magnitudini di estinzione (circa sei gradi), quasi
/// tutto verso l'orizzonte.
double ambraDellaStella(double estinzioneInMagnitudini) {
  final e = estinzioneInMagnitudini <= 0 ? 0.0 : estinzioneInMagnitudini;
  return e / (e + 3);
}

/// LO SCINTILLIO (voce 11.2): solo sotto [kAltezzaDelloScintillio] gradi,
/// appena percepibile li' e pieno a due gradi. Restituisce l'ampiezza
/// dell'oscillazione della luce, da 0 a [kScintillioMassimo].
const double kAltezzaDelloScintillio = 20;
const double kScintillioMassimo = 0.45;

double ampiezzaDelloScintillio(double altezzaGradi) {
  if (altezzaGradi >= kAltezzaDelloScintillio || altezzaGradi <= -90) return 0;
  final a = altezzaGradi.abs();
  if (a <= 2) return kScintillioMassimo;
  if (a >= kAltezzaDelloScintillio) return 0;
  final t = (kAltezzaDelloScintillio - a) / (kAltezzaDelloScintillio - 2);
  return kScintillioMassimo * t * t;
}

/// L'ALONE DELL'ARIA (voce 11.3): il fondo schiarisce appena verso
/// l'orizzonte e si spegne a [kAltezzaDellAlone] gradi.
const double kAltezzaDellAlone = 15;
const Color kColoreDellAlone = Color.fromARGB(255, 46, 58, 96);
const double kLuceDellAloneAllOrizzonte = 0.55;

/// Sotto l'orizzonte il cielo si disegna INTERO (ordine FH voce 7.3): lo
/// smorza il velo del terreno, con la sua opacita', e non un'attenuazione
/// stella per stella. Fino all'ordine FG valeva 0,32 e il terreno non c'era.
const double kLuceSottoLOrizzonte = 1.0;
