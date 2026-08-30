import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../design_system/tokens/color_tokens.dart';
import 'package:provider/provider.dart';

import '../../services/app_services.dart';
import '../../features/sigilli/regia_del_cammino.dart';
import '../archetypes/archetype_history.dart';
import '../arts/arti_preferite.dart';
import '../entitlement/question_allowance.dart';
import '../entitlement/registro_degli_eos.dart';
import '../identity/natal_identity.dart';
import '../chat/user_profile.dart';
import '../identity/profile_controller.dart';
import '../sigilli/diario_del_cammino.dart';
import '../../features/onboarding/scena_del_ritrovamento.dart';
import '../onboarding/onboarding_controller.dart';
import 'cammino_da_custodire.dart';
import 'rinascita_del_cammino.dart';
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
    // **E ANCHE LA FORMA DI CORTESIA, ordine CF voce 07.** Il nome viaggiava
    // e il genere no: chi rientrava su un telefono appena reinstallato si
    // sentiva chiamare con la forma iniziale del controller invece che con
    // la sua. Si legge dallo stesso profilo e nello stesso `try`, perche'
    // senza quel provider non c'e' ne' l'uno ne' l'altra.
    String? forma;
    try {
      final profilo = context.read<ProfileController>().profile;
      nome = profilo.displayName;
      forma = profilo.courtesyForm == CourtesyForm.unknown
          ? null
          : profilo.courtesyForm.name;
    } catch (errore) {
      nome = null;
      forma = null;
    }

    IdentitaDaCustodire? identita;
    try {
      identita = IdentitaDaCustodire.daiDettagli(
        context.read<BirthIdentityController>().details,
        nome: nome,
        forma: forma,
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
  /// **LA RINASCITA DA RACCONTARE, ordine AR voce 06.** Vero quando questo
  /// avvio ha azzerato un cammino che esisteva: la home lo legge una volta e
  /// mostra la riga onesta, perche' chi riapre e trova il Journal spento deve
  /// capire in una frase cosa e' successo, e sapere che i suoi Eos sono dove
  /// li aveva lasciati. Un Cerchio nuovo non lo vede mai.
  static bool rinascitaDaRaccontare = false;

  /// **PERCHE' IL GIRO NON HA PORTATO NIENTE.** Ordine AZ voce 01, fatto F1.
  ///
  /// Fino alla 2192 questo giro rispondeva `null` e basta, e quel nulla stava
  /// per tre cose diverse: non c'e' un borsellino da interrogare, il server
  /// non ha risposto, il server ha detto di no. **Chi chiamava non poteva
  /// dire niente alla persona proprio perche' non sapeva cosa era successo**,
  /// ed e' il silenzio che il fondatore ha visto.
  static Future<EsitoDelGiro> custodisciEAdotta(
    BuildContext context,
  ) async {
    final QuestionAllowance borsa;
    try {
      borsa = context.read<QuestionAllowance>();
    } catch (errore) {
      // Fuori dall'app viva non c'e' nessun borsellino: non e' un guasto e
      // non va raccontato a nessuno.
      return const EsitoDelGiro();
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
    // **LA RINASCITA VIENE PRIMA DI TUTTO, ordine AR voce 06.** Se il
    // cammino va azzerato lo si fa QUI, prima di raccoglierlo: raccoglierlo
    // prima vorrebbe dire mandare al Cerchio i numeri che si stanno
    // buttando, e la fusione, che difende sempre il piu' alto, li
    // riporterebbe indietro tutti.
    final eRinato = await RinascitaDelCammino.rinasci();
    if (eRinato) {
      try {
        if (context.mounted) {
          await context.read<DiarioDelCammino>().azzeraPerLaRinascita();
        }
      } catch (errore) {
        // Senza diario non c'e' memoria da svuotare.
      }
      rinascitaDaRaccontare = true;
    }
    if (!context.mounted) return const EsitoDelGiro();
    final mio = raccogli(context);
    quanteVolte++;
    // **IL NO DEL SERVER NON MUORE PIU' NEL GESTO.** Ordine AZ voce 01, ed e'
    // il fatto F1. `PortaVeraDelCerchio` RILANCIA apposta su `unauthenticated`,
    // `permission-denied`, `invalid-argument` e `failed-precondition`, per
    // distinguere un rifiuto da una rete assente. Qui pero' non c'era nessun
    // try: quell'eccezione risaliva fino al gestore del tocco e moriva li'.
    // La persona toccava, non entrava, e **non le veniva detto niente**.
    final CamminoDaCustodire? tornato;
    try {
      tornato = await borsa.sincronizza(cammino: mio, azzeraIlCammino: eRinato);
    } on FirebaseFunctionsException catch (errore) {
      if (context.mounted) {
        try {
          context.read<AppServices>().guasti.registra(
                operazione: 'giro del Custode dopo il riconoscimento',
                errore: errore,
              );
        } catch (senzaRegistro) {
          // Senza servizi non c'e' registro dei guasti, e non e' questo il
          // momento di crearne uno: si sta gia' raccontando un guasto, e un
          // guasto dentro il racconto di un guasto non aiuta nessuno.
        }
      }
      return EsitoDelGiro(rifiutatoDalServer: true, codice: errore.code);
    }
    // **IL NULLA E' L'ALTRO MODO**, e chiede un'altra frase: qui il server non
    // ha risposto, e riprovare fra un momento ha senso.
    if (tornato == null) return const EsitoDelGiro(senzaRisposta: true);
    if (!context.mounted) return EsitoDelGiro(cammino: tornato);
    // **LA DOTE RACCONTA LA SUA STORIA, ordine BF voce 01.** Il benvenuto e
    // l'accredito del giorno arrivavano in silenzio dentro il saldo, e il
    // fondatore ha letto i 270 di un Cerchio appena nato come il borsellino
    // vecchio che tornava dopo la cancellazione. Qui, che e' l'unico posto
    // con in mano sia la risposta del server sia l'albero dei provider, gli
    // accrediti si scrivono nel registro con parole di persona.
    _raccontaGliAccrediti(context, borsa);
    await adotta(context, tornato);
    if (!context.mounted) return EsitoDelGiro(cammino: tornato);
    // **IL RITO NON SI RIFA' A CHI IL CERCHIO CONOSCE GIA', ordine AP voce
    // 05.** La decisione sta in `Ritrovamento`, in un punto solo, perche' la
    // stessa domanda arriva anche dal "Continua come" della voce 06.
    final esito = Ritrovamento.da(
      tornato,
      saldoEos: borsa.saldoEos,
      cerchioAppenaNato: borsa.cerchioAppenaNato,
    );
    if (esito.siSalta) {
      try {
        await context.read<OnboardingController>().ritrovato();
      } catch (errore) {
        // Senza il controller non c'e' nessun rito da saltare.
      }
    }
    return EsitoDelGiro(cammino: tornato);
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
    final giro = await custodisciEAdotta(context);
    if (!context.mounted) return null;
    final esito = cosaHaRitrovato(context, giro);
    // **NESSUN RIENTRO MUTO.** Ordine AZ voce 01, fatto F1: si tocca "Continua
    // con Google", si entra davvero, e poi non succede niente e nessuno dice
    // perche'. La frase sta in `Ritrovamento` e si mostra QUI, in un punto
    // solo, perche' i chiamanti sono tre e uno dei tre si dimenticherebbe.
    final daDire = esito.cosaDireAllaPersona;
    if (daDire != null) {
      final messaggero = ScaffoldMessenger.maybeOf(context);
      messaggero?.showSnackBar(SnackBar(
        key: const Key('rientro_andato_storto'),
        content: Text(daDire),
        duration: const Duration(seconds: 8),
        // **E SI PUO' RIPROVARE SENZA INVENTARSI UNA NASCITA.** Senza questa
        // riga l'unica strada che resta a chi e' entrato e non ha ritrovato
        // niente e' rifare il rito da capo, ed e' cio' che il fondatore ha
        // fatto: F2 e F3, dati di nascita a caso perche' non c'era altro da
        // fare. Il giro si rifa' da solo, e il piu' delle volte basta.
        action: SnackBarAction(
          label: 'Riprova',
          onPressed: () {
            if (!context.mounted) return;
            dopoIlRiconoscimento(context, mostraLaScena: mostraLaScena);
          },
        ),
      ));
    }
    if (!mostraLaScena || !esito.qualcosaDaMostrare) {
      // **A CHI ENTRA SU UN CERCHIO APPENA NATO LO SI DICE.** Ordine BG voce
      // 01: il fondatore ha toccato "Faccio gia' parte del Cerchio" dopo la
      // cancellazione, Google ha creato un account nuovo in silenzio, e
      // senza questa riga si ritroverebbe nell'onboarding senza sapere
      // perche'. Non e' un errore: e' la verita' detta al posto del
      // Bentornato che mentiva.
      if (mostraLaScena && esito.cerchioAppenaNato) {
        // **L'AVVISO E' UN DIALOGO, ordine BH voce 03.** Parole del
        // fondatore: "l'utente deve essere avvertito che l'email non
        // risulta registrata". La snackbar di BG.01 durava otto secondi e
        // si poteva perdere: adesso l'avviso si legge e si congeda con un
        // tocco. La riga si declina sui fatti (BH.01): con la dote se e'
        // arrivata, con la verita' della lapide se e' stata fermata.
        var doteArrivata = false;
        try {
          doteArrivata =
              context.read<QuestionAllowance>().benvenutoAppenaArrivato;
        } catch (senzaProvider) {
          doteArrivata = false;
        }
        await showDialog<void>(
          context: context,
          builder: (dialogo) => AlertDialog(
            key: const Key('cerchio_appena_nato'),
            backgroundColor: ColorTokens.neutralSurface,
            title: const Text('Questa email non aveva un Cerchio'),
            content: Text(doteArrivata
                ? 'Ne è nato uno nuovo, da zero, già registrato con il tuo '
                    'account: la dote di benvenuto è tua.'
                : 'Ne è nato uno nuovo, da zero, già registrato con il tuo '
                    'account. Il benvenuto non si ripete: questa email lo '
                    'aveva già ricevuto.'),
            actions: [
              TextButton(
                key: const Key('cerchio_appena_nato_capito'),
                onPressed: () => Navigator.of(dialogo).pop(),
                child: const Text('Ho capito'),
              ),
            ],
          ),
        );
      }
      return esito;
    }
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
    EsitoDelGiro giro,
  ) {
    var saldo = 0;
    try {
      saldo = context.read<QuestionAllowance>().saldoEos;
    } catch (errore) {
      saldo = 0;
    }
    var appenaNato = false;
    try {
      appenaNato = context.read<QuestionAllowance>().cerchioAppenaNato;
    } catch (errore) {
      appenaNato = false;
    }
    return Ritrovamento.da(
      giro.cammino,
      saldoEos: saldo,
      cerchioAppenaNato: appenaNato,
      rifiutatoDalServer: giro.rifiutatoDalServer,
      senzaRisposta: giro.senzaRisposta,
    );
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
    // **IL NOME E LA FORMA TORNANO NEL PROFILO, ordine CF voce 07.**
    //
    // **Prima non tornavano, ed e' misurato.** La custodia il nome lo
    // portava gia', ma qui si adottava soltanto l'identita' di nascita:
    // il profilo restava quello iniziale, cioe' il nome d'esempio della
    // Demo. Chi usciva dal rito perche' non c'era piu' niente da chiedere
    // si ritrovava chiamato con un nome che non era il suo.
    //
    // **Si scrive solo cio' che il Cerchio ha davvero**: un campo nullo
    // nella custodia non cancella quello che c'e' sul telefono, perche'
    // il ritrovamento e' una fusione e non una sostituzione.
    final custodita = cammino.identita;
    if (custodita != null &&
        (custodita.nome != null || custodita.forma != null)) {
      try {
        final profilo = context.read<ProfileController>();
        profilo.setProfile(profilo.profile.copyWith(
          displayName: custodita.nome ?? profilo.profile.displayName,
          courtesyForm: custodita.forma == null
              ? profilo.profile.courtesyForm
              : CourtesyForm.fromId(custodita.forma),
        ));
      } catch (errore) {
        // Senza il controller del profilo non c'e' niente da riprendere.
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

  /// GLI ACCREDITI DEL SERVER, SCRITTI NEL REGISTRO CON PAROLE DI PERSONA.
  /// Ordine BF voce 01.
  ///
  /// La consegna svuota la lista, quindi nessun accredito si racconta due
  /// volte; se il registro non c'e' (le prove piu' piccole non lo montano)
  /// gli accrediti si lasciano da parte per il prossimo giro, non si
  /// buttano.
  static void _raccontaGliAccrediti(
      BuildContext context, QuestionAllowance borsa) {
    final RegistroDegliEos registro;
    try {
      registro = context.read<RegistroDegliEos>();
    } catch (errore) {
      return;
    }
    for (final accredito in borsa.prendiGliAccreditiDaRaccontare()) {
      final perche = switch (accredito.motivo) {
        // **"DONO DI BENVENUTO" E NON "BENVENUTO NEL CERCHIO", ordine CF
        // voce 05.** Era l'unica stringa dell'app che dichiarava un genere
        // fuori dalle porte del genere: qui non c'e' nessuna scelta di
        // forma, quindi a chi aveva scelto il femminile il registro degli
        // Eos diceva comunque "Benvenuto". Un nome di dono non ha genere e
        // non ne serve uno. **Testo provvisorio**: le parole che la
        // persona legge le approva il fondatore.
        'benvenuto' => 'Dono di benvenuto',
        'accredito_del_giorno' => 'Dono del giorno',
        // Un motivo nuovo del server non deve sparire dalla storia: si
        // racconta con la parola piu' larga che resti vera.
        _ => 'Dono del Cerchio',
      };
      registro.segna(quanti: accredito.quanti, perche: perche);
    }
  }
}
