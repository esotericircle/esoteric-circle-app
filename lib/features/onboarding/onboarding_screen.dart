import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/city_catalog.dart';
import '../../core/astro/night_sky.dart';
import '../../core/astro/zodiac.dart';
import '../../core/chat/user_profile.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/birth_place.dart';
import '../../core/identity/circle_seal.dart';
import '../../core/identity/profile_controller.dart';
import '../../design_system/components/zodiac_wheel.dart' show drawZodiacGlyph;
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../identity/seal_painter.dart';
import 'reveal_screen.dart';
import 'risveglio_ignitions.dart';

/// "Il Risveglio": la primissima soglia del cerchio, un rituale a passi sul
/// cosmo, mostrato una sola volta al primo avvio prima del Santuario.
///
/// Non piu' un semplice saluto: il Cerchio accoglie, poi la persona attraversa i
/// passi che compongono il suo cielo. La data, e nasce il Sole nel segno (reale,
/// dalla tavola tropicale). L'ora, e sorge l'Ascendente (segnaposto dichiarato:
/// il calcolo vero arrivera' dal motore a effemeridi); se non la sa, si salta con
/// grazia. Il luogo, e il cielo si ancora alla Terra. Il nome. Il vocativo.
/// Infine il sigillo, che pulsa come un cuore. Ogni passo ha la sua accensione
/// disegnata dal codice, ridotta sotto Riduci Movimento.
///
/// Nessun Maestro compare qui: al Risveglio non e' ancora stato scelto, quindi
/// nessun colore di Maestro. La base e' la tavolozza cosmica neutra del Cerchio
/// (fondo nero, oro, nebulose viola): il Maestro si rivela solo alla fine.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.clock});

  /// Orologio iniettabile per i test. Di default l'ora locale.
  final DateTime Function()? clock;

  static Route<void> route({DateTime Function()? clock}) {
    return MaterialPageRoute<void>(
      builder: (_) => OnboardingScreen(clock: clock),
      fullscreenDialog: false,
    );
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// I passi del rituale, in ordine. L'accoglienza apre, il sigillo chiude.
enum _Step { accoglienza, data, ora, luogo, nome, vocativo, sigillo }

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ignite;

  // La tavolozza cosmica neutra del Cerchio: nessun accento di Maestro, che al
  // Risveglio non e' ancora scelto. Fondo nero, oro, alone viola desaturato.
  static const MaestroPalette _palette = MaestroPalette.neutral;

  _Step _step = _Step.accoglienza;

  // I dati raccolti lungo il rituale.
  DateTime _birthDate = DateTime(1990, 6, 15);
  bool _timeKnown = true;
  int _hour = 12;
  int _minute = 0;
  BirthPlace? _place;
  final TextEditingController _placeCtrl = TextEditingController();
  List<City> _placeResults = const [];
  final TextEditingController _nameCtrl = TextEditingController();
  CourtesyForm? _courtesy;

  @override
  void initState() {
    super.initState();
    _ignite = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playIgnition();
  }

  @override
  void dispose() {
    _ignite.dispose();
    _placeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  void _playIgnition() {
    if (_reduceMotion) {
      _ignite.value = 1.0; // gia' accesa, senza moto
    } else {
      _ignite
        ..reset()
        ..forward();
    }
  }

  Zodiac get _sunSign => NightSky.sunSign(_birthDate);

  BirthIdentity get _identity => BirthIdentity.fromParts(
        birthDate: _birthDate,
        birthHour: _timeKnown ? _hour : null,
        birthMinute: _timeKnown ? _minute : null,
        birthPlace: _place,
      );

  String get _name =>
      _nameCtrl.text.trim().isEmpty ? 'Anima del Cerchio' : _nameCtrl.text.trim();

  void _goNext() {
    const order = _Step.values;
    final i = _step.index;
    if (i < order.length - 1) {
      setState(() => _step = order[i + 1]);
      _playIgnition();
    }
  }

  /// Sigilla il rito: salva profilo e identita', poi mostra la rivelazione del
  /// cielo, che a sua volta entra nel Cerchio.
  void _finish() {
    final profile = context.read<ProfileController>();
    profile.setProfile(UserProfile(
      displayName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      courtesyForm: _courtesy ?? CourtesyForm.neutral,
    ));
    profile.setIdentity(_identity);
    Navigator.of(context)
        .pushReplacement(RevealScreen.route(clock: widget.clock));
  }

  void _searchPlace(String query) {
    setState(() => _placeResults = CityCatalog.search(query));
  }

  void _pickCity(City city) {
    setState(() {
      _place = city.toPlace();
      _placeCtrl.text = city.label;
      _placeResults = const [];
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.4),
            radius: 1.2,
            colors: [
              _palette.surfaceElevated.withValues(alpha: 0.55),
              ColorTokens.neutralDeepest,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
            child: Column(
              key: const Key('onboarding_risveglio'),
              children: [
                const SizedBox(height: SpacingTokens.lg),
                if (_step != _Step.accoglienza)
                  _StepDots(
                    total: _Step.values.length - 1,
                    current: _step.index - 1,
                    palette: _palette,
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(
                        milliseconds: _reduceMotion ? 0 : 260),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildStep(),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.accoglienza:
        return _accoglienza();
      case _Step.data:
        return _dataStep();
      case _Step.ora:
        return _oraStep();
      case _Step.luogo:
        return _luogoStep();
      case _Step.nome:
        return _nomeStep();
      case _Step.vocativo:
        return _vocativoStep();
      case _Step.sigillo:
        return _sigilloStep();
    }
  }

  // --- Passo 0: l'accoglienza del Cerchio, senza Maestro ---
  Widget _accoglienza() {
    return _StepBody(
      visual: _CosmicGlow(palette: _palette, ignite: _ignite),
      title: 'Il Risveglio',
      subtitle:
          'Sei sulla soglia del Cerchio. Comporremo insieme il tuo cielo, un '
          'passo alla volta.',
      content: Text(
        'Nulla di inventato: quel che non si può ancora calcolare resta '
        'marcato. La tua Guida si rivelerà solo alla fine.',
        textAlign: TextAlign.center,
        style: TypographyTokens.body(size: 14).copyWith(
          color: ColorTokens.textSecondary,
          height: 1.5,
        ),
      ),
      cta: _Cta(label: 'Inizia il rito', palette: _palette, onTap: _goNext),
    );
  }

  // --- Passo 1: la data, e nasce il Sole nel segno ---
  Widget _dataStep() {
    return _StepBody(
      visual: AnimatedBuilder(
        animation: _ignite,
        builder: (_, __) => CustomPaint(
          painter: SunInSignPainter(
            sign: _sunSign,
            t: _ignite.value,
            color: _palette.goldSoft,
          ),
        ),
      ),
      title: 'Quando hai visto la luce',
      subtitle:
          'Dalla tua data nasce il Sole nel segno. Questo è reale, dalla '
          'tavola dei segni.',
      content: Column(
        children: [
          _DatePicker(
            date: _birthDate,
            palette: _palette,
            onChanged: (d) => setState(() => _birthDate = d),
          ),
          const SizedBox(height: SpacingTokens.md),
          _SignBadge(sign: _sunSign, palette: _palette),
        ],
      ),
      cta: _Cta(label: 'Continua', palette: _palette, onTap: _goNext),
    );
  }

  // --- Passo 2: l'ora, e sorge l'Ascendente ---
  Widget _oraStep() {
    return _StepBody(
      visual: AnimatedBuilder(
        animation: _ignite,
        builder: (_, __) => CustomPaint(
          painter: HorizonRisePainter(
            t: _ignite.value,
            color: _palette.goldSoft,
            known: _timeKnown,
          ),
        ),
      ),
      title: 'A che ora, se lo sai',
      subtitle:
          'Con l\'ora sorge l\'Ascendente all\'orizzonte. Il suo calcolo esatto '
          'arriva dal motore a effemeridi, quindi per ora è un segnaposto.',
      content: Column(
        children: [
          AnimatedOpacity(
            opacity: _timeKnown ? 1 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: _TimePicker(
              hour: _hour,
              minute: _minute,
              enabled: _timeKnown,
              palette: _palette,
              onChanged: (h, m) => setState(() {
                _hour = h;
                _minute = m;
              }),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          _SkipTimeToggle(
            skipped: !_timeKnown,
            palette: _palette,
            onChanged: (skip) => setState(() {
              _timeKnown = !skip;
              _playIgnition();
            }),
          ),
          if (!_timeKnown) ...[
            const SizedBox(height: SpacingTokens.sm),
            const _ProvvisorioNote(
              text:
                  'Va bene così. Senza l\'ora l\'Ascendente si salta: il resto '
                  'del tuo cielo resta saldo.',
            ),
          ] else
            const _AscendantProvvisorio(),
        ],
      ),
      cta: _Cta(label: 'Continua', palette: _palette, onTap: _goNext),
    );
  }

  // --- Passo 3: il luogo, e il cielo si ancora alla Terra ---
  Widget _luogoStep() {
    return _StepBody(
      visual: AnimatedBuilder(
        animation: _ignite,
        builder: (_, __) => CustomPaint(
          painter: HousesAnchorPainter(
            t: _ignite.value,
            color: _palette.goldSoft,
            anchored: _place != null,
          ),
        ),
      ),
      title: 'Dove hai visto la luce',
      subtitle:
          'Il luogo ancora il cielo alla Terra e dispone la ruota delle case.',
      content: _PlaceField(
        controller: _placeCtrl,
        results: _placeResults,
        chosen: _place,
        palette: _palette,
        onChanged: _searchPlace,
        onPick: _pickCity,
      ),
      cta: _Cta(
        label: _place == null ? 'Salta per ora' : 'Continua',
        palette: _palette,
        onTap: _goNext,
      ),
    );
  }

  // --- Passo 4: il nome ---
  Widget _nomeStep() {
    return _StepBody(
      visual: _NameGlow(
        name: _nameCtrl.text.trim(),
        palette: _palette,
        ignite: _ignite,
      ),
      title: 'Come ti chiami',
      subtitle: 'Il cerchio ti chiamerà per nome, non con un\'etichetta.',
      content: TextField(
        key: const Key('risveglio_nome_field'),
        controller: _nameCtrl,
        textAlign: TextAlign.center,
        onChanged: (_) => setState(() {}),
        style: TypographyTokens.display(size: 22)
            .copyWith(color: _palette.goldSoft),
        cursorColor: _palette.goldSoft,
        decoration: InputDecoration(
          hintText: 'Il tuo nome',
          hintStyle: TypographyTokens.body(size: 16)
              .copyWith(color: ColorTokens.textSecondary),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: _palette.gold.withValues(alpha: 0.4)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: _palette.goldSoft),
          ),
        ),
      ),
      cta: _Cta(
        label: 'Continua',
        palette: _palette,
        enabled: _nameCtrl.text.trim().isNotEmpty,
        onTap: _goNext,
      ),
    );
  }

  // --- Passo 5: il vocativo ---
  Widget _vocativoStep() {
    return _StepBody(
      visual: _CosmicGlow(palette: _palette, ignite: _ignite),
      title: 'Come vuoi che ti parli',
      subtitle:
          'Sceglilo tu: accorderemo ogni frase al vocativo che preferisci.',
      content: _VocativoChoice(
        selected: _courtesy,
        palette: _palette,
        onChanged: (c) => setState(() => _courtesy = c),
      ),
      cta: _Cta(
        label: 'Continua',
        palette: _palette,
        enabled: _courtesy != null,
        onTap: _goNext,
      ),
    );
  }

  // --- Passo 6: il sigillo, che pulsa come un cuore ---
  Widget _sigilloStep() {
    final seal = CircleSeal.from(name: _name, identity: _identity);
    return _StepBody(
      visual: _PulsingSeal(
        seal: seal,
        palette: _palette,
        reduceMotion: _reduceMotion,
        onComplete: _finish,
      ),
      title: 'Posa il dito al centro',
      subtitle:
          'Il tuo Sigillo pulsa come un cuore. Tienilo premuto per sigillare il '
          'rito.',
      content: const SizedBox(height: SpacingTokens.sm),
      cta: null,
    );
  }
}

// ------------------------------------------------------------------
// Impalcatura comune di un passo: visivo in alto, titolo, sottotitolo,
// corpo, e l'invito a proseguire.
// ------------------------------------------------------------------
class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.visual,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.cta,
  });

  final Widget visual;
  final String title;
  final String subtitle;
  final Widget content;
  final Widget? cta;

  @override
  Widget build(BuildContext context) {
    // Il contenuto scorre, l'invito a proseguire resta fisso in basso e sempre
    // raggiungibile: nessun passo finisce sotto il bordo.
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: SpacingTokens.md),
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: RepaintBoundary(child: visual),
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TypographyTokens.display(size: 24)
                      .copyWith(color: const Color(0xFFE8C463)),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TypographyTokens.body(size: 15).copyWith(
                    color: ColorTokens.textPrimary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
                content,
                const SizedBox(height: SpacingTokens.lg),
              ],
            ),
          ),
        ),
        if (cta != null)
          Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.sm),
            child: cta,
          ),
      ],
    );
  }
}

