import CoreData
import SwiftUI
import CoreGraphics
import Combine
import SwiftfulLoadingIndicators
import SVGView
import UIKit

struct SheetStrWrapper: Identifiable {
    let id = UUID()
    let str: String
}

struct AvoidFloatingPanel: ViewModifier {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var timerController: TimerContoller
    @Environment(\.horizontalSizeClass) private var hSizeClass

    
    func body(content: Content) -> some View {
        let condition = stopwatchManager.currentPadFloatingStage == 2 && timerController.mode == .stopped
        
        content
            .padding(.leading, condition ? 360 : 0)
            .padding(.leading, condition ? nil : 0)
            .onChange(of: hSizeClass) { newValue in
                if (newValue == .compact) {
                    stopwatchManager.currentPadFloatingStage = 1
                }
            }
    }
}

class TimerUIViewNew: UIViewController, UIContextMenuInteractionDelegate {
    let sm = SettingsManager.standard
    
    var scrambleController: ScrambleController!
    var timerController: TimerContoller!
    var stopwatchManager: StopwatchManager?
    var fontManager: FontManager!
    
    var subscriptions: [AnyCancellable] = []
    
    @IBOutlet weak var scrambleLabel: UILabel!
    #warning("TODO: remove fixed height in storyboard, maybe fine since no hit testing, bg, etc.")
    @IBOutlet weak var timeLabel: UIView!

    @IBSegueAction func addTimerHeader(_ coder: NSCoder) -> UIViewController? {
        let hostingController = UIHostingController(coder: coder, rootView: TimerHeader(previewMode: false))
        hostingController!.view.backgroundColor = UIColor.clear
        return hostingController
    }
    
    @IBOutlet weak var longPressGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    let textLayer: CubeTimeTextLayer = {
        let textLayer = CubeTimeTextLayer()
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }()
    
    func updateTimerTextSize(mode _mode: TimerState? = nil) {
        // Must do explicitly else time will freeze until size finished
        CATransaction.begin()
        let mode = _mode ?? self.timerController.mode
        NSLog("UPDATE TIMER TEXT SIZE")
        if UIDevice.deviceIsPad && traitCollection.horizontalSizeClass == .regular {
            textLayer.fontSize = mode == .running ? 88 : 66
        } else if UIDevice.deviceModelName != "iPhoneSE" {
            textLayer.fontSize = mode == .running ? 70 : 56
        } else {
            textLayer.fontSize = 54
        }
        CATransaction.commit()
    }
    
