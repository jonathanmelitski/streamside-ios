//
//  CoordinateDetailView.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/27/25.
//

import SwiftUI
import USGSShared

struct CoordinateDetailView: View {
    @ObservedObject var vm = SharedViewModel.shared
    @State var coordinate: UserSavedCoordinate
    @State var editingIcon: Bool = false
    let iconWidth: CGFloat = 64
    @State var selectedColor: Color
    @State var selectedIcon: String
    @FocusState var titleTextFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(coordinate: UserSavedCoordinate) {
        self.coordinate = coordinate
        self.selectedColor = coordinate.color.toSwiftUIColor
        self.selectedIcon = coordinate.iconString
        self.titleTextFocused = coordinate.name == ""
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.editingIcon = true
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [
                                    coordinate.color.toSwiftUIColor.mix(with: .white, by: 0.3),
                                    coordinate.color.toSwiftUIColor
                                ], startPoint: .top, endPoint: .bottom))
                                .frame(width: iconWidth)
                            Image(systemName: self.coordinate.iconString)
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                        
                    }
                    .buttonStyle(.plain)
                    Group {
                        TextField("Location Name", text: $coordinate.name, prompt: Text("New Location"), axis: .vertical)
                            .submitLabel(.done)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.leading)
                            .focused($titleTextFocused)
                            .onChange(of: coordinate.name) { _, new in
                                guard titleTextFocused else { return }
                                guard new.contains("\n") else { return }
                                titleTextFocused = false
                                coordinate.name = new.replacing("\n", with: "")
                            }
                            
                    }
                    .font(.largeTitle)
                    .bold()
                    Spacer()
                }
                Spacer()
                Button("Delete Location") {
                    withAnimation {
                        vm.deleteCoordinate(coordinate: coordinate)
                        dismiss()
                    }
                    
                }
            }
            if editingIcon {
                Color.black.opacity(0.000001)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.editingIcon = false
                        }
                    }
                VStack {
                    HStack {
                        VStack(alignment: .center, spacing: 12) {
                            Color.clear
                                .frame(width: iconWidth, height: iconWidth)
                            ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                                .labelsHidden()
                            IconPicker(selection: $selectedIcon)
                                .padding(.bottom, 12)
                            
                        }
                        .background {
                            RoundedRectangle(cornerSize: .init(width: iconWidth, height: iconWidth))
                                .fill(.ultraThickMaterial)
                                
                                .shadow(radius: 8)
                        }
                            
                        Spacer()
                    }
                    Spacer()
                }
                VStack {
                    HStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.editingIcon = false
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [
                                        coordinate.color.toSwiftUIColor.mix(with: .white, by: 0.3),
                                        coordinate.color.toSwiftUIColor
                                    ], startPoint: .top, endPoint: .bottom))
                                    .frame(width: iconWidth)
                                Image(systemName: self.coordinate.iconString)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    Spacer()
                }
                
            }
        }
        .onChange(of: selectedColor) {
            withAnimation {
                self.coordinate.color = CodableColor(from: selectedColor)
            }
        }
        .onChange(of: selectedIcon) {
            withAnimation {
                self.coordinate.iconString = selectedIcon
            }
        }
        .onChange(of: coordinate) {
            withAnimation {
                self.vm.updateCoordinate(id: self.coordinate.id) {
                    return self.coordinate
                }
            }
        }
    }
}


struct IconPicker: View {
    @Binding var selection: String
    @State var active: Bool = false
    
    let symbolsPerRow = 6
    
    var body: some View {
        Button {
            withAnimation {
                self.active = true
            }
        } label: {
            Image(systemName: selection)
                .padding(4)
        }
        .sheet(isPresented: $active) {
            ScrollView {
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    ForEach(0..<Int(ceil(Double(UserSavedCoordinate.allSymbolOptions.count) / Double(symbolsPerRow)))) { i in
                        GridRow {
                            Spacer()
                            ForEach(i * symbolsPerRow..<((i * symbolsPerRow + symbolsPerRow) >= UserSavedCoordinate.allSymbolOptions.count ? UserSavedCoordinate.allSymbolOptions.count : i * symbolsPerRow + symbolsPerRow)) { j in
                                Button {
                                    withAnimation {
                                        selection = UserSavedCoordinate.allSymbolOptions[j]
                                        self.active = false
                                    }
                                } label: {
                                    Image(systemName: UserSavedCoordinate.allSymbolOptions[j])
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .presentationDetents([.medium])
            }
        }
    }
}
