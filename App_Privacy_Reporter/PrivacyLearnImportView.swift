//
//  PrivacyLearnImportView.swift
//  App_Privacy_Reporter
//
//  Created by xiwang wang on 2021/10/20.
//

import SwiftUI

struct PrivacyLearnImportView: View {
  var body: some View {
    List{
      Section {
        Image("1")
          .resizable()
          .aspectRatio(contentMode: .fill)
      } header: {
        HStack{
          Image(systemName: "1.circle")
            .imageScale(.large)
            .foregroundColor(.blue)
          Text("1")
            .foregroundColor(.blue)
        }
        .textCase(nil)
      }
      
      Section {
        Image("2")
          .resizable()
          .aspectRatio(contentMode: .fill)
      } header: {
        HStack{
          Image(systemName: "2.circle")
            .imageScale(.large)
            .foregroundColor(.blue)
          Text("2")
            .foregroundColor(.blue)
        }
        .textCase(nil)
      }
      
      Section {
        Image("3")
          .resizable()
          .aspectRatio(contentMode: .fill)
      } header: {
        HStack{
          Image(systemName: "3.circle")
            .imageScale(.large)
            .foregroundColor(.blue)
          Text("3-1")
            .foregroundColor(.blue)
        }
        .textCase(nil)
      } footer: {
      Text("3-2")
        .foregroundColor(.blue)
    }
      
      Section {
        Image("4")
          .resizable()
          .aspectRatio(contentMode: .fill)
      } header: {
        HStack{
          Image(systemName: "4.circle")
            .imageScale(.large)
            .foregroundColor(.blue)
          Text("4 \(UIApplication.appName!)")
            .foregroundColor(.blue)
        }
        .textCase(nil)
      }
    }
  }
}

struct PrivacyLearnImportView_Previews: PreviewProvider {
  static var previews: some View {
    PrivacyLearnImportView()
  }
}
