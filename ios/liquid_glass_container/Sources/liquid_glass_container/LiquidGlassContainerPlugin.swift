import Flutter
import UIKit

public class LiquidGlassContainerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "liquid_glass_container",
      binaryMessenger: registrar.messenger())
    let instance = LiquidGlassContainerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(
      GlassViewFactory(messenger: registrar.messenger()),
      withId: "liquid_glass_container/glass_view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getCapabilities":
      var nativeGlass = false
      if #available(iOS 26.0, *) { nativeGlass = true }
      result([
        "nativeGlass": nativeGlass,
        "reduceTransparency": UIAccessibility.isReduceTransparencyEnabled,
        "osMajorVersion": ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
      ])
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

final class GlassViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    GlassPlatformView(
      frame: frame,
      viewId: viewId,
      args: args as? [String: Any],
      messenger: messenger)
  }
}

/// Hosts a UIVisualEffectView carrying UIGlassEffect (iOS 26+) or a
/// UIBlurEffect material fallback on older systems. The effect samples
/// whatever renders beneath it in the native hierarchy — including the
/// Flutter view — so glass over Flutter content behaves exactly like
/// glass in a native app, and inherits system appearance settings
/// (iOS 27 transparency slider, Reduce Transparency, Increase Contrast).
final class GlassPlatformView: NSObject, FlutterPlatformView {
  private let container: GlassHostView
  private let channel: FlutterMethodChannel

  init(
    frame: CGRect,
    viewId: Int64,
    args: [String: Any]?,
    messenger: FlutterBinaryMessenger
  ) {
    container = GlassHostView(frame: frame, args: args ?? [:])
    channel = FlutterMethodChannel(
      name: "liquid_glass_container/glass_view_\(viewId)",
      binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return result(FlutterMethodNotImplemented) }
      switch call.method {
      case "update":
        self.container.apply(args: call.arguments as? [String: Any] ?? [:])
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }
}

final class GlassHostView: UIView {
  private let effectView = UIVisualEffectView()
  private var capsule = false
  private var cornerRadius: CGFloat = 0

  init(frame: CGRect, args: [String: Any]) {
    super.init(frame: frame)
    backgroundColor = .clear
    effectView.frame = bounds
    effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(effectView)
    apply(args: args)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

  func apply(args: [String: Any]) {
    let style = args["style"] as? String ?? "regular"
    let interactive = args["interactive"] as? Bool ?? false
    let tint = (args["tint"] as? NSNumber).map { Self.color(argb: $0.int64Value) }
    capsule = args["capsule"] as? Bool ?? false
    cornerRadius = CGFloat((args["cornerRadius"] as? NSNumber)?.doubleValue ?? 0)
    isUserInteractionEnabled = interactive
    effectView.isUserInteractionEnabled = interactive

    if #available(iOS 26.0, *) {
      let glass: UIGlassEffect
      if style == "clear" {
        glass = UIGlassEffect(style: .clear)
      } else {
        glass = UIGlassEffect(style: .regular)
      }
      glass.isInteractive = interactive
      if let tint { glass.tintColor = tint }
      effectView.effect = glass
      effectView.cornerConfiguration =
        capsule
        ? .capsule()
        : .uniformCorners(radius: .fixed(cornerRadius))
    } else {
      effectView.effect = UIBlurEffect(style: .systemMaterial)
      if let tint {
        effectView.contentView.backgroundColor = tint.withAlphaComponent(0.25)
      } else {
        effectView.contentView.backgroundColor = nil
      }
      effectView.clipsToBounds = true
      effectView.layer.cornerCurve = .continuous
      updateLegacyCorners()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if #unavailable(iOS 26.0) { updateLegacyCorners() }
  }

  private func updateLegacyCorners() {
    effectView.layer.cornerRadius =
      capsule ? min(bounds.width, bounds.height) / 2 : cornerRadius
  }

  private static func color(argb: Int64) -> UIColor {
    UIColor(
      red: CGFloat((argb >> 16) & 0xFF) / 255,
      green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255,
      alpha: CGFloat((argb >> 24) & 0xFF) / 255)
  }
}
