import SwiftUI


func getSolveDateFormatter(_ date: Date) -> DateFormatter {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_NZ")
    #warning("l10n")
    
    if (Calendar.current.isDateInToday(date)) {
        dateFormatter.dateFormat = "h:mm:ss a"
    } else {
        dateFormatter.dateFormat = "dd/MM/yy"
    }
    
    return dateFormatter
}

struct TimeDetailView: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    private var solve: Solve
    
    private let date: Date
    private let time: String
    private let puzzleType: PuzzleType
    private let scramble: String
    private let phases: Array<Double>?
    
    @State private var userComment: String
    
    @Binding var currentSolve: Solve?
    
    @FocusState private var commentFocus: Bool
    
    
    init(for solve: Solve, currentSolve: Binding<Solve?>?, sessionsCanMoveTo: Binding<[Session]?>? = nil, sessionsCanMoveTo_playground: Binding<[Session]?>? = nil) {
        self.solve = solve
        self.date = solve.date ?? Date(timeIntervalSince1970: 0)
        self.time = formatSolveTime(secs: solve.time, penalty: Penalty(rawValue: solve.penalty)!)
        self.puzzleType = PUZZLE_TYPES[Int(solve.scrambleType)]
        self.scramble = solve.scramble ?? "Retrieving scramble failed."
                
        if let multiphaseSolve = (solve as? MultiphaseSolve), let phases = multiphaseSolve.phases {
            var phaseLengths = phases
            phaseLengths.insert(0, at: 0)
            phaseLengths = phaseLengths.chunked().map({ $0[1] - $0[0] })
            self.phases = phaseLengths
        } else {
            self.phases = nil
        }
        
        self._currentSolve = currentSolve ?? Binding.constant(nil)
        _userComment = State(initialValue: solve.comment ?? "")
    }
    
    
    var body: some View {
        let sessionType = stopwatchManager.currentSession.sessionType
        
        NavigationView {
            ZStack {
                BackgroundColour()
                
                GeometryReader { geo in
                    ScrollView {
                        VStack {
                            VStack(spacing: 4) {
                                HStack(alignment: .bottom) {
                                    switch solve.penalty {
                                    case Penalty.dnf.rawValue:
                                        Text("DNF")
                                            .font(.largeTitle.weight(.bold))
                                        
                                        if (dynamicTypeSize <= .xLarge) {
                                            Text("(\(formatSolveTime(secs: solve.time)))")
                                                .recursiveMono(style: .title3, weight: .semibold)
                                                .foregroundColor(Color("grey"))
                                                .padding(.leading, 8)
                                                .offset(y: -4)
                                        }
                                        
                                    case Penalty.plustwo.rawValue:
                                        Text("\(formatSolveTime(secs: (solve.time + 2)))")
                                            .recursiveMono(style: .largeTitle, weight: .bold)
                                            .modifier(DynamicText())
                                        
                                        if (dynamicTypeSize <= .xLarge) {
                                            Text("(\(time))")
                                                .recursiveMono(style: .title3, weight: .semibold)
                                                .foregroundColor(Color("grey"))
                                                .padding(.leading, 8)
                                                .modifier(DynamicText())
                                                .offset(y: -4)
                                        }
                                    default:
                                        Text(time)
                                            .recursiveMono(style: .largeTitle, weight: .bold)
                                            .modifier(DynamicText())
                                    }
                                    
                                    Spacer()
                                }
                                
                                CTDivider()
                                
                                
                                HStack {
                                    HStack(alignment: .center, spacing: 4) {
                                        Image(puzzleType.imageName)
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                        
                                        Text(puzzleType.name)
                                    }
                                    
                                    Text("|")
                                        .offset(y: -1)  // slight offset of bar
                                    
                                    Text(date, formatter: getSolveDateFormatter(date))
                                    
                                    
                                    Spacer()
                                }
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Group {
                                    if puzzleType.name == "Megaminx" {
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
                                .recursiveMono(size: 17, weight: .semibold)
                                .padding(.top, 28)
                                
                                AsyncSVGView(puzzle: solve.scrambleType, scramble: scramble)
                                    .frame(maxWidth: 240)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, geo.size.width * 0.15)
                                
                                
                                HStack(spacing: 6) {
                                    Spacer()
                                    
                                    CTButton(type: solve.penalty == Penalty.none.rawValue ? .halfcoloured(nil) : .mono, size: .medium, onTapRun: {
                                        stopwatchManager.changePen(solve: self.solve, pen: .none)
                                    }) {
                                        Label("OK", systemImage: "checkmark.circle")
                                    }
                                    
                                    CTButton(type: solve.penalty == Penalty.plustwo.rawValue ? .halfcoloured(nil) : .mono, size: .medium, onTapRun: {
                                        stopwatchManager.changePen(solve: self.solve, pen: .plustwo)
                                    }) {
                                        Label(title: {
                                            Text("+2")
                                        }, icon: {
                                            Image("+2.label")
                                                .renderingMode(.template)
                                        })
                                    }
                                    
                                    CTButton(type: solve.penalty == Penalty.dnf.rawValue ? .halfcoloured(nil) : .mono, size: .medium, onTapRun: {
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
                                
                                Text("CubeTime")
                                    .recursiveMono(size: 13)
                                    .foregroundColor(Color("grey").opacity(0.36))
                            }
                            .padding(.vertical, -4)

                            
                            
                            
                            // BUTTONS
                            
                            HStack(spacing: 8) {
                                CTCopyButton(toCopy: getShareStr(solve: solve, phases: (solve as? MultiphaseSolve)?.phases), buttonText: "Copy Solve")
                                
                                
                                CTShareButton(toShare: getShareStr(solve: solve, phases: (solve as? MultiphaseSolve)?.phases), buttonText: "Share Solve")
                                
                                
                                CTButton(type: .coloured(Color("red")), size: .large, square: true, onTapRun: {
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
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 4)
                            
                            // END BUTTONS
                            
                            
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SESSION")
                                    .font(.subheadline.weight(.semibold))
                                
                                CTDivider()
                                
                                HStack {
                                    Image(systemName: "square.on.square")
                                    
                                    Text(stopwatchManager.currentSession.name ?? "Unknown session name")
                                }
                                .padding(.vertical, 6)
                                .font(.body.weight(.medium))
                                
                                SessionPickerMenu(sessions: sessionType == SessionType.playground.rawValue ? stopwatchManager.sessionsCanMoveToPlayground[Int(solve.scrambleType)] : stopwatchManager.sessionsCanMoveTo) { session in
                                    withAnimation(Animation.customDampedSpring) {
                                        stopwatchManager.moveSolve(solve: solve, to: session)
                                    }
                                    currentSolve = nil
                                    dismiss()
                                } label: {
                                    CTBubble(type: .mono, size: .medium, outlined: false, square: false, hasShadow: true, hasBackground: true, hasMaterial: true, supportsDynamicResizing: true, expandWidth: false) {
                                        Label("Move to…", systemImage: "arrow.up.right")
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                            
                            
                            if (stopwatchManager.currentSession.sessionType == SessionType.multiphase.rawValue) {
                                if let phases = phases {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("PHASES")
                                            .font(.subheadline.weight(.semibold))
                                        
                                        CTDivider()
                                        
                                        AveragePhases(phaseTimes: phases, count: phases.count)
                                            .padding(.top, -24)
                                            .padding(.bottom, -12)
                                    }
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                                }
                            }
                            
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("COMMENT")
                                    .font(.subheadline.weight(.semibold))
                                
                                CTDivider()
                                
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
                                                .accentColor(Color("accent"))
                                        }
                                    }
                                    .ignoresSafeArea(.keyboard, edges: [.bottom])
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
                            CTDoneButton(onTapRun: {
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
    }
}

