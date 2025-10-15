//
//  menuView.swift
//  prueba
//
//  Created by Alumno on 11/01/24.
//

/*
 
 //Original


import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Color("Background").ignoresSafeArea()
                
                VStack(){
                    HStack(alignment: .lastTextBaseline){
                        Spacer()
                        Image("LStar")
                    }
                    .frame(width: 300.0)
                    HStack(alignment: .firstTextBaseline){
                        Text("CADI").foregroundColor(Color(.white)).font(Font.varTitle)
                    }
                    .frame(height: 90.0)

                    VStack{
                        NavigationLink(destination: CameraScanView(labelData: Classification())){
                            Text("escanea")
                                .foregroundColor(.white)
                                .font(Font.varButtonLabel)
                                .frame(width: 300.0, height: 50.0)
                                .background(Color("Secundarycolor"))
                                .cornerRadius(100)
                            
                        }
                        

                        
                    }.padding()
                    HStack(alignment: .firstTextBaseline){
                        Image("SStar")
                        Spacer()
                    }
                    .frame(width: 300.0)
                    
                    Image("Mascot").resizable().aspectRatio(contentMode: .fit).frame(width: 300.0, height: 300.0)
                }
            }
            .navigationTitle("Inicio").navigationBarHidden(true)
                
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    MenuView()
}

*/


/*
 
 //Version 1 reto
import SwiftUI

struct MenuView: View {
    
    @State private var isPhotoTaken = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
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
                                    
                                    VStack {
                                        NavigationLink(destination: CameraScanView(labelData: Classification())){
                                            Text("Escanear")
                                                .font(.title)
                                                .foregroundColor(.white)
                                                .font(Font.varButtonLabel)
                                                .padding()
                                                .frame(width: 300.0, height: 50.0)
                                                .background(Color.verdeBoton)
                                                .cornerRadius(20)
                                            
                                        }
                                        
                                        /*
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
                                         */
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
            .navigationTitle("Diagnóstico").navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}
 

 */



/*
 
 // Camara Apple
import SwiftUI

struct MenuView: View {
    @State private var capturedImage: UIImage?
    @State private var isImagePickerPresented = false
    
    @State private var isPhotoTaken = false
    
    var body: some View {
        VStack {
            // Display the captured image if available
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550, height: 550)
                    .padding()
                
                // Move to the diagnosis section below the image
                ScrollView {
                    VStack {
                        Text("Diagnóstico:")
                            .font(.title)
                            .padding(.top)
                        
                        Text("Aquí aparecerá el diagnóstico")
                            .font(.body)
                            .padding()
                    }
                }
            }
            
            // Button to open the camera
            Button(action: {
                isImagePickerPresented = true
            }) {
                Text("Tomar Foto")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            CameraPicker(capturedImage: $capturedImage, isImagePickerPresented: $isImagePickerPresented)
        }
        
        
        
    }
}


  
#Preview {
    MenuView()
}

*/



/*
 
 //Version 2 reto
import SwiftUI

struct MenuView: View {
    
 
 @State private var capturedImage: UIImage?
 @State private var isImagePickerPresented = false
 
 @State private var isPhotoTaken = false
 
    
    var body: some View {
        
        NavigationStack {
            ZStack {
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
                                    
                                    VStack {
                                        NavigationLink(destination: CameraScanView(labelData: Classification())){
                                            Text("Escanear")
                                                .font(.title)
                                                .foregroundColor(.white)
                                                .font(Font.varButtonLabel)
                                                .padding()
                                                .frame(width: 300.0, height: 50.0)
                                                .background(Color.verdeBoton)
                                                .cornerRadius(20)
                                            
                                        }
                                        
                                        /*
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
                                         */
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
            .navigationTitle("Diagnóstico").navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}
 

 */
