import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/identity/identity_controller.dart';
import '../../design_system/components/golden_motes.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'widgets/stardust_name.dart';

/// Nome e forma di cortesia, subito dopo l'intro. Il nome si compone in
/// calligrafia dorata di polvere di stelle mentre l'utente scrive.
class NameStep extends StatefulWidget {
  const NameStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    final identity = context.read<IdentityController>();
    _text = TextEditingController(text: identity.name);
    _text.addListener(() => identity.setName(_text.text));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final identity = context.watch<IdentityController>();

    return Stack(
      children: [
        const Positioned.fill(child: GoldenMotes(count: 20)),
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          // Riempie l'altezza sui grandi schermi (lo Spacer spinge in basso la
          // forma di cortesia), ma scorre con grazia su schermi piu' piccoli
          // cosi' i testi generosi non vanno mai in overflow.
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: SpacingTokens.md),
              Text('IL CERCHIO TI ACCOGLIE',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.label(size: 13)
                      .copyWith(color: palette.goldSoft, letterSpacing: 3)),
              const SizedBox(height: SpacingTokens.lg),
              Text('Come vuoi che ti chiami il cerchio?',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.display(size: 26)),
              const SizedBox(height: SpacingTokens.lg),
              StardustName(name: identity.name),
              const SizedBox(height: SpacingTokens.md),
              _NameField(controller: _text),
              const Spacer(),
              Text('Come preferisci che ci si rivolga a te?',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.body(size: TypographyTokens.guide)
                      .copyWith(color: ColorTokens.textSecondary)),
              const SizedBox(height: SpacingTokens.md),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: SpacingTokens.sm,
                runSpacing: SpacingTokens.sm,
                children: [
                  for (final f in AddressForm.values)
                    _FormChip(
                      form: f,
                      selected: identity.form == f,
                      onTap: () => identity.setForm(f),
                    ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xl),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: identity.hasName
                      ? palette.gold
                      : palette.gold.withValues(alpha: 0.3),
                  foregroundColor: palette.deepest,
                  padding:
                      const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusPill),
                  ),
                ),
                onPressed: identity.hasName ? widget.onContinue : null,
                child: Text('Accendi il tuo cielo',
                    style: TypographyTokens.body(size: 17, weight: 600)
                        .copyWith(color: palette.deepest)),
              ),
              const SizedBox(height: SpacingTokens.sm),
            ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.words,
      style: TypographyTokens.body(size: TypographyTokens.guide),
      decoration: InputDecoration(
        hintText: 'scrivi il tuo nome',
        hintStyle: TypographyTokens.body(size: TypographyTokens.guide)
            .copyWith(color: ColorTokens.textMuted),
        filled: true,
        fillColor: palette.surface.withValues(alpha: 0.4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          borderSide: BorderSide(color: palette.gold.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          borderSide: BorderSide(color: palette.gold),
        ),
      ),
    );
  }
}

class _FormChip extends StatelessWidget {
  const _FormChip({
    required this.form,
    required this.selected,
    required this.onTap,
  });

  final AddressForm form;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? palette.gold.withValues(alpha: 0.2)
              : ColorTokens.glassTint,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(
            color: selected ? palette.gold : ColorTokens.glassStroke,
          ),
        ),
        child: Text(form.label,
            style: TypographyTokens.body(size: 16).copyWith(
              color:
                  selected ? palette.goldSoft : ColorTokens.textSecondary,
            )),
      ),
    );
  }
}
