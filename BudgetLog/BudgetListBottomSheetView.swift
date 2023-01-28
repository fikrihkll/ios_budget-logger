//
//  BudgetListBottomSheetView.swift
//  BudgetLog
//
//  Created by Fikri Haikal on 15/01/23.
//

import SwiftUI

struct BudgetListBottomSheetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isAdding = false
    @State private var textBudgetNameController: String = ""
    private var onItemClicked: (UUID) -> Void
    @State private var dummyBudgetList = []
    @StateObject private var viewModel = BudgetListViewModel()
    
    init(onItemClicked: @escaping (UUID) -> Void) {
        self.onItemClicked = onItemClicked
    }
    
    var body: some View {
        VStack {
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
                            onItemClicked(viewModel.addNewBudget(name: textBudgetNameController, moc: viewContext) ?? UUID())
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
                ForEach(viewModel.listBudget) { (item) in
                    BudgetItemView(item: item, onItemClicked: self.onItemClicked)
                        .swipeActions(allowsFullSwipe: false) {
                            Button (action: { viewModel.removeBudget(id: item.id, moc: viewContext) }) {
                                Label("Delete", systemImage: "trash.circle.fill")
                          }
                          .tint(.blue)
                        }
                }
                .listRowBackground(Color.clear)
                
            }.onAppear() {
                viewModel.getListBudget(moc: self.viewContext)
            }
        }.background(Color.gray.opacity(0.1))
    }
}

struct BudgetItemView: View {
    
    private var item: Budget
    private var onItemClicked: (UUID) -> Void
    
    init(item: Budget, onItemClicked: @escaping (UUID) -> Void) {
        self.item = item
        self.onItemClicked = onItemClicked
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(item.name)
                    Spacer()
                }
                HStack {
                    Text("Rp. \(FormatterUtil.formatNominal(nominal: item.nominal))"
                    ).font(.caption)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(16.0)
            .onTapGesture {
                onItemClicked(item.id)
            }
        }
        
    }
}

struct BudgetListBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetListBottomSheetView(onItemClicked: {str in
            
        })
    }
}
