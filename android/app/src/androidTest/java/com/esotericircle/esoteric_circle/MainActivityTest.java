package com.esotericircle.esoteric_circle;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

/**
 * Le prove sul dispositivo vero, ordine FE voce 21: Firebase Test Lab fa
 * girare le prove di integration_test/ su telefoni fisici attraverso questo
 * runner.
 */
@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
  @Rule
  public ActivityTestRule<MainActivity> rule =
      new ActivityTestRule<>(MainActivity.class, true, false);
}
