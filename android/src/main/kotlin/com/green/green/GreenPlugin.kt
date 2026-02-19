package com.green.green

import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Minimal plugin registration for green.
 * All game engine logic is handled by gameframework packages.
 */
class GreenPlugin: FlutterPlugin {
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // Minimal registration - gameframework handles the engine integration
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // Cleanup if needed
  }
}
