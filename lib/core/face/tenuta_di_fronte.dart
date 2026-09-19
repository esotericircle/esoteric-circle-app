import 'scansione_a_pose.dart' show SoglieInUso, SoglieVive;

/// **LA SCANSIONE BREVE DEL RITORNO.** Ordine CR voce 08, 6 settembre 2026.
///
/// **Parole dell'ordine**: *"i RITORNI, che sono una scansione breve di fronte
/// e producono soltanto la lettura dell'istante"*.
///
/// **PERCHE' NON SI RIUSA LA SCANSIONE A QUATTRO POSE.** Girare la testa serve
/// a due cose: misurare la geometria da piu' angoli, e provare che davanti
/// all'obiettivo c'e' una persona viva. Nel ritorno la geometria non si misura
/// affatto, perche' i tratti sono gia' stati letti e non cambiano da un giorno
/// all'altro: chiedere di nuovo quattro movimenti sarebbe far pagare a chi
/// torna il prezzo di una misura che nessuno rifara'.
///
/// **MA LA VITALITA' NON SI REGALA.** Una fotografia stampata tenuta davanti
/// alla fotocamera resta immobile e resta di fronte: se bastasse essere
/// inquadrati, il ritorno sarebbe la porta di servizio del muro. Qui si chiede
/// il fronte **tenuto nel tempo**, e la tenuta si azzera appena l'angolo si
/// perde. E' una barriera piu' bassa di quattro pose, ed e' dichiarata come
/// tale: il ritorno non produce nessuna lettura dei tratti, quindi non c'e'
/// nessun responso permanente da falsificare.
class TenutaDiFronte {
  TenutaDiFronte({this.soglie = const SoglieVive()});

  /// Le soglie in uso, cosi' una prova puo' mettere le sue.
  final SoglieInUso soglie;

  Duration _tenuta = Duration.zero;
  bool _compiuta = false;

  /// Vero quando il fronte e' stato tenuto abbastanza a lungo.
  bool get compiuta => _compiuta;

  /// Quanto manca, da zero a uno. Serve alla scena per mostrare che il tempo
  /// sta passando invece di lasciare la persona ferma davanti a una richiesta
  /// muta.
  double get progresso {
    if (_compiuta) return 1;
    final richiesta = soglie.tenuta.inMicroseconds;
    if (richiesta <= 0) return 1;
    final q = _tenuta.inMicroseconds / richiesta;
    return q < 0 ? 0 : (q > 1 ? 1 : q);
  }

  /// Un fotogramma. Restituisce vero nell'istante in cui la tenuta si compie.
  bool passo({
    required double yaw,
    required double pitch,
    required Duration trascorso,
  }) {
    if (_compiuta) return false;
    final diFronte = yaw.abs() <= soglie.tolleranzaDelFronte &&
        pitch.abs() <= soglie.tolleranzaDelFronte;
    if (!diFronte) {
      // **PERDERE IL FRONTE AZZERA.** Senza questo, quattro istanti di
      // fronte sparsi in mezzo minuto varrebbero come mezzo secondo di
      // fronte tenuto, e la tenuta smetterebbe di misurare qualcosa.
      _tenuta = Duration.zero;
      return false;
    }
    _tenuta += trascorso;
    if (_tenuta >= soglie.tenuta) {
      _compiuta = true;
      return true;
    }
    return false;
  }

  /// Ricomincia da capo.
  void ricomincia() {
    _tenuta = Duration.zero;
    _compiuta = false;
  }
}
