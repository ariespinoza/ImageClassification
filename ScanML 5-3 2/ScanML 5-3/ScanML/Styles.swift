//
//  Styles.swift
//  ScanML
//
//  Created by Alumno on 01/10/25.
//

import SwiftUI


extension Color {
    static let verdeOscuro = Color(red: 32/255, green: 75/255, blue: 54/255)
    static let beige = Color(red: 255/255, green: 255/255, blue: 245/255) // Fondo beige
    static let verdeBoton = Color(red: 45/255, green: 116/255, blue: 84/255)
    static let sageGreen = Color(red: 176/255, green: 190/255, blue: 169/255)
    static let verdeClaro = Color(red: 59/255, green: 150/255, blue: 108/255)
    static let grisFondo = Color(red: 245/255, green: 245/255, blue: 245/255)
    static let verdeTitulos = Color(red: 28/255, green: 53/255, blue: 41/255)
}



// Modificador para la franja verde lateral
struct GreenSidebarModifier: ViewModifier {
    let sidebarWidth: CGFloat = 40
    let sidebarColor = Color.verdeOscuro

    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            // Franja verde
            sidebarColor
                .frame(width: sidebarWidth)
                .edgesIgnoringSafeArea(.vertical)
            
            // Contenido principal
           content
               // .background(Color.beige.edgesIgnoringSafeArea(.all))
                
        }
    }
}

extension View {
    func greenSidebar() -> some View {
        self.modifier(GreenSidebarModifier())
    }
}



// Modificador para los títulos en verde
struct GreenTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontWeight(.bold)
            .foregroundColor(Color.verdeTitulos)
    }
}

extension View {
    func greenTitle() -> some View {
        self.modifier(GreenTitle())
    }
}



