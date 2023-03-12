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
    
    @State private var userComment: String
    @State private var offsetValue: CGFloat = -25
    
    @State private var showShareSheet: Bool = false
    
    @Binding var currentSolve: Solves?
    
    @FocusState private var commentFocus: Bool
    
    
    init(for solve: Solves, currentSolve: Binding<Solves?>?, sessionsCanMoveTo: Binding<[Sessions]?>? = nil, sessionsCanMoveTo_playground: Binding<[Sessions]?>? = nil) {
        self.solve = solve
        self.date = solve.date ?? Date(timeIntervalSince1970: 0)
        self.time = formatSolveTime(secs: solve.time, penType: Penalty(rawValue: solve.penalty)!)
        self.puzzle_type = puzzle_types[Int(solve.scramble_type)]
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
        let sess_type = stopwatchManager.currentSession.session_type
        
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
                                        
                                        let rawTime = formatSolveTime(secs: solve.time)
                                        Text("(\(rawTime))")
                                            .font(.title3.weight(.semibold))
                                            .foregroundColor(Color("grey"))
                                            .padding(.leading, 8)
                                            .offset(y: -4)
                                        
                                    case Penalty.plustwo.rawValue:
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
                                    
                                    HierarchicalButton(type: solve.penalty == Penalty.none.rawValue ? .halfcoloured : .mono, size: .medium, onTapRun: {
                                        stopwatchManager.changePen(solve: self.solve, pen: .none)
                                    }) {
                                        Label("OK", systemImage: "checkmark.circle")
                                    }
                                    
                                    HierarchicalButton(type: solve.penalty == Penalty.plustwo.rawValue ? .halfcoloured : .mono, size: .medium, onTapRun: {
                                        stopwatchManager.changePen(solve: self.solve, pen: .plustwo)
                                    }) {
                                        Label(title: {
                                            Text("+2")
                                        }, icon: {
                                            Image("+2.label")
                                                .renderingMode(.template)
                                        })
                                    }
                                    
                                    HierarchicalButton(type: solve.penalty == Penalty.dnf.rawValue ? .halfcoloured : .mono, size: .medium, onTapRun: {
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
                                    .recursiveMono(fontSize: 13, weight: .regular)
                                    .foregroundColor(Color("indent0"))
                            }
                            .padding(.vertical, -4)

                            
                            
                            
                            // BUTTONS
                            
                            HStack(spacing: 8) {
                                HierarchicalButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {
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
                                                    .foregroundColor(Color("accent"))
                                                   
                                            }
                                            
                                            
                                            Image(systemName: "checkmark")
                                                .font(.subheadline.weight(.semibold))
                                                .clipShape(Rectangle().offset(x: self.offsetValue))
                                        }
                                        .frame(width: 20)
                                        
                                        Text("Copy Solve")
                                    }
                                }
                                
                                
                                ShareButton(solve: solve)
                                
//                                GeometryReader { buttonGeo in
//
//                                    .background(
//                                        ShareSheetViewController(isPresenting: self.$showShareSheet) {
//                                            let toShare: String = getShareStr(solve: solve)
//
//                                            let activityViewController = UIActivityViewController(activityItems: [toShare], applicationActivities: nil)
//                                            activityViewController.isModalInPresentation = true
//
//                                            if (UIDevice.deviceIsPad) {
//                                                let buttonFrame = CGRect(x: buttonGeo.frame(in: .global).minX,
//                                                                          y: buttonGeo.frame(in: .global).minY,
//                                                                          width: buttonGeo.size.width,
//                                                                          height: buttonGeo.size.height)
//
//                                                let sourceView = UIView(frame: buttonFrame)
//
//                                                print(buttonGeo.frame(in: .global).minX)
//                                                print(buttonGeo.size.width)
//
//
//
//                                                activityViewController.popoverPresentationController?.sourceView = sourceView
//                                            }
//
//                                            activityViewController.completionWithItemsHandler = { _, _, _, _ in
//                                                self.showShareSheet = false
//                                            }
//
//                                            return activityViewController
//                                        }
//                                    )
//                                }
//                                .background(.red)
                                
                                
                                HierarchicalButton(type: .red, size: .large, square: true, onTapRun: {
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
                                
                                SessionPickerMenu(sessions: sess_type == SessionType.playground.rawValue ? stopwatchManager.sessionsCanMoveToPlayground[Int(solve.scramble_type)] : stopwatchManager.sessionsCanMoveTo) { session in
                                    withAnimation(Animation.customDampedSpring) {
                                        stopwatchManager.moveSolve(solve: solve, to: session)
                                    }
                                    currentSolve = nil
                                    dismiss()
                                } label: {
                                    HierarchicalButtonBase(type: .mono, size: .medium, outlined: false, square: false, hasShadow: true, hasBackground: true, expandWidth: false) {
                                        Label("Move to…", systemImage: "arrow.up.right")
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                            
                            
                            if (stopwatchManager.currentSession.session_type == SessionType.multiphase.rawValue) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("PHASES")
                                        .font(.subheadline.weight(.semibold))
                                    
                                    ThemedDivider()
                                    
                                    #warning("TODO: ERROR CHECKING")
                                    AveragePhases(phaseTimes: phases!, count: phases!.count)
                                        .padding(.top, -24)
                                        .padding(.bottom, -12)
                                }
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                            }
                            
                            
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
    }
}

struct ShareButtonBase: View {
    var onTapRun: () -> ()
    
    var body: some View {
        HierarchicalButton(type: .coloured, size: .large, expandWidth: true, onTapRun: onTapRun) {
            Label("Share Solve", systemImage: "square.and.arrow.up")
        }
    }
}

final class ShareButtonUIViewController: UIViewController {
    var solve: Solves
    var hostingController: UIHostingController<ShareButtonBase>!
    var activityViewController: UIActivityViewController!
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    init(solve: Solves) {
        self.solve = solve
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        self.hostingController = UIHostingController(rootView: ShareButtonBase(onTapRun: { }))
        
        self.addChild(hostingController)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let toShare: String = getShareStr(solve: solve)

        self.activityViewController = UIActivityViewController(activityItems: [toShare], applicationActivities: nil)
        self.activityViewController.isModalInPresentation = true

        if (UIDevice.deviceIsPad) {
            self.activityViewController.popoverPresentationController?.sourceView = self.view
        }

        self.hostingController.rootView.onTapRun = { [weak self] in
            guard let self = self else { return }
            if (!self.hostingController.isBeingPresented) {
                self.present(self.activityViewController, animated: true, completion: nil)
            }
        }
    }
}

struct ShareButton: UIViewControllerRepresentable {
    let solve: Solves
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let shareButtonUIViewController = ShareButtonUIViewController(solve: solve)
        shareButtonUIViewController.view?.backgroundColor = .clear
        shareButtonUIViewController.hostingController.rootView.background(.clear)
        shareButtonUIViewController.hostingController.view?.backgroundColor = .clear
        
        return shareButtonUIViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
