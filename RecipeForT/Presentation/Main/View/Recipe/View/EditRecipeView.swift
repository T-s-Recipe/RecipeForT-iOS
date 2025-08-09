//
//  EditRecipeView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/23/25.
//

import SwiftUI
import Swinject

struct EditRecipeView: View {
    @EnvironmentObject var router: Router
    @State private var editor: RecipeEditor
    @State private var isFullScreenCoverPresented: Bool = false
    
    init(recipe: Recipe?, resolver: Resolver) {
        self.editor = RecipeEditor(recipe: recipe, resolver: resolver)
    }
    
    var body: some View {
        VStack {
            navigationHeader
            
            ScrollView(.vertical) {
                LazyVStack {
                    RecipeBaseInfo(editor: editor)
                    
                    thickDivider
                    
                    IngredientsInfo(editor: editor)
                    
                    thickDivider
                    
                    DetailedStepsInfo(editor: editor)
                }
            }
        }
        .fullScreenCover(isPresented: $isFullScreenCoverPresented) {
            MustReadSheet()
        }
    }
    
    @ViewBuilder private var navigationHeader: some View {
        HStack {
            Button {
                router.dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            .tint(.black)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("Recipe")
                
                Button {
                    isFullScreenCoverPresented.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .tint(.black)
            }
            
            Spacer()
            
            Button {
                // TODO: 레시피 등록 기능
            } label: {
                Text("등록")
            }
            .tint(.black)
        }
        .padding()
        
        Divider()
    }
    
    private var thickDivider: some View {
        Rectangle()
            .frame(height: 10)
            .foregroundStyle(.gray.opacity(0.3))
    }
}

// MARK: - Subviews
extension EditRecipeView {
    struct RecipeBaseInfo: View {
        enum TextFieldType {
            case title, servings, cost, time, notes
            
            var next: TextFieldType? {
                switch self {
                case .title:
                    return .servings
                case .servings:
                    return .cost
                case .cost:
                    return .time
                case .time:
                    return .notes
                case .notes:
                    return nil
                }
            }
        }
        
        @FocusState private var focused: TextFieldType?
        @State private var viewModel: RecipeBaseInfoViewModel = RecipeBaseInfoViewModel()
        
        init(editor: RecipeEditor) {
            self.viewModel.delegate = editor
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Base Information")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                
                Text("Picture *")
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(.clear)
                    .strokeBorder(.gray)
                    .frame(width: 80, height: 60)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .padding(16)
                            .foregroundStyle(.gray)
                    }
                
                Text("Title *")
                
                textField("Title of the recipe", text: $viewModel.titleText, equals: .title)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Servings *")
                        
                        textField("How many servings?", text: $viewModel.servingsText, equals: .servings, isDisabled: viewModel.isServingsTextFieldDisabled)
                        
                        HStack(spacing: 8) {
                            CheckboxButton(isOn: $viewModel.isServingsTextFieldDisabled)
                            
                            Text("Not sure")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cost ($)")
                        
                        textField("Cooking cost", text: $viewModel.costText, equals: .cost, isDisabled: viewModel.isCostTextFieldDisabled)
                        
                        HStack(spacing: 8) {
                            CheckboxButton(isOn: $viewModel.isCostTextFieldDisabled)
                            
                            Text("Not sure")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Duration (min)")
                        
                        textField("Total cooking time", text: $viewModel.timeText, equals: .time, isDisabled: viewModel.isTimeTextFieldDisabled)
                        
                        HStack(spacing: 8) {
                            CheckboxButton(isOn: $viewModel.isTimeTextFieldDisabled)
                            
                            Text("Not sure")
                        }
                    }
                }
                
                Text("Recipe Notes")
                
                textField("Add notes or tips for this recipe", text: $viewModel.notesText, equals: .notes)
                    .lineLimit(10)
            }
            .padding()
        }
        
