//
//  AppSelector.swift
//  App_Privacy_Reporter
//
//  Created by xiwang wang on 2021/10/9.
//

import AVFAudio
import Colorful
import Kingfisher
import SwiftUI

struct ApplicationView: View {
    let instructedHeight: CGFloat = 35
    
    @State var app: NDPrivacySummary.NDApplicationSummary
    @State var appSummary: AppSummary?
//    @State var avatarImage: KFImage?
//    @State var appName: String?
    
    var body: some View {
        HStack {
            ZStack {
              if let avatarImage = appSummary?.avatarImage {
                    avatarImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: instructedHeight * 0.75, height: instructedHeight * 0.75)
                        .cornerRadius(8)
                } else {
                    Image("AppStore")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: instructedHeight * 0.75, height: instructedHeight * 0.75)
                        .cornerRadius(8)
                        .foregroundColor(.pink)
                }
            }
            .frame(width: instructedHeight, height: instructedHeight)
            VStack(alignment: .leading, spacing: 6) {
                Text(appSummary?.appName ?? "[? Application]")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                HStack(spacing: 0) {
                    Text(app.bundleIdentifier)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    HStack(spacing: 2) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 8, weight: .regular, design: .rounded))
                        Text("\(app.reportPrivacyElement.count / 2)")
                            .minimumScaleFactor(0.5)
                        Spacer()
                    }
                    .frame(width: 40)
                    .foregroundColor(.red)
                    HStack(spacing: 2) {
                        Image(systemName: "network")
                            .font(.system(size: 8, weight: .regular, design: .rounded))
                        Text("\(app.reportNetworkElement.count)")
                            .minimumScaleFactor(0.5)
                        Spacer()
                    }
                    .frame(width: 40)
                    .foregroundColor(.blue)
                }
                .font(.system(size: 10, weight: .regular, design: .monospaced))
            }
        }
        .frame(height: instructedHeight)
        .onAppear {
        }
    }
}



//struct AppSelector_Previews: PreviewProvider {
//    static var previews: some View {
//        AppSelector(insightReport:NDPrivacySummary(privacyAccess: [NDPrivacyAccess(data: <#Data#>)],
//                                                   networkAccess: [NDNetworkAccess()]))
//    }
//}
