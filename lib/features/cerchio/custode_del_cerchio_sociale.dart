import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../push/custode_montato.dart';

/// **IL CUSTODE DEL CERCHIO SOCIALE, ordine EY.** Sta sopra il Navigator,
/// accanto al custode delle push, e fa tre cose:
///
/// 1. tiene allineato il profilo del Cerchio con cio' che solo il telefono
///    sa: il segno (mai la data), il Maestro di riferimento, il gradino del
///    Cammino e la maggiore eta';
/// 2. da' al server il recapito delle notifiche, se il permesso c'e' gia',
///    perche' i segni arrivino anche a chi non ha acceso i Doni;
/// 3. insegna alla porta della condivisione dove prendere il codice del
///    link d'invito (EY.15).
class CustodeDelCerchioSociale extends StatefulWidget {
  const CustodeDelCerchioSociale({
    super.key,
    required this.child,
    this.recapito = const RecapitoAssente(),
  });

  final Widget child;
  final RecapitoDelDispositivo recapito;

  @override
  State<CustodeDelCerchioSociale> createState() =>
      _CustodeDelCerchioSocialeState();
}

class _CustodeDelCerchioSocialeState extends State<CustodeDelCerchioSociale> {
  String? _ultimaFirma;
  bool _recapitoDato = false;

  IlCerchioSociale? _sociale() {
    try {
      return context.read<IlCerchioSociale>();
    } catch (errore) {
      // Una prova che monta l'app senza il Cerchio sociale: niente da fare.
      return null;
    }
  }

  Future<void> _sincronizza() async {
    final sociale = _sociale();
    if (sociale == null || !sociale.vivo || !mounted) return;
    BirthIdentity? identita;
    int gradino = 0;
    try {
      final p = context.read<ProfileController>();
      identita = p.identity.isExample ? null : p.identity;
    } catch (_) {}
    try {
      gradino = context.read<DiarioDelCammino>().progressoDelCammino.accesi;
    } catch (_) {}
    var maestro = await IlCerchioSociale.ilMaestroRicordato();
    if (maestro == null && mounted) {
      try {
        maestro = context.read<MaestroController>().activeMaestro;
      } catch (_) {}
    }
    final firma =
        '${identita?.birthDate.toIso8601String()}|${maestro?.name}|$gradino';
    if (firma == _ultimaFirma) return;
    _ultimaFirma = firma;
    await sociale.sincronizza(
        identita: identita, maestro: maestro, gradino: gradino);
    await sociale.caricaIlCerchio();
    if (!_recapitoDato) {
      _recapitoDato = true;
      final token = await widget.recapito.adesso();
      if (token != null && token.length >= 20) {
        await sociale.scriviIlToken(token);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // **LA CARD PORTA IL LINK, ordine EY voce 15**: la porta unica della
    // condivisione chiede il codice qui, e lo aggiunge lei.
    PortaDellaCondivisione.codiceDellInvito = () async {
      final sociale = _sociale();
      return sociale?.codiceDelLink();
    };
  }

  @override
  Widget build(BuildContext context) {
    // Si riascoltano i dati che il profilo pubblico porta: un gradino nuovo
    // o la nascita corretta arrivano al Cerchio da soli.
    try {
      context.watch<ProfileController>();
      context.watch<DiarioDelCammino>();
    } catch (_) {}
    WidgetsBinding.instance.addPostFrameCallback((_) => _sincronizza());
    return widget.child;
  }
}
