import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../archetypes/archetype_history.dart';
import '../arts/arti_preferite.dart';
import '../astro/natal_chart_controller.dart';
import '../astro/zodiac_controller.dart';
import '../entitlement/entitlement_service.dart';
import '../entitlement/question_allowance.dart';
import '../synastry/collezione_delle_coppie.dart';
import '../entitlement/registro_degli_eos.dart';
import '../onboarding/onboarding_controller.dart';
import '../rituals/scelta_degli_avvisi.dart';
import '../sigilli/coda_delle_feste.dart';
import '../sigilli/diario_del_cammino.dart';
import '../ricordi/registro_dei_ricordi.dart';
import '../ricordi/scrigno_dei_custoditi.dart';
import 'identity_controller.dart';
import 'natal_identity.dart';
import 'profile_controller.dart';
import '../../features/santuario/greeting_controller.dart';

/// COSA L'APP DIMENTICA IN MEMORIA QUANDO QUALCUNO SE NE VA.
/// Ordine BC voce 02.
///
/// **Il fatto del fondatore**: "ho provato a cancellare l'account, ma i dati
/// restano. Se uno cancella l'account, tutti i dati devono essere cancellati,
/// mentre il borsellino, i traguardi e altri dati attualmente restano anche
/// dopo la conferma della cancellazione."
///
/// **LA CAUSA, e non era quella scritta nell'ordine.** L'ordine diceva che la
/// cancellazione "esegue solo `memory.deleteAllData()`": non e' piu' vero
/// dalla build 2195, perche' l'ordine AZ voce 08 le aveva gia' aggiunto la
/// dimenticanza del disco e l'uscita. **Il buco era un terzo posto, che
/// nessuno guardava**: i controller vivono per tutta la sessione dell'app, e
/// nessuno li svuotava. Quello che il fondatore vedeva a schermo era la
/// memoria, non il disco; e alla prima scrittura quella memoria tornava anche
/// sul disco appena pulito.
///
/// **Esisteva una mezza cura, e serviva a un'altra cosa.** L'ordine AZ voce 15
/// aveva scritto `_dimenticaLaMemoriaViva` dentro la schermata dell'account,
/// che svuotava due controller su undici, **ed era chiamata solo dall'uscita e
/// mai dalla cancellazione**: uscire puliva piu' di cancellare.
///
/// **PERCHE' STA QUI E NON NELLA SCHERMATA.** Perche' un elenco che vive
/// dentro un widget lo vede solo chi apre quel widget, e domani chi aggiunge
/// un controller nuovo non passa di li'. Qui c'e' l'elenco completo, e la
/// prova `test/cancellare_dimentica_tutto_test.dart` **enumera i provider
/// dichiarati in `app.dart`** e cade se ne compare uno che tiene dati di una
/// persona e non e' in questa lista.
class DimenticanzaDellaMemoriaViva {
  const DimenticanzaDellaMemoriaViva._();

  /// **I CONTROLLER CHE NON TENGONO DATI DI NESSUNO**, e per questo non si
  /// svuotano. Sono qui a nome perche' la prova che enumera i provider possa
  /// distinguerli dai dimenticati: senza questo elenco, ogni controller nuovo
  /// farebbe cadere la prova anche quando non c'entra niente.
  ///
  /// - `MaestroController`: quale Maestro e' al centro del carosello adesso.
  /// - `ParallaxController`: quanto e' inclinato il telefono in questo istante.
  /// - `QualityTierController`: quanto e' potente questo telefono.
  ///
  /// Tutti e tre descrivono **il telefono o la scena**, non la persona.
  /// - `SettingsController`: movimento ridotto, sottotitoli, suono. **E' la
  ///   stessa ragione per cui il prefisso `settings.` non si cancella dal
  ///   disco**: buttarlo vorrebbe dire punire chi se ne va, e rimettere a mano
  ///   un'accessibilita' che qualcuno aveva scelto per necessita'.
  /// - `AccountDelCerchio`: **NON tiene niente di suo, e va detto perche' la
  ///   guardia lo ha scoperto solo il 31 agosto 2026.** Il suo stato lo
  ///   RICALCOLA a ogni `rileggi()` chiedendolo alla porta dell'autenticazione,
  ///   e la cancellazione chiama `rileggi()` subito dopo: svuotarlo qui non
  ///   toglierebbe niente, perche' un istante dopo tornerebbe a leggere la
  ///   stessa verita' dal fornitore. **La ragione era vera e non era scritta**,
  ///   e la guardia non poteva vederlo perche' il suo RegExp cercava
  ///   `=> Classe()` e questo provider nasce con un argomento.
  static const impersonali = <String>[
    'MaestroController',
    'ParallaxController',
    'QualityTierController',
    'SettingsController',
    'AccountDelCerchio',
  ];

