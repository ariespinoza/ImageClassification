//
//  pruebaApp.swift
//  prueba
//
//  Created by Alumno on 11/01/24.
// App Adpatada de la desarollada para "Dilo en Señas" por los alumnos:
// Alonso Morales, Diego Rofriguez, Juan Chavez, Rafhael Chavez, Emiliano Gonzalez
// Diseño: Emiliano Lucero
//

import SwiftUI

@main
struct pruebaApp: App {
    
    @StateObject private var predictionStatus = PredictionStatus()
    
    var body: some Scene {
        WindowGroup {
            MenuView()
                .environmentObject(predictionStatus)
        }
    }
}