/// I pallini di avanzamento del rituale.
class _StepDots extends StatelessWidget {
  const _StepDots({
    required this.total,
    required this.current,
    required this.palette,
  });

  final int total;
  final int current;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: i == current ? 18 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: i <= current
                  ? palette.goldSoft
                  : palette.gold.withValues(alpha: 0.25),
            ),
          ),
      ],
    );
  }
}

/// Una soglia cosmica neutra che respira con l'accensione del passo: un cerchio
/// d'oro con un alone viola desaturato e poche stelle. Nessun volto di Maestro,
/// che al Risveglio non e' ancora scelto.
class _CosmicGlow extends StatelessWidget {
  const _CosmicGlow({required this.palette, required this.ignite});

  final MaestroPalette palette;
  final Animation<double> ignite;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: ignite,
        builder: (_, __) => SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: _CosmicGlowPainter(palette: palette, t: ignite.value),
          ),
        ),
      ),
    );
  }
}

/// Disegna la soglia cosmica: un anello d'oro, un alone viola desaturato che
/// cresce con l'accensione, e poche stelle sparse. Base cosmica neutra, mai un
/// colore di Maestro.
class _CosmicGlowPainter extends CustomPainter {
  _CosmicGlowPainter({required this.palette, required this.t});

  final MaestroPalette palette;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.34;

