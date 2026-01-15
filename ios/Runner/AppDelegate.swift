import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var audioEventChannel: FlutterEventChannel?
  private var audioEventSink: FlutterEventSink?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup audio listening channel
    let controller = window?.rootViewController as! FlutterViewController
    audioEventChannel = FlutterEventChannel(
      name: "com.momentum.audio/listening",
      binaryMessenger: controller.binaryMessenger
    )
    audioEventChannel?.setStreamHandler(AudioListeningHandler())
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class AudioListeningHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    setupAudioSession()
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    NotificationCenter.default.removeObserver(self)
    return nil
  }
  
  private func setupAudioSession() {
    let session = AVAudioSession.sharedInstance()
    
    do {
      try session.setCategory(.ambient, mode: .default, options: [])
      try session.setActive(true)
    } catch {
      print("Failed to setup audio session: \(error)")
    }
    
    // Listen for audio interruptions (when other apps start/stop audio)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleInterruption(_:)),
      name: AVAudioSession.interruptionNotification,
      object: session
    )
    
    // Listen for route changes (headphones plugged/unplugged)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleRouteChange(_:)),
      name: AVAudioSession.routeChangeNotification,
      object: session
    )
  }
  
  @objc private func handleInterruption(_ notification: Notification) {
    guard let info = notification.userInfo,
          let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
          let type = AVAudioSession.InterruptionType(rawValue: typeValue)
    else { return }
    
    if type == .began {
      // Audio started elsewhere
      eventSink?("START")
    } else if type == .ended {
      // Check if audio should resume
      if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
        let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
        if options.contains(.shouldResume) {
          eventSink?("START")
        } else {
          eventSink?("STOP")
        }
      } else {
        eventSink?("STOP")
      }
    }
  }
  
  @objc private func handleRouteChange(_ notification: Notification) {
    guard let info = notification.userInfo,
          let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
          let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
    else { return }
    
    let session = AVAudioSession.sharedInstance()
    
    // Check if audio is currently playing
    if reason == .newDeviceAvailable || reason == .oldDeviceUnavailable {
      // Device change - check current state
      if session.isOtherAudioPlaying {
        eventSink?("START")
      } else {
        eventSink?("STOP")
      }
    }
  }
}