    @objc func frame(displaylink: CADisplayLink) {
        self.textLayer.textDontAnimate = formatSolveTime(secs: -timerController.timerStartTime!.timeIntervalSinceNow, dp: sm.timeDpWhenRunning)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textLayer.frame = self.timeLabel.bounds
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textLayer.font = CTFontCreateWithFontDescriptor(fontManager.ctFontDescBold, 0, nil)
        updateTimerTextSize()
        timeLabel.layer.addSublayer(textLayer)
        
        let displaylink = CADisplayLink(target: self,
                                        selector: #selector(frame))
        displaylink.isPaused = true
        displaylink.add(to: .current,
                        forMode: .default)
        
                
        sm.preferencesChangedSubject
            .filter({
                $0 == \SettingsManager.gestureDistance ||
                $0 == \SettingsManager.holdDownTime
            })
            .sink(receiveValue: { [self] _ in
                NSLog("RECIEVE LONG PRESS SINK")
                longPressGesture.allowableMovement = sm.gestureDistance
                longPressGesture.minimumPressDuration = sm.holdDownTime
            })
            .store(in: &subscriptions)
        
        scrambleController.$scrambleStr
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: scrambleLabel)
            .store(in: &subscriptions)
        
        
        timerController.$timerCGColor
            .receive(on: RunLoop.main)
            .assign(to: \.colorDontAnimate!, on: textLayer)
            .store(in: &subscriptions)
        
        timerController.$mode
            .receive(on: RunLoop.main)
            .sink(receiveValue: { newValue in
                NSLog("label bounds: \(self.timeLabel.bounds), layer: \(self.textLayer.bounds)")
                self.updateTimerTextSize(mode: newValue)
                self.scrambleLabel.isHidden = newValue != .stopped
                UIApplication.shared.isIdleTimerDisabled = newValue != .stopped
                displaylink.isPaused = newValue != .running || self.sm.timeDpWhenRunning == -1
            })
            .store(in: &subscriptions)
        
        timerController.$secondsStr
            .receive(on: RunLoop.main)
            .sink(receiveValue: { newValue in
                // Isn't updating from displaylink
                if displaylink.isPaused {
                    self.textLayer.textDontAnimate = newValue
                }
            })
            .store(in: &subscriptions)
        
        
        scrambleController.$scrambleType
            .receive(on: RunLoop.main)
            .sink(receiveValue: { newScr in
                // TODO
//                self.scrambleLabel.adjustsFontSizeToFitWidth = newScr == 7
//                self.scrambleLabel.minimumScaleFactor = 0.5
            })
            .store(in: &subscriptions)
        
        
        fontManager.$uiFontScramble
            .receive(on: RunLoop.main)
            .assign(to: \.font, on: scrambleLabel)
            .store(in: &subscriptions)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        scrambleLabel.addInteraction(interaction)
        
        // Im not adding each of these individually in storyboard
        for direction in UISwipeGestureRecognizer.Direction.allCases {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
            gesture.direction = direction
            gesture.require(toFail: longPressGesture)
                        
            view.addGestureRecognizer(gesture)
        }
        
        // Can't find these in storyboard
        panGesture.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirectPointer.rawValue)]
    }
    
    // MARK: - Gestures
    
    
    @objc func swipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        #if DEBUG
        NSLog("SWIPED: \(timerController.mode), DIR: \(gestureRecognizer.direction)")
        #endif
        
        timerController.handleGesture(direction: gestureRecognizer.direction)
    }
    
    private var panHasTriggeredGesture = false
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
#if DEBUG
        NSLog("State: \(sender.state), panHasTriggeredGesture: \(panHasTriggeredGesture)")