    // Alone viola desaturato che respira con l'accensione.
    canvas.drawCircle(
      c,
      r * 2.1,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.glow.withValues(alpha: 0.32 * t),
          palette.primary.withValues(alpha: 0.12 * t),
          const Color(0x00000000),
        ], stops: const [
          0.0,
          0.5,
          1.0
        ]).createShader(Rect.fromCircle(center: c, radius: r * 2.1)),
    );

    // Poche stelle attorno, la volta che si intuisce.
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    const stars = [
      Offset(-0.9, -0.5), Offset(0.8, -0.7), Offset(1.05, 0.35),
      Offset(-1.1, 0.4), Offset(0.2, -1.05), Offset(-0.35, 1.05),
      Offset(0.75, 0.9),
    ];
    for (var i = 0; i < stars.length; i++) {
      final p = c + stars[i] * r;
      canvas.drawCircle(p, (i.isEven ? 1.4 : 0.9), starPaint);
    }

    // L'anello d'oro portante.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = palette.gold.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      c,
      r * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = palette.goldSoft.withValues(alpha: 0.4),
    );

    // Un piccolo cuore di luce dorata al centro, che si accende.
    canvas.drawCircle(
      c,
      r * 0.18,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.goldSoft.withValues(alpha: 0.9 * t),
          palette.gold.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: c, radius: r * 0.18)),
    );
  }

  @override
  bool shouldRepaint(_CosmicGlowPainter old) =>
      old.t != t || old.palette != palette;
}

