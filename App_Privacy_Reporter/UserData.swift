//
//  UserData.swift
//  App_Privacy_Reporter
//
//  Created by xiwang wang on 2021/10/9.
//

import SwiftUI
import Combine

let privacyFileData: [PrivacyFile] = loadFiles()//load("PrivacyFiles.json")

final class UserData: ObservableObject {
  @Published var privacyFiles = privacyFileData
}

func loadFiles() ->[PrivacyFile] {
  var res: [PrivacyFile] = []
  let inboxDirPath = NSHomeDirectory() + "/Documents/Inbox"
//  print(inboxDirPath)
  do {
    let paths = try FileManager.default.contentsOfDirectory(atPath: inboxDirPath)
    if (paths.count > 0) {
      for itemPath in paths {
        if itemPath.hasPrefix(".") {
          continue
        }
        
        let fullPath = URL(string: inboxDirPath)!.appendingPathComponent(itemPath)
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd hh:mm"
        let file = PrivacyFile(name: itemPath, time:(dateFormatter.string(from: fullPath.creationDate!)), size: "\(fullPath.fileSize / 1024)kb", path: fullPath.absoluteString)
        
        res.append(file)
//        print(itemPath);
      }
      
    }
  } catch  {
    print(error.localizedDescription)
    //@throw NSException(name: NSExceptionName(rawValue: "ERROR"), reason: error.localizedDescription, userInfo: nil) as! Error
  }
  return res
}


func load<T: Decodable>(_ filename: String) -> T {
  let data: Data
  
  guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
    fatalError("Couldn't find \(filename) in main bundle")
  }
  
  do {
    data = try Data(contentsOf: file)
  } catch {
    fatalError("Couldn't load \(filename) from main bundle: \n\(error)")
  }
  
  do {
    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: data)
  } catch {
    fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
  }
}


public extension FileManager {
  static var documentsDirectoryURL: URL {
    return `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
  
  static var documentsInboxDirectoryURL: URL {
    return self.documentsDirectoryURL.appendingPathComponent("Inbox")
  }
}

extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