        @ViewBuilder private func textField(
            _ prompt: String,
            text: Binding<String>,
            equals: TextFieldType,
            isDisabled: Bool = false
        ) -> some View {
            TextField(prompt, text: text, axis: .vertical)
                .focused($focused, equals: equals)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .foregroundStyle(isDisabled ? .gray : .primary)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isDisabled ? .gray.opacity(0.3) : .clear)
                        .strokeBorder(focused == equals ? .black : .gray)
                )
                .onSubmit { focused = equals.next }
                .disabled(isDisabled)
        }
    }
    
    struct IngredientsInfo: View {
        @State private var viewModel: IngredientsInfoViewModel = IngredientsInfoViewModel()
        
        init(editor: RecipeEditor) {
            self.viewModel.delegate = editor
        }
        
        var body: some View {
            VStack(spacing: 12) {
                Text("Ingredients")
                    .font(.title3.bold())
                    .padding(.top, 16)
                
                // MARK: - Basic ingredients
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyVStack {
                            ForEach($viewModel.ingredients) { $ingredient in
                                VStack {
                                    IngredientRow(ingredient: $ingredient) {
                                        viewModel.onRemoveIngredient(with: ingredient.id)
                                    } onMoveUp: {
                                        viewModel.onMoveIngredientUp(with: ingredient.id)
                                    } onMoveDown: {
                                        viewModel.onMoveIngredientDown(with: ingredient.id)
                                    }

                                    if ingredient.id != viewModel.ingredients.last?.id {
                                        Divider().padding(.vertical, 8)
                                    }
                                }
                            }
                        }
                    }
                    .contentMargins(16)
                } header: {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Basic ingredients")
                            .font(.headline)
                        
                        Rectangle()
                            .frame(height: 2)
                    }
                    .padding([.top, .horizontal])
                }
                
                HStack {
                    Button {
                        viewModel.onAddIngredient()
                    } label: {
                        Label("Add Ingredient", systemImage: "plus.circle")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.gray)
                            )
                    }
                    .tint(.white)
                    .padding([.horizontal, .bottom])
                }
                
                // MARK: - Sources area
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyVStack {
                            ForEach($viewModel.sources) { $source in
                                VStack {
                                    IngredientRow(ingredient: $source) {
                                        viewModel.onRemoveSource(with: source.id)
                                    } onMoveUp: {
                                        viewModel.onMoveSourceUp(with: source.id)
                                    } onMoveDown: {
                                        viewModel.onMoveSourceDown(with: source.id)
                                    }

                                    if source.id != viewModel.sources.last?.id {
                                        Divider().padding(.vertical, 8)
                                    }
                                }
                            }
                        }
                    }
                    .contentMargins(16)
                } header: {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Source")
                            .font(.headline)
                        
                        Rectangle()
                            .frame(height: 2)
                    }
                    .padding([.top, .horizontal])
                }
                
                HStack {
                    Button {
                        viewModel.onAddSource()
                    } label: {
                        Label("Add Ingredient", systemImage: "plus.circle")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.gray)
                            )
                    }
                    .tint(.white)
                    .padding([.horizontal, .bottom])
                }
            }
        }
    }
    
    struct IngredientRow: View {
        @Binding var ingredient: Ingredient
        @State private var formatter = DecimalFormatter()
        
        private let maxNameLength: Int = 20
        
        let onRemove: () -> Void
        let onMoveUp: () -> Void
        let onMoveDown: () -> Void
        
        var body: some View {
            HStack(spacing: 12) {
                VStack(spacing: 0) {
                    Button {
                        onMoveUp()
                    } label: {
                        Image(systemName: "chevron.up")
                            .padding(.horizontal, 7)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.clear)
                                    .strokeBorder(.gray)
                            )
                    }
                    .tint(.gray)
                    
                    Button {
                        onMoveDown()
                    } label: {
                        Image(systemName: "chevron.down")
                            .padding(.horizontal, 7)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.clear)
                                    .strokeBorder(.gray)
                            )
                    }
                    .tint(.gray)
                }
                
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "minus.circle")
                }
                .tint(.gray)
                
                VStack(alignment: .leading) {
                    Text("Name")
                    
                    TextField("Ingredient name", text: $ingredient.name)
                        .padding(12)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.clear)
                                .strokeBorder(.gray)
                        )
                }
                
                Group {
                    decimalTextField("Tbsp", value: $ingredient.units[.tablespoon])
                    decimalTextField("Tsp", value: $ingredient.units[.teaspoon])
                    decimalTextField("Cup", value: $ingredient.units[.cup])
                    decimalTextField("g", value: $ingredient.units[.gram])
                    decimalTextField("ml", value: $ingredient.units[.milliliters])
                    decimalTextField("oz", value: $ingredient.units[.ounce])
                    decimalTextField("Qty", value: $ingredient.units[.quantity])
                }
            }
        }
        
        @ViewBuilder private func decimalTextField(_ label: any StringProtocol, value: Binding<Decimal?>) -> some View {
            VStack {
                Text(label)
                
                TextField("0", value: value, formatter: formatter)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .padding(12)
                    .frame(width: 80, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.clear)
                            .strokeBorder(.gray)
                    )
            }
        }
        
        private func onNameChange(_ : String, after: String) {
            guard after.count > maxNameLength else { return }
            ingredient.name = String(after.prefix(maxNameLength))
        }
    }
    
    struct DetailedStepsInfo: View {
        @State private var viewModel: DetailedStepsInfoViewModel = DetailedStepsInfoViewModel()
        
        init(editor: RecipeEditor) {
            self.viewModel.delegate = editor
        }
        
        var body: some View {
            VStack(spacing: 12) {
                Text("Detailed Steps")
                    .font(.title3.bold())
                    .padding(.top, 16)
                
                LazyVStack {
                    ForEach($viewModel.detailedSteps) { $step in
                        Section {
                            ForEach($step.detailedProcesses) { $process in
                                DetailedProcessCell(process: $process) {
                                    viewModel.onRemoveDetailedProcess(stepID: step.id, processID: process.id)
                                } onMoveUp: {
                                    viewModel.onMoveDetailedProcessUp(stepID: step.id, processID: process.id)
                                } onMoveDown: {
                                    viewModel.onMoveDetailedProcessDown(stepID: step.id, processID: process.id)
                                }
                                
                                if process.id != step.detailedProcesses.last?.id {
                                    Divider().padding(.vertical, 8)
                                }
                            }
                        } header: {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    TextField(step.title, text: $step.title)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.onRemoveStep(with: step.id)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                                
                                Rectangle()
                                    .frame(height: 2)
                                
                                Text("Detailed process *")
                                
                                Text("Photo: Optional / Recipe: Required")
                                    .foregroundStyle(.secondary)
                            }
                            .padding([.top, .horizontal])
                        } footer: {
                            HStack {
                                Button {
                                    viewModel.onAddDetailedProcess(stepID: step.id)
                                } label: {
                                    Label("Add Ingredient", systemImage: "plus.circle")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(.gray)
                                        )
                                }
                                .tint(.white)
                                .padding([.horizontal, .bottom])
                            }
                        }
                    }
                }
                
                HStack {
                    Button {
                        viewModel.onAddStep()
                    } label: {
                        Label("Next Step", systemImage: "plus.circle")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.gray)
                            )
                    }
                    .tint(.white)
                    .padding([.horizontal, .bottom])
                }
            }
        }
    }
    
    struct DetailedProcessCell: View {
        @Binding var process: CookingDetailedProcess
        
        let onRemove: () -> Void
        let onMoveUp: () -> Void
        let onMoveDown: () -> Void
        
        var body: some View {
            HStack(alignment: .top) {
                HStack {
                    VStack(spacing: 0) {
                        Button {
                            onMoveUp()
                        } label: {
                            Image(systemName: "chevron.up")
                                .padding(.horizontal, 7)
                                .padding(.vertical, 9)
                                .background(
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(.clear)
                                        .strokeBorder(.gray)
                                )
                        }
                        .tint(.gray)
                        
                        Button {
                            onMoveDown()
                        } label: {
                            Image(systemName: "chevron.down")
                                .padding(.horizontal, 7)
                                .padding(.vertical, 9)
                                .background(
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(.clear)
                                        .strokeBorder(.gray)
                                )
                        }
                        .tint(.gray)
                    }
                    
                    Button {
                        onRemove()
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .tint(.gray)
                }
                
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.clear)
                        .strokeBorder(.gray)
                        .frame(width: 80, height: 60)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .padding(16)
                                .foregroundStyle(.gray)
                        }
                    
                    TextField("Description here", text: $process.description, axis: .vertical)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .foregroundStyle(.primary)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.clear)
                                .strokeBorder(.gray)
                        )
                        .lineLimit(5)
                }
            }
            .padding()
        }
    }
}

// MARK: - Sheet
extension EditRecipeView {
    struct MustReadSheet: View {
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.black)
                    
                    Spacer()
                    
                    Text("Must read")
                    
                    Spacer()
                }
                .padding()
                
                Divider()
                
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sauce mixing order")
                            .font(.headline)
                        
                        Text("When writing out detailed recipe steps, please follow this order:")
                            .bulletPoint()
                        
                        Text("List the ingredients starting with those that don't stick to the spoon, followed by those that do. (e.g. sugar, salt -> honey, soy sauce")
                            .bulletPoint()
                        
                        Text("Measurement units")
                            .font(.headline)
                        
                        Text("1T: 1 tablespoon")
                            .bulletPoint()
                        
                        Text("1t: 1 teaspoon")
                            .bulletPoint()
                        
                        Text("Recipe")
                            .font(.headline)
                        
                        Text("When writing a recipe, avoid writing long sentences. Break them down into shorter steps as much as possible.")
                            .bulletPoint()
                    }
                    .padding(16)
                }
            }
        }
    }
}

#Preview {
    EditRecipeView(recipe: nil, resolver: PreviewHelper.shared.resolver)
}
