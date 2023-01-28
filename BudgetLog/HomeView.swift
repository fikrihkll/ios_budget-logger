//
//  HomeView.swift
//  BudgetLog
//
//  Created by Fikri Haikal on 07/01/23.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @State private var budgetId: UUID? = nil
    @State private var isInserting = true
    @State private var isDeleting = false
    @State private var isSelected = false
    
    @StateObject private var viewModel = HomeViewModel()
    private var headerController = HeaderController()
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack(alignment: .leading) {
                    Spacer()
                        .frame(height: 16.0)
                    HeaderView(
                        viewModel: viewModel,
                        onBudgetIdChanged: { (newBudgetId) in
                            viewModel.setBudgetId(newBudgetId: newBudgetId, moc: moc)
                            headerController.notifyBudgetInfoChanged()
                        },
                        controller: headerController
                    ).onAppear(perform: {
                        if (budgetId == nil) {
                            headerController.requestOpenListBudget()
                        }
                    })
                    
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
                    
                    ForEach(viewModel.listExpense) { item in
                        HStack {
                            LogItemView(
                                log: item,
                                isDeleting: self.isDeleting,
                                onDeleteClicked: { (log) in
                                    viewModel.removeExpense(log: log, moc: moc)
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
    
    private func addExpense(
        nominal: Double,
        desc: String,
        category: String
    ) {
        if !category.isEmpty {
            viewModel.addExpense(
                moc: self.moc,
                log: Log(
                    id: UUID(),
                    budgetId: viewModel.budgetId,
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

struct HeaderView: View, HeaderAction {
    
    @Environment(\.managedObjectContext) var moc
    
    @State private var isEditing = false
    @State private var textMaxBudgetController: String = ""
    @State private var textBudgetNameController: String = ""
    @State private var isListBudgetShown = false
    private var onBudgetIdChanged: ((UUID) -> Void)
    private var controller: HeaderController?
    private var viewModel: HomeViewModel
    
    init(
        viewModel: HomeViewModel,
        onBudgetIdChanged: @escaping ((UUID) -> Void),
        controller: HeaderController? = nil
    ) {
        self.viewModel = viewModel
        self.onBudgetIdChanged = onBudgetIdChanged
        if controller != nil {
            self.controller = controller!
            self.controller?.setListenerReference(actionListener: self)
        }
        if (viewModel.budgetInfo != nil) {
            _textBudgetNameController = State(initialValue: viewModel.budgetInfo?.name ?? "")
            _textMaxBudgetController = State(initialValue: String(format: "%.1f", viewModel.budgetInfo?.nominal ?? "0.0"))
        }
    }
    
    func onBudgetInfoChanged() {
        if (viewModel.budgetInfo != nil) {
            textBudgetNameController = viewModel.budgetInfo!.name
            textMaxBudgetController = String(format: "%.1f", viewModel.budgetInfo!.nominal)
        }
    }
    
    var body: some View {
        if isEditing {
            TextField(
                "Budget Name",
                text: $textBudgetNameController
            )
            .textFieldStyle(.roundedBorder)
        } else {
            Button(action: {
                isListBudgetShown.toggle()
            }) {
                Text(
                    viewModel.budgetInfo?.name ?? "-"
                ).font(.title2).fontWeight(.bold)
                Image(systemName: "chevron.up.chevron.down")
            }
            .sheet(isPresented: $isListBudgetShown) {
                
                BudgetListBottomSheetView(
                    onItemClicked: { (item) in
                        print("clicked \(item)")
                        onBudgetIdChanged(item)
                        isListBudgetShown.toggle()
                    }
                )
                
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .onAppear() {
                if controller?.isRequestingForShowingListBudget == true {
                    controller?.isRequestingForShowingListBudget = false
                    isListBudgetShown.toggle()
                }
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
                    "Rp. \(FormatterUtil.formatNominal(nominal: viewModel.budgetInfo?.nominal ?? 0.0))"
                ).font(.title3)
            }
            Spacer()
            EditButton()
                .simultaneousGesture(TapGesture().onEnded({
                    viewModel.editBudget(budgetId: viewModel.budgetId!, newName: textBudgetNameController, newNominal: Double(textMaxBudgetController) ?? 0.0, moc: moc)
                    isEditing.toggle()
                }))
        }
    }
    
}

class HeaderController {
    
    private var actionListener: HeaderAction? = nil
    var isRequestingForShowingListBudget = false
    
    func requestOpenListBudget() {
        isRequestingForShowingListBudget = true
    }
    
    func notifyBudgetInfoChanged() {
        actionListener?.onBudgetInfoChanged()
    }
    
    func setListenerReference(actionListener: HeaderAction) {
        self.actionListener = actionListener
    }
    
}

protocol HeaderAction {
    
    func onBudgetInfoChanged()
    
}

struct LogItemView: View {
    
    @State var log: Log
    private let formatter = NumberFormatter()
    private var isDeleting: Bool = false
    private var onDeleteClicked: (Log) -> Void

    init(log: Log, isDeleting: Bool, onDeleteClicked:  @escaping (Log) -> Void) {
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
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
                    self.onDeleteClicked(log)
                }) {
                    Image(systemName: "minus.circle.fill")
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Rp. \(FormatterUtil.formatNominal(nominal: log.nominal ?? 0.0))")
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
