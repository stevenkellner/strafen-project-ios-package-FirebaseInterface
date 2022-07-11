//
//  FConfigurator.swift
//  
//
//  Created by Steven on 18.06.22.
//

import FirebaseCore

/// Used to confire firebase app.
struct FConfigurator {
    
    /// Indicates whether firebase is already configured.
    private var alreadyConfigured = false
    
    /// Shared instance for singelton
    public static var shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Configures firebase app,
    mutating func configure() {
        guard !self.alreadyConfigured else { return }
        self.alreadyConfigured = true
        FirebaseApp.configure()
    }
    
    mutating func configure(from bundle: Bundle) {
        guard let filePath = bundle.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: filePath) else { return }
        guard !self.alreadyConfigured else { return }
        self.alreadyConfigured = true
        FirebaseApp.configure(options: options)
    }
}
