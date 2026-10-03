/// IL CUSTODE DELLE PUSH, MONTATO. Ordine CI voce 07.
///
/// **Il fatto misurato che ha aperto questa voce.** `CustodeDellePush`
/// esisteva col suo corpo e le sue prove, e **nessuno lo montava**: cercato in
/// tutto `lib`, l'unico posto che lo nominava era il file che lo dichiara. Le
/// notifiche push non potevano arrivare nemmeno a funzioni distribuite,
/// perche' il dispositivo non registrava mai il proprio recapito. Il lato
/// server era pronto e il lato telefono non c'era.
///
/// **Perche' e' un widget e non una riga dentro il provider.** Registrare il
/// recapito non e' costruire un oggetto: e' un ciclo di vita. Bisogna
/// chiederlo al sistema quando l'app e' viva, riascoltarlo quando il sistema
/// lo rigenera, rimandarlo quando le scelte cambiano, e toglierlo quando la
/// persona esce. Un `create:` fa la prima cosa e nessuna delle altre.
///
/// **DOVE STA MONTATO: sopra il Navigator, dentro i provider.** Li' l'account
/// c'e' gia' ed e' vivo, e le scelte degli avvisi pure. Piu' in basso avrebbe
/// il ciclo di vita di una schermata, cioe' morirebbe cambiando pagina.
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/identity/account_del_cerchio.dart';
import '../../core/rituals/custode_delle_push.dart';
import '../../core/rituals/prova_delle_push.dart';
import '../../core/rituals/scelta_degli_avvisi.dart';
import '../../services/push/fuso_del_telefono.dart';

/// Chi chiede il recapito al sistema. Un'interfaccia, per una ragione sola:
/// nelle prove non c'e' nessun sistema a cui chiederlo.
abstract class RecapitoDelDispositivo {
  const RecapitoDelDispositivo();

  /// Il recapito di adesso, nullo quando non se ne puo' avere uno.
  Future<String?> adesso();

  /// Ogni volta che il sistema lo rigenera. Succede reinstallando l'app,
  /// ripristinando un backup, e ogni tanto per conto suo: **senza questo,
  /// dopo la prima rigenerazione il server spingerebbe verso un indirizzo
  /// morto e la persona smetterebbe di ricevere le push senza che nessuno se
  /// ne accorga**, cioe' esattamente il difetto da cui la voce CG.16 nasce.
  Stream<String> quandoCambia();
}

/// Il recapito vero, da Firebase Messaging.
class RecapitoVero extends RecapitoDelDispositivo {
  const RecapitoVero();

  @override
  Future<String?> adesso() async {
    try {
      final messaggi = FirebaseMessaging.instance;
      // **IL PERMESSO DELLE NOTIFICHE NON SI CHIEDE QUI.** Su Android
      // dalla 13 e su iOS serve, ma chiederlo all'avvio sarebbe il dialogo
      // che compare senza che nessuno lo abbia chiesto. Lo chiede il menu'
      // degli avvisi, che e' il punto in cui la persona dice di volerli:
      // qui si prende il recapito solo se il permesso c'e' gia'.
      final stato = await messaggi.getNotificationSettings();
      if (stato.authorizationStatus == AuthorizationStatus.denied ||
          stato.authorizationStatus == AuthorizationStatus.notDetermined) {
        return null;
      }
      return await messaggi.getToken();
    } catch (errore) {
      debugPrint('Push: il recapito non si legge. $errore');
      return null;
    }
  }

  @override
  Stream<String> quandoCambia() {
    try {
      return FirebaseMessaging.instance.onTokenRefresh;
    } catch (errore) {
      debugPrint('Push: il rinnovo del recapito non si ascolta. $errore');
      return const Stream<String>.empty();
    }
  }
}

/// Un recapito che non c'e': il valore di partenza, e quello delle prove.
class RecapitoAssente extends RecapitoDelDispositivo {
  const RecapitoAssente();

  @override
  Future<String?> adesso() async => null;

  @override
  Stream<String> quandoCambia() => const Stream<String>.empty();
}

class CustodeMontato extends StatefulWidget {
  const CustodeMontato({
    super.key,
    required this.child,
    this.recapito = const RecapitoAssente(),
    this.fuso,
  });

  final Widget child;
  final RecapitoDelDispositivo recapito;

  /// Il fuso da dichiarare al server. Nullo vuol dire quello del sistema.
  final String? fuso;

  @override
  State<CustodeMontato> createState() => _CustodeMontatoState();
}

class _CustodeMontatoState extends State<CustodeMontato> {
  bool _avviato = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _avvia());
  }

  Future<void> _avvia() async {
    if (_avviato || !mounted) return;
    _avviato = true;
    final custode = context.read<CustodeDellePush>();
    await custode.carica();
    final token = await widget.recapito.adesso();
    if (token != null && token.isNotEmpty && mounted) {
      await custode.tokenNuovo(token);
    }
    widget.recapito.quandoCambia().listen((nuovo) async {
      if (!mounted) return;
      await context.read<CustodeDellePush>().tokenNuovo(nuovo);
      await _sincronizza();
    });
    await _sincronizza();
  }

  /// **LA SINCRONIA E' GOVERNATA DAL DIRITTO, e non solo dalle scelte.**
  ///
  /// La regola premium col mese di prova, decisa in CG.16, vive qui: chi non
  /// ha diritto alle push non manda nessun recapito al server, quindi il giro
  /// notturno non lo trova e non spende niente per lui. Le chiamate locali
  /// restano accese e gratuite per tutti, e sono quelle che riceve oggi.
  Future<void> _sincronizza() async {
    if (!mounted) return;
    final custode = context.read<CustodeDellePush>();
    final scelta = context.read<SceltaDegliAvvisi>();
    final tier = context.read<EntitlementService>().tier;
    final account = context.read<AccountDelCerchio>();
    final riceve = ProvaDellePush.riceveLePush(
      tier: tier,
      registratoIl: account.natoIl,
      adesso: DateTime.now(),
    );
    if (!riceve) {
      // **NON BASTA NON MANDARE: SI TOGLIE.** Chi esce dal diritto, per
      // esempio finita la prova, avrebbe lasciato sul server un recapito
      // vivo, e il giro notturno avrebbe continuato a spingergli le push
      // pagandole. Il diritto si perde, il recapito se ne va con lui.
      await custode.dimentica();
      return;
    }
    await custode.sincronizza(
      scelta: scelta,
      // **IL NOME IANA, NON L'ABBREVIAZIONE. Ordine CQ voce 1.09**, 3
      // settembre 2026. Qui c'era il nome corto del fuso di Dart, che su
      // Android torna `CEST`, e il server pretende `Area/Citta`: ventitre
      // chiamate, ventitre 400, e la raccolta delle push mai nata.
      fuso: widget.fuso ?? fusoDelTelefono(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // **LE SCELTE SI RIASCOLTANO**: spegnendo un Dono nel menu' degli avvisi,
    // il recapito che il server ha in mano deve cambiare subito, altrimenti
    // quella push continua a partire e la persona ha spento un interruttore
    // che non spegne niente.
    context.watch<SceltaDegliAvvisi>();
    if (_avviato) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sincronizza());
    }
    return widget.child;
  }
}
