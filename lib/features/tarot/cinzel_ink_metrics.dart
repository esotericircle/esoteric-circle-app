// GENERATO, non modificare a mano.
//
// Prodotto disegnando ogni glifo con lo stesso stile dei cartigli (Cinzel, peso
// e interlinea di `cartiglioBaseStyle`, senza l'ombra che allargherebbe il
// segno) e contando i pixel davvero accesi.
//
// `top` e `bottom` sono relativi alla linea di base restituita da
// `computeDistanceToActualBaseline`, `left` e `right` sono i fianchi vuoti che
// il glifo lascia dentro il proprio passo di avanzamento. Tutto e' normalizzato
// alla dimensione del font.
//
// Misurato dal rasterizzatore vero e non da uno esterno, perche' fra i due c'e'
// uno scarto sistematico di qualche centesimo: con la tavola sbagliata il
// numero restava fuori centro di mezzo pixel.
//
// Serve perche' le metriche di un font descrivono la riga e il passo, non
// l'inchiostro: la riga comprende ascendenti e discendenti che in un testo tutto
// maiuscolo restano vuoti, e il passo comprende i fianchi. Misurando su quelle,
// il testo appare spinto in alto e non arriva mai al bordo del suo spazio.

/// I limiti dell'inchiostro di ogni glifo usato nei cartigli.
const Map<String, ({double top, double bottom, double left, double right})>
    kCinzelInk = {
  '0': (top: -0.67858, bottom: 0.05189, left: 0.05078, right: 0.05197),
  '1': (top: -0.67858, bottom: 0.03626, left: 0.04688, right: 0.04787),
  '2': (top: -0.67858, bottom: 0.03626, left: 0.04688, right: 0.03250),
  '3': (top: -0.67858, bottom: 0.08704, left: 0.04688, right: 0.05472),
  '4': (top: -0.67858, bottom: 0.03626, left: 0.01563, right: 0.04059),
  '5': (top: -0.69811, bottom: 0.08314, left: 0.03125, right: 0.06334),
  '6': (top: -0.69811, bottom: 0.05189, left: 0.05469, right: 0.04841),
  '7': (top: -0.66686, bottom: 0.03626, left: 0.02344, right: 0.02609),
  '8': (top: -0.67858, bottom: 0.05189, left: 0.04297, right: 0.04303),
  '9': (top: -0.67858, bottom: 0.07533, left: 0.04688, right: 0.05231),
  'A': (top: -0.68249, bottom: 0.03626, left: 0.00000, right: -0.00375),
  'B': (top: -0.66686, bottom: 0.03626, left: 0.04688, right: 0.03562),
  'C': (top: -0.67858, bottom: 0.05189, left: 0.04688, right: 0.05034),
  'D': (top: -0.66686, bottom: 0.03626, left: 0.04688, right: 0.03975),
  'E': (top: -0.68249, bottom: 0.03626, left: 0.04688, right: 0.03097),
  'F': (top: -0.68249, bottom: 0.03626, left: 0.04688, right: 0.05356),
  'G': (top: -0.67858, bottom: 0.05189, left: 0.04688, right: 0.01831),
  'H': (top: -0.66686, bottom: 0.03626, left: 0.04688, right: 0.04813),
  'I': (top: -0.66686, bottom: 0.03626, left: 0.04688, right: 0.04578),
  'J': (top: -0.66686, bottom: 0.23939, left: 0.00781, right: 0.03588),
  'K': (top: -0.66686, bottom: 0.03626, left: 0.04688, right: -0.00256),
  'L': (top: -0.66686, bottom: 0.03626, left: 0.04688, right: 0.01597),
  'M': (top: -0.67858, bottom: 0.05579, left: 0.00000, right: -0.00322),
  'N': (top: -0.67858, bottom: 0.05189, left: 0.03516, right: 0.03278),
  'O': (top: -0.67858, bottom: 0.05189, left: 0.05469, right: 0.04469),
  'P': (top: -0.66686, bottom: 0.03626, left: 0.04688, right: 0.03625),
  'Q': (top: -0.67858, bottom: 0.26283, left: 0.05078, right: -0.00019),
  'R': (top: -0.66686, bottom: 0.03626, left: 0.04688, right: -0.00256),
  'S': (top: -0.67858, bottom: 0.05189, left: 0.05078, right: 0.04791),
  'T': (top: -0.68249, bottom: 0.03626, left: 0.01563, right: 0.01328),
  'U': (top: -0.66686, bottom: 0.05189, left: 0.03906, right: 0.03556),
  'V': (top: -0.66686, bottom: 0.05579, left: 0.00000, right: -0.00238),
  'W': (top: -0.68249, bottom: 0.05189, left: 0.00000, right: -0.00156),
  'X': (top: -0.66686, bottom: 0.03626, left: 0.00000, right: -0.00003),
  'Y': (top: -0.66686, bottom: 0.03626, left: 0.00000, right: -0.00241),
  'Z': (top: -0.68249, bottom: 0.03626, left: 0.04688, right: 0.02909),
  "'": (top: -0.67858, bottom: -0.46374, left: 0.03125, right: 0.03766),
};