/// Il nome che si accende, come inciso.
class _NameGlow extends StatelessWidget {
  const _NameGlow({
    required this.name,
    required this.palette,
    required this.ignite,
  });

  final String name;
  final MaestroPalette palette;
  final Animation<double> ignite;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: ignite,
        builder: (_, __) => Text(
          name.isEmpty ? '...' : name,
          textAlign: TextAlign.center,
          style: TypographyTokens.display(size: 34).copyWith(
            color: palette.goldSoft,
            shadows: [
              Shadow(
                color: palette.glow.withValues(alpha: 0.6 * ignite.value),
                blurRadius: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// L'invito a proseguire, in fondo al passo.
class _Cta extends StatelessWidget {
  const _Cta({
    required this.label,
    required this.palette,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final MaestroPalette palette;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('onboarding_continue'),
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
                gradient: LinearGradient(colors: [
                  palette.primary.withValues(alpha: 0.85),
                  palette.surfaceElevated.withValues(alpha: 0.85),
                ]),
                border:
                    Border.all(color: palette.gold.withValues(alpha: 0.7)),
              ),
              child: Text(label,
                  style: TypographyTokens.display(size: 17)
                      .copyWith(color: palette.goldSoft)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Selettore di data a tre ruote: giorno, mese, anno.
class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.date,
    required this.palette,
    required this.onChanged,
  });

  final DateTime date;
  final MaestroPalette palette;
  final ValueChanged<DateTime> onChanged;

  static const _mesi = [
    'Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu',
    'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic',
  ];

  int get _daysInMonth => DateTime(date.year, date.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final years = [for (var y = DateTime.now().year; y >= 1920; y--) y];
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _wheel<int>(
          key: const Key('risveglio_giorno'),
          value: date.day.clamp(1, _daysInMonth),
          items: [for (var d = 1; d <= _daysInMonth; d++) d],
          label: (d) => d.toString().padLeft(2, '0'),
          onChanged: (d) =>
              onChanged(DateTime(date.year, date.month, d)),
        ),
        _wheel<int>(
          key: const Key('risveglio_mese'),
          value: date.month,
          items: [for (var m = 1; m <= 12; m++) m],
          label: (m) => _mesi[m - 1],
          onChanged: (m) {
            final maxDay = DateTime(date.year, m + 1, 0).day;
            onChanged(DateTime(date.year, m, date.day.clamp(1, maxDay)));
          },
        ),
        _wheel<int>(
          key: const Key('risveglio_anno'),
          value: date.year,
          items: years,
          label: (y) => y.toString(),
          onChanged: (y) {
            final maxDay = DateTime(y, date.month + 1, 0).day;
            onChanged(DateTime(y, date.month, date.day.clamp(1, maxDay)));
          },
        ),
      ],
      ),
    );
  }

  Widget _wheel<T>({
    required Key key,
    required T value,
    required List<T> items,
    required String Function(T) label,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        color: palette.deepest.withValues(alpha: 0.4),
      ),
      child: DropdownButton<T>(
        key: key,
        value: value,
        dropdownColor: palette.deepest,
        underline: const SizedBox.shrink(),
        iconEnabledColor: palette.goldSoft,
        style: TypographyTokens.display(size: 18)
            .copyWith(color: palette.goldSoft),
        items: [
          for (final it in items)
            DropdownMenuItem<T>(value: it, child: Text(label(it))),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

/// Selettore d'ora: ore e minuti.
class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.hour,
    required this.minute,
    required this.enabled,
    required this.palette,
    required this.onChanged,
  });

  final int hour;
  final int minute;
  final bool enabled;
  final MaestroPalette palette;
  final void Function(int hour, int minute) onChanged;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _wheel(
            key: const Key('risveglio_ora'),
            value: hour,
            items: [for (var h = 0; h < 24; h++) h],
            onChanged: (h) => onChanged(h, minute),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
            child: Text(':',
                style: TypographyTokens.display(size: 20)
                    .copyWith(color: palette.goldSoft)),
          ),
          _wheel(
            key: const Key('risveglio_minuto'),
            value: minute,
            items: [for (var m = 0; m < 60; m++) m],
            onChanged: (m) => onChanged(hour, m),
          ),
        ],
      ),
    );
  }

  Widget _wheel({
    required Key key,
    required int value,
    required List<int> items,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        color: palette.deepest.withValues(alpha: 0.4),
      ),
      child: DropdownButton<int>(
        key: key,
        value: value,
        dropdownColor: palette.deepest,
        underline: const SizedBox.shrink(),
        iconEnabledColor: palette.goldSoft,
        style: TypographyTokens.display(size: 18)
            .copyWith(color: palette.goldSoft),
        items: [
          for (final it in items)
            DropdownMenuItem<int>(
              value: it,
              child: Text(it.toString().padLeft(2, '0')),
            ),
        ],
        onChanged: enabled ? (v) => v == null ? null : onChanged(v) : null,
      ),
    );
  }
}

