import 'package:flutter/foundation.dart';
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

  /// Base URL for the Unity WebGL build directory (web only).
  /// Defaults to 'unity_build/Build', which expects the Unity build to be
  /// synced to the Flutter app's web/unity_build/ folder via:
  ///   game sync unity --platform web
  final String unityWebBuildUrl;

  const GreenWidget({
    Key? key,
    required this.onEngineCreated,
    this.onMessage,
    this.onSceneLoaded,
    this.config,
    this.unityWebBuildUrl = 'unity_build/Build',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? GameEngineConfig(
      androidPlatformViewMode: AndroidPlatformViewMode.virtualDisplay,
      runImmediately: true,
      engineSpecificConfig: kIsWeb ? {
        'buildUrl': unityWebBuildUrl,
        'loaderUrl': '$unityWebBuildUrl/WebGL.loader.js',
        // Unity .br files are decompressed by `game sync unity --platform web`
        // so Flutter's dev server can serve them without Content-Encoding: br.
        'dataUrl': '$unityWebBuildUrl/WebGL.data',
        'frameworkUrl': '$unityWebBuildUrl/WebGL.framework.js',
        'codeUrl': '$unityWebBuildUrl/WebGL.wasm',
      } : null,
    );

    return GameWidget(
      engineType: GameEngineType.unity,
      onEngineCreated: onEngineCreated,
      onMessage: onMessage,
      onSceneLoaded: onSceneLoaded,
      config: effectiveConfig,
    );
  }
}
