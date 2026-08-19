import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../features/sigilli/regia_del_cammino.dart';
import '../archetypes/archetype_history.dart';
import '../arts/arti_preferite.dart';
import '../entitlement/question_allowance.dart';
import '../identity/natal_identity.dart';
import '../identity/profile_controller.dart';
import '../sigilli/diario_del_cammino.dart';
import '../../features/onboarding/scena_del_ritrovamento.dart';
import '../onboarding/onboarding_controller.dart';
import 'cammino_da_custodire.dart';
import 'ritrovamento.dart';

/// IL CUSTODE DEL CAMMINO: lo raccoglie, lo manda, e adotta cio' che torna.
/// Ordine AP voci 02 e 03.
///
/// **Il fatto che apre quest'ordine.** Mauro ha reinstallato l'app, e' entrato
/// con lo stesso account Google, e il borsellino e' tornato solo visitando il
/// Passport mentre i traguardi accesi non sono tornati affatto.
///
/// **Cosa si e' scoperto misurando, e non e' quello che la premessa P3
/// diceva.** La premessa diceva che nessuno chiede lo stato all'avvio.
/// Misurato: la chiamata parte gia', perche' `lib/app.dart` costruisce il
/// borsellino con `..sincronizza()` e la barra sottile lo legge al primo
/// fotogramma. Cio' che mancava era altro, ed e' esattamente il caso di
/// Mauro: **nessuno rifaceva la chiamata DOPO il riconoscimento**, cioe' nel
/// momento in cui l'identita' cambia e il Cerchio diventa un altro. Chi
/// entrava col suo account restava con lo stato di prima, che era vuoto.
///
/// **UNA CHIAMATA SOLA, andata e ritorno.** Il custode non apre un giro suo:
/// passa il cammino a `QuestionAllowance.sincronizza`, che e' l'unica che
/// chiede lo stato, e riceve indietro cio' che il server ha fuso. Due
/// chiamate nello stesso momento sarebbero la seconda porta sullo stesso
/// dato.
///
/// **Il custode non fonde niente**: la fusione vive sul server, in
/// `functions/src/cammino.ts`. Qui si raccoglie e si adotta.
class CustodeDelCammino {
  const CustodeDelCammino._();

  /// **CHI E' GIA' PASSATO DI QUI IN QUESTA SESSIONE.** La chiamata all'avvio
  /// e quella dopo il riconoscimento sono due momenti diversi e devono
  /// avvenire tutte e due: questo conto serve solo alle prove, per dire
  /// quante volte il Cerchio e' stato interrogato.
  @visibleForTesting
  static int quanteVolte = 0;

  /// Raccoglie il cammino che questo telefono ha da custodire.
  ///
  /// Legge dalle porte uniche che gia' esistono, mai da una copia sua: il
  /// diario per i gesti e i Sigilli, il profilo e l'identita' di nascita per
  /// chi sei, lo storico dell'archetipo, le arti preferite.
  static CamminoDaCustodire raccogli(BuildContext context) {
    DiarioDelCammino? diario;
    try {
      diario = context.read<DiarioDelCammino>();
    } catch (errore) {
      diario = null;
    }
    final stato = diario?.statoDelCammino();

    String? nome;
    try {
      nome = context.read<ProfileController>().profile.displayName;
    } catch (errore) {
      nome = null;
    }

    IdentitaDaCustodire? identita;
    try {
      identita = IdentitaDaCustodire.daiDettagli(
        context.read<BirthIdentityController>().details,
        nome: nome,
      );
    } catch (errore) {
      identita = null;
    }

    String? archetipo;
    DateTime? quandoArchetipo;
    try {
      final ultimo = context.read<ArchetypeHistory>().ultimo;
      archetipo = ultimo?.dominante.name;
      quandoArchetipo = ultimo?.quando;
    } catch (errore) {
      archetipo = null;
    }

    List<String> arti = const [];
    try {
      arti = context.read<ArtiPreferiteController>().ids;
    } catch (errore) {
      arti = const [];
    }

    return CamminoDaCustodire(
      identita: identita,
      gesti: stato?.gestiCompiuti ?? const {},
      giorni: stato?.giorniConGesto ?? const {},
      oreGiuste: stato?.gestiNellOraGiusta ?? const {},
      serie: diario?.seriePerRito ?? const {},
      sigilli: {
        for (final id in diario?.accesi ?? const <String>{})
          id: diario?.quandoSiEAcceso(id) ?? DateTime.now(),
      },
      archetipoDominante: archetipo,
      archetipoQuando: quandoArchetipo,
      artiPreferite: arti,
      primoGiorno: diario?.primoGiorno,
      ultimoGiorno: diario?.ultimoGiorno,
    );
  }

