//
//  PrivacyAppDetail.swift
//  App_Privacy_Reporter
//
//  Created by xiwang wang on 2021/10/12.
//

import SwiftUI
import AVFAudio
import Colorful
import Kingfisher

private let formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

private func localizedDate(from8601Date str: String) -> String {
    guard let date = formatter.date(from: str) else {
        return "Unknown Date"
    }
    return DateFormatter.localizedString(from: date,
                                         dateStyle: .long,
                                         timeStyle: .long)
}

struct PrivacyAppDetail: View {
    
    @State var app: NDPrivacySummary.NDApplicationSummary
    @State var appSummary: AppSummary?
    @State var folderPrivacys: Bool = false
    @State var folderNetworks: Bool = false
    
    var body: some View {
        VStack {
            LazyVStack {
                HStack {
                    if let avatarImage = appSummary?.avatarImage {
                        avatarImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                    } else {
                        Image("AppStore")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .foregroundColor(.pink)
                    }
                    
                    VStack (alignment: .leading, content: {
                        Text(appSummary?.appName ?? "")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        Text(appSummary?.sellerName ?? "")
                            .font(.system(size: 16))
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                      Text("bundleId: \(app.bundleIdentifier)")
                            .font(.system(size: 16))
                    })
                }
                HStack {
                    VStack {
                        HStack {
                            Image(systemName: "hand.raised.slash.fill")
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                            Text("\(app.reportPrivacyElement.count)")
                                .font(.system(size: 30, weight: .bold))
                        }
                        Spacer()
                        Text("privacyAccess")
                    }
                    .foregroundColor(.red)
                    Spacer()
                    VStack {
                        HStack {
                            Image(systemName: "network")
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                            Text("\(app.reportNetworkElement.count)")
                                .font(.system(size: 30, weight: .bold))
                        }
                        Spacer()
                        Text("networkAccess")
                    }
                    .foregroundColor(.green)
                }.padding()
            }
            .padding()
            List {
                Section(header:
                            HStack{
                    Text("privacyAccessTimeline")
                    Spacer()
                    if folderPrivacys {
                        Image(systemName: "chevron.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 15)
                            .foregroundColor(.gray)
                    } else {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 15)
                            .foregroundColor(.gray)
                    }
                }
                            .onTapGesture(perform: {
                    folderPrivacys = !folderPrivacys
                })
                ) {
                    if !folderPrivacys {
                        if app.reportPrivacyElement.count > 0 {
                            ForEach(app.reportPrivacyElement, id: \.self) { privacy in
                                HStack(spacing: 8) {
                                    Circle()
                                        .foregroundColor(.red)
                                        .frame(width: 6, height: 6)
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Group {
                                                if privacy.category.lowercased() == "location" {
                                                    Image(systemName: "location.circle.fill")
                                                } else if privacy.category.lowercased() == "photos" {
                                                    Image(systemName: "photo.fill.on.rectangle.fill")
                                                } else if privacy.category.lowercased() == "contacts" {
                                                    Image(systemName: "person.2.circle.fill")
                                                } else if privacy.category.lowercased() == "camera" {
                                                    Image(systemName: "camera.circle.fill")
                                                } else if privacy.category.lowercased() == "microphone" {
                                                    Image(systemName: "mic.circle.fill")
                                                }
                                            }
                                            .foregroundColor(.pink)
                                            .frame(width: 10)
                                            .font(.system(size: 12, weight: .semibold, design: .default))
                                            Text(LocalizedStringKey(privacy.category))
                                                .font(.system(size: 12, weight: .semibold, design: .default))
                                        }
                                        Text(localizedDate(from8601Date: privacy.timeStamp))
                                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        } else {
                            Text("No Privacy Access Data")
                        }
                    }
                }
                Section(header: HStack{
                    Text("networkAccessTimeline")
                    Spacer()
                    if folderNetworks {
                        Image(systemName: "chevron.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 15)
                            .foregroundColor(.gray)
                    } else {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 15)
                            .foregroundColor(.gray)
                    }
                }.onTapGesture(perform: {
                    folderNetworks = !folderNetworks
                })) {
                    if !folderNetworks {
                        if app.reportNetworkElement.count > 0 {
                            ForEach(app.reportNetworkElement, id: \.self) { privacy in
                                HStack(spacing: 8) {
                                    Circle()
                                        .foregroundColor(.red)
                                        .frame(width: 6, height: 6)
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Text(privacy.domain)
                                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                        }
                                        Text(localizedDate(from8601Date: privacy.timeStamp))
                                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        } else {
                            Text("No Network Access Data")
                        }
                    }
                }
            }
            
            
        }
    }
}

struct PrivacyAppDetail_Previews: PreviewProvider {
    static var previews: some View {
        let app = NDPrivacySummary.NDApplicationSummary(bundleIdentifier: "122", reportPrivacyElement: [NDPrivacyAccess(accessor: NDAccessor(identifier: "1", identifierType: "1"), category: "2", identifier: "2", kind: "3", timeStamp: "3", type: "3")], reportNetworkElement: [NDNetworkAccess(domain: "1", firstTimeStamp: "2", context: "3", timeStamp: "4", domainType: 2, initiatedType: "4", hits: 1, type: "5", domainOwner: "5", bundleid: "1")])
        PrivacyAppDetail(app: app, appSummary: AppSummary(bundleIdentifier: "com.alipay.com", appName: "支付宝 - 生活好支付宝", avatarImage: nil, sellerName: "杭州支付宝科技有限公司", privacyCount: 12, networkCount: 22))
    }
}