/// L'opzione "Non la so" per l'ora di nascita.
class _SkipTimeToggle extends StatelessWidget {
  const _SkipTimeToggle({
    required this.skipped,
    required this.palette,
    required this.onChanged,
  });

  final bool skipped;
  final MaestroPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('risveglio_ora_skip'),
      onPressed: () => onChanged(!skipped),
      icon: Icon(
        skipped ? Icons.check_circle_rounded : Icons.circle_outlined,
        size: 18,
        color: palette.goldSoft,
      ),
      label: Text(
        'Non la so',
        style: TypographyTokens.body(size: 14)
            .copyWith(color: palette.goldSoft),
      ),
    );
  }
}

/// La nota che marca l'Ascendente come provvisorio quando l'ora c'e'.
class _AscendantProvvisorio extends StatelessWidget {
  const _AscendantProvvisorio();

  @override
  Widget build(BuildContext context) {
    return const _ProvvisorioNote(
      text:
          'L\'Ascendente esatto arriva col motore a effemeridi. Per ora è un '
          'segnaposto, non una posizione vera.',
    );
  }
}

/// Una nota provvisoria, con il suo distintivo, per non spacciare segnaposto per
/// contenuto reale.
class _ProvvisorioNote extends StatelessWidget {
  const _ProvvisorioNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFE8C463);
    return Container(
      key: const Key('risveglio_provvisorio'),
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: gold.withValues(alpha: 0.3)),
        color: gold.withValues(alpha: 0.06),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: gold.withValues(alpha: 0.18),
            ),
            child: Text('Provvisorio',
                style: TypographyTokens.body(size: 10)
                    .copyWith(color: gold, letterSpacing: 0.5)),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(text,
                style: TypographyTokens.body(size: 12).copyWith(
                    color: ColorTokens.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

/// Il campo di ricerca del luogo, con i suggerimenti dell'elenco offline.
class _PlaceField extends StatelessWidget {
  const _PlaceField({
    required this.controller,
    required this.results,
    required this.chosen,
    required this.palette,
    required this.onChanged,
    required this.onPick,
  });

  final TextEditingController controller;
  final List<City> results;
  final BirthPlace? chosen;
  final MaestroPalette palette;
  final ValueChanged<String> onChanged;
  final ValueChanged<City> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          key: const Key('risveglio_luogo_field'),
          controller: controller,
          textAlign: TextAlign.center,
          onChanged: onChanged,
          style: TypographyTokens.body(size: 17)
              .copyWith(color: palette.goldSoft),
          cursorColor: palette.goldSoft,
          decoration: InputDecoration(
            hintText: 'Cerca la tua città',
            hintStyle: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textSecondary),
            prefixIcon: Icon(Icons.search_rounded, color: palette.goldSoft),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: palette.gold.withValues(alpha: 0.4)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: palette.goldSoft),
            ),
          ),
        ),
        if (results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: SpacingTokens.sm),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
              color: palette.deepest.withValues(alpha: 0.6),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  for (final c in results)
                    InkWell(
                      key: Key('citta_${c.name}'),
                      onTap: () => onPick(c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.md,
                            vertical: SpacingTokens.sm),
                        child: Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 16, color: palette.goldSoft),
                            const SizedBox(width: SpacingTokens.sm),
                            Expanded(
                              child: Text(c.label,
                                  style: TypographyTokens.body(size: 15)
                                      .copyWith(
                                          color: ColorTokens.textPrimary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (chosen != null && results.isEmpty) ...[
          const SizedBox(height: SpacingTokens.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public_rounded, size: 16, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Text('${chosen!.city} · ${chosen!.timeZoneId}',
                  style: TypographyTokens.body(size: 13)
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
          ),
        ],
        // Citta' non in elenco: si guida verso la piu' vicina fra le grandi,
        // cosi' non e' mai un vicolo cieco.
        if (chosen == null &&
            results.isEmpty &&
            controller.text.trim().length >= 2) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Non è in elenco? Scegli la città grande più vicina: '
            'il cielo si ancora comunque.',
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 12)
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
        ],
      ],
    );
  }
}

