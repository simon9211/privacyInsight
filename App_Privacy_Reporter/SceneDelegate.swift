//
//  SceneDelegate.swift
//  App_Privacy_Reporter
//
//  Created by xiwang wang on 2021/10/14.
//

import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
  var window: UIWindow?
  
//  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//    guard let windowScene = scene as? UIWindowScene else {
//      return
//    }
//
//    let window = UIWindow(windowScene: windowScene)
//    window.rootViewController = UIHostingController(rootView: PrivacyFileListView())
//    self.window = window
//    window.makeKeyAndVisible()
//  }
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let urlContext = URLContexts.first else {
      return
    }
    
    // FileStore.shared.importPrioritizedTasks(from: urlContext.url)
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // ...
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // ...
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // ...
  }

  // ...
}
