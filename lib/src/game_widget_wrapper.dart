import 'package:flutter/widgets.dart';
import 'package:gameframework/gameframework.dart';

/// Optional convenience wrapper around GameWidget with package-specific defaults.
/// 
/// You can also use GameWidget directly from gameframework package.
class GreenWidget extends StatelessWidget {
  final GameEngineCreatedCallback onEngineCreated;
  final GameEngineMessageCallback? onMessage;
  final GameEngineSceneLoadedCallback? onSceneLoaded;
  final GameEngineConfig? config;

  const GreenWidget({
    Key? key,
    required this.onEngineCreated,
    this.onMessage,
    this.onSceneLoaded,
    this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      engineType: GameEngineType.unity,
      onEngineCreated: onEngineCreated,
      onMessage: onMessage,
      onSceneLoaded: onSceneLoaded,
      config: config ?? const GameEngineConfig(
        androidPlatformViewMode: AndroidPlatformViewMode.virtualDisplay,
        runImmediately: true,
      ),
    );
  }
}