/// La scelta del vocativo: Lui, Lei, Neutro.
class _VocativoChoice extends StatelessWidget {
  const _VocativoChoice({
    required this.selected,
    required this.palette,
    required this.onChanged,
  });

  final CourtesyForm? selected;
  final MaestroPalette palette;
  final ValueChanged<CourtesyForm> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [
      (CourtesyForm.masculine, 'Lui', 'lui'),
      (CourtesyForm.feminine, 'Lei', 'lei'),
      (CourtesyForm.neutral, 'Neutro', 'neutro'),
    ];
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final (form, label, keyId) in options)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              child: _chip(form, label, keyId),
            ),
        ],
      ),
    );
  }

  Widget _chip(CourtesyForm form, String label, String keyId) {
    final on = selected == form;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('vocativo_$keyId'),
        onTap: () => onChanged(form),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg, vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            gradient: on
                ? LinearGradient(colors: [
                    palette.primary.withValues(alpha: 0.9),
                    palette.surfaceElevated.withValues(alpha: 0.9),
                  ])
                : null,
            border: Border.all(
                color: palette.gold.withValues(alpha: on ? 0.9 : 0.35)),
          ),
          child: Text(label,
              style: TypographyTokens.display(size: 16).copyWith(
                  color: on ? palette.goldSoft : ColorTokens.textSecondary)),
        ),
      ),
    );
  }
}

