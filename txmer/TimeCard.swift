//
//  TimeCard.swift
//  txmer
//
//  Created by macos sucks balls on 11/27/21.
//

import SwiftUI

struct MultiTextField: UIViewRepresentable {
    
    func makeCoordinator() -> MultiTextField.Coordinator {
        return MultiTextField.Coordinator(parent1: self)
    }
    
    @EnvironmentObject var obj: observed
    
    
    func makeUIView(context: UIViewRepresentableContext<MultiTextField>) -> UITextView {
        let view = UITextView()
        view.font = .systemFont(ofSize: 19, weight: .light)
        view.text = "sdfsdf"
        view.textColor = UIColor.black
        view.backgroundColor = .clear
        
        view.delegate = context.coordinator
        self.obj.size = view.contentSize.height
        view.isEditable = true
        view.isUserInteractionEnabled = true
        view.isScrollEnabled = true
        
        
        
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<MultiTextField>) {

    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultiTextField
        init(parent1: MultiTextField) {
            parent = parent1
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.text = ""
            textView.textColor = .black
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.obj.size = textView.contentSize.height
        }
    }
    
}

class observed: ObservableObject {
    @Published var size: CGFloat = 0
}

@available(iOS 15.0, *)
struct SolvePopupView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    @EnvironmentObject var obj: observed
    
    var timeListManager: TimeListManager
    
    
    let solve: Solves
    
    // Copy all items out of solve that are used by the UI
    // This is so that when the item is deleted they don't reset to default values
    let date: Date
    let time: String
    let puzzle_type: PuzzleType
    let puzzle_subtype: String
    let scramble: String
    
    @Binding var currentSolve: Solves?
    
    @State private var userComment: String = "SDKLJHFSDKJLFHSDF"
    
    
    init(solve: Solves, currentSolve: Binding<Solves?>, timeListManager: TimeListManager){
        self.solve = solve
        self.date = solve.date ?? Date(timeIntervalSince1970: 0)
        self.time = formatSolveTime(secs: solve.time)
        self.puzzle_type = puzzle_types[Int(solve.scramble_type)]
        self.puzzle_subtype = puzzle_type.subtypes[Int(solve.scramble_subtype)]!
        self.scramble = solve.scramble ?? "Retrieving scramble failed."
        self._currentSolve = currentSolve
        self.timeListManager = timeListManager
        _userComment = State(initialValue: solve.comment ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                ScrollView() {
                    VStack (spacing: 12) {
                        HStack {
                            Text(date, format: .dateTime.day().month().year())
                                .padding(.leading, 16)
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                            
                            Spacer()
                        }
                        
                        VStack {
                            HStack {
                                //Image("sq-1")
                                //  .padding(.trailing, 8)
                                Image(puzzle_type.name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                //                                    .padding(.leading, 2)
                                //                                    .padding(.top, 2)
                                //                                    .padding(.bottom, 2)
                                //                                    .padding([.bottom, .leading], 1)
                                    .padding(.leading, 2)
                                    .padding(.trailing, 4)
                                //.padding(.leading)
                                
                                Text(puzzle_type.name)
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                
                                Spacer()
                                
                                Text(puzzle_subtype.uppercased())
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .offset(y: 2)
                                
                            }
                            .padding(.leading, 12)
                            .padding(.trailing)
                            .padding(.top, 12)
                            
                            Divider()
                                .padding(.leading)
                            
                            Text(scramble)
                                .font(.system(size: 17, weight: .regular, design: .monospaced))
                                .padding(.leading)
                                .padding(.trailing)
                            
                            
                            Divider()
                                .padding(.leading)
                            
                            Image("scramble-placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.leading, 32)
                                .padding(.trailing, 32)
                                .padding(.bottom, 12)
                            
                        }
                        //.frame(minHeight: minRowHeight * 10)
                        //.frame(height: 300)
                        .background(Color(uiColor: .white).clipShape(RoundedRectangle(cornerRadius:10)))
                        //.listStyle(.insetGrouped)
                        .padding(.trailing)
                        .padding(.leading)
                        
                        VStack {
                            HStack {
                                Image(systemName: "square.text.square.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 30, weight: .semibold))
                                //.padding(.trailing, 8)
                                Text("Comment")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                
                                Spacer()
                                
                            }
                            //.padding(.leading)
                            //                            .padding(.trailing)
                            //                            .padding(.top)
                            .padding(.leading, 12)
                            .padding(.trailing)
                            .padding(.top, 12)
                            
                            Divider()
                                .padding(.leading)
                            //                                .padding(.bottom)
                            
                            ZStack {
                                TextEditor(text: $userComment)
                                    .padding(.horizontal)
                                    .padding(.bottom, 12)
                                    .onChange(of: userComment) { newValue in
                                        solve.comment = newValue
                                    }
                                Text(userComment).opacity(0)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                
                            }
                            
                            
                            /*TextField("Notes", text: $userComment)
                            
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                                .onChange(of: userComment) { newValue in
                                    solve.comment = newValue
                                }
                             */
                            
                        }
                        //.frame(minHeight: minRowHeight * 10)
                        //.frame(height: 300)
                        .background(Color(uiColor: .white).clipShape(RoundedRectangle(cornerRadius:10)))
                        //.listStyle(.insetGrouped)
                        .padding(.trailing)
                        .padding(.leading)
                        
                        HStack {
                            Text("Copy Solve")
                                .padding(12)
                            Spacer()
                        }
                        .onTapGesture {UIPasteboard.general.string = "Exported by txmer.\n\(time): \(scramble)"}
                        .background(Color.white.clipShape(RoundedRectangle(cornerRadius:10)))
                        .padding(.horizontal)
                        
                        
                        
                        
                    }
                    .offset(y: -6)
                    .navigationTitle(time)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                withAnimation {
                                    currentSolve = nil
                                }
                                managedObjectContext.delete(solve) // Todo read context from environment
                                timeListManager.resort()
                            } label: {
                                Text("Delete Solve")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color.red)
                            }
                        }
                        
                        
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                currentSolve = nil
                            } label: {
                                
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))
                                    .padding(.leading, -4)
                                Text("Time List")
                                    .padding(.leading, -4)
                            }
                        }
                    }
                }
            }
        }
    }
}


