import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../services/avvisi_locali.dart';
import '../maestro/maestro.dart';
import '../permissions/app_permission.dart';
import '../permissions/esito_del_permesso.dart';
import '../../services/regia_delle_chiamate.dart';
import 'avvisi_del_rito.dart';

/// LA VOLTA IN CUI IL PERMESSO SI CHIEDE DAVVERO. Ordine BZ voce 04.
///
/// **Il fatto del fondatore, che ha aperto la voce:** "LE NOTIFICHE NON
/// FUNZIONANO! Stamattina e oggi me ne sarebbero dovute arrivare 3 invece
/// nemmeno una."
///
/// **La causa, contata nel codice e non stimata.** L'ordine BC voce 05 ha
/// costruito le cinque chiamate del giorno e le programma a ogni avvio, dal
/// primo fotogramma. Ma la prima riga di
/// `AvvisiDelRito.programmaLeChiamateDelGiorno` e' `if (!await
/// servizio.permessoConcesso()) return const []`, e il permesso del sistema
/// **l'app lo chiedeva in due soli punti**: dentro il Rito dell'Alba e dentro
/// il menu' Notifiche. Da Android 13 le notifiche nascono NEGATE: chi non e'
/// mai entrato in quelle due schermate non ha mai visto il dialogo di sistema,
/// quindi `permessoConcesso` rispondeva no a ogni avvio e **le cinque chiamate
/// non venivano programmate nemmeno una volta**. L'app credeva di averle
/// chieste; il telefono non ne aveva in coda nessuna.
///
/// **Perche' nessuna prova lo aveva visto.** Tutte le prove degli avvisi
/// costruiscono il servizio finto con `permesso = true`, cioe' misurano la
/// catena a permesso gia' concesso. Era vera ogni misura e falsa la
/// conclusione: la catena funziona, e non parte mai. La prova nuova
/// (`test/le_notifiche_arrivano_davvero_test.dart`) misura **quante chiamate
/// il sistema del telefono ha davvero in coda dopo un avvio**, partendo da un
/// telefono che non ha mai concesso niente.
///
/// **La cura, e i suoi limiti scritti.** All'avvio, una volta sola nella vita
/// dell'installazione, l'app mostra la stessa spiegazione del Rito dell'Alba
/// (`AvvisiDelRito.spiegazione`, che nomina i Doni e le loro ore) e poi
/// chiede al sistema. Una volta sola, perche' su Android il dialogo di sistema
/// compare una volta e poi il no diventa definitivo: insistere non
/// aggiungerebbe una possibilita', la toglierebbe.
///
/// **DALL'ORDINE EV NON SI CHIEDE PIU' ALL'AVVIO** ma alla prima apertura di
/// un Dono ([alPrimoDono]), con un foglio di due righe: il fondatore ha
/// chiesto di togliere la scheda dall'avvio, dove copriva la home col testo
/// lungo e il pulsante finiva sotto la barra.
///
/// **Non si chiede a chi sta entrando nel Cerchio**: durante l'ingresso la
/// scena e' occupata dal Risveglio, e un foglio di sistema sopra la prima
/// impressione dell'app e' il modo piu' rapido di farsi dire di no.
class ChiamataDelPrimoGiorno {
  const ChiamataDelPrimoGiorno._();

  /// **LA CHIAVE E' SUA E NON QUELLA DEL RITO DELL'ALBA.**
  ///
  /// `avvisi.alba.giaChiesto` dice che la spiegazione e' stata mostrata dal
  /// rito; questa dice che e' stata mostrata all'avvio. Sono due porte e due
  /// memorie: se ne condividessero una, chi ha aperto il rito una volta e non
  /// ha mai visto il dialogo (perche' il rito lo mostra piu' avanti nel suo
  /// flusso) resterebbe senza avvisi per sempre, che e' esattamente il caso
  /// che questa voce cura.
  static const String chiaveChiesto = 'avvisi.primoGiorno.chiesto';

