import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/astro/birth_details.dart';
import '../../core/astro/birth_place.dart';
import '../../core/astro/place_repository.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/golden_motes.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'onboarding_controller.dart';
import 'widgets/sky_thread.dart';

/// Onboarding Il Risveglio: raccolta a passi dei dati di nascita, come una
/// piccola cerimonia. Attorno al campo centrale c'e' sempre vita: particelle
/// dorate che fluttuano e il filo del cielo che si compone a ogni dato.
class OnboardingForm extends StatelessWidget {
  const OnboardingForm({super.key, required this.onSubmit});

  final ValueChanged<BirthDetails> onSubmit;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<OnboardingController>();
    final palette = context.palette;

    final nodes = [
      SkyNode('Data', c.dateValid),
      SkyNode('Ora', c.time != null || c.timeUnknown),
      SkyNode('Luogo', c.placeValid),
    ];

    return Stack(
      children: [
        const Positioned.fill(child: GoldenMotes()),
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: SpacingTokens.xs),
              Text('ACCENDI IL TUO CIELO',
                  style: TypographyTokens.label(size: 13).copyWith(
                    color: palette.goldSoft,
                    letterSpacing: 3,
                  )),
              const SizedBox(height: SpacingTokens.sm),
              SkyThread(nodes: nodes),
              const SizedBox(height: SpacingTokens.md),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                  ),
                  child: _StepContent(key: ValueKey(c.step), controller: c),
                ),
              ),
              Row(
                children: [
                  if (c.stepIndex > 0)
                    TextButton(
                      onPressed: c.back,
                      child: Text('Indietro',
                          style: TypographyTokens.body(size: 14)
                              .copyWith(color: ColorTokens.textSecondary)),
                    ),
                  const Spacer(),
                  _ContinueButton(
                    label: c.isLastStep ? 'Rivela il mio cielo' : 'Continua',
                    enabled: c.canProceed,
                    onTap: () {
                      if (c.isLastStep) {
                        final details = c.build();
                        if (details != null) onSubmit(details);
                      } else {
                        c.next();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedScale(
      scale: enabled ? 1 : 0.97,
      duration: const Duration(milliseconds: 250),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor:
              enabled ? palette.gold : palette.gold.withValues(alpha: 0.3),
          foregroundColor: palette.deepest,
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.xl,
            vertical: SpacingTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          ),
        ),
        onPressed: enabled ? onTap : null,
        child: Text(label,
            style: TypographyTokens.body(size: 17, weight: 600)
                .copyWith(color: palette.deepest)),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({super.key, required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.step) {
      case OnboardingStep.date:
        return _DateStep(controller: controller);
      case OnboardingStep.time:
        return _TimeStep(controller: controller);
      case OnboardingStep.place:
        return _PlaceStep(controller: controller);
    }
  }
}

class _StepShell extends StatelessWidget {
  const _StepShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.expandChild = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TypographyTokens.display(size: 26)),
        const SizedBox(height: SpacingTokens.xs),
        Text(subtitle,
            style: TypographyTokens.body(size: 15)
                .copyWith(color: ColorTokens.textSecondary)),
        const SizedBox(height: SpacingTokens.xl),
        if (expandChild) Expanded(child: child) else child,
      ],
    );
  }
}

/// Cornice luminosa attorno al campo centrale: un alone che respira.
class _FieldAura extends StatelessWidget {
  const _FieldAura({required this.child, this.filled = false});
  final Widget child;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: filled ? 1 : 0.4),
      duration: const Duration(milliseconds: 500),
      builder: (context, v, child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          boxShadow: [
            BoxShadow(
              color: palette.glow.withValues(alpha: 0.18 * v),
              blurRadius: 34,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
      child: child,
    );
  }
}

class _DateStep extends StatelessWidget {
  const _DateStep({required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final date = controller.date;
    return _StepShell(
      title: 'Quando sei nato?',
      subtitle: 'La data e\' il primo filo del tuo cielo. E\' obbligatoria.',
      child: _FieldAura(
        filled: date != null,
        child: _TapField(
          icon: Icons.calendar_today_outlined,
          label: date == null
              ? 'Scegli la data di nascita'
              : DateFormat('d MMMM yyyy', 'it').format(date),
          filled: date != null,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime(now.year - 30, now.month, now.day),
              firstDate: DateTime(1900),
              lastDate: now,
              helpText: 'Data di nascita',
            );
            if (picked != null) {
              controller.setDate(picked);
              HapticFeedback.selectionClick(); // una stella si accende
            }
          },
        ),
      ),
    );
  }
}

