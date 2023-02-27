import SwiftUI

struct TimeDetailView: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager

    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    private let titleDateFormat: DateFormatter
    
    private var solve: Solves
    
    private let date: Date
    private let time: String
    private let puzzle_type: PuzzleType
    private let scramble: String
    private let phases: Array<Double>?
    
    
    @State private var userComment: String
    @State private var offsetValue: CGFloat = -25
    
    @Binding var currentSolve: Solves?
    
    @FocusState private var commentFocus: Bool
    
    
    init(for solve: Solves, currentSolve: Binding<Solves?>?) {
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
        
        
        self.titleDateFormat = DateFormatter()
        titleDateFormat.locale = Locale(identifier: "en_US_POSIX")
        titleDateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        titleDateFormat.dateFormat = "h:mm a, dd/mm/yyyy"
    }
    
    
    var body: some View {
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
                                            .foregroundColor(Color(uiColor: .systemGray))
                                            .padding(.leading, 8)
                                            .offset(y: -4)
                                        
                                    case PenTypes.plustwo.rawValue:
                                        let addedTime = formatSolveTime(secs: (solve.time + 2))
                                        Text("\(addedTime)")
                                            .font(.largeTitle.weight(.bold))
                                        
                                        Text("(\(time))")
                                            .font(.title3.weight(.semibold))
                                            .foregroundColor(Color(uiColor: .systemGray))
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
                                
                                Capsule()
                                    .fill(Color("indent1"))
                                    .frame(height: 1)
                                
                                
                                HStack {
                                    Text(date, formatter: titleDateFormat)
                                        .font(.system(size: 15, weight: .regular, design: .monospaced))
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
                                .font(Font(CTFontCreateWithFontDescriptor(stopwatchManager.ctFontDesc, 17, nil)))
                                .padding(.top, 28)
            //                    .font(.system(size: 17, weight: .medium, design: .monospaced))
                                
                                AsyncSVGView(puzzle: solve.scramble_type, scramble: scramble)
                                    .frame(maxWidth: 240)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, geo.size.width * 0.15)
                                
                                
                                HStack(spacing: 6) {
                                    Text("CubeTime.")
                                        .foregroundColor(Color("indent1"))
                                        .font(.custom("RecursiveSansLnrSt-Regular", size: 16))
                                    
                                    Spacer()
                                    
                                    #warning("doesn't update when pressed, AND doesn't update time list view either")
                                    HierarchialButton(type: .mono, size: .medium, onTapRun: {
                                        solve.penalty = PenTypes.none.rawValue
                                        
                                        if managedObjectContext.hasChanges {
                                            try! managedObjectContext.save()
                                        }
                                    }) {
                                        Label("OK", systemImage: "checkmark.circle")
                                    }
                                    
                                    HierarchialButton(type: .mono, size: .medium, onTapRun: {
                                        solve.penalty = PenTypes.plustwo.rawValue
                                        
                                        if managedObjectContext.hasChanges {
                                            try! managedObjectContext.save()
                                        }
                                    }) {
                                        Label("+2", image: "+2.label")
                                    }
                                    
                                    HierarchialButton(type: .mono, size: .medium, onTapRun: {
                                        solve.penalty = PenTypes.dnf.rawValue
                                        
                                        if managedObjectContext.hasChanges {
                                            try! managedObjectContext.save()
                                        }
                                    }) {
                                        Label("DNF", systemImage: "xmark.circle")
                                    }
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                            .padding(.top)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SESSION")
                                    .font(.subheadline.weight(.semibold))
                                
                                Capsule()
                                    .fill(Color("indent1"))
                                    .frame(height: 1)
                                
                                HStack {
                                    Image(systemName: "square.on.square")
                                    
                                    Text("session name sdlkfjsdklf")
                                }
                                .padding(.vertical, 6)
                                .font(.body.weight(.medium))
                                
                                HStack {
                                    Spacer()
                                    
                                    HierarchialButton(type: .mono, size: .medium, onTapRun: {}) {
                                        Label("Move to…", systemImage: "arrow.up.right")
                                    }
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                            
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("COMMENT")
                                    .font(.subheadline.weight(.semibold))
                                
                                Capsule()
                                    .fill(Color("indent1"))
                                    .frame(height: 1)
                                
                                
                                
                                
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
                                
                                HierarchialButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {}) {
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
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 48)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                currentSolve = nil
                                
                                dismiss()
                                
                                if managedObjectContext.hasChanges {
                                    try! managedObjectContext.save()
                                }
                            } label: {
                                Text("Done")
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Time Detail")
                }
            }
        }
    }
}