  /// Svuota tutto cio' che l'app tiene in mano di una persona.
  ///
  /// **Ognuno dietro il suo try, e non e' pigrizia**: le prove e le anteprime
  /// montano schermate con una parte sola dei provider, e una dimenticanza che
  /// si rompesse a meta' lascerebbe la memoria peggio di come l'ha trovata.
  /// Torna quanti ne ha svuotati davvero, cosi' una prova puo' contarli invece
  /// di crederci.
  static int dimentica(BuildContext context) {
    var quanti = 0;
    void prova(void Function() cosa) {
      try {
        cosa();
        quanti++;
      } catch (senzaQuelProvider) {
        // Chi non c'e' nell'albero non ha niente da dimenticare.
      }
    }

    prova(() => context.read<QuestionAllowance>().dimenticaChiSeNeVa());
    // ORDINE BO VOCE 13: le coppie scoperte dicono chi ha guardato e quando.
    prova(() => context.read<CollezioneDelleCoppie>().dimenticaChiSeNeVa());
    prova(() => context.read<BirthIdentityController>().clear());
    prova(() => context.read<DiarioDelCammino>().dimenticaChiSeNeVa());
    // ORDINE BX VOCE 11: i sogni annotati sono la memoria piu' privata
    // che l'app custodisca, e non fanno eccezione.
    prova(() => context.read<CodaDelleFeste>().dimenticaChiSeNeVa());
    prova(() => context.read<RegistroDegliEos>().dimenticaChiSeNeVa());
    prova(() => context.read<ZodiacController>().dimenticaChiSeNeVa());
    prova(() => context.read<EntitlementService>().dimenticaChiSeNeVa());
    prova(() => context.read<ProfileController>().dimenticaChiSeNeVa());
    prova(() => context.read<SceltaDegliAvvisi>().dimenticaLeScelte());
    prova(() => context.read<NatalChartController>().reset());
    prova(() => context.read<IdentityController>().dimenticaChiSeNeVa());
    // **QUESTI CINQUE LI HA TROVATI LA PROVA, non l'occhio.** Enumerando i
    // provider dichiarati in `app.dart` sono usciti cinque controller che
    // nessuno aveva contato, e quattro di loro tenevano dati di una persona:
    // l'archetipo scoperto, il saluto dei Maestri, le arti preferite e il
    // fatto stesso di aver gia' fatto l'onboarding.
    prova(() => context.read<ArchetypeHistory>().dimenticaChiSeNeVa());
    prova(() => context.read<GreetingController>().dimenticaChiSeNeVa());
    prova(() => context.read<ArtiPreferiteController>().dimenticaChiSeNeVa());
    prova(() => context.read<OnboardingController>().dimenticaChiSeNeVa());
    // **I RICORDI DEL CERCHIO, ordine CG voci 03 e 06.** L'indice porta le
    // righe magre di tutto cio' che la persona ha fatto, lo scrigno i responsi
    // che ha dichiarato di voler tenere: sono la memoria piu' completa che
    // l'app abbia mai avuto di qualcuno, e se ne vanno con lei.
    prova(() => context.read<RegistroDeiRicordi>().dimentica());
    prova(() => context.read<ScrignoDeiCustoditi>().dimentica());
    return quanti;
  }
}
