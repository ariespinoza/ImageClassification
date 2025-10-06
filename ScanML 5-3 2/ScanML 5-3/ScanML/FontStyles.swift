//
//  FontStyles.swift
//  prueba
//
//  Created by Alumno on 11/01/24.
//

import Foundation
import SwiftUI

extension Font{
    
    static var varButtonLabel: Font{
        return Font.custom("Chapeau-Medium",size:20)
    }
    
    static var varTitle: Font{
        return Font.custom("Chapeau-Bold",size:50)
    }
    
    static var varItemLabel: Font{
        return Font.custom("Chapeau-Bold",size:20)
    }
    static var varMainTitle: Font{
        return Font.custom("Chapeau-Bold",size:75)
    }
    static var varTitleSmall: Font{
        return Font.custom("Chapeau-Bold",size:42)
    }
    static var varSignOption: Font{
        return Font.custom("Chapeau-Bold",size:30)
    }
}
