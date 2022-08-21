//
// ContentView.swift
//
// Created by Joey deVilla, August 2022.
// Companion project for the Auth0 blog article
// “Using Auth0 User and App Metadata in iOS and SwiftUI”.
//


import SwiftUI
import Auth0


struct ContentView: View {
  
  @State private var userProfile = Profile.empty
  @State private var accessToken: String = ""
  @State private var cachedUserMetadata: [String : Any]? = nil
  
  @State private var isAuthenticated = false
  @State private var isJustLaunched = true
  @State private var personalAffirmation = ""
  @State private var shouldDisplayAnnouncement = false
  @State private var announcement = ""
  @State private var announcementUrl = URL(string: "about:blank")
  
  
  var body: some View {
      
    if isAuthenticated {
      
      // “Logged in” screen
      // ------------------
      
      ScrollView {
        
        VStack {
          
          Text("You’re logged in!")
            .modifier(TitleStyle())
          
          VStack {
            UserImage(urlString: userProfile.picture)
            Text("Name: \(userProfile.name)")
            Text("Email: \(userProfile.email)")
          }
          .padding()
          
          VStack { // Affirmation section
            
            // Affirmation label and text field
            Text("Your personal affirmation:")
            TextField("Your affirmation here", text: $personalAffirmation)
              .modifier(TextFieldStyle())
            
            HStack { // Affirmation button row
              Spacer()
              Button("Refresh affirmation") {
                getMetadata()
              }
              Spacer()
              Button("Save affirmation") {
                updateUserMetadata()
              }
              Spacer()
            } // HStack - Affirmation button row
            
          } // VStack - Affirmation section
          
          // Announcement {
          if shouldDisplayAnnouncement {
            VStack {
              Spacer()
              Link(
                announcement,
                destination: announcementUrl!)
              .modifier(AnnouncementStyle())
            }
          }
          
          Button("Log out") {
            logout()
          }
          .buttonStyle(BigButtonStyle())
          
        } // VStack
        
      } // ScrollView

    } else {
      
      // “Logged out” screen
      // ------------------
      
      VStack {
        
        if isJustLaunched {
          Text("Metadata demo")
            .modifier(TitleStyle())
        } else {
          Text("You’re logged out.")
            .modifier(TitleStyle())
        }
        
        Button("Log in") {
          login()
        }
        .buttonStyle(BigButtonStyle())
        
      } // VStack
      
    } // if isAuthenticated
    
  } // body
  
  
  // MARK: View modifiers
  // --------------------
  
  struct TitleStyle: ViewModifier {
    let titleFontBold = Font.title.weight(.bold)
    let cornflowerBlue = Color(red: 0.392, green: 0.584, blue: 0.929)
    
    func body(content: Content) -> some View {
      content
        .font(titleFontBold)
        .foregroundColor(cornflowerBlue)
        .padding()
    }
  }
  
  struct TextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
      content
        .multilineTextAlignment(.center)
        .border(.gray)
        .padding(.top, -5)
        .padding([.leading, .trailing], 20)
    }
  }
  
  struct AnnouncementStyle: ViewModifier {
    let announcementFont = Font.body.bold().italic()
    let orange = Color(red: 1, green: 0.647, blue: 0)
    
    func body(content: Content) -> some View {
      content
        .font(announcementFont)
        .foregroundColor(orange)
        .padding([.top, .bottom], 20)
    }
  }
  
  struct BigButtonStyle: ButtonStyle {
    let cornflowerBlue = Color(red: 0.392, green: 0.584, blue: 0.929)
    
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .padding()
        .background(cornflowerBlue)
        .foregroundColor(.white)
        .clipShape(Capsule())
    }
  }
  
}


extension ContentView {
  
  private func login() {
    guard let domain = auth0Plist()?["Domain"]
    else {
      return
    }
    
    Auth0
      .webAuth()
      .audience("https://\(domain)/api/v2/")
      .scope("openid profile email read:current_user update:current_user_metadata")
      .start { result in
        
        switch result {
          
          case .failure(let error):
          print("Failed to log in: \(error)")
          
          case .success(let credentials):
            self.isAuthenticated = true
            self.isJustLaunched = false
            self.userProfile = Profile.from(credentials.idToken)
            self.accessToken = credentials.accessToken
            self.getMetadata()
          
            print("ID token: \(credentials.idToken)")
            print("Access token: \(credentials.accessToken)")
            print("Scope: \(credentials.scope!)")
          
        } // switch
        
      } // start
  }
  
  func getMetadata() {
    if accessToken == "" {
      return
    }
    
    Auth0
      .users(token: accessToken)
      .get(userProfile.id, fields: ["user_metadata", "app_metadata"])
      .start { result in
        
        switch result {
        
          case .failure(let error):
            print("Error: Couldn’t retrieve metadata.\n\(error.localizedDescription)")
          
          case .success(let metadata):
            // Get user metadata
            let userMetadata = metadata["user_metadata"] as? [String: Any]
            self.cachedUserMetadata = userMetadata
            self.personalAffirmation = cachedUserMetadata?["personal_affirmation"] as? String ?? ""
          
            // Get app metadata
            let appMetadata = metadata["app_metadata"] as? [String: Any]
            self.shouldDisplayAnnouncement = appMetadata?["display_announcement"] as? Bool ?? false
            self.announcement = appMetadata?["announcement_text"] as? String ?? "ANNOUNCEMENT - TAP HERE"
            let announcementUrlString = appMetadata?["announcement_url"] as? String ?? "about:blank"
            self.announcementUrl = URL(string: announcementUrlString)
            
        } // switch
        
      } // start()
  }
  
  func updateUserMetadata() {
    if accessToken == "" {
      return
    }
    
    let updatedPersonalAffirmation = personalAffirmation.trimmingCharacters(in: .whitespacesAndNewlines)
    
    Auth0
      .users(token: accessToken)
      .patch(userProfile.id, userMetadata: ["personal_affirmation": updatedPersonalAffirmation])
      .start { result in
        
        switch result {
          
          case .failure(let error):
            print("Error: Couldn’t update 'personal_affirmation' in the user metadata.\n\(error.localizedDescription)")
          
          case .success(let updatedUserMetadata):
            self.cachedUserMetadata = updatedUserMetadata
          
          } // switch
          
        } // start()
  }
  
  private func logout() {
    Auth0
      .webAuth()
      .clearSession { result in
        
        switch result {
          
          case .failure(let error):
            print("Failed with: \(error)")
          
          case .success:
            self.isAuthenticated = false
            self.userProfile = Profile.empty
          
        } // switch
        
      } // clearSession()
  }
  
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
