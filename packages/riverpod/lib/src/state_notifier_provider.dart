import 'package:state_notifier/state_notifier.dart';

import 'common.dart';
import 'framework/framework.dart';
import 'internals.dart';

// ignore: must_be_immutable, false positive, _state is immutable but lazy loaded.
class StateNotifierProvider<Notifier extends StateNotifier<Object>>
    extends Provider<Notifier> {
  StateNotifierProvider(
    Create<Notifier, ProviderReference> create, {
    String name,
  }) : super(
          (ref) {
            final notifier = create(ref);
            ref.onDispose(notifier.dispose);
            return notifier;
          },
          name: name,
        );

  SetStateProvider<Object> _state;
}

/// Adds [value] to [StateNotifierProvider].
///
/// This is done as an extension as a workaround to language limitations.
extension StateNotifierProviderValue<Value>
    on StateNotifierProvider<StateNotifier<Value>> {
  SetStateProvider<Value> get value {
    _state ??= SetStateProvider<Value>((ref) {
      final notifier = ref.dependOn(this).value;

      ref.onDispose(
        notifier.addListener((newValue) => ref.state = newValue),
      );

      return ref.state;
    }, name: name == null ? null : '$name.value');
    return _state as SetStateProvider<Value>;
  }
}
