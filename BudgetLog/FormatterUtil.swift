//
//  FormatterHelper.swift
//  BudgetLog
//
//  Created by Fikri Haikal on 22/01/23.
//

import Foundation

class FormatterUtil {
    
    static private var formatter = NumberFormatter()
    
    private init(){
     
    }
    
    static func formatNominal(nominal: Double) -> String {
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: nominal)) ?? ""
    }
    
}
