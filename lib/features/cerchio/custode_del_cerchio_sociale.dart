import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
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
    String? nomeProprio;
    int gradino = 0;
    try {
      final p = context.read<ProfileController>();
      identita = p.identity.isExample ? null : p.identity;
      nomeProprio = p.profile.displayName;
    } catch (senzaQuelDato) {
      // Il dato e' facoltativo: senza, si va avanti col ripiego.
    }
    try {
      gradino = context.read<DiarioDelCammino>().progressoDelCammino.accesi;
    } catch (senzaQuelDato) {
      // Il dato e' facoltativo: senza, si va avanti col ripiego.
    }
    var maestro = await IlCerchioSociale.ilMaestroRicordato();
    if (maestro == null && mounted) {
      try {
        maestro = context.read<MaestroController>().activeMaestro;
      } catch (senzaQuelDato) {
        // Il dato e' facoltativo: senza, si va avanti col ripiego.
      }
    }
    final firma =
        '${identita?.birthDate.toIso8601String()}|${maestro?.name}|$gradino';
    if (firma == _ultimaFirma) return;
    _ultimaFirma = firma;
    await sociale.sincronizza(
        identita: identita,
        maestro: maestro,
        gradino: gradino,
        nomeProprio: nomeProprio);
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
  Widget build(BuildContext context) {
    // Si riascoltano i dati che il profilo pubblico porta: un gradino nuovo
    // o la nascita corretta arrivano al Cerchio da soli.
    try {
      context.watch<ProfileController>();
      context.watch<DiarioDelCammino>();
    } catch (senzaQuelDato) {
      // Il dato e' facoltativo: senza, si va avanti col ripiego.
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _sincronizza());
    return widget.child;
  }
}
