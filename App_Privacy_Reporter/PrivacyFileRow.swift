//
//  PrivacyFileRow.swift
//  App_Privacy_Reporter
//
//  Created by xiwang wang on 2021/10/9.
//

import SwiftUI

struct PrivacyFileRow: View {
  let name: String
  let size: String
  let time: String
  
  var body: some View {
    VStack(alignment: HorizontalAlignment.trailing, spacing: 0) {
      HStack {
        Text(name)
          .font(.system(size: 20, weight: .bold))
          .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
        Spacer()
        Text(size)
          .font(.system(size: 15))
          .foregroundColor(.green)
          .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
      }
      .padding()
      Text("fileAddTime: \(time)")
        .font(.system(size: 16))
        .multilineTextAlignment(.trailing)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
    }
  }
}

struct PrivacyFileRow_Previews: PreviewProvider {
  static var previews: some View {
    PrivacyFileRow(name: "sss", size: "200kb", time: "2021/10/10 10:20")
  }
}
