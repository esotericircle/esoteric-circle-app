import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/astro/birth_details.dart';
import '../../core/astro/birth_place.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'onboarding_controller.dart';

/// Onboarding Il Risveglio: raccolta a passi dei dati di nascita.
///
/// Data e luogo obbligatori, ora e genere opzionali. Registrazione progressiva
/// e anonima: nessun contatto, il telefono non entra mai nel form.
class OnboardingForm extends StatelessWidget {
  const OnboardingForm({super.key, required this.onSubmit});

  final ValueChanged<BirthDetails> onSubmit;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<OnboardingController>();
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SpacingTokens.xs),
          Text('IL RISVEGLIO',
              style: TypographyTokens.body(size: 12).copyWith(
                color: palette.goldSoft,
                letterSpacing: 3,
              )),
          const SizedBox(height: SpacingTokens.xs),
          _ProgressDots(count: c.stepsCount, index: c.stepIndex),
          const SizedBox(height: SpacingTokens.lg),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _StepContent(
                key: ValueKey(c.step),
                controller: c,
              ),
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
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: c.canProceed
                      ? palette.gold
                      : palette.gold.withValues(alpha: 0.3),
                  foregroundColor: palette.deepest,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.xl,
                    vertical: SpacingTokens.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusPill),
                  ),
                ),
                onPressed: c.canProceed
                    ? () {
                        if (c.isLastStep) {
                          final details = c.build();
                          if (details != null) onSubmit(details);
                        } else {
                          c.next();
                        }
                      }
                    : null,
                child: Text(
                  c.isLastStep ? 'Rivela il mio cielo' : 'Continua',
                  style: TypographyTokens.body(size: 15, weight: 600)
                      .copyWith(color: palette.deepest),
                ),
              ),
            ],
          ),
        ],
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
      case OnboardingStep.gender:
        return _GenderStep(controller: controller);
    }
  }
}

class _StepShell extends StatelessWidget {
  const _StepShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

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
        const SizedBox(height: SpacingTokens.lg),
        Expanded(child: child),
      ],
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
      child: Align(
        alignment: Alignment.topCenter,
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
            if (picked != null) controller.setDate(picked);
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
          _TapField(
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
                      initialTime: time ?? const TimeOfDay(hour: 12, minute: 0),
                      helpText: 'Ora di nascita',
                    );
                    if (picked != null) controller.setTime(picked);
                  },
          ),
          const SizedBox(height: SpacingTokens.md),
          _CheckRow(
            label: 'Non conosco l\'ora',
            value: controller.timeUnknown,
            onChanged: controller.setTimeUnknown,
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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final results = BirthPlaces.all
        .where((p) => p.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final selected = widget.controller.place;

    return _StepShell(
      title: 'Dove sei nato?',
      subtitle: 'Il luogo ancora il tuo cielo alla terra. E\' obbligatorio.',
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            style: TypographyTokens.body(size: 15),
            decoration: InputDecoration(
              hintText: 'Cerca la citta\'',
              hintStyle: TypographyTokens.body(size: 15)
                  .copyWith(color: ColorTokens.textMuted),
              prefixIcon: Icon(Icons.search, color: palette.goldSoft),
              filled: true,
              fillColor: ColorTokens.glassTint,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide: BorderSide(
                    color: palette.gold.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide: BorderSide(color: palette.gold),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, i) {
                final place = results[i];
                final isSel = place == selected;
                return Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                  child: DepthCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    onTap: () => widget.controller.setPlace(place),
                    child: Row(
                      children: [
                        Icon(
                          isSel
                              ? Icons.place
                              : Icons.place_outlined,
                          color: isSel
                              ? palette.goldSoft
                              : ColorTokens.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(place.label,
                            style: TypographyTokens.body(size: 15)),
                        const Spacer(),
                        if (isSel)
                          Icon(Icons.check, color: palette.goldSoft, size: 18),
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

class _GenderStep extends StatelessWidget {
  const _GenderStep({required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _StepShell(
      title: 'Come ti identifichi?',
      subtitle: 'Opzionale, e non cambia il calcolo del cielo.',
      child: Align(
        alignment: Alignment.topCenter,
        child: Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          children: [
            for (final g in Gender.values)
              GestureDetector(
                onTap: () => controller.setGender(
                    controller.gender == g ? null : g),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.md,
                    vertical: SpacingTokens.sm,
                  ),
                  decoration: BoxDecoration(
                    color: controller.gender == g
                        ? palette.gold.withValues(alpha: 0.2)
                        : ColorTokens.glassTint,
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusPill),
                    border: Border.all(
                      color: controller.gender == g
                          ? palette.gold
                          : ColorTokens.glassStroke,
                    ),
                  ),
                  child: Text(
                    g.label,
                    style: TypographyTokens.body(size: 14).copyWith(
                      color: controller.gender == g
                          ? palette.goldSoft
                          : ColorTokens.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
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
        vertical: SpacingTokens.md,
      ),
      child: Row(
        children: [
          Icon(icon, color: palette.goldSoft, size: 22),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              label,
              style: TypographyTokens.body(size: 16).copyWith(
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
          Container(
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

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: i == index ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i <= index
                    ? palette.gold
                    : palette.gold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              ),
            ),
          ),
      ],
    );
  }
}