#endif
        if panHasTriggeredGesture {
            if (sender.state == .cancelled || sender.state == .ended) {
                panHasTriggeredGesture = false
            }
            return
        }
        if sender.state != .cancelled {
            let translation = sender.translation(in: sender.view!.superview)
            let velocity = sender.velocity(in: sender.view!.superview)
            
            let d_x = translation.x
            let d_y = translation.y
            
            
            let v_x = velocity.x
            let v_y = velocity.y
            
            if v_x.magnitude > sm.gestureDistanceTrackpad || v_y.magnitude > sm.gestureDistanceTrackpad {
                panHasTriggeredGesture = true
                if d_x.magnitude > d_y.magnitude {
                    if d_x > 0 {
                        timerController.handleGesture(direction: .right)
                    } else if d_x < 0 {
                        timerController.handleGesture(direction: .left)
                    }
                } else {
                    if d_y < 0 {
                        timerController.handleGesture(direction: .up)
                    } else if d_y > 0 {
                        timerController.handleGesture(direction: .down)
                    }
                }
            } else {
                sender.state = .cancelled
            }
        }
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            timerController.longPressStart()
        } else if sender.state == .ended {
            timerController.longPressEnd()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touches.first?.view == self.view {
            timerController.touchDown()
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if touches.first?.view == self.view {
            timerController.touchUp()
        }
    }
    
    
    private var taskTimerReady: DispatchWorkItem?
    private var isLongPress = false
    private var keyDownThatStopped: UIKeyboardHIDUsage? = nil
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        if timerController.mode == .running {
            keyDownThatStopped = key.keyCode
            timerController.touchDown()
        } else if key.keyCode == .keyboardSpacebar {
            timerController.touchDown()
            let newTaskTimerReady = DispatchWorkItem {
                self.timerController.longPressStart()
                self.isLongPress = true
            }
            taskTimerReady = newTaskTimerReady
            DispatchQueue.main.asyncAfter(deadline: .now() + sm.holdDownTime, execute: newTaskTimerReady)
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        
        if keyDownThatStopped == key.keyCode {
            keyDownThatStopped = nil
            timerController.touchUp() // In case any key previously stopped
        } else if keyDownThatStopped == nil && key.keyCode == .keyboardSpacebar {
            taskTimerReady?.cancel()
            if isLongPress {
                timerController.longPressEnd()
                isLongPress = false
            } else {
                timerController.touchUp()
            }
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
    
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configuration: UIContextMenuConfiguration, highlightPreviewForItemWithIdentifier identifier: NSCopying) -> UITargetedPreview? {
        let previewParams = UIPreviewParameters()
        previewParams.backgroundColor = .clear
        return UITargetedPreview(view: scrambleLabel, parameters: previewParams)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            var children = [UIAction]()
            if let scrambleString = self.scrambleController.scrambleStr {
                children.append(
                    UIAction(title: "Copy Scramble", image: UIImage(systemName: "doc.on.doc")) { _ in
                        copyScramble(scramble: scrambleString)
                    }
                )
            }
            if let stopwatchManager = self.stopwatchManager {
                children.append(
                    UIAction(title: stopwatchManager.isScrambleLocked ? "Unlock Scramble" : "Lock Scramble",
                             image: UIImage(systemName: stopwatchManager.isScrambleLocked ? "lock.rotation.open" : "lock.rotation")) { _ in
                        stopwatchManager.isScrambleLocked.toggle()
                    }
                )
            }
            return UIMenu(children: children)
        })
    }
    
    
    
    
    
    // Setting coming soon. Watch this space :)
    // - backspace/del/ctrl-z = delete
    // - plus/ctrl-n/ctrl-rightarrow = new scramble
    // - ctrl-1,2,3 = ok, +2, dnf
    // - option-{2,7 | M | S | K | P | C | B} = switch playground puzzle type
    
    
    // iPad keyboard support
    
    
    
    #warning("TODO: make this a UIMenu for mac catalyst and sections in the discoverability overlay")
    override var keyCommands: [UIKeyCommand]? {
        get {
            guard let stopwatchManager else {return []}
            if (stopwatchManager.timerController !== timerController) {return []}
            let curPen: Penalty? = {
                guard let pen = stopwatchManager.solveItem?.penalty else {return nil}
                return Penalty(rawValue: pen)
            }()
            
            var commands = [
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve), input: "\u{08}", discoverabilityTitle: "Delete Solve", attributes: .destructive),
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve), input: UIKeyCommand.inputDelete, discoverabilityTitle: "Delete Solve", attributes: .destructive),
                // ANSI delete (above doesnt register in simulator? not sure
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve), input: "\u{7F}", attributes: .destructive),
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve), input: "z", modifierFlags: [.command], discoverabilityTitle: "Delete Solve", attributes: .destructive),
                
                UIKeyCommand(title: "New Scramble", action: #selector(newScr), input: "+", discoverabilityTitle: "New Scramble"),
                UIKeyCommand(title: "New Scramble", action: #selector(newScr), input: "n", modifierFlags: [.command], discoverabilityTitle: "New Scramble"),
                UIKeyCommand(title: "New Scramble", action: #selector(newScr), input: UIKeyCommand.inputRightArrow, modifierFlags: [.command], discoverabilityTitle: "New Scramble"),
                
                UIKeyCommand(title: "Penalty: None", action: #selector(penNone), input: "1", modifierFlags: [.command], discoverabilityTitle: "Remove penalty", state: curPen == Penalty.none ? .on : .off),
                UIKeyCommand(title: "Penalty: +2", action: #selector(penPlus2), input: "2", modifierFlags: [.command], discoverabilityTitle: "Set penalty to +2", state: curPen == Penalty.plustwo ? .on : .off),
                UIKeyCommand(title: "Penalty: DNF", action: #selector(penDNF), input: "3", modifierFlags: [.command], discoverabilityTitle: "Set penalty to DNF", state: curPen == Penalty.dnf ? .on : .off),
            ]
            
            if (SessionType(rawValue: stopwatchManager.currentSession.sessionType) == .playground) {
                commands += [
                    UIKeyCommand(title: "Scramble: 2x2", action: #selector(setScramble), input: "2", modifierFlags: [.alternate], propertyList: 0, discoverabilityTitle: "Set scramble to 2x2"),
                    UIKeyCommand(title: "Scramble: 3x3", action: #selector(setScramble), input: "3", modifierFlags: [.alternate], propertyList: 1, discoverabilityTitle: "Set scramble to 3x3"),
                    UIKeyCommand(title: "Scramble: 4x4", action: #selector(setScramble), input: "4", modifierFlags: [.alternate], propertyList: 2, discoverabilityTitle: "Set scramble to 4x4"),
                    UIKeyCommand(title: "Scramble: 5x5", action: #selector(setScramble), input: "5", modifierFlags: [.alternate], propertyList: 3, discoverabilityTitle: "Set scramble to 5x5"),
                    UIKeyCommand(title: "Scramble: 6x6", action: #selector(setScramble), input: "6", modifierFlags: [.alternate], propertyList: 4, discoverabilityTitle: "Set scramble to 6x6"),
                    UIKeyCommand(title: "Scramble: 7x7", action: #selector(setScramble), input: "7", modifierFlags: [.alternate], propertyList: 5, discoverabilityTitle: "Set scramble to 7x7"),
                    UIKeyCommand(title: "Scramble: Square-1", action: #selector(setScramble), input: "1", modifierFlags: [.alternate], propertyList: 6, discoverabilityTitle: "Set scramble to Square-1"),
                    UIKeyCommand(title: "Scramble: Megaminx", action: #selector(setScramble), input: "M", modifierFlags: [.alternate], propertyList: 7, discoverabilityTitle: "Set scramble to Megaminx"),
                    UIKeyCommand(title: "Scramble: Pyraminx", action: #selector(setScramble), input: "P", modifierFlags: [.alternate], propertyList: 8, discoverabilityTitle: "Set scramble to Pyraminx"),
                    UIKeyCommand(title: "Scramble: Clock", action: #selector(setScramble), input: "C", modifierFlags: [.alternate], propertyList: 9, discoverabilityTitle: "Set scramble to Clock"),
                    UIKeyCommand(title: "Scramble: Skewb", action: #selector(setScramble), input: "S", modifierFlags: [.alternate], propertyList: 10, discoverabilityTitle: "Set scramble to Skewb"),
                    UIKeyCommand(title: "Scramble: 3x3 OH", action: #selector(setScramble), input: "O", modifierFlags: [.alternate], propertyList: 11, discoverabilityTitle: "Set scramble to 3x3 OH"),
                    UIKeyCommand(title: "Scramble: 3x3 BLD", action: #selector(setScramble), input: "B", modifierFlags: [.alternate], propertyList: 12, discoverabilityTitle: "Set scramble to 3x3 BLD"),
                    UIKeyCommand(title: "Scramble: 4x4 BLD", action: #selector(setScramble), input: "8", modifierFlags: [.alternate], propertyList: 13, discoverabilityTitle: "Set scramble to 4x4 BLD"),
                    UIKeyCommand(title: "Scramble: 5x5 BLD", action: #selector(setScramble), input: "9", modifierFlags: [.alternate], propertyList: 14, discoverabilityTitle: "Set scramble to 5x5 BLD")
                ]
            }
            
            return commands
        }
    }
    
    @objc func deleteSolve() {
        stopwatchManager?.deleteLastSolve()
    }
    
    @objc func newScr() {
        scrambleController.rescramble()
    }
    
    @objc func penNone() {
        stopwatchManager?.changePen(to: .none)
    }
    
    @objc func penPlus2() {
        stopwatchManager?.changePen(to: .plustwo)
    }
    
    @objc func penDNF() {
        stopwatchManager?.changePen(to: .dnf)
    }
    
    @objc func setScramble(keyCommand: UIKeyCommand) {
        if let stopwatchManager = stopwatchManager, let type = keyCommand.propertyList as? Int {
            stopwatchManager.playgroundScrambleType = Int32(type)
        }
    }
}


struct TimerViewRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var timerController: TimerContoller
    @EnvironmentObject var scrambleController: ScrambleController
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "TimerView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "timerStoryboard") as! TimerUIViewNew
        
        vc.scrambleController = scrambleController
        vc.timerController = timerController
        vc.stopwatchManager = stopwatchManager
        vc.fontManager = fontManager
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct TimerTime: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var timerController: TimerContoller
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    var body: some View {
        let fontSize: CGFloat = (UIDevice.deviceIsPad && hSizeClass == .regular)
            ? timerController.mode == .running ? 88 : 66
            : timerController.mode == .running ? 70 : 56
        
        HStack{
            Text(timerController.secondsStr)
                .modifier(DynamicText())
                // for smaller phones (iPhoneSE and test sim), disable animation to larger text
                // to prevent text clipping and other UI problems
                .ifelse (UIDevice.deviceModelName == "iPhoneSE") { view in
                    return view
                        .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDescBold, 54, nil)))
                } elseDo: { view in
                    return view
                        .modifier(AnimatingFontSize(font: fontManager.ctFontDescBold, fontSize: fontSize))
                }
            
            Group {
                if (timerController.mode == .inspecting) {
                    if (15..<17 ~= timerController.inspectionSecs) {
                        Text("[+2]")
                    } else if (timerController.inspectionSecs >= 17) {
                        Text("[DNF]")
                    }
                }
            }
            .modifier(AnimatingFontSize(font: fontManager.ctFontDescBold, fontSize: fontSize - 32))
        }
        .animation(Animation.customBouncySpring, value: timerController.mode == .running)
        .foregroundColor(timerController.timerColour)
        .padding(.horizontal)
        .modifier(AvoidFloatingPanel())
    }
}

struct ScrambleText: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var scrambleController: ScrambleController
    @EnvironmentObject var fontManager: FontManager
    let scr: String
    var timerSize: CGSize
    @Binding var scrambleSheetStr: SheetStrWrapper?
    
    
    var body: some View {
        let mega: Bool = stopwatchManager.currentSession.scrambleType == 7
        
        Text(scr)
            .padding(4)
            .background(Color("base"))
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 4, style: .continuous))
            .contextMenu {
                if let scrambleString = scrambleController.scrambleStr {
                    Button {
                        copyScramble(scramble: scrambleString)
                    } label: {
                        Label("Copy Scramble", systemImage: "doc.on.doc")
                    }
                }
                
                if (stopwatchManager.isScrambleLocked) {
                    Button {
                        stopwatchManager.isScrambleLocked = false
                    } label: {
                        Label("Unlock Scramble", systemImage: "lock.rotation.open")
                    }
                } else {
                    Button {
                        stopwatchManager.isScrambleLocked = true
                    } label: {
                        Label("Lock Scramble", systemImage: "lock.rotation")
                    }
                }
            }
            .onTapGesture {
                scrambleSheetStr = SheetStrWrapper(str: scr)
            }
        
            .font(Font(fontManager.uiFontScramble))
            .fixedSize(horizontal: mega, vertical: false)
            .multilineTextAlignment(mega ? .leading : .center)
            .if(mega) { view in
                view.minimumScaleFactor(0.00001).scaledToFit()
            }
        
            .padding(.top, 35 + (UIDevice.hasBottomBar ? 0 : 8))
            .padding(.bottom, 40)

            .frame(maxWidth: timerSize.width, maxHeight: timerSize.height / 2, alignment: .center)
        
            .padding(.horizontal)
            .modifier(AvoidFloatingPanel())
            .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
    }
}


struct TimerView: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var timerController: TimerContoller
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var scrambleController: ScrambleController
    @EnvironmentObject var tabRouter: TabRouter
    
    @StateObject var gm = GradientManager()
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @Environment(\.dismiss) var dismiss

    
    // GET USER DEFAULTS
    @AppStorage("onboarding") var showOnboarding: Bool = true
    @Preference(\.showCancelInspection) private var showCancelInspection
    @Preference(\.scrambleSize) private var scrambleSize
    @Preference(\.showPrevTime) private var showPrevTime
    @Preference(\.inputMode) private var inputMode
    
    
    // FOCUS STATES
    @FocusState private var targetFocused: Bool
    @FocusState private var manualInputFocused: Bool
    
    
    @State private var manualInputTime: String = ""
    @State private var showInputField: Bool = false
    @State private var toggleSessionName: Bool = false
    
    // scramble sheet
    @State private var presentedAvg: CalculatedAverage?
    @State private var scrambleSheetStr: SheetStrWrapper?
    @State private var showDrawScrambleSheet: Bool = false
    
    @State private var menuExpanded: Bool = false
    
    @State private var justManuallyInput: Bool = false
    @State private var showManualInputFormattedText: Bool = false
    
    @State var algTrainerSubset = 0
    
    @State private var showSessions: Bool = false
    
    
    var body: some View {
        let typingMode = inputMode == .typing && stopwatchManager.currentSession.sessionType != SessionType.multiphase.rawValue
        
        GeometryReader { geo in
            Color("base")
                .ignoresSafeArea()
            
            
            if (typingMode || targetFocused || manualInputFocused) {
                Color.white.opacity(0.0001)
                    .onTapGesture {
                        switch (inputMode) {
                        case .timer:
                            manualInputFocused = false
                            targetFocused = false
                            showInputField = false
                            manualInputTime = ""
                            
                        case .typing:
                            if (showManualInputFormattedText) {
                                showManualInputFormattedText = false
                                manualInputFocused = true
                                
                                
                                if justManuallyInput {
                                    manualInputTime = ""
                                    justManuallyInput = false
                                }
                            } else {
                                manualInputFocused = false
                                showManualInputFormattedText = true
                            }
                        }
                        
                        
                        stopwatchManager.showPenOptions = false
                    }
            }
            
            
            if !((typingMode || showInputField) && !showManualInputFormattedText) {
                VStack(alignment: .center, spacing: 0) {
                    TimerTime()
                        .allowsHitTesting(false)
                        .confirmationDialog("Are you sure you want to delete this solve?", isPresented: $stopwatchManager.showDeleteSolveConfirmation, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                stopwatchManager.deleteLastSolve()
                            }
                            Button("Cancel", role: .cancel) { }
                        }
                    
                    
                    if timerController.mode == .inspecting && showCancelInspection {
                        CTButton(type: .mono, size: .medium, onTapRun: {
                            timerController.interruptInspection()
                        }) {
                            Text("Cancel")
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea()
            }
            
            
            if (typingMode || showInputField) && !showManualInputFormattedText {
                TextField("0.00", text: $manualInputTime)
                    .focused($manualInputFocused)
                    .frame(maxWidth: geo.size.width-32)
                    .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDescBold, {
                        if (UIDevice.deviceIsPad && hSizeClass == .regular) {
                            return 66
                        } else {
                            return 56
                        }
                    }(), nil)))
                    .multilineTextAlignment(.center)
                    .foregroundColor(timerController.timerColour)
                    .background(Color("base"))
                    .modifier(DynamicText())
                    .modifier(AvoidFloatingPanel())
                    .modifier(ManualInputTextField(text: $manualInputTime))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .ignoresSafeArea()
                    .onSubmit {
                        if (!typingMode) {
                            if manualInputTime != "" {
                                // record entered time time
                                timerController.stop(timeFromStr(manualInputTime))
                                
                                // remove focus and reset time
                                showInputField = false
                                manualInputFocused = false
                                manualInputTime = ""
                            }
                        } else {
                            timerController.stop(timeFromStr(manualInputTime))
                            
                            // remove focus and reset time
                            manualInputFocused = false
                            justManuallyInput = true
                            
                            stopwatchManager.displayPenOptions()
                            
                            showManualInputFormattedText = true
                        }
                    }
            }
            
            
            if !stopwatchManager.hideUI {
                BottomTools(timerSize: geo.size, scrambleSheetStr: $scrambleSheetStr, presentedAvg: $presentedAvg)
                    .modifier(AvoidFloatingPanel())
                    .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
                
                // 50 for tab + 8 for padding + 16/0 for bottom bar gap
                
                let stages: [CGFloat] = [35, 35+16+55, geo.size.height-CGFloat(50)]
                
                #warning("todo: combine these into one hstack, doesn't need to be separate...")
                if (UIDevice.deviceIsPad && hSizeClass == .regular) {
                    HStack(alignment: .top) {
                        FloatingPanel(currentStage: $stopwatchManager.currentPadFloatingStage, stages: stages) {
                            PadTimerHeader(targetFocused: self.$targetFocused, showSessions: nil)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                PadTimerHeader(targetFocused: self.$targetFocused, showSessions: nil)
                                
                                PrevSolvesDisplay(count: 3)
                                    .padding(.horizontal, 8)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                PadTimerHeader(targetFocused: self.$targetFocused, showSessions: $showSessions)
                                
                                if (self.showSessions) {
                                    SessionsView()
                                } else {
                                    TimeListView()
                                }
                            }
                        }
                        
                        Spacer()
                        
                        
                        if (!self.menuExpanded) {
                            if (stopwatchManager.isScrambleLocked) {
                                Image(systemName: "lock.rotation")
                                    .font(.system(size: 17, weight: .medium, design: .default))
                                    .imageScale(.medium)
                                    .frame(width: 35, height: 35, alignment: .center)
                                    .onTapGesture {
                                        stopwatchManager.showUnlockScrambleConfirmation = true
                                    }
                            } else {
                                LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .small, speed: .fast)
                                    .frame(maxHeight: 35)
                                    .padding(.top, UIDevice.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
                                    .opacity(scrambleController.scrambleStr == nil ? 1 : 0)
                            }
                        }
                        
                        TimerMenu(expanded: self.$menuExpanded)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal)
                    .zIndex(3)
                    .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
                } else {
                    HStack(alignment: .top, spacing: 6) {
                        TimerHeader(targetFocused: $targetFocused, previewMode: false)
                        
                        Spacer()
                        
                        if (stopwatchManager.isScrambleLocked) {
                            Image(systemName: "lock.rotation")
                                .font(.system(size: 17, weight: .medium, design: .default))
                                .imageScale(.medium)
                                .frame(width: 35, height: 35, alignment: .center)
                                .onTapGesture {
                                    stopwatchManager.showUnlockScrambleConfirmation = true
                                }
                        } else {
                            LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .small, speed: .fast)
                                .frame(maxHeight: 35)
                                .padding(.top, UIDevice.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
                                .opacity(scrambleController.scrambleStr == nil ? 1 : 0)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal)
                    .zIndex(3)
                    .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
                }
            }
            
            if stopwatchManager.zenMode {
                CTCloseButton(hasBackgroundShadow: true, onTapRun: {
                    withAnimation(.customEaseInOut) {
                        stopwatchManager.zenMode = false
                    }
                })
                .padding([.trailing, .top])
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            
            
            if let scr = scrambleController.scrambleStr, timerController.mode == .stopped {
                ScrambleText(scr: scr, timerSize: geo.size, scrambleSheetStr: $scrambleSheetStr)
                    .confirmationDialog("Unlock scramble?", isPresented: $stopwatchManager.showUnlockScrambleConfirmation, titleVisibility: .visible) {
                        Button("Unlock!") {
                            stopwatchManager.isScrambleLocked = false
                            scrambleController.rescramble()
                        }
                        
                        Button("Cancel", role: .cancel) { }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            
            
            if scrambleController.scrambleStr != nil && (typingMode || stopwatchManager.showPenOptions) {
                HStack {
                    let showPlus = stopwatchManager.currentSession.sessionType != SessionType.multiphase.rawValue && !justManuallyInput && (inputMode != .typing || manualInputTime != "")
                    
                    
                    PenaltyBar {
                        HStack(spacing: 12) {
                            if (stopwatchManager.solveItem != nil && !manualInputFocused && (inputMode == .typing ? showManualInputFormattedText : true)) {
                                PenaltyButton(penType: .plustwo, penSymbol: "+2", imageSymbol: true, canType: false, colour: Color("orange"))
                                
                                PenaltyButton(penType: .dnf, penSymbol: "xmark.circle", imageSymbol: false, canType: false, colour: Color("red"))
                                    .frame(maxWidth: .infinity)
                                
                                PenaltyButton(penType: .none, penSymbol: "checkmark.circle", imageSymbol: false, canType: false, colour: Color("green"))
                                
                                if (showPlus) {
                                    ThemedDivider(isHorizontal: false)
                                        .padding(.vertical, 6)
                                }
                            }
                            
                            if (showPlus) {
                                if (!typingMode) {
                                    Button {
                                        // IF CURRENT MODE = INPUT
                                        if manualInputFocused {
                                            if manualInputTime != "" {
                                                // record entered time time
                                                timerController.stop(timeFromStr(manualInputTime))
                                                
                                                // remove focus and reset time
                                                showInputField = false
                                                manualInputFocused = false
                                                manualInputTime = ""
                                            }
                                        } else {
                                            showInputField = true
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                manualInputFocused = true
                                            }
                                            
                                            manualInputTime = ""
                                            
                                        }
                                    } label: {
                                        if manualInputFocused {
                                            Text("Done")
                                                .font(.body.weight(.medium))
                                                .padding(.horizontal, 8)
                                        } else {
                                            Image(systemName: "plus.circle")
                                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                        }
                                    }
                                    .disabled(manualInputFocused ? (manualInputTime == "") : false)
                                } else if (typingMode) {
                                    Button {
                                        timerController.stop(timeFromStr(manualInputTime))
                                        
                                        // remove focus and reset time
                                        manualInputFocused = false
                                        justManuallyInput = true
                                        
                                        stopwatchManager.displayPenOptions()
                                        
                                        showManualInputFormattedText = true
                                    } label: {
                                        Text("Done")
                                            .font(.body.weight(.medium))
                                            .padding(.horizontal, 8)
                                    }
                                }
                            }
                        }
                        .if (showPlus || (stopwatchManager.solveItem != nil && !manualInputFocused && showManualInputFormattedText)) { view in
                            view.padding(.horizontal, 5)
                        }
                    }
                    
                }
                .modifier(AvoidFloatingPanel())
                .disabled(scrambleController.scrambleStr == nil)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: UIDevice.deviceIsPad && hSizeClass == .regular ? 55 : 40)
            }
        }
        .sheet(item: $scrambleSheetStr, onDismiss: {
            scrambleSheetStr = nil
            dismiss()
        }) { str in
            #warning("crashes if you PULL DOWN on one sheet presented by draw scramble and quickly tap on scramble text")
            TimeScrambleDetail(binding: $scrambleSheetStr, str.str, scrambleController.scrambleSVG)
                .tint(Color("accent"))
        }
        
        .sheet(item: $presentedAvg, onDismiss: {
            self.presentedAvg = nil
        }) { item in
            StatsDetailView(solves: item)
                .tint(Color("accent"))
                #warning("TODO: use SWM env object")
        }
        
        .onReceive(stopwatchManager.$hideUI) { newValue in
            tabRouter.hideTabBar = newValue
        }
        
        .statusBar(hidden: stopwatchManager.hideUI)
        .ignoresSafeArea(.keyboard)
    }
}


struct TimeScrambleDetail: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    
    @Binding var scramble: SheetStrWrapper?
    
    var scrambleString: String
    var svg: String?
    @State var windowedScrambleSize: Int = SettingsManager.standard.scrambleSize
    
    init(binding: Binding<SheetStrWrapper?>, _ scrambleString: String, _ svg: String?) {
        self._scramble = binding
        self.scrambleString = scrambleString
        self.svg = svg
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    ScrollView {
                        Text(scrambleString)
                            .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDesc, CGFloat(windowedScrambleSize), nil)))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    
                    if let svg = svg {
                        SVGView(string: svg)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300)
                            .padding(.horizontal, geo.size.width * 0.1)
                            .padding(.vertical)
                    } else {
                        LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .medium, speed: .normal)
                    }
                }
                .frame(maxWidth: .infinity)
                .navigationTitle("Scramble")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack(alignment: .bottom) {
                            Button {
                                windowedScrambleSize = max(windowedScrambleSize - 1, 1)
                            } label: {
                                Image(systemName: "textformat.size.smaller")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("accent"))
                            }
                            
                            
                            Button {
                                windowedScrambleSize += 1
                            } label: {
                                Image(systemName: "textformat.size.larger")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("accent"))
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        CTDoneButton(onTapRun: {
                            dismiss()
                            scramble = nil
                        })
                    }
                }
            }
        }
    }
}