  /// **IL GIRO INTERO: raccoglie, manda, adotta.**
  ///
  /// Si chiama all'avvio e SUBITO DOPO il riconoscimento di un account,
  /// perche' e' li' che l'identita' cambia e il Cerchio diventa un altro.
  /// Torna il cammino che il server ha fuso, oppure nullo se non ha risposto:
  /// senza rete non si mostra niente di falso e non si cancella niente, si
  /// riprova alla prossima apertura.
  static Future<CamminoDaCustodire?> custodisciEAdotta(
    BuildContext context,
  ) async {
    final QuestionAllowance borsa;
    try {
      borsa = context.read<QuestionAllowance>();
    } catch (errore) {
      return null;
    }
    // **PRIMA SI ASPETTA CHE IL DIARIO ABBIA LETTO IL DISCO**, ordine AN
    // voce 04 e AO voce 04: raccogliere un cammino ancora in volo vorrebbe
    // dire mandare al Cerchio un telefono che sembra vuoto, e la fusione
    // non avrebbe due parti da fondere.
    try {
      await context.read<DiarioDelCammino>().pronto;
    } catch (errore) {
      // Senza diario non c'e' niente da aspettare.
    }
    if (!context.mounted) return null;
    final mio = raccogli(context);
    quanteVolte++;
    final tornato = await borsa.sincronizza(cammino: mio);
    if (tornato == null) return null;
    if (!context.mounted) return tornato;
    await adotta(context, tornato);
    if (!context.mounted) return tornato;
    // **IL RITO NON SI RIFA' A CHI IL CERCHIO CONOSCE GIA', ordine AP voce
    // 05.** La decisione sta in `Ritrovamento`, in un punto solo, perche' la
    // stessa domanda arriva anche dal "Continua come" della voce 06.
    final esito = Ritrovamento.da(tornato, saldoEos: borsa.saldoEos);
    if (esito.siSalta) {
      try {
        await context.read<OnboardingController>().ritrovato();
      } catch (errore) {
        // Senza il controller non c'e' nessun rito da saltare.
      }
    }
    return tornato;
  }

  /// **IL GIRO DOPO UN RICONOSCIMENTO, e la scena che lo racconta.** Ordine
  /// AP voci 05 e 06.
  ///
  /// Si chiama quando una persona e' appena stata riconosciuta, da qualunque
  /// delle due strade: la porta piccola del Risveglio (voce 04) o il
  /// "Continua come" della custodia (voce 06). Le due strade portano allo
  /// stesso posto, e questo e' il posto: il cammino torna, il rito non si
  /// rifa' se non serve, e cio' che e' stato ritrovato SI VEDE.
  ///
  /// **All'avvio invece la scena non si mostra**, ed e' voluto: chi apre
  /// l'app ogni mattina non deve vedersi annunciare un bentornato. Il
  /// ritrovamento e' una notizia solo nel momento in cui si temeva di aver
  /// perso qualcosa.
  static Future<Ritrovamento?> dopoIlRiconoscimento(
    BuildContext context, {
    bool mostraLaScena = true,
  }) async {
    final tornato = await custodisciEAdotta(context);
    if (!context.mounted) return null;
    final esito = cosaHaRitrovato(context, tornato);
    if (!mostraLaScena || !esito.qualcosaDaMostrare) return esito;
    final navigatore = Navigator.maybeOf(context);
    if (navigatore == null) return esito;
    await navigatore.push(ScenaDelRitrovamento.route(
      ritrovamento: esito,
      onProsegui: () => navigatore.maybePop(),
    ));
    return esito;
  }

  /// **COSA IL CERCHIO HA RITROVATO**, per chi deve mostrarlo. La decisione
  /// e' sempre di `Ritrovamento`: qui si legge soltanto.
  static Ritrovamento cosaHaRitrovato(
    BuildContext context,
    CamminoDaCustodire? cammino,
  ) {
    var saldo = 0;
    try {
      saldo = context.read<QuestionAllowance>().saldoEos;
    } catch (errore) {
      saldo = 0;
    }
    return Ritrovamento.da(cammino, saldoEos: saldo);
  }

  /// ADOTTA il cammino che il Cerchio ha restituito.
  ///
  /// **Non e' una sostituzione cieca**, e la ragione e' che cio' che arriva
  /// e' GIA' la fusione fra il telefono e il server: il piu' alto dei
  /// contatori, l'unione dei Sigilli, le date piu' vecchie dove sono un
  /// primato. Adottarlo non puo' quindi togliere niente a nessuno.
  static Future<void> adotta(
    BuildContext context,
    CamminoDaCustodire cammino,
  ) async {
    try {
      await context.read<DiarioDelCammino>().adottaIlCammino(cammino);
    } catch (errore) {
      // Senza diario non c'e' cammino da adottare, come in una prova che
      // monta una scena da sola.
    }
    if (!context.mounted) return;
    final identita = cammino.identita?.aBirthIdentity();
    if (identita != null) {
      try {
        context.read<BirthIdentityController>().riprendiDa(identita);
      } catch (errore) {
        // Idem: senza il controller non c'e' identita' da riprendere.
      }
    }
    if (!context.mounted) return;
    if (cammino.artiPreferite.isNotEmpty) {
      try {
        await context
            .read<ArtiPreferiteController>()
            .adottaDalCerchio(cammino.artiPreferite);
      } catch (errore) {
        // Idem.
      }
    }
    // **IL RITORNO DEI PREMI NON SI FA QUI**: i Sigilli tornati accesi vanno
    // pagati, e a pagarli e' la sincronia dell'ordine AN voce 04, che sa
    // gia' quali premi mancano e non li conta due volte. Qui basta averli
    // rimessi nel diario.
    if (!context.mounted) return;
    // **LA SINCRONIA RIPARTE, e serve il permesso di rifarla.** Il suo
    // catenaccio "una volta per sessione" era pensato per l'avvio; qui
    // l'identita' e' appena cambiata e i Sigilli tornati accesi non hanno
    // ancora avuto il loro premio, quindi il giro va rifatto una volta
    // ancora. Il doppio pagamento resta impossibile, perche' ogni movimento
    // porta il suo identificativo e il server ripete la risposta di allora.
    RegiaDelCammino.riprendiDaCapo();
    await RegiaDelCammino.riprendiIPremiPersi(context);
  }
}
