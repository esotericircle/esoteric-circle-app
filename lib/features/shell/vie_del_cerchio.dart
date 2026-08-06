import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/icona_del_cerchio.dart';

/// LE VIE DEL CERCHIO, DICHIARATE UNA VOLTA SOLA.
///
/// **Perche' esiste questo file.** Le destinazioni ancorate dell'app si
/// mostrano su DUE superfici: la barra del guscio, nel Santuario e nel
/// Passport, e la striscia Esplora, dove quella barra non c'e'. Erano due
/// elenchi scritti a mano, e hanno fatto quel che fanno sempre due elenchi
/// scritti a mano: sono divergiuti. Misurato il 6 agosto 2026 leggendo cio' che
/// arriva a video, non i sorgenti: la barra diceva `[Il Cerchio, Medora,
/// Caligo, Aura, Passport]` e Esplora `[Il Cerchio, Medora, Caligo, Aura]`. E
/// non era solo il numero: la voce del Cerchio portava la mezzaluna dentro il
/// cerchio nella barra e una mezzaluna di sistema in Esplora, cioe' la stessa
/// via con due volti.
///
/// **Le cinque vie compaiono su tutte e due le superfici, Passport compreso.**
/// La strada alternativa era tenerlo fuori da Esplora perche' e' una vista del
/// guscio, ma quella ragione non regge dove Esplora vive: nelle chat e nei
/// domini la barra del guscio non c'e' affatto, quindi lasciarlo fuori vorrebbe
/// dire che da una chat il Passport costa due passi mentre ogni altra
/// destinazione ne costa uno, cioe' proprio la strada lunga per cui Esplora e'
/// nata. Se un giorno si decidesse il contrario, la si toglie da qui, in un
/// punto solo, con la ragione accanto.
///
/// **I tre Maestri non si scrivono:** vengono da `Maestro.fixedOrder`, che e'
/// gia' la loro fonte e il loro ordine. Un quarto Maestro entrerebbe nelle due
/// superfici da solo.
enum SpecieDiVia { cerchio, maestro, passport }

@immutable
class ViaDelCerchio {
  const ViaDelCerchio._(this.specie, [this.maestro]);

  final SpecieDiVia specie;

  /// Il Maestro, quando la via e' un dominio. Nullo per il Cerchio e per il
  /// Passport.
  final Maestro? maestro;

  /// Le cinque vie, nell'ordine in cui si leggono da sinistra a destra.
  static final List<ViaDelCerchio> tutte = List<ViaDelCerchio>.unmodifiable([
    const ViaDelCerchio._(SpecieDiVia.cerchio),
    for (final m in Maestro.fixedOrder)
      ViaDelCerchio._(SpecieDiVia.maestro, m),
    const ViaDelCerchio._(SpecieDiVia.passport),
  ]);

  /// L'identificativo stabile, che entra nelle chiavi delle due superfici.
  String get id => switch (specie) {
        SpecieDiVia.cerchio => 'cerchio',
        SpecieDiVia.maestro => maestro!.id,
        SpecieDiVia.passport => 'passport',
      };

  /// Il nome a video. Passa dalle stringhe dell'app, non da una costante
  /// scritta qui: e' testo che la persona legge, quindi e' materia di i18n.
  String get etichetta => switch (specie) {
        SpecieDiVia.cerchio => AppStrings.navSantuario,
        SpecieDiVia.maestro => maestro!.displayName,
        SpecieDiVia.passport => AppStrings.navPassport,
      };

  /// Il disegno della via, con colore e lato decisi da chi la mostra: la
  /// dimensione ottica e lo stato acceso appartengono alla superficie, il
  /// SEGNO appartiene alla via.
  ///
  /// Non e' un `IconData` perche' la voce del Cerchio non esiste fra le icone
  /// di Material: e' una falce dentro un anello, e va disegnata.
  Widget icona(Color colore, double lato) {
    final chiave = Key('via_icona_$id');
    return switch (specie) {
      SpecieDiVia.cerchio =>
        IconaDelCerchio(key: chiave, colore: colore, dimensione: lato),
      SpecieDiVia.maestro =>
        Icon(maestro!.icon, key: chiave, color: colore, size: lato),
      SpecieDiVia.passport =>
        Icon(Icons.badge_outlined, key: chiave, color: colore, size: lato),
    };
  }
}
