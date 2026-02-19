import Flutter
import UIKit
import gameframework_unity

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Note: Unity initialization is now automatic during plugin registration
    // Manual initialization is optional but can provide launch options for advanced use cases
    // UnityPlayerUtils.shared.InitUnityIntegrationWithOptions(
    //     argc: CommandLine.argc,
    //     argv: CommandLine.unsafeArgv,
    //     launchOptions
    // )
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - App Lifecycle Forwarding to Unity (Recommended)
  // These callbacks ensure Unity responds properly to app state changes
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    UnityPlayerUtils.shared.applicationDidBecomeActive()
  }
  
  override func applicationWillResignActive(_ application: UIApplication) {
    super.applicationWillResignActive(application)
    UnityPlayerUtils.shared.applicationWillResignActive()
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    UnityPlayerUtils.shared.applicationDidEnterBackground()
  }
  
  override func applicationWillEnterForeground(_ application: UIApplication) {
    super.applicationWillEnterForeground(application)
    UnityPlayerUtils.shared.applicationWillEnterForeground()
  }
  
  override func applicationWillTerminate(_ application: UIApplication) {
    super.applicationWillTerminate(application)
    UnityPlayerUtils.shared.applicationWillTerminate()
  }
  
  override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    super.applicationDidReceiveMemoryWarning(application)
    UnityPlayerUtils.shared.applicationDidReceiveMemoryWarning()
  }
}
