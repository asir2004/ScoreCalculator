//
//  GPA_ConverterApp.swift
//  GPA Converter
//
//  Created by Asir Bygud on 2023-06-29.
//

import SwiftUI

@main
struct GPA_ConverterApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
