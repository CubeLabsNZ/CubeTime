import SwiftUI


class observed: ObservableObject {
    @Published var size: CGFloat = 0
}
//
//struct AnimatedCheckmark: View {
//
//
//    @State var offsetValue: CGFloat = -25
//
//    var body: some View {
//
//    }
//}

struct SolvePopupView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    var timeListManager: TimeListManager?
    
    @State var offsetValue: CGFloat = -25
    
    
    let solve: Solves
    
    // Copy all items out of solve that are used by the UI
    // This is so that when the item is deleted they don't reset to default values
    let date: Date
    let time: String
    let puzzle_type: PuzzleType
    let puzzle_subtype: String
    let scramble: String
    
//    @Binding var currentSession: Sessions
    
    @Binding var currentSolve: Solves?
    
    @State private var userComment: String
    
    
    init(/*currentSession: Binding<Sessions>*/solve: Solves, currentSolve: Binding<Solves?>?, timeListManager: TimeListManager?){
        
//        self._currentSession = currentSession
        
        self.solve = solve
        self.date = solve.date ?? Date(timeIntervalSince1970: 0)
        self.time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
        self.puzzle_type = puzzle_types[Int(solve.scramble_type)]
        self.puzzle_subtype = puzzle_type.subtypes[Int(solve.scramble_subtype)]!
        self.scramble = solve.scramble ?? "Retrieving scramble failed."
        self._currentSolve = currentSolve ?? Binding.constant(nil)
        self.timeListManager = timeListManager
        _userComment = State(initialValue: solve.comment ?? "")
        
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
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
                                .foregroundColor(colourScheme == .light ? .black : .white)
                                .padding([.bottom, .horizontal], 12)
                            
                            /*
                            Divider()
                                .padding(.leading)
                            
                            Image("scramble-placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding([.horizontal, .bottom])
                                .padding(.top, 12)
                            */
                        }
                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                        .padding(.trailing)
                        .padding(.leading)
                        
                        VStack {
                            HStack {
                                Image(systemName: "square.text.square.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                //.padding(.trailing, 8)
                                Text("Comment")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                
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
                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                        //.listStyle(.insetGrouped)
                        .padding(.trailing)
                        .padding(.leading)
                        
                        Button {
                            UIPasteboard.general.string = "Exported by CubeTime.\n\(time): \(scramble)"
                            withAnimation(Animation.interpolatingSpring(stiffness: 140, damping: 20).delay(0.25)) {
                                self.offsetValue = 0
                            }
                        } label: {
                            HStack {
                                Text("Copy Solve")
                                    .padding([.leading, .vertical], 14)
                                
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .clipShape(Rectangle().offset(x: self.offsetValue))
                                
                                Spacer()
                            }
                        }
                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                        .padding(.horizontal)
                            
                        
                        
                        
                        
                        
                    }
                    .offset(y: -6)
                    .navigationTitle(time)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if timeListManager != nil { // Only show delete if called from timelist and not stats
                                Button {
                                    withAnimation {
                                        currentSolve = nil
                                    }
                                    managedObjectContext.delete(solve) // Todo read context from environment
                                    timeListManager?.resort()
                                    try! managedObjectContext.save()
                                } label: {
                                    Text("Delete Solve")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(Color.red)
                                }
                            }
                        }
                        
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                currentSolve = nil
                                
                                self.presentation.wrappedValue.dismiss()
                                
                                
//                                dismiss() // Dismiss in case called from StatsView
                                    
                                if managedObjectContext.hasChanges {
                                    try! managedObjectContext.save()
                                }
                            } label: {
                                
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))
                                    .padding(.leading, -4)
                                Text(timeListManager == nil ? "Stats" : "Time List")
                                    .padding(.leading, -4)
                            }
                        }
                    }
                }
            }
        }
    }
}


struct TimeCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    let solve: Solves
    let timeListManager: TimeListManager
    
    @State var formattedTime: String
    @State var pen: PenTypes
    
    @Binding var currentSolve: Solves?
    @Binding var isSelectMode: Bool
    
    @Binding var selectedSolves: [Solves]
    
    @State var isSelected = false
    
    
    init(solve: Solves, timeListManager: TimeListManager, currentSolve: Binding<Solves?>, isSelectMode: Binding<Bool>, selectedSolves: Binding<[Solves]>) {
        self.solve = solve
        self.timeListManager = timeListManager
        self._formattedTime = State(initialValue: formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!))
        self._pen = State(initialValue: PenTypes(rawValue: solve.penalty)!)
        self._currentSolve = currentSolve
        self._isSelectMode = isSelectMode
        self._selectedSolves = selectedSolves
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color(uiColor: .systemGray4) : colourScheme == .dark ? Color(uiColor: .systemGray6) : Color(uiColor: .systemBackground))
                .contentShape(RoundedRectangle(cornerRadius: 10))
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
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .font(.system(size: 17, weight: .bold, design: .default))
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .contentShape(RoundedRectangle(cornerRadius: 10))

        
        .onChange(of: isSelectMode) {newValue in
            if !newValue && isSelected {
                withAnimation {
                    isSelected = false
                }
            }
        }
        .contextMenu {
//            Button {
//            } label: {
//                Label("Move To", systemImage: "arrow.up.forward.circle")
//            }
//
//            Divider()
            
            Button {
                pen = .none
                self.solve.penalty = pen.rawValue
                formattedTime = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
                try! managedObjectContext.save()
            } label: {
                Label("No Penalty", systemImage: "checkmark.circle") /// TODO: add custom icons because no good icons
            }
            
            Button {
                pen = .plustwo
                self.solve.penalty = pen.rawValue
                formattedTime = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
                try! managedObjectContext.save()
            } label: {
                Label("+2", systemImage: "plus.circle") /// TODO: add custom icons because no good icons
            }
            
            Button {
                pen = .dnf
                self.solve.penalty = pen.rawValue
                formattedTime = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
                try! managedObjectContext.save()
            } label: {
                Label("DNF", systemImage: "slash.circle") /// TODO: add custom icons because no good icons
            }
            
            Divider()
            
            Button (role: .destructive) {
                managedObjectContext.delete(solve)
                try! managedObjectContext.save()
                withAnimation {
                    timeListManager.delete(solve)
                }
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
    }
}
