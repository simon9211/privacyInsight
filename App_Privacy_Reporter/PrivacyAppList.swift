//
//  PrivacyDetail.swift
//  App_Privacy_Reporter
//
//  Created by xiwang wang on 2021/10/9.
//

import SwiftUI
import Kingfisher



struct PrivacyAppList: View {
  
  let file: PrivacyFile
  
  @State var loading: Bool = false
  @State var progress: Progress = Progress()
  @State var hideApple: Int = 0
  @State var insightReport: NDPrivacySummary?
//  @State var appKeys: [String] = []
  @State var appSummarys: [AppSummary] = []
  @State var renderAppSummarys: [AppSummary] = []
  @State var selectedApplication: NDPrivacySummary.NDApplicationSummary?
  @State var header: String = ""
  @State private var searchText = ""
  @State private var sort: Int = 0
  @State private var sortType: Int = 0
  
  var body: some View {
    VStack {
      if loading {
        ZStack {
          VStack(spacing: 8) {
            ProgressView()
            ProgressView(progress)
              .progressViewStyle(LinearProgressViewStyle())
              .animation(.interactiveSpring(), value: progress)
              .padding()
            Text("buildingSummaryTips")
              .font(.system(size: 12, weight: .semibold, design: .rounded))
          }
        }
      } else if let insightReport = insightReport {
        List {
          HStack {
            Text(generateRecordRange())
              .font(.system(size: 10, weight: .semibold, design: .monospaced))
          }
          ForEach(renderAppSummarys, id: \.id) { appSummary in
            if let app = insightReport.applicationSummary[appSummary.bundleIdentifier]{
              NavigationLink(destination: PrivacyAppDetail(app: app, appSummary: appSummary)) {
                ApplicationView(app: app, appSummary: appSummary)
                  .padding(4)
                  .scaleEffect(1)
                  .onTapGesture {
                    selectedApplication = app
                  }
                  .onTapGesture {
                    selectedApplication = app
                  }
                  .padding(.horizontal, 8)
              }
                
            }
          }
        }
        .searchable(text: $searchText, prompt: "search")
        .navigationTitle(Text("apps"))
        .onChange(of: searchText, perform: { s in
          rebuildSummarys(filter: !searchText.isEmpty)
        })
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Menu {
              let hide = Binding(
                get: { self.hideApple },
                set: { self.hideApple = $0 == self.hideApple ? -1 : $0 }
              )
              Picker(selection: hide, label: Text("Sorting options")) {
                Label("hideApple", systemImage: "applelogo")
                  .tag(0)
              }
              
              Picker(selection: $sortType, label: Text("Sorting options")) {
                Label("ascending", systemImage: "arrow.up")
                  .tag(0)
                Label("descending", systemImage: "arrow.down")
                  .tag(1)
              }
              .onChange(of: sortType, perform: { typeValue in
                rebuildSummarys()
              })
              
              Picker(selection: $sort, label: Text("Sorting options")) {
                Label("numberOfPrivacy", systemImage: "hand.raised.fill")
                  .tag(0)
                
                Label("numberOfNetwork", systemImage: "network")
                  .tag(1)
              }
              .onChange(of: sort, perform: { typeValue in
                rebuildSummarys()
              })
            }
          label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
          }
          }
        }
      }
    }
    
    .onChange(of: hideApple, perform: { _ in
      rebuildSummarys()
    })
    .onAppear {
      if let insightReportCache = appListCache[file.name] {
        insightReport = insightReportCache
        loading = false
        prepareApplicationInfo()
      } else {
        loading = true
        DispatchQueue.global().async {
          prepareInsightData(with: URL(string: "file://" + file.path)!)
          DispatchQueue.main.async {
            loading = false
          }
        }
      }
    }
  }
  
  func prepareInsightData(with url: URL) {
    debugPrint("[i] loading insight data \(url.path)")
    guard url.pathExtension.lowercased() == "ndjson" else {
      errorProcessingInsight(with: "Wrong format, requires .ndjson file.")
      return
    }
    var read: Data?
    do {
      read = try Data(contentsOf: url)
    } catch {
      errorProcessingInsight(with: error.localizedDescription)
    }
    guard let read = read,
          let text = String(data: read, encoding: .utf8)
    else {
      errorProcessingInsight(with: "Failed to decode record file.")
      return
    }
    debugPrint("[i] loaded ndjson with length: \(read.count)")
    var privacyAccessBuilder: [NDPrivacyAccess] = []
    var networkAccessBuilder: [NDNetworkAccess] = []
  analyzer: for line in text.components(separatedBy: "\n") {
    let cleanedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
    if cleanedLine.count < 1 { continue analyzer }
    // try for each decoder
    if let privacyAccess = try? NDPrivacyAccess(cleanedLine) {
      privacyAccessBuilder.append(privacyAccess)
      continue analyzer
    }
    if let networkAccess = try? NDNetworkAccess(cleanedLine) {
      networkAccessBuilder.append(networkAccess)
      continue analyzer
    }
    debugPrint("[E] ignoring unknown line")
  }
    let summary = NDPrivacySummary(privacyAccess: privacyAccessBuilder,
                                   networkAccess: networkAccessBuilder) { pass in
      updateProgress(total: pass.0, current: pass.1)
    }
    print(
            """
            Loaded privacy summary with \(summary.applicationSummary.count) applications
            ===> Privacy Record \(summary.privacyAccess.count)
            ===> Network Record \(summary.networkAccess.count)
            """
    )
    if summary.privacyAccess.count < 1 && summary.networkAccess.count < 1 {
      errorProcessingInsight(with: "Nothing to load.")
      return
    }
    DispatchQueue.main.async {
      insightReport = summary
      appListCache[file.name] = summary
      loading = false
      prepareApplicationInfo()
      //insightReader = AppSelector(insightReport: summary)
    }
  }
  
  func prepareApplicationInfo() {
    
    if let summaryCache = appSummaryCache[file.name] {
      appSummarys = summaryCache
      return
    }
    var apps: [AppSummary] = []
    insightReport?.applicationSummary.forEach{ app in
      DispatchQueue.global().async {
        guard let queryIdUrl = URL(string: "https://itunes.apple.com/lookup?bundleId=\(app.key)") else {
          debugPrint("could not load \(app.key)")
          return
        }
        if let cache = appStoreQueryCache[queryIdUrl],
           let apiResult = try? ASAPIResult(cache).results?.first {
          debugPrint("[i] Cached application \(app) => \(apiResult.trackName ?? "nope!")")
          let appSummary = AppSummary(bundleIdentifier: app.key, appName: apiResult.trackName , avatarImage: KFImage(URL(string: apiResult.artworkUrl60 ?? "")), sellerName: apiResult.sellerName, privacyCount: app.value.reportPrivacyElement.count, networkCount: app.value.reportNetworkElement.count)
          apps.append(appSummary)
          DispatchQueue.main.async {
            appSummarys = apps
            appSummaryCache[file.name] = apps
            rebuildSummarys()
          }
          return
        }
        URLSession
          .shared
          .dataTask(with: queryIdUrl) { data, _, _ in
            if let data = data,
               let str = String(data: data, encoding: .utf8),
               let apiResult = try? ASAPIResult(str).results?.first {
              appStoreQueryCache[queryIdUrl] = str
              debugPrint("[i] Loaded application \(app) => \(apiResult.trackName ?? "nope!")")
              let appSummary = AppSummary(bundleIdentifier: app.key, appName: apiResult.trackName , avatarImage: KFImage(URL(string: apiResult.artworkUrl60 ?? "")), sellerName: apiResult.sellerName,privacyCount: app.value.reportPrivacyElement.count, networkCount: app.value.reportNetworkElement.count)
              apps.append(appSummary)
              DispatchQueue.main.async {
                appSummarys = apps
                appSummaryCache[file.name] = apps
                rebuildSummarys()
              }
            }
          }
          .resume()
      }
    }
  }
  
  func errorProcessingInsight(with reason: String) {
    DispatchQueue.main.async {
      //            let alert = NSAlert()
      //            alert.messageText = reason
      //            alert.runModal()
    }
  }
  
  func updateProgress(total: Int, current: Int) {
    DispatchQueue.main.async {
      let builder = Progress(totalUnitCount: Int64(exactly: total) ?? 0)
      builder.completedUnitCount = Int64(exactly: current) ?? 0
      progress = builder
    }
  }
  
  func generateHeader() -> String {
    
    "[Insight]" +
    //        " - " +
    //        "Privacy " + String(insightReport.privacyAccess.count) +
    //        " " +
    //        "Network " + String(insightReport.networkAccess.count) +
    " " +
    generateRecordRange()
  }
  
  func generateRecordRange() -> String {
    DateFormatter.localizedString(from: insightReport!.beginDate,
                                  dateStyle: .medium,
                                  timeStyle: .medium)
    + " -> " +
    DateFormatter.localizedString(from: insightReport!.endingDate,
                                  dateStyle: .medium,
                                  timeStyle: .medium)
  }
  
  func rebuildSummarys(filter: Bool = false) {
    let origSummary = appSummarys
      .sorted { s1, s2 in
        if sort == 0 {
          //隐私数量
          if sortType == 0 {
            return  s1.privacyCount > s2.privacyCount
          } else {
            return  s1.privacyCount < s2.privacyCount
          }
          
        } else {
          if sortType == 0 {
            return  s1.networkCount > s2.networkCount
          } else {
            return  s1.networkCount < s2.networkCount
          }
        }
      }
    
    if hideApple == 0 {
      debugPrint("hide apple")
      renderAppSummarys = origSummary
        .filter { !$0.bundleIdentifier.lowercased().contains(".apple.") }
    } else {
      debugPrint("unhide apple")
      renderAppSummarys = origSummary
    }
    
    if filter {
      var newAppSummary: [AppSummary] = []
      debugPrint("searchText \(searchText)")
      renderAppSummarys.forEach { appSummary in
        debugPrint("appSummary.appName?.contains(searchText)): \(String(describing: appSummary.appName?.contains(searchText)))")
        if ((appSummary.appName!.contains(searchText))){
          newAppSummary.append(appSummary)
        }
      }
      renderAppSummarys = newAppSummary
    }
  }
}

struct PrivacyDetail_Previews: PreviewProvider {
  static var previews: some View {
    PrivacyAppList(file: PrivacyFile(name: "", time: "", size: "", path: ""))
  }
}
