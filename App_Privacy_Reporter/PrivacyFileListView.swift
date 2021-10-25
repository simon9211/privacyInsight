//
//  ContentView.swift
//  App_Privacy_Reporter
//
//  Created by xiwang wang on 2021/10/9.
//

import SwiftUI

struct PrivacyFileListView: View {
  @State private var privacyFiles: [PrivacyFile] = []
  @State var showingProfile = false
  
  var menuButton: some View {
    Button(action: {
      self.showingProfile.toggle()
    }) {
      Image(systemName: "list.bullet.circle")
        .imageScale(.large)
        .padding()
    }
  }
  
  var body: some View {
    NavigationView {
      VStack {
        if privacyFiles.isEmpty {
          Text("noPrivacyFile")
            .padding()
            .multilineTextAlignment(.center)
        } else {
          List {
            ForEach(privacyFiles) { privacy in
              NavigationLink(destination: PrivacyAppList(file: privacy)) {
                PrivacyFileRow(name: privacy.name, size: privacy.size, time: privacy.time)
              }
            }
            .onDelete { offsets in
              offsets.sorted(by: > ).forEach { (i) in
                do {
                  try FileManager.default.removeItem(at: URL(string: "file://" + privacyFiles[i].path)!)
                  appListCache.removeValue(forKey: privacyFiles[i].name)
                  appSummaryCache.removeValue(forKey: privacyFiles[i].name)
                } catch  {
                  print(error.localizedDescription)
                  //@throw NSException(name: NSExceptionName(rawValue: "ERROR"), reason: error.localizedDescription, userInfo: nil) as! Error
                }
              }
              privacyFiles.remove(atOffsets: offsets)
            }
          }
          .toolbar {
              EditButton()
          }
        }
      }
      .navigationTitle(Text("privacyReports"))
      .navigationBarItems(leading: menuButton)
      .sheet(isPresented: $showingProfile) {
        PravacyMenuView()
      }
    }
    .onAppear {
      privacyFiles = loadFiles()
    }
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
      privacyFiles = loadFiles()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    PrivacyFileListView()
  }
}