@available(iOS 15.0, *)
struct TimeCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    let solve: Solves
    let formattedTime: String
    
    @Binding var currentSolve: Solves?
    @Binding var isSelectMode: Bool
    
    @Binding var selectedSolves: [Solves]
    
    @State var isSelected = false
    
    init(solve: Solves, currentSolve: Binding<Solves?>, isSelectMode: Binding<Bool>, selectedSolves: Binding<[Solves]>) {
        self.solve = solve
        self.formattedTime = formatSolveTime(secs: solve.time)
        self._currentSolve = currentSolve
        self._isSelectMode = isSelectMode
        self._selectedSolves = selectedSolves
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color(uiColor: .systemGray4) : Color(uiColor: .systemBackground))
                .frame(maxWidth: 120, minHeight: 55, maxHeight: 55) /// todo check operforamcne of the on tap/long hold gestures on the zstack vs the rounded rectange
                .onTapGesture {
                    if isSelectMode {
                        withAnimation {
                            if isSelected {
                                isSelected = false
                                if let index = selectedSolves.firstIndex(of: solve) {
                                    selectedSolves.remove(at: index)
                                }
                            } else {
                                isSelected = true
                                selectedSolves.append(solve)
                            }
                        }
                    } else {
                        currentSolve = solve
                    }
                }
                .onLongPressGesture {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            VStack {
                Text(formattedTime)
                    .font(.system(size: 17, weight: .bold, design: .default))
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("AccentColor"))
                }
            }
        }.onChange(of: isSelectMode) {newValue in
            if !newValue && isSelected {
                withAnimation {
                    isSelected = false
                }
            }
        }
        
        
        
        
            //            .contextMenu {
            //
            //                Button {
            //                    print("MOVE TO PRESSED")
            //                } label: {
            //                    Label("Move To", systemImage: "arrow.up.forward.circle")
            //                }
            //
            //                Divider()
            //
            //                Button {
            //                    print("OK PRESSED")
            //                } label: {
            //                    Label("No Penalty", systemImage: "checkmark.circle") /// TODO: add custom icons because no good icons
            //                }
            //
            //                Button {
            //                    print("+2 pressed")
            //                } label: {
            //                    Label("+2", systemImage: "plus.circle") /// TODO: add custom icons because no good icons
            //                }
            //
            //                Button {
            //                    print("DNF pressed")
            //                } label: {
            //                    Label("DNF", systemImage: "slash.circle") /// TODO: add custom icons because no good icons
            //                }
            //
            //                Divider()
            //
            //                Button (role: .destructive) {
            //                    /*
            //                    managedObjectContext.delete(solve)
            //                    do {
            //                        try managedObjectContext.save()
            //                    } catch {
            //                        if let error = error as NSError? {
            //                            // Replace this implementation with code to handle the error appropriately.
            //                            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //
            //                            /*
            //                             Typical reasons for an error here include:
            //                             * The parent directory does not exist, cannot be created, or disallows writing.
            //                             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
            //                             * The device is out of space.
            //                             * The store could not be migrated to the current model version.
            //                             Check the error message to determine what the actual problem was.
            //                             */
            //                            fatalError("Unresolved error \(error), \(error.userInfo)")
            //                        }
            //                    }
            //                     */
            //                    print("Button tapped")
            //                    //timeListManager.resort()
            //                } label: {
            //                    Label {
            //                        Text("Delete Solve")
            //                            .foregroundColor(Color.red)
            //                    } icon: {
            //                        Image(systemName: "trash")
            //                            .foregroundColor(Color.green) /// FIX: colours not working
            //                    }
            //                }
            //            }
            
            
            //        Button(action: {
            //            print(solve.time)
            //
            //        }) {
            
            
            //        }
            
            //
            
        }
    }
    
    
