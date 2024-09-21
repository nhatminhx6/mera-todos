//
//  MeraTodosApp.swift
//  MeraTodos
//
//  Created by NhatMinh on 21/9/24.
//

import SwiftUI

@main
struct MeraTodosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
