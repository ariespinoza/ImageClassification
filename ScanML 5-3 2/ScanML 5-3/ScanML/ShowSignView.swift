//
//  ShowSignView.swift
//  Proyecto_Equipo1
//
//  Created by Alumno on 15/10/23.
//

import SwiftUI

struct ShowSignView: View {
    private(set) var labelData: Classification
    
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(Color.verdeOscuro)
                .cornerRadius(10)
                .frame(width: 250, height: 60)
                
            Text(labelData.label.capitalized)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(Font
                    .custom("Chapeau-Medium", size: 20))
                
        }
    }
       
}

struct ShowSignView_Previews: PreviewProvider {
    static var previews: some View {
        ShowSignView(labelData: Classification())
    }
}
