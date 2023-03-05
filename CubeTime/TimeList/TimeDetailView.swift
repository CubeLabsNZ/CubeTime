import SwiftUI


func getSolveDateFormatter(_ date: Date) -> DateFormatter {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_NZ")
    
    if (Calendar.current.isDateInToday(date)) {
        dateFormatter.dateFormat = "h:mm a"
    } else {
        dateFormatter.dateFormat = "dd/MM/yy"
    }
    
    return dateFormatter
}

struct TimeDetailView: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager

    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    private var solve: Solves
    
    private let date: Date
    private let time: String
    private let puzzle_type: PuzzleType
    private let scramble: String
    private let phases: Array<Double>?
    
    #warning("TODO: i dont know what im doing")
    @Binding var sessionsCanMoveTo: [Sessions]?
    @Binding var sessionsCanMoveTo_playground: [Sessions]?
    
    @State var sessionsCanMoveTo_s: [Sessions]? = nil
    @State var sessionsCanMoveTo_playground_s: [Sessions]? = nil
    
    @State private var userComment: String
    @State private var offsetValue: CGFloat = -25
    
    @Binding var currentSolve: Solves?
    
    @FocusState private var commentFocus: Bool
    
    
    init(for solve: Solves, currentSolve: Binding<Solves?>?, sessionsCanMoveTo: Binding<[Sessions]?>? = nil, sessionsCanMoveTo_playground: Binding<[Sessions]?>? = nil) {
        self.solve = solve
        self.date = solve.date ?? Date(timeIntervalSince1970: 0)
        self.time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
        self.puzzle_type = puzzle_types[Int(solve.scramble_type)]
        self.scramble = solve.scramble ?? "Retrieving scramble failed."
            
        if let multiphaseSolve = (solve as? MultiphaseSolve) {
            self.phases = multiphaseSolve.phases ?? [0.00, 0.00, 0.00, 0.00]
        } else {
            self.phases = nil
        }
        
        self._currentSolve = currentSolve ?? Binding.constant(nil)
        _userComment = State(initialValue: solve.comment ?? "")
        
        self._sessionsCanMoveTo = sessionsCanMoveTo ?? .constant(nil)
        self._sessionsCanMoveTo_playground = sessionsCanMoveTo_playground ??  .constant(nil)
    }
    
    
    var body: some View {
        let sess_type = stopwatchManager.currentSession.session_type
        
        NavigationView {
            ZStack {
                Color("base")
                    .ignoresSafeArea()
                
                GeometryReader { geo in
                    ScrollView {
                        VStack {
                            VStack(spacing: 4) {
                                HStack(alignment: .bottom) {
                                    switch solve.penalty {
                                    case PenTypes.dnf.rawValue:
                                        Text("DNF")
                                            .font(.largeTitle.weight(.bold))
                                        
                                        let rawTime = formatSolveTime(secs: solve.time)
                                        Text("(\(rawTime))")
                                            .font(.title3.weight(.semibold))
                                            .foregroundColor(Color("grey"))
                                            .padding(.leading, 8)
                                            .offset(y: -4)
                                        
                                    case PenTypes.plustwo.rawValue:
                                        let addedTime = formatSolveTime(secs: (solve.time + 2))
                                        Text("\(addedTime)")
                                            .font(.largeTitle.weight(.bold))
                                        
                                        Text("(\(time))")
                                            .font(.title3.weight(.semibold))
                                            .foregroundColor(Color("grey"))
                                            .padding(.leading, 8)
                                            .offset(y: -4)
                                    default:
                                        Text(time)
                                            .font(.largeTitle.weight(.bold))
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(alignment: .center) {
                                        Text(puzzle_type.name)
                                            .font(.title3.weight(.semibold))
                                        
                                        Image(puzzle_type.name)
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                    }
                                    .offset(y: -4)
                                }
                                
                                ThemedDivider()
                                
                                
                                HStack {
                                    Text(date, formatter: getSolveDateFormatter(date))
                                        .recursiveMono(fontSize: 15, weight: .regular)
                                        .foregroundColor(Color("grey"))
                                    
                                    Spacer()
                                }
                                
                                Group {
                                    if puzzle_type.name == "Megaminx" {
                                        Text(scramble)
                                            .fixedSize(horizontal: true, vertical: false)
                                            .multilineTextAlignment(.leading)
                                            // WORKAROUND
                                            .minimumScaleFactor(0.00001)
                                            .scaledToFit()
                                    } else {
                                        Text(scramble)
                                    }
                                }
                                .recursiveMono(fontSize: 17, weight: .medium)
                                .padding(.top, 28)
                                
                                AsyncSVGView(puzzle: solve.scramble_type, scramble: scramble)
                                    .frame(maxWidth: 240)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, geo.size.width * 0.15)
                                
                                
                                HStack(spacing: 6) {
                                    Spacer()
                                    
                                    HierarchialButton(type: solve.penalty == PenTypes.none.rawValue ? .halfcoloured : .mono, size: .medium, onTapRun: {
                                        stopwatchManager.changePen(solve: self.solve, pen: .none)
                                    }) {
                                        Label("OK", systemImage: "checkmark.circle")
                                    }
                                    
                                    HierarchialButton(type: solve.penalty == PenTypes.plustwo.rawValue ? .halfcoloured : .mono, size: .medium, onTapRun: {
                                        stopwatchManager.changePen(solve: self.solve, pen: .plustwo)
                                    }) {
                                        Label(title: {
                                            Text("+2")
                                        }, icon: {
                                            Image("+2.label")
                                                .renderingMode(.template)
                                        })
                                    }
                                    
                                    HierarchialButton(type: solve.penalty == PenTypes.dnf.rawValue ? .halfcoloured : .mono, size: .medium, onTapRun: {
                                        stopwatchManager.changePen(solve: self.solve, pen: .dnf)
                                    }) {
                                        Label("DNF", systemImage: "xmark.circle")
                                    }
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                            .padding(.top)
                            
                            
                            HStack {
                                Spacer()
                                
                                Text("CubeTime.")
                                    .recursiveMono(fontSize: 13, weight: .semibold)
                                    .foregroundColor(Color("indent0"))
                            }
                            .padding(.vertical, -4)

                            
                            
                            
                            // BUTTONS
                            
                            HStack(spacing: 8) {
                                HierarchialButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {
                                    copySolve(solve: solve)
                                    
                                    withAnimation(Animation.customSlowSpring.delay(0.25)) {
                                        self.offsetValue = 0
                                    }
                                    
                                    withAnimation(Animation.customFastEaseOut.delay(2.25)) {
                                        self.offsetValue = -25
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        ZStack {
                                            if self.offsetValue != 0 {
                                                Image(systemName: "doc.on.doc")
                                                    .font(.subheadline.weight(.medium))
                                                    .foregroundColor(Color.accentColor)
                                                   
                                            }
                                            
                                            
                                            Image(systemName: "checkmark")
                                                .font(.subheadline.weight(.semibold))
                                                .clipShape(Rectangle().offset(x: self.offsetValue))
                                        }
                                        .frame(width: 20)
                                        
                                        Text("Copy Solve")
                                    }
                                }
                                
                                HierarchialButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {
                                    shareSolve(solve: solve)
                                }) {
                                    Label("Share Solve", systemImage: "square.and.arrow.up")
                                }
                                
                                HierarchialButton(type: .red, size: .large, square: true, onTapRun: {
                                    if currentSolve == nil {
                                        dismiss()
                                    }

                                    currentSolve = nil

                                    withAnimation {
                                        stopwatchManager.delete(solve: solve)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                }
                                .frame(width: 35)
                            }
                            .padding(.top, 16)
                            
                            // END BUTTONS
                            
                            
                            
                            
                            
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SESSION")
                                    .font(.subheadline.weight(.semibold))
                                
                                ThemedDivider()
                                
                                HStack {
                                    Image(systemName: "square.on.square")
                                    
                                    Text(stopwatchManager.currentSession.name ?? "Unknown session name")
                                }
                                .padding(.vertical, 6)
                                .font(.body.weight(.medium))
                                
                                let sessions = { () -> [Sessions]? in
                                    if sess_type != SessionTypes.playground.rawValue {
                                        if let sessionsCanMoveTo = sessionsCanMoveTo {
                                            return sessionsCanMoveTo
                                        } else {
                                            return sessionsCanMoveTo_s
                                        }
                                    } else {
                                        if let sessionsCanMoveTo_playground = sessionsCanMoveTo_playground {
                                            return sessionsCanMoveTo_playground
                                        } else {
                                            return sessionsCanMoveTo_playground_s
                                        }
                                    }
                                }()
                                
                                SessionPickerMenu(sessions: sessions) { session in
                                    withAnimation(Animation.customDampedSpring) {
                                        stopwatchManager.moveSolve(solve: solve, to: session)
                                    }
                                    currentSolve = nil
                                    dismiss()
                                } label: {
                                    HierarchialButtonBase(type: .mono, size: .medium, outlined: false, square: false, hasShadow: true, hasBackground: true, expandWidth: false) {
                                        Label("Move to…", systemImage: "arrow.up.right")
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                            
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("COMMENT")
                                    .font(.subheadline.weight(.semibold))
                                
                                ThemedDivider()
                                
                                
                                
                                
                                ZStack {
                                    Group {
                                        if #available(iOS 16.0, *) {
                                            TextEditor(text: $userComment)
                                                .scrollContentBackground(.hidden)
                                        } else {
                                            TextEditor(text: $userComment)
                                                .onAppear {
                                                    let textViewAppearance = UITextView.appearance()
                                                    
                                                    textViewAppearance.backgroundColor = .clear
                                                    textViewAppearance.textContainerInset =
                                                         UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
                                                }
                                                .background(Color.red)
                                        }
                                    }
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Button("Comment") {
                                                commentFocus = false
                                            }
                                        }
                                    }
                                    .focused($commentFocus)
                                    .onChange(of: userComment) { newValue in
                                        solve.comment = newValue
                                    }
                                    
                                    
                                    if userComment == "" {
                                        Text("Comment something…")
                                            .padding(.vertical, 16)
                                            .foregroundColor(Color("grey"))
                                            .font(.subheadline.weight(.regular))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .allowsHitTesting(false)
                                    }
                                    
                                    Text(userComment)
                                        .padding(.vertical, 16)
                                        .opacity(0)
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 48)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            DoneButton(onTapRun: {
                                currentSolve = nil
                                
                                dismiss()
                                
                                if managedObjectContext.hasChanges {
                                    try! managedObjectContext.save()
                                }
                            })
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Time Detail")
                }
            }
        }
        .task {
            // Don't even.
            if sess_type == SessionTypes.playground.rawValue {
                NSLog("ses is pg")
                if sessionsCanMoveTo_playground != nil {
                    return
                }
                sessionsCanMoveTo_playground_s = getSessionsCanMoveTo(managedObjectContext: managedObjectContext, scrambleType: solve.scramble_type, currentSession: stopwatchManager.currentSession)
                NSLog("set canmoveto_p = \(sessionsCanMoveTo_playground)")
            } else {
                if sessionsCanMoveTo != nil {
                    return
                }
                sessionsCanMoveTo_s = getSessionsCanMoveTo(managedObjectContext: managedObjectContext, scrambleType: solve.scramble_type, currentSession: stopwatchManager.currentSession)
            }
        }
    }
}
