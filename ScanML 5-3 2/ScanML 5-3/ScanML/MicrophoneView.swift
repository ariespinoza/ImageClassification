//
//  MicrophoneView.swift
//  ScanML
//
//  Created by Alumno on 01/10/25.
//

import SwiftUI

struct MicrophoneView: View {
    @State private var animate = false
    

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.black.opacity(0.9), Color.black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Animated sound waves
            VStack {
                Spacer()
                ZStack {
                    ForEach(0..<5) { i in
                        WaveShape(amplitude: CGFloat(10 + i*5), frequency: CGFloat(1 + Double(i)*0.2), phase: animate ? .pi*2 : 0)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.verdeClaro.opacity(0.6 - Double(i)*0.1), Color.verdeOscuro.opacity(0.3 - Double(i)*0.05)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 3
                            )
                            .frame(height: 100)
                            .offset(y: CGFloat(-i*20))
                            .animation(
                                Animation.easeInOut(duration: 1.2 + Double(i)*0.2)
                                    .repeatForever(autoreverses: true),
                                value: animate
                            )
                    }
                    
                    // Central mic
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.verdeOscuro, Color.verdeClaro]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 50
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: Color.verdeClaro.opacity(0.6), radius: 20, x: 0, y: 0)
                        .overlay(
                            Image(systemName: "mic.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        )
                        .scaleEffect(animate ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: animate
                        )
                }
                Spacer()
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// Custom wave shape
struct WaveShape: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height / 2
        path.move(to: CGPoint(x: 0, y: height))
        for x in stride(from: 0, to: width, by: 1) {
            let relativeX = x / width
            let y = height + sin(relativeX * frequency * 2 * .pi + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

#Preview {
    MicrophoneView()
}
