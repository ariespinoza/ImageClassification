//
//  MicrophoneButton.swift
//  ScanML
//
//  Created by Alumno on 01/10/25.
//

import SwiftUI

struct MicrophoneButton: View {
    let color: Color
    
    @State private var position: CGPoint = CGPoint(
        x: UIScreen.main.bounds.width - 80,
        y: UIScreen.main.bounds.height - 150
    )
    @State private var showMicView = false
    @State private var isPressed = false
    @State private var floatOffset: CGFloat = 0
    @State private var animateWave = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Ondas discretas alrededor del botón
                ForEach(0..<2) { i in
                    Circle()
                        .stroke(color.opacity(0.15 - Double(i)*0.05), lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .scaleEffect(animateWave ? 1.3 + CGFloat(i)*0.2 : 1.0)
                        .opacity(animateWave ? 0.0 : 1.0)
                        .animation(
                            Animation.easeOut(duration: 2.0)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.4),
                            value: animateWave
                        )
                }
                
                // Botón principal
                Button(action: {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                        showMicView = true
                    }
                }) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(color)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .scaleEffect(isPressed ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
                }
            }
            // Posición con efecto flotante
            .position(x: position.x, y: position.y + floatOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                            let x = min(max(value.location.x, 50), geo.size.width - 50)
                            let y = min(max(value.location.y, 50), geo.size.height - 50)
                            position = CGPoint(x: x, y: y)
                        }
                    }
                    .onEnded { _ in
                        let margin: CGFloat = 60
                        let corners = [
                            CGPoint(x: margin, y: margin),
                            CGPoint(x: geo.size.width - margin, y: margin),
                            CGPoint(x: margin, y: geo.size.height - margin),
                            CGPoint(x: geo.size.width - margin, y: geo.size.height - margin)
                        ]
                        if let nearest = corners.min(by: { distance(from: position, to: $0) < distance(from: position, to: $1) }) {
                            withAnimation(.spring()) {
                                position = nearest
                            }
                        }
                    }
            )
            .sheet(isPresented: $showMicView) {
                MicrophoneView()
                    .transition(.scale)
                    .animation(.spring(), value: showMicView)
            }
            .onAppear {
                // Flotación y animación de ondas discretas
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    floatOffset = 8
                }
                animateWave = true
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = from.x - to.x
        let dy = from.y - to.y
        return sqrt(dx*dx + dy*dy)
    }
}

#Preview {
    ZStack {
        Color.white.edgesIgnoringSafeArea(.all)
        MicrophoneButton(color: Color(red: 32/255, green: 75/255, blue: 54/255))
    }
}