/// Il distintivo del segno solare, ricavato in modo reale dalla data.
class _SignBadge extends StatelessWidget {
  const _SignBadge({required this.sign, required this.palette});

  final Zodiac sign;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.deepest.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_rounded, size: 18, color: palette.goldSoft),
          const SizedBox(width: SpacingTokens.sm),
          Text('Sole in ${sign.italianName}',
              style: TypographyTokens.display(size: 16)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(width: SpacingTokens.sm),
          // Il simbolo del segno, tracciato a vettori dal codice, non un glifo
          // di font: si rende identico ovunque.
          SizedBox(
            width: 20,
            height: 20,
            child: CustomPaint(
              painter: _GlyphPainter(sign: sign, color: palette.goldSoft),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il simbolo di un segno, tracciato a vettori dal codice.
class _GlyphPainter extends CustomPainter {
  _GlyphPainter({required this.sign, required this.color});

  final Zodiac sign;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    drawZodiacGlyph(
        canvas, sign, size.center(Offset.zero), size.shortestSide * 0.42, paint);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.sign != sign || old.color != color;
}

/// Il Sigillo che pulsa come un cuore sotto il dito; tenuto premuto, sigilla il
/// rito. Sotto Riduci Movimento non pulsa: un tocco sigilla.
class _PulsingSeal extends StatefulWidget {
  const _PulsingSeal({
    required this.seal,
    required this.palette,
    required this.reduceMotion,
    required this.onComplete,
  });

  final CircleSeal seal;
  final MaestroPalette palette;
  final bool reduceMotion;
  final VoidCallback onComplete;

  @override
  State<_PulsingSeal> createState() => _PulsingSealState();
}

class _PulsingSealState extends State<_PulsingSeal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heart;
  bool _sealed = false;

  @override
  void initState() {
    super.initState();
    _heart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _heart.dispose();
    super.dispose();
  }

  void _startBeat() {
    if (widget.reduceMotion) return;
    _heart.repeat(reverse: true);
  }

  void _stopBeat() {
    if (_heart.isAnimating) _heart.stop();
    _heart.value = 0;
  }

  void _seal() {
    if (_sealed) return;
    _sealed = true;
    _stopBeat();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        key: const Key('risveglio_sigillo'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _startBeat(),
        onTapUp: (_) {
          _stopBeat();
          if (widget.reduceMotion) _seal();
        },
        onTapCancel: _stopBeat,
        onLongPress: _seal,
        child: AnimatedBuilder(
          animation: _heart,
          builder: (_, child) {
            final beat = widget.reduceMotion
                ? 0.0
                : Curves.easeInOut.transform(_heart.value);
            final scale = 1.0 + 0.06 * beat;
            return Transform.scale(scale: scale, child: child);
          },
          child: SizedBox(
            width: 150,
            height: 150,
            child: CustomPaint(
              painter: SealPainter(seal: widget.seal, progress: 1.0),
            ),
          ),
        ),
      ),
    );
  }
}
