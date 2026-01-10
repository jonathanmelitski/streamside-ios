//
//  StreamsideFirebase.swift
//  USGS
//
//  Created by Jonathan Melitski on 10/6/25.
//


// static operations added via extensions
public struct StreamsideFirebase {}

enum FirebaseError: Error {
    case noData, invalidObject
}

public struct ProfileEncodingConfiguration {
    let firebase: Bool
    
    init(firebase: Bool = false) {
        self.firebase = firebase
    }
}

extension Profile {
  var dictionary: [String: Any]? {
      let enc = JSONEncoder()
      enc.keyEncodingStrategy = .convertToSnakeCase
      
      guard let data = try? enc.encode(self, configuration: .init(firebase: true)) else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
