//
//  PravacyMenuView.swift
//  App_Privacy_Reporter
//
//  Created by xiwang wang on 2021/10/20.
//

import SwiftUI

struct PravacyMenuView: View {
  @State var learnImport: Bool = false
  var body: some View {
    List {
      Section {
        Text("learnImportFile")
          .foregroundColor(.blue)
          .onTapGesture {
            learnImport.toggle()
          }
      }
      .padding()
      
      Section {
        VStack(alignment: HorizontalAlignment.leading) {
          Text("version \(UIApplication.appVersion!)")
            .padding()
          Divider()
          Text("describe \(UIApplication.appName!) \(UIApplication.appName!)")
            .lineSpacing(5.0)
            .multilineTextAlignment(.leading)
            .foregroundColor(.black)
            .font(.system(size: 15))
            .padding(5)
            .fixedSize(horizontal: false, vertical: true)
          Divider()
          HStack{
            Image(systemName: "plus.message")
              .imageScale(.large)
              .padding()
              .foregroundColor(.blue)
            Text("join Telegram group")
              .foregroundColor(.blue)
          }
          .frame( height: 44)
          Divider()
          HStack {
            Image(systemName: "hand.raised")
              .imageScale(.large)
              .padding()
              .foregroundColor(.blue)
            Text("privacy policy")
              .foregroundColor(.blue)
          }
          .frame( height: 44)
          .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        }
        
      } header: {
        Text("about \(UIApplication.appName!)")
          .textCase(nil)
      }
    }
    .sheet(isPresented: $learnImport) {
      PrivacyLearnImportView()
    }
  }
}

struct PravacyMenuView_Previews: PreviewProvider {
  static var previews: some View {
    PravacyMenuView()
  }
}
