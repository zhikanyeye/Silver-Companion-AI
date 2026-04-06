import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DemoIdentity {
  const DemoIdentity({
    required this.actorId,
    required this.displayName,
    required this.identityLabel,
  });

  final String actorId;
  final String displayName;
  final String identityLabel;

  DemoIdentity copyWith({
    String? actorId,
    String? displayName,
    String? identityLabel,
  }) {
    return DemoIdentity(
      actorId: actorId ?? this.actorId,
      displayName: displayName ?? this.displayName,
      identityLabel: identityLabel ?? this.identityLabel,
    );
  }
}

class DemoIdentityStore {
  static const _actorIdKey = 'demo_actor_id';
  static const _displayNameKey = 'demo_display_name';
  static const _identityLabelKey = 'demo_identity_label';

  Future<DemoIdentity> loadOrCreate() async {
    final preferences = await SharedPreferences.getInstance();
    final existingActorId = preferences.getString(_actorIdKey)?.trim() ?? '';
    final existingDisplayName =
        preferences.getString(_displayNameKey)?.trim() ?? '';
    final existingIdentity =
        preferences.getString(_identityLabelKey)?.trim() ?? '';

    if (existingActorId.isNotEmpty && existingDisplayName.isNotEmpty) {
      return DemoIdentity(
        actorId: existingActorId,
        displayName: existingDisplayName,
        identityLabel:
            existingIdentity.isEmpty ? '社区住户' : existingIdentity,
      );
    }

    final seed = Random().nextInt(9000) + 1000;
    final identity = DemoIdentity(
      actorId: 'guest-${DateTime.now().millisecondsSinceEpoch}-$seed',
      displayName: '邻里$seed',
      identityLabel: '社区住户',
    );
    await save(identity);
    return identity;
  }

  Future<void> save(DemoIdentity identity) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_actorIdKey, identity.actorId);
    await preferences.setString(_displayNameKey, identity.displayName.trim());
    await preferences.setString(
      _identityLabelKey,
      identity.identityLabel.trim(),
    );
  }
}
