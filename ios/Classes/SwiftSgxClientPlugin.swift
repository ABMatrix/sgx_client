import Flutter
import UIKit

public class SwiftSgxClientPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sgx_client", binaryMessenger: registrar.messenger())
    let instance = SwiftSgxClientPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }

  public func methodToEnforceBundling() {
    verify_mra_cert("");
    rust_cstr_free("");
  }
}
