//
//  CameraView.swift
//  ScanML
//
//  Created by Alumno on 01/10/25.
//

import SwiftUI

struct CameraView: View {
    
    @State private var isPhotoTaken = false
    
    var body: some View {
        
        NavigationStack {
            HStack(spacing: 0) {
                ZStack {
                    
                    Color(UIColor.systemBackground)
                        .edgesIgnoringSafeArea(.all)
                    
                    HStack(spacing: 0) {
                        
                        
                        // Contenido principal
                        ScrollView {
                            VStack(spacing: 30) {
                                
                                // Título
                                Text("Diagnóstico por Foto")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(Color.verdeTitulos)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("Centre la planta en la cámara para continuar")
                                    .font(.title2)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Imagen y botón de cámara
                                ZStack {
                                    Image("CoffeePlant")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 650, height: 700)
                                        .clipped()
                                        .cornerRadius(45)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 45)
                                                .stroke(.black, lineWidth: 4)
                                        )
                                        .shadow(color: .black.opacity(0.4), radius: 50, x: 5, y: 5)
                                        .overlay(Color.white.opacity(isPhotoTaken ? 0.7 : 0)
                                            .cornerRadius(45)
                                        )
                                        .animation(.easeInOut(duration: 0.3), value: isPhotoTaken)
                                    
                                    Button(action: {
                                        withAnimation {
                                            isPhotoTaken = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation {
                                                isPhotoTaken = false
                                            }
                                        }
                                    }) {
                                        Image(systemName: "camera")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                            .padding(30)
                                            .background(Color.black.opacity(0.3))
                                            .clipShape(Circle())
                                    }
                                }
                                
                                // Botón Tomar foto
                                Button(action: { print("Tomar foto") }) {
                                    Text("Tomar foto")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: 400)
                                        .background(Color.verdeBoton)
                                        .cornerRadius(20)
                                }
                                
                                Spacer().frame(height: 150) // espacio para micrófono
                            }
                            .padding(50)
                        }
                    }
                    
                    
                    MicrophoneButton(color: Color.verdeOscuro)
                }
            }
            .greenSidebar()
            
        }
    }
    
}

#Preview {
    CameraView()
}


