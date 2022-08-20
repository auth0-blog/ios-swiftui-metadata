//
// UserImage.swift
//
// Created by Joey deVilla, August 2022.
// Companion project for the Auth0 blog article
// “Using Auth0 User and App Metadata in iOS and SwiftUI”.
//


import SwiftUI


struct UserImage: View {
  // Given the URL of the user’s picture, this view asynchronously
  // loads that picture and displays it. It displays a “person”
  // placeholder image while downloading the picture or if
  // the picture has failed to download.
  
  var urlString: String
  
  
  var body: some View {
    AsyncImage(url: URL(string: urlString)) { image in
      image
        .frame(maxWidth: 128)
    } placeholder: {
      Image(systemName: "person.circle.fill")
        .resizable()
        .scaledToFit()
        .frame(maxWidth: 128)
        .foregroundColor(.blue)
        .opacity(0.5)
    }
    .padding(20)
  }
}


struct UserImage_Previews: PreviewProvider {
    static var previews: some View {
        UserImage(urlString: "")
    }
}
