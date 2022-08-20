//
// Utilities.swift
//
// Created by Joey deVilla, August 2022.
// Companion project for the Auth0 blog article
// “Using Auth0 User and App Metadata in iOS and SwiftUI”.
//


import Foundation


func auth0Plist() -> [String: Any]? {
  guard let path = Bundle.main.path(forResource: "Auth0", ofType: "plist")
  else {
    print("Missing Auth0.plist file!")
    return nil
  }

  return NSDictionary(contentsOfFile: path) as? [String: Any]
}