class _TimeStep extends StatelessWidget {
  const _TimeStep({required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final time = controller.time;
    return _StepShell(
      title: 'A che ora?',
      subtitle:
          'L\'ora serve per l\'Ascendente e le Case. Se non la conosci, va bene lo stesso: leggeremo un cielo parziale.',
      child: Column(
        children: [
          _FieldAura(
            filled: time != null && !controller.timeUnknown,
            child: _TapField(
              icon: Icons.schedule_outlined,
              label: controller.timeUnknown
                  ? 'Ora non conosciuta'
                  : (time == null
                      ? 'Scegli l\'ora di nascita'
                      : time.format(context)),
              filled: time != null && !controller.timeUnknown,
              onTap: controller.timeUnknown
                  ? null
                  : () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime:
                            time ?? const TimeOfDay(hour: 12, minute: 0),
                        helpText: 'Ora di nascita',
                      );
                      if (picked != null) {
                        controller.setTime(picked);
                        HapticFeedback.selectionClick();
                      }
                    },
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          _CheckRow(
            label: 'Non conosco l\'ora',
            value: controller.timeUnknown,
            onChanged: (v) {
              controller.setTimeUnknown(v);
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }
}

class _PlaceStep extends StatefulWidget {
  const _PlaceStep({required this.controller});
  final OnboardingController controller;

  @override
  State<_PlaceStep> createState() => _PlaceStepState();
}

class _PlaceStepState extends State<_PlaceStep> {
  final _text = TextEditingController();
  List<BirthPlace> _results = const [];
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(_refresh);
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<PlaceRepository>();
    await repo.ensureLoaded();
    if (!mounted) return;
    setState(() {
      _ready = true;
      _results = repo.search(_text.text);
    });
  }

  void _refresh() {
    if (!_ready) return;
    final repo = context.read<PlaceRepository>();
    setState(() => _results = repo.search(_text.text, limit: 12));
  }

  @override
  void dispose() {
    _text.removeListener(_refresh);
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selected = widget.controller.place;

    return _StepShell(
      title: 'Dove sei nato?',
      subtitle: 'Il luogo ancora il tuo cielo alla terra. E\' obbligatorio.',
      expandChild: true,
      child: Column(
        children: [
          _FieldAura(
            filled: selected != null,
            child: TextField(
              controller: _text,
              style: TypographyTokens.body(size: 15),
              decoration: InputDecoration(
                hintText: selected != null
                    ? selected.displayLabel
                    : 'Scrivi il tuo comune di nascita',
                hintStyle: TypographyTokens.body(size: 15).copyWith(
                    color: selected != null
                        ? ColorTokens.textPrimary
                        : ColorTokens.textMuted),
                prefixIcon: Icon(Icons.search, color: palette.goldSoft),
                filled: true,
                fillColor: palette.surface.withValues(alpha: 0.5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                  borderSide:
                      BorderSide(color: palette.gold.withValues(alpha: 0.35)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                  borderSide: BorderSide(color: palette.gold),
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          if (!_ready)
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: Text('Sto radunando i luoghi...',
                  style: TypographyTokens.body(size: 13)
                      .copyWith(color: ColorTokens.textMuted)),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _results.length,
                itemBuilder: (context, i) {
                  final place = _results[i];
                  final isSel = place == selected;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                    child: DepthCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md,
                        vertical: SpacingTokens.sm,
                      ),
                      onTap: () {
                        widget.controller.setPlace(place);
                        HapticFeedback.selectionClick();
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Icon(isSel ? Icons.place : Icons.place_outlined,
                              color: isSel
                                  ? palette.goldSoft
                                  : ColorTokens.textSecondary,
                              size: 20),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: Text(place.displayLabel,
                                style: TypographyTokens.body(size: 15)),
                          ),
                          if (isSel)
                            Icon(Icons.check,
                                color: palette.goldSoft, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  const _TapField({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.lg,
      ),
      child: Row(
        children: [
          Icon(icon, color: palette.goldSoft, size: 24),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              label,
              style: TypographyTokens.display(size: 18).copyWith(
                color: filled
                    ? ColorTokens.textPrimary
                    : ColorTokens.textSecondary,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: ColorTokens.textMuted),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? palette.gold : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
            ),
            child: value
                ? Icon(Icons.check, size: 16, color: palette.deepest)
                : null,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Text(label, style: TypographyTokens.body(size: 15)),
        ],
      ),
    );
  }
}
