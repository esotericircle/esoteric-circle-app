import 'package:flutter/material.dart';

import '../../../../core/face/mian_xiang.dart';

/// **I CINQUE ELEMENTI HANNO UN COLORE, E VINCE SULLA SCENA.**
/// Ordine CR voce 09, 6 settembre 2026.
///
/// **Parole dell'ordine**: *"Le zone del volto si colorano secondo l'elemento
/// dominante misurato, e il colore vince sulla scena"*.
///
/// **I COLORI NON SONO SCELTI A GUSTO.** Nella tradizione dei cinque elementi
/// ogni fase ha il suo colore, ed e' una corrispondenza vecchia quanto la
/// materia: Legno verde, Fuoco rosso, Terra giallo, Metallo bianco, Acqua nero.
/// Qui si usano quelli, portati alla luminosita' che serve per accendersi
/// sopra un fondo scuro: **il nero dell'Acqua diventa il blu profondo che il
/// nero e' sempre stato nella pittura cinese**, perche' un nero su fondo scuro
/// non e' un colore, e' un buco.
///
/// **PERCHE' STA NELLA FEATURE E NON NEI TOKEN DEL DESIGN SYSTEM.** Questi
/// cinque colori non appartengono al Maestro ne' al tema: appartengono a una
/// tradizione, e valgono soltanto dentro questa funzione. Metterli fra i token
/// di sistema li renderebbe disponibili ovunque, e il primo che li usasse per
/// un pulsante avrebbe scritto un colore rituale in un posto che non lo e'.
///
/// **IL COLORE NON SOSTITUISCE IL NOME.** L'elemento si legge sempre anche
/// scritto: chi non distingue i colori non deve perdere la lettura, e un
/// responso affidato a una tinta sarebbe un responso che una persona su dodici
/// non riceve.
class ColoreDellElemento {
  const ColoreDellElemento._();

  static const Map<ElementoDelVolto, Color> _colori = {
    // Legno: il verde della crescita.
    ElementoDelVolto.legno: Color(0xFF3FBF7F),
    // Fuoco: il rosso, portato a un vermiglio che non spegne il testo sopra.
    ElementoDelVolto.fuoco: Color(0xFFE8523F),
    // Terra: il giallo ocra, il colore della terra del fiume Giallo.
    ElementoDelVolto.terra: Color(0xFFE0A93B),
    // Metallo: il bianco, appena freddo, perche' un bianco puro su fondo
    // scuro abbaglia e non si legge come un colore.
    ElementoDelVolto.metallo: Color(0xFFDCE3EA),
    // Acqua: il nero della tradizione, che su fondo scuro diventa il blu
    // profondo con cui la pittura cinese lo ha sempre reso.
    ElementoDelVolto.acqua: Color(0xFF3E7BD6),
  };

  /// Il colore dell'elemento. **Ogni elemento ne ha uno**: un elemento senza
  /// colore tornerebbe un valore di ripiego, e un ripiego silenzioso e' cio'
  /// che questo ordine nasce per togliere.
  static Color di(ElementoDelVolto e) => _colori[e]!;

  /// Tutti i colori, per chi deve controllarli tutti insieme.
  static Map<ElementoDelVolto, Color> get tutti => Map.unmodifiable(_colori);
}