  /// Vero se questa porta ha gia' chiesto una volta.
  static Future<bool> giaChiesto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(chiaveChiesto) ?? false;
    } catch (errore) {
      // Memoria non leggibile: si risponde "gia' chiesto" per non insistere.
      // Un avviso in meno e' un difetto; un dialogo di sistema a ogni avvio
      // e' un motivo per disinstallare.
      debugPrint('ChiamataDelPrimoGiorno.giaChiesto: memoria non leggibile '
          '($errore)');
      return true;
    }
  }

  /// Segna che questa porta ha chiesto.
  static Future<void> segnaChiesto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(chiaveChiesto, true);
    } catch (errore) {
      debugPrint('ChiamataDelPrimoGiorno.segnaChiesto: memoria non '
          'scrivibile ($errore)');
    }
  }

  /// Chiede il permesso se non e' mai stato chiesto da qui. Torna vero se dopo
  /// questa chiamata il permesso c'e'.
  ///
  /// [servizio] si inietta solo nelle prove: l'app vera usa `avvisiDelCerchio`.
  /// [dentroIlCerchio] dice se la persona ha gia' fatto l'ingresso: a chi sta
  /// entrando non si chiede niente.
  /// **IL FOGLIO SI INIETTA, e non e' un vezzo.** Il foglio della spiegazione
  /// e' un `showModalBottomSheet` che non si chiude da solo, e in una prova di
  /// widget aspettarne il futuro vuol dire smettere di disegnare fotogrammi
  /// proprio mentre lui aspetta una risposta. La prova della voce misura
  /// **quante chiamate restano in coda al telefono**, non come e' fatto il
  /// foglio: quello ha gia' le sue prove, in comune con le altre due porte che
  /// lo usano. Qui si sostituisce la risposta della persona.
  static Future<bool> Function(BuildContext)? spiegazionePerLeProve;

  /// **IL FOGLIO DICE SOLO L'INDISPENSABILE.** Il fondatore, 1 ottobre
  /// 2026, sulla scheda che compariva all'avvio: *"Il testo è eccessivo. Cmq
  /// elimina tutta la scheda all'avvio. Serve solo una scheda "Attiva le
  /// notifiche" quando l'utente apre la prima volta un dono e con il testo
  /// minimo indispensabile Senza dire 4 notifiche al giorno e altri
  /// dettagli"*, e poi: *"Aggiungi magari, che potrà attivare e disattivare le
  /// notifiche dal menù notifiche"*. La spiegazione lunga resta nel menu'
  /// Notifiche, dove chi la legge l'ha cercata.
  static const String titolo = 'Attiva le notifiche';
  static const String testo = 'Ti avviso quando i tuoi Doni sono pronti. '
      'Puoi attivarle e disattivarle dal menù Notifiche.';
  static const String pulsante = 'Attiva';

  /// **SPENTO NELLE PROVE, E SOVRASCRIVIBILE.** Nelle prove dei Doni il
  /// foglio comparirebbe sopra la scena a ogni prima apertura e coprirebbe i
  /// gesti che le prove fanno (69 prove rosse alla prima suite dell'ordine
  /// EV). Una prova che vuole il foglio lo riaccende.
  static bool alPrimoDonoAcceso =
      !Platform.environment.containsKey('FLUTTER_TEST');

  /// **ALLA PRIMA APERTURA DI UN DONO**, e non all'avvio (il fondatore, 1
  /// ottobre 2026: all'avvio la scheda copriva la home, e il pulsante finiva
  /// sotto la barra). Ogni Dono la chiama quando si apre; chiede una volta
  /// sola nella vita dell'installazione e, se la persona dice si', programma
  /// subito le chiamate del giorno, che all'avvio senza permesso non erano
  /// partite.
  static Future<void> alPrimoDono(BuildContext context) async {
    if (!alPrimoDonoAcceso) return;
    if (await giaChiesto()) return;
    if (!context.mounted) return;
    final concesso = await forseChiedi(context, dentroIlCerchio: true);
    if (concesso && context.mounted) {
      await RegiaDelleChiamate.riprogramma(context);
    }
  }

  static Future<bool> forseChiedi(
    BuildContext context, {
    ServizioAvvisi? servizio,
    required bool dentroIlCerchio,
  }) async {
    final porta = servizio ?? avvisiDelCerchio;
    if (!porta.disponibile) return false;
    if (!dentroIlCerchio) return false;
    // Chi il permesso ce l'ha gia' non deve vedere niente.
    if (await porta.permessoConcesso()) return true;
    if (await giaChiesto()) return false;
    await segnaChiesto();
    if (!context.mounted) return false;
    final finto = spiegazionePerLeProve;
    if (finto != null) {
      if (!await finto(context)) return false;
      final esito = await PortaDelPermesso.chiedi(
        AppPermission.notifications,
        richiestaDiSistema: porta.chiediPermesso,
      );
      return esito == EsitoDelPermesso.concesso;
    }
    return requestPermissionWithPrelude(
      context,
      permission: AppPermission.notifications,
      palette: MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)),
      copy: const PermissionCopy(
        icon: Icons.notifications_active_rounded,
        title: titolo,
        body: testo,
        cta: pulsante,
      ),
      systemRequest: () async {
        final esito = await PortaDelPermesso.chiedi(
          AppPermission.notifications,
          richiestaDiSistema: porta.chiediPermesso,
        );
        return esito == EsitoDelPermesso.concesso;
      },
    );
  }
}
