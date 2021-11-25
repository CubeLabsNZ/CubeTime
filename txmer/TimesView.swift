//
//  TimesView.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import SwiftUI

func getDismiss() {
    if #available(iOS 15.0, *) {
        
    } else {
        
    }
}



//@available(iOS 15.0, *)
struct SolvePopupView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("dismiss") {
            presentationMode.wrappedValue.dismiss()
        }
        
        
        .font(.title)
       
    }
}

/*
@available(iOS 14.0, *)
struct SolvePopupView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button("dismiss") {
            presentationMode.wrappedValue.dismiss()
        }
        .font(.title)
    }
}
*/

@available(iOS 15.0, *)
struct TimesView: View {
    @State private var showingPopupSlideover = false
    
    let time = (1...5).map { "Time \($0)" }
    
    /*
    let columns: [GridItem] = [
        GridItem(.fixed(Int(UIScreen.main.bounds.size.width) - 16*2 - 2*11), spacing: 11),
        GridItem(.fixed(Int(UIScreen.main.bounds.size.width) - 16*2 - 2*11), spacing: 11),
        GridItem(.fixed(Int(UIScreen.main.bounds.size.width) - 16*2 - 2*11), spacing: 11)
    ]
     */
    
    let columns = [
        GridItem(.adaptive(minimum: 112), spacing: 11)
    ]
    
    let values = SetValues()
    
    var body: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(time, id: \.self) { item in
                    ZStack {
                        
                        Button(action: {
                            print(item)
                            showingPopupSlideover.toggle()
                            
                        }) {
                            Text(item)
                                
                            
                                .font(.system(size: 17, weight: .bold, design: .default))
                                .foregroundColor(Color.black)
                                .frame(width: 112, height: 53)
                                
                                .background(Color.white)
                                .cornerRadius(10)
                                
                                
                                 
                                 
                                /*
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.white)
                                        .frame(width: 112, height: 53) /// FIX: don't hardcode values - use geometryty reader to get width of screnn!?!?! oh or use uiscreen extnesion from maintimerview
                                )
                                 */
                        }
                        .onLongPressGesture {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        }
                        .sheet(isPresented: $showingPopupSlideover) {
                            SolvePopupView()
                        }
                        .contextMenu {
                            
                            
                            //.foregroundColor(Color.green)
                            
                            Button {
                                print("MOVE TO PRESSED")
                            } label: {
                                Label("Move To", systemImage: "arrow.up.forward.circle")
                            }
                            
                            Divider()
                            
                            Button {
                                print("OK PRESSED")
                            } label: {
                                Label("No Penalty", systemImage: "checkmark.circle") /// TODO: add custom icons because no good icons
                            }
                            
                            Button {
                                print("+2 pressed")
                            } label: {
                                Label("+2", systemImage: "plus.circle") /// TODO: add custom icons because no good icons
                            }
                            
                            Button {
                                print("DNF pressed")
                            } label: {
                                Label("DNF", systemImage: "slash.circle") /// TODO: add custom icons because no good icons
                            }
                            
                            
                            
                            Divider()
                            
                            Button (role: .destructive) {
                                print("delete time pressed")
                            } label: {
                                Label {
                                    Text("Delete Solve")
                                        .foregroundColor(Color.red)
                                } icon: {
                                    Image(systemName: "trash")
                                        .foregroundColor(Color.green) /// FIX: colours not working
                                }
                            }
                            
                            
                        }
                        //.cornerRadius(10)
                }
            }
            //.frame(minHeight: geometry.size.height - CGFloat(values.tabBarHeight))
                
                
                
            /*
            ScrollView {
                
            }
             */
            //
                
        }
        .padding(.leading)
        .padding(.trailing)
        
    }
    /*
    var items: [GridItem] {
        Array(repeating: .init(.adaptive(minimum: 120)), count: 2)
    }
    

    var style: GridLayout
    
    var times: [GridItem] {
        switch style {
        case .vertical:
            return Array(repeating: .init(.adaptive(minimum: 120)), count: 2)
        case .horizontal:
            return Array(repeating: .init(.fixed(120)), count: 2)
        }
        
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(viewModel.reminderCategories, id: \.id) { category in
                switch style {
                case .horizontal:
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: items, pinnedViews: [.sectionHeaders]) {
                            Section(header: categoryHHeader(with: category.header.name)) {
                                ReminderListView(category: category)
                            }
                        }
                        .padding(.vertical)
                    }
                case .vertical:
                    LazyVGrid(columns: items, spacing: 10, pinnedViews: [.sectionHeaders]) {
                        Section(header: categoryVHeader(with: category.header.name)) {
                            ReminderListView(category: category)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    
    */
    
}

struct TimesView_Previews: PreviewProvider {
    static var previews: some View {
        TimesView()
    }
}
}
