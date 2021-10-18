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
  @State var hideApple: Bool = true
  @State var insightReport: NDPrivacySummary?
  @State var appKeys: [String] = []
  @State var appSummarys: [AppSummary] = []
  @State var highlightIndex: Int?
  @State var selectedApplication: NDPrivacySummary.NDApplicationSummary?
  @State var header: String = ""
  @State private var searchText = ""
  
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
              .frame(width: UIScreen.screenWidth * 0.5)
            Spacer()
            VStack {
              Text("hideApple")
                .font(.system(size: 10))
              Toggle("", isOn: $hideApple)
                .labelsHidden()
            }
          }
          ForEach(appKeys, id: \.self) { key in
            if let idx = appKeys.firstIndex(of: key),
               let app = insightReport.applicationSummary[key],
               let appSummary = appSummarys.first(where: { $0.bundleIdentifier == key})
            {
              NavigationLink(destination: PrivacyAppDetail(app: app, appSummary: appSummary)) {
                ApplicationView(app: app, appSummary: appSummary)
                  .padding(4)
                  .onHover { hover in
                    highlightIndex = hover ? idx : nil
                  }
                  .scaleEffect(idx == highlightIndex ? 1.02 : 1)
                  .background(
                    Color
                      .yellow
                      .opacity(idx == highlightIndex ? 0.2 : 0)
                      .cornerRadius(8)
                  )
                  .animation(.interactiveSpring(), value: highlightIndex)
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
          rebuildKeys(filter: !searchText.isEmpty)
        })
        //                .navigationBarItems(trailing: Toggle("Hide Apple", isOn: $hideApple))
      }
    }
    
    .onChange(of: hideApple, perform: { _ in
      rebuildKeys()
    })
    .onAppear {
      if let insightReportCache = appListCache[file.name] {
        insightReport = insightReportCache
        loading = false
        rebuildKeys()
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
      rebuildKeys()
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
    appKeys.forEach{ app in
      DispatchQueue.global().async {
        guard let queryIdUrl = URL(string: "https://itunes.apple.com/lookup?bundleId=\(app)") else {
          debugPrint("could not load \(app)")
          return
        }
        if let cache = appStoreQueryCache[queryIdUrl],
           let apiResult = try? ASAPIResult(cache).results?.first {
          debugPrint("[i] Cached application \(app) => \(apiResult.trackName ?? "nope!")")
          let appSummary = AppSummary(bundleIdentifier: app, appName: apiResult.trackName , avatarImage: KFImage(URL(string: apiResult.artworkUrl60 ?? "")), sellerName: apiResult.sellerName)
          apps.append(appSummary)
          DispatchQueue.main.async {
            appSummarys = apps
            appSummaryCache[file.name] = apps
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
              let appSummary = AppSummary(bundleIdentifier: app, appName: apiResult.trackName , avatarImage: KFImage(URL(string: apiResult.artworkUrl60 ?? "")), sellerName: apiResult.sellerName)
              apps.append(appSummary)
              DispatchQueue.main.async {
                appSummarys = apps
                appSummaryCache[file.name] = apps
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
  
  func rebuildKeys(filter: Bool = false) {
    let origKeys = insightReport!
      .applicationSummary
      .keys
      .sorted()
    if hideApple {
      debugPrint("hide apple")
      appKeys = origKeys
        .filter { !$0.lowercased().hasPrefix("com.apple") }
    } else {
      debugPrint("unhide apple")
      appKeys = origKeys
    }
    
    if filter {
      var newAppKeys: [String] = []
      debugPrint("searchText \(searchText)")
      appSummarys.forEach { appSummary in
        debugPrint("appSummary.appName?.contains(searchText)): \(String(describing: appSummary.appName?.contains(searchText)))")
        if appKeys.contains(appSummary.bundleIdentifier) && ((appSummary.appName!.contains(searchText))){
          newAppKeys.append(appSummary.bundleIdentifier)
        }
      }
      appKeys = newAppKeys
    }
  }
}

struct PrivacyDetail_Previews: PreviewProvider {
  static var previews: some View {
    PrivacyAppList(file: PrivacyFile(name: "", time: "", size: "", path: ""))
  }
}
