//
//  HomeView.swift
//  BudgetLog
//
//  Created by Fikri Haikal on 07/01/23.
//

import SwiftUI

struct HomeView: View {
    
    @State private var isInserting = true
    @State private var isDeleting = false
    @State private var isSelected = false
    
    @StateObject private var viewModel = HomeViewModel()
    
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack(alignment: .leading) {
                    Spacer()
                        .frame(height: 16.0)
                    HeaderView()
                    
                    Spacer()
                        .frame(height: 32.0)
                    
                    HStack {
                        Text("Expenses")
                        Spacer()
                        Button(action: {
                            isDeleting.toggle()
                        }) {
                            Image(systemName: "minus")
                        }
                        Button(action: {
                            isInserting.toggle()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    
                    if (isInserting) {
                        InputExpenseView { (result) in
                            addExpense(
                                nominal: result.nominal,
                                desc: result.desc,
                                category: result.category
                            )
                        }
                    }
                    
                    ForEach(viewModel.listExpense.indices, id: \.self) { index in
                        HStack {
                            LogItemView(
                                log: viewModel.listExpense[index],
                                index: index,
                                isDeleting: self.isDeleting,
                                onDeleteClicked: { (selectedIndex) in
                                    deleteItems(index: selectedIndex)
                                    print("HERE \(selectedIndex)")
                                }
                            )
                        }
                    }
                    
                    
                    
                    
                    Spacer()
                }
            }
            
            .navigationTitle("Budget Log")
            .padding(.horizontal, 16.0)
        }
    }
    
    private func deleteItems(index: Int) {
        viewModel.removeExpense(index: index)
    }
    
    private func addExpense(
        nominal: Double,
        desc: String,
        category: String
    ) {
        if !category.isEmpty {
            viewModel.addExpense(
                log: Log(
                    id: UUID(),
                    nominal: nominal,
                    description: desc,
                    date: Date().timeIntervalSince1970,
                    category: category
                )
            )
        }
    }
}

struct InputExpenseView: View {
    
    @State private var textBudgetController: String = ""
    @State private var textDescController: String = ""
    @State private var selectedCategory: String = ""
    private var listCategory = ["Meal", "Food", "Drink", "Transport", "Subscription"]
    private var onSavePressed: ((nominal: Double, desc: String, category: String)) -> Void
    
    init(onSavePressed: @escaping ((nominal: Double, desc: String, category: String)) -> Void) {
        self.onSavePressed = onSavePressed
    }
    
    var body: some View {
        TextField(
            "Nominal",
            text: $textBudgetController
        )
        .textFieldStyle(.roundedBorder)
        .keyboardType(.numberPad)
        
        TextField(
            "Description",
            text: $textDescController
        ).textFieldStyle(.roundedBorder)
        
        HStack {
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(listCategory.indices, id: \.self) { index in
                        CategoryExpenseView(
                            title: listCategory[index],
                            index: index,
                            isSelected: selectedCategory == listCategory[index],
                            onItemClicked: { (selectedIndex) in
                                self.selectedCategory = listCategory[selectedIndex]
                            }
                        )
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                self.onSavePressed(
                    (
                        nominal: (Double(textBudgetController) ?? 0.0),
                        desc: textDescController,
                        category: selectedCategory
                    )
                )
            }) {
                Text("Save")
            }
            .padding(.leading)
        }
    }
    
}

struct CategoryExpenseView: View {
    
    @State var title: String
    var isSelected: Bool
    var index: Int
    var onItemClicked: (Int) -> Void
    
    init(
        title: String,
        index: Int,
        isSelected: Bool,
        onItemClicked: @escaping (Int) -> Void
    ) {
        _title = State(initialValue: title)
        self.index = index
        self.onItemClicked = onItemClicked
        self.isSelected = isSelected
    }
    
    var body: some View {
        Group {
            Button(
                action: {
                    self.onItemClicked(index)
            }) {
                Image(systemName: "cup.and.saucer.fill")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                Text(title)
                    .foregroundColor(Color.white)
            }
            .padding(8)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
            
        }
        .background(isSelected ? Color.gray : Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
    }
    
}

struct HeaderView: View {
    
    @State private var isEditing = false
    @State private var textMaxBudgetController: String = ""
    @State private var textBudgetNameController: String = ""
    @State private var isListBudgetShown = false
    
    var body: some View {
        if isEditing {
            TextField(
                "Budget Name",
                text: $textBudgetNameController
            )
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
        } else {
            Button(action: {
                isListBudgetShown.toggle()
            }) {
                Text(
                    "Italy"
                ).font(.title2).fontWeight(.bold)
                Image(systemName: "chevron.up.chevron.down")
            }
            .sheet(isPresented: $isListBudgetShown) {
                
                BudgetListBottomSheetView(
                    onItemClicked: { (item) in
                        print("clicked \(item)")
                        isListBudgetShown.toggle()
                    }
                )
                
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        Divider()
        HStack {
            if (isEditing) {
                TextField(
                    "Set Budget",
                    text: $textMaxBudgetController
                )
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            } else {
                Text(
                    "Rp. 14,000,000"
                ).font(.title3)
            }
            Spacer()
            EditButton()
                .simultaneousGesture(TapGesture().onEnded({
                    isEditing.toggle()
                }))
        }
    }
    
}

struct LogItemView: View {
    
    @State var log: Log
    private let formatter = NumberFormatter()
    private var index: Int
    private var isDeleting: Bool = false
    private var onDeleteClicked: (Int) -> Void

    init(log: Log, index: Int, isDeleting: Bool, onDeleteClicked:  @escaping (Int) -> Void) {
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        self.index = index
        self.isDeleting = isDeleting
        self.onDeleteClicked = onDeleteClicked
        
        _log = State(initialValue: log)
    }
    
    func setLog(log: Log) {
        self.log = log
    }
    
    var body: some View {
        HStack {
            if (isDeleting) {
                Button(action: {
                    self.onDeleteClicked(index)
                }) {
                    Image(systemName: "minus.circle.fill")
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Rp. \(formatter.string(from: NSNumber(value: log.nominal ?? 0.0)) ?? "")")
                        .fontWeight(.bold)
                    Spacer()
                    Text(getDate(timeMilis: log.date ?? 0.0))
                        .foregroundColor(Color.gray)
                        .font(.caption)
                }
                HStack {
                    Text(log.description ?? "")
                        .font(.body)
                        .foregroundColor(Color.gray)
                    Spacer()
                    Text(log.category ?? "")
                        .foregroundColor(Color.gray)
                        .font(.caption)
                }
                Divider()
                
            }
            .padding(.top, 16.0)
        }
    }
    
    private func getDate(timeMilis: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let date = Date(timeIntervalSince1970: TimeInterval(timeMilis))
        
        return dateFormatter.string(from: date)
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
