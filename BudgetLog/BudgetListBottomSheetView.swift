//
//  BudgetListBottomSheetView.swift
//  BudgetLog
//
//  Created by Fikri Haikal on 15/01/23.
//

import SwiftUI

struct BudgetListBottomSheetView: View {
    
    @State private var isAdding = false
    @State private var textBudgetNameController: String = ""
    private var onItemClicked: (String) -> Void
    
    init(onItemClicked: @escaping (String) -> Void) {
        self.onItemClicked = onItemClicked
    }
    
    var body: some View {
        if isAdding {
            HStack {
                TextField(
                    "Budget Name",
                    text: $textBudgetNameController
                )
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                
                Spacer()
                Button(action: {}) {
                    Text("Save")
                }
                .simultaneousGesture(
                    LongPressGesture()
                        .onEnded { _ in
                            isAdding.toggle()
                        }
                )
                .highPriorityGesture(
                    TapGesture().onEnded { _ in
                        onItemClicked("New Item")
                    })
            }
            .padding(EdgeInsets(top: 32.0, leading: 24.0, bottom: 16.0, trailing: 24.0))
        } else {
            HStack {
                Spacer()
                Button(action: {
                    isAdding.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
            .padding(EdgeInsets(top: 32.0, leading: 0.0, bottom: 0.0, trailing: 24.0))
        }
        
        Spacer(minLength: 16.0)
        List {
            ForEach([1,2,3], id: \.self) {(item) in
                HStack {
                    Text("Item \(item)")
                    Spacer()
                }
                .onTapGesture {
                    onItemClicked("Item \(item)")
                }
            }
        }
     
    }
}
