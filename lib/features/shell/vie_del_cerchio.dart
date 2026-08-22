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

/// LA DESTINAZIONE CHE UNA ROTTA DI DOMINIO DICHIARA DI ESSERE.
///
/// **Perche' esiste, e perche' il nome non basta.** La regola contro il
/// doppione confrontava il NOME della classe della schermata, `'DomainScreen'`,
/// letto dall'albero: cosi' il dominio di Medora e quello di Caligo risultavano
/// LA STESSA schermata, e toccare Caligo dalla stanza di Medora tornava sulla
/// stanza di Medora ripitturata di rosso. Visto sul telefono il 7 agosto 2026:
/// il colore cambiava, il dominio no. Il 6 agosto era gia' stata scritta la
/// decisione che l'osservatore riconosce il tipo e non un nome, perche' un nome
/// e' una stringa che chiunque puo' scrivere diversa: ma nemmeno il TIPO basta,
/// perche' un tipo solo veste tre stanze diverse. Cio' che identifica una
/// stanza e' la DESTINAZIONE, cioe' la rotta PIU' il suo argomento.
///
/// La dichiara la fabbrica della rotta, `DomainScreen.route`, dentro
/// `RouteSettings.arguments`: cosi' ogni porta che apre un dominio, la barra,
/// il Santuario, il guscio, la dichiara senza saperlo, perche' passano tutte
/// da quella fabbrica. E' un valore tipizzato e non una stringa, quindi non
/// esiste il modo di scriverlo "quasi uguale".
/// **LE PORTE CHE NON HANNO UN ARGOMENTO.** Ordine AU voce 10.
///
/// `DestinazioneDominio` esisteva gia' e funziona, perche' un dominio porta il
/// suo Maestro. Il menu' utente e il Calendario invece non hanno argomenti, e
/// per questo nessuno gli aveva dato una destinazione: **si aprivano con un
/// `push` diretto**, e ogni tocco impilava una rotta nuova sopra quella
/// identica gia' aperta. Il fondatore l'ha misurato: dieci aperture del menu'
/// utente, dieci tocchi su indietro per tornare al principio.
///
/// Un valore tipizzato e non una stringa, per la stessa ragione scritta sopra:
/// una stringa la si puo' scrivere "quasi uguale".
enum PortaDelCerchio {
  /// Il menu' utente in alto a sinistra.
  account,

  /// Il Calendario degli Eventi, dal centro della barra sottile.
  calendario;
}

@immutable
class DestinazioneDominio {
  const DestinazioneDominio(this.maestro);

  final Maestro maestro;

  @override
  bool operator ==(Object other) =>
      other is DestinazioneDominio && other.maestro == maestro;

  @override
  int get hashCode => maestro.hashCode;

  @override
  String toString() => 'DestinazioneDominio(${maestro.id})';
}

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
