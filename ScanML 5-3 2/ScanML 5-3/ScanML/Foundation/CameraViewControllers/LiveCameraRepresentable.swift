//
//  LivecameraRepresentable.swift
//  Proyecto_Equipo1
//
//  Created by Alumno on 09/10/23.
//
import Foundation
import SwiftUI
import AVFoundation

struct LiveCameraRepresentable: UIViewControllerRepresentable {
    
    var handleObservations: (LivePredictionResults, String, String) -> ()
    
    func makeUIViewController(context: Context) -> LiveCameraViewController {
        let vc = LiveCameraViewController(handleObservations: handleObservations)
        do {
            try vc.runSession()
        } catch {
            print(error.localizedDescription)
        }
        return vc
    }
    
    func updateUIViewController(_ cameraViewController: LiveCameraViewController, context: Context) {
    }
}

