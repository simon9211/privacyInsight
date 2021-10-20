//
//  App_Privacy_ReporterApp.swift
//  App_Privacy_Reporter
//
//  Created by xiwang wang on 2021/10/9.
//

import SwiftUI

public var appStoreQueryCache: [URL: String] = [:]
public var appListCache: [String: NDPrivacySummary] = [:]
public var appSummaryCache: [String: [AppSummary]] = [:]

@main
struct AppPrivacyReporterApp: App {
  
  @UIApplicationDelegateAdaptor var delegate: AppDelegate
  @EnvironmentObject var sceneDelegate: SceneDelegate // 👈🏻
  
  var body: some Scene {
    WindowGroup {
      PrivacyFileListView()
    }
  }
  
}

extension UIScreen{
  static let screenWidth = UIScreen.main.bounds.size.width
  static let screenHeight = UIScreen.main.bounds.size.height
  static let screenSize = UIScreen.main.bounds.size
}

extension UIApplication {
  static var appVersion: String? {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }
  
  static var appName: String? {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
  }
}

