//
// Profile.swift
//
// Created by Joey deVilla, August 2022.
// Companion project for the Auth0 blog article
// “Using Auth0 User and App Metadata in iOS and SwiftUI”.
//


import JWTDecode


struct Profile {
  
  let id: String
  let name: String
  let email: String
  let emailVerified: String
  let picture: String
  let updatedAt: String

}


extension Profile {
  
  static var empty: Self {
    return Profile(
      id: "",
      name: "",
      email: "",
      emailVerified: "",
      picture: "",
      updatedAt: ""
    )
  }
  
  static func from(_ idToken: String) -> Self {
      guard
        let jwt = try? decode(jwt: idToken),
        let id = jwt.subject,
        let name = jwt.claim(name: "name").string,
        let email = jwt.claim(name: "email").string,
        let emailVerified = jwt.claim(name: "email_verified").boolean,
        let picture = jwt.claim(name: "picture").string,
        let updatedAt = jwt.claim(name: "updated_at").string
      else {
        return .empty
      }
   
      return Profile(
        id: id,
        name: name,
        email: email,
        emailVerified: String(describing: emailVerified),
        picture: picture,
        updatedAt: updatedAt
      )
    }

}
