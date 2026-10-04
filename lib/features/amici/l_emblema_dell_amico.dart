import 'package:flutter/material.dart';

import '../../core/amici/amici_offline.dart';
import '../../core/cerchio/le_icone_del_cerchio.dart';
import '../cerchio/widgets/disegni_del_cerchio.dart';

/// **L'EMBLEMA DELL'AMICO SCRITTO, ordine FC voce 10, 5 ottobre 2026.**
///
/// Il fondatore: *"Emblema del segno zodiacale"*. Ogni amico scritto porta
/// nel tondo l'emblema del suo segno solare, ricavato dalla data di nascita
/// che la persona ha scritto, dalla porta sola del segno ([Amico.segno], che
/// chiama `IlSegnoDelCielo`). Le icone sono quelle dei segni della famiglia
/// del Cerchio: nessun asset nuovo.
///
/// **Il tondo e' quello del Cerchio** ([IconaTonda]), con gli stessi margini
/// interni dell'ordine EZ voce 01: l'emblema sta intero nel quadrato
/// inscritto e la cornice non lo taglia. **Mai un tondo nero**: finche'
/// l'immagine non c'e', la prima lettera del nome.
///
/// **L'emblema appartiene all'amico, non alla lista**: lo usano la rubrica,
/// il bottone dell'amico in "Oroscopo per", il titolo dell'oroscopo
/// dell'amico e il dialogo che lo toglie. L'elenco dei punti sta nel
/// rapporto dell'ordine FC.
class LEmblemaDellAmico extends StatelessWidget {
  const LEmblemaDellAmico({super.key, required this.amico, this.lato = 44});

  final Amico amico;
  final double lato;

  @override
  Widget build(BuildContext context) => IconaTonda(
        key: Key('emblema_amico_${amico.id}'),
        icona: IconaDelProfilo.delSegno(amico.segno),
        lato: lato,
        nome: amico.nome,
      );
}
