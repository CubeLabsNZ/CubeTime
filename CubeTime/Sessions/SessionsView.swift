import SwiftUI
import CoreData
import Combine
import SwiftfulLoadingIndicators

// MARK: - MAIN SESSION VIEW
struct SessionsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @State var showNewSessionPopUp = false
    
    @StateObject var cloudkitStatusManager = CloudkitStatusManager()
    
    @ScaledMetric(wrappedValue: 25, relativeTo: .subheadline) private var height
    
    @FetchRequest(
        entity: Session.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Session.pinned, ascending: false),
            NSSortDescriptor(keyPath: \Session.name, ascending: true)
        ]
    ) var sessions: FetchedResults<Session>
    
    @State private var showImport = false
    @State private var showExport = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView {
                    VStack (spacing: 10) {
                        HStack {
                            Menu {
                                Button() {
                                    showExport = true
                                } label: {
                                    Label("Export Sessions", systemImage: "square.and.arrow.up")
                                        .labelStyle(.titleAndIcon)
                                        .imageScale(.small)
                                }
                                
                                Button() {
                                    showImport = true
                                } label: {
                                    Label("Import Sessions", systemImage: "square.and.arrow.down")
                                        .labelStyle(.titleAndIcon)
                                        .imageScale(.small)
                                }
                            } label: {
                                CTBubble(type: .coloured(nil), size: .small, outlined: false, square: false, hasShadow: true, hasBackground: true, supportsDynamicResizing: true, expandWidth: false) {
                                    Label("Import & Export", systemImage: "square.and.arrow.up.on.square")
                                        .labelStyle(.titleAndIcon)
                                        .imageScale(.small)
                                }
                            }
                            .background(
                                Group {
                                    NavigationLink(destination: ExportFlowPickSessions(sessions: sessions), isActive: $showExport) { EmptyView() }
                                    NavigationLink(destination: ImportFlow(), isActive: $showImport) { EmptyView() }
                                }
                            )
                            
                            Spacer()
                            
                            Group {
                                if let status = cloudkitStatusManager.currentStatus {
                                    Group {
                                        switch (status) {
                                        case 0:
                                            Text("Synced to iCloud")
                                                .foregroundColor(Color("accent"))
                                        case 1:
                                            Text("Sync to iCloud failed")
                                                .foregroundColor(Color("grey"))
                                        default:
                                            Text("iCloud unavailable")
                                                .foregroundColor(Color("grey"))
                                        }
                                    }
                                    .font(.subheadline.weight(.medium))
                                    .frame(height: height)
                                } else {
                                    LoadingIndicator(animation: .bar, color: Color("accent"), size: .small, speed: .normal)
                                        .frame(height: height)
                                }
                                
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal)
                                                
                        if ((sessions.firstIndex(where: { !$0.pinned }) ?? 0) != 0) {
                            Text("PINNED SESSIONS")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                                .offset(y: 4)
                                .padding(.top, 4)
                        }
                        
                        ForEach(Array(zip(sessions.indices, sessions)), id: \.0) { index, item in
                            if (index == (sessions.firstIndex(where: { !$0.pinned }) ?? 0)) {
                                Text("SESSIONS")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                                    .offset(y: 4)
                            }
                            
                            SessionCard(item: item, allSessions: sessions)
                        }
                    }
                }
                .safeAreaInset(safeArea: .tabBar, avoidBottomBy: (UIDevice.deviceIsPad && hSizeClass == .regular) ? 0 : 50)
            }
            .background(
                BackgroundColour(isSessions: true)
            )
            .overlay(alignment: .bottomLeading) {
                CTButton(type: .coloured(nil), size: .large, onTapRun: {
                    showNewSessionPopUp = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .offset(x: -2)
                        
                        Text("New Session")
                    }
                }
                .if(!(UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
                    view
                        .padding(.bottom, 58)
                        .padding(.bottom, UIDevice.hasBottomBar ? 0 : nil)
                }
                .if(UIDevice.deviceIsPad && hSizeClass == .regular) { view in
                    view
                        .padding(.bottom, 8)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Sessions")
            .navigationBarTitleDisplayMode((UIDevice.deviceIsPad && hSizeClass == .regular) ? .inline : .large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !(UIDevice.deviceIsPad && hSizeClass == .regular) {
                        NavigationLink(destination: ToolsList()) {
                            CTBubble(type: .coloured(nil), size: .small, outlined: false, square: false, hasShadow: true, hasBackground: true, hasMaterial: true, supportsDynamicResizing: true, expandWidth: false) {
                                Label("Tools", systemImage: "wrench.and.screwdriver")
                                    .labelStyle(.titleAndIcon)
                                    .imageScale(.small)
                            }
                        }
                        .buttonStyle(CTButtonStyle())
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showNewSessionPopUp) {
            NewSessionRootView(showNewSessionPopUp: $showNewSessionPopUp)
                .tint(Color("accent"))
                .environment(\.managedObjectContext, managedObjectContext)
        }
    }
}


// MARK: - CUSTOMISE SESSIONS
struct CustomiseSessionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    let sessionItem: Session
    
    @State private var name: String
    @State private var targetStr: String
    @State private var phaseCount: Int
    
    @State var pinnedSession: Bool
    
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    @ScaledMetric(relativeTo: .title2) var bigFrameHeight: CGFloat = 220
    
    
    @State private var sessionEventType: Int32
    
    
    init(sessionItem: Session) {
        self.sessionItem = sessionItem
        
        self._name = State(initialValue: sessionItem.name ?? "")
        self._pinnedSession = State(initialValue: sessionItem.pinned)
        self._targetStr = State(initialValue: filteredStrFromTime((sessionItem as? CompSimSession)?.target))
        self._phaseCount = State(initialValue: Int((sessionItem as? MultiphaseSession)?.phaseCount ?? 0))
        
        self._sessionEventType = State(initialValue: sessionItem.scrambleType)
    }
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundColour()
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .center, spacing: 0) {
                            PuzzleHeaderImage(imageName: PUZZLE_TYPES[Int(sessionEventType)].name)
                            
                            SessionNameField(name: $name)
                        }
                        .frame(height: bigFrameHeight)
                        .modifier(CardBlockBackground())
                        
                        if sessionItem.sessionType == SessionType.compsim.rawValue {
                            CompSimTargetEntry(targetStr: $targetStr)
                        }
                        
                        if sessionItem.sessionType == SessionType.playground.rawValue {
                            EventPicker(sessionEventType: $sessionEventType)
                        }
                        
                        
                        PinSessionToggle(pinnedSession: $pinnedSession)
                    }
                }
                .navigationBarTitle("Customise Session", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        CTDoneButton(onTapRun: {
                            sessionItem.name = name
                            sessionItem.pinned = pinnedSession
                            
                            if sessionItem.sessionType == SessionType.compsim.rawValue {
                                (sessionItem as! CompSimSession).target = timeFromStr(targetStr)!
                            }
                            
                            if sessionItem.sessionType == SessionType.multiphase.rawValue {
                                (sessionItem as! MultiphaseSession).phaseCount = Int16(phaseCount)
                            }
                            
                            if sessionItem.sessionType == SessionType.playground.rawValue {
                                if sessionItem == stopwatchManager.currentSession {
                                    stopwatchManager.playgroundScrambleType = sessionEventType
                                } else {
                                    sessionItem.scrambleType = sessionEventType
                                }
                            }
                            
                            try! managedObjectContext.save()
                            
                            dismiss()
                        })
                        .disabled(self.name.isEmpty || (sessionItem.sessionType == SessionType.compsim.rawValue && targetStr.isEmpty))
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}


// MARK: - HELPER FUNCTIONS
struct EventPicker: View {
    @ScaledMetric var spacing = 48
    @ScaledMetric var imageSize = 32
    
    @Binding var sessionEventType: Int32
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Session Event")
                    .font(.body.weight(.medium))
                
                Spacer()
                
                Menu {
                    Picker("", selection: $sessionEventType) {
                        ForEach(Array(PUZZLE_TYPES.enumerated()), id: \.offset) {index, element in
                            Text(element.name).tag(Int32(index))
                                .font(.body)
                        }
                    }
                } label: {
                    Text(PUZZLE_TYPES[Int(sessionEventType)].name)
                        .font(.body)
                        .frame(maxWidth: 120, alignment: .trailing)
                    
                }
            }
            .frame(maxWidth: .infinity)
            .padding([.horizontal, .top])
            
            CTDivider()
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: spacing), spacing: 8)], spacing: 8) {
                ForEach(Array(zip(PUZZLE_TYPES.indices, PUZZLE_TYPES)), id: \.0) { index, element in
                    CTButton(type: (index == sessionEventType) ? .halfcoloured(nil) : .mono,
                             size: .ultraLarge,
                             square: true,
                             onTapRun: {
                        sessionEventType = Int32(index)
                    }) {
                        Image(element.name)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: imageSize, height: imageSize)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding([.horizontal, .bottom])
        }
        .frame(maxWidth: .infinity)
        .modifier(CardBlockBackground())
    }
}

struct SessionNameField: View {
    @Binding var name: String
    
    var body: some View {
        TextField("Session Name", text: $name)
            .padding(12)
            .font(.title2.weight(.semibold))
            .multilineTextAlignment(TextAlignment.center)
            .background(Color("indent1"))
            .cornerRadius(8)
            .padding([.horizontal, .bottom])
            .accentColor(Color("accent"))
    }
}

struct PuzzleHeaderImage: View {
    let imageName: String
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .padding(.vertical)
            .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 4)
    }
}

struct PinSessionToggle: View {
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    @Binding var pinnedSession: Bool
    var body: some View {
        Toggle(isOn: $pinnedSession) {
            Text("Pin Session?")
                .font(.body.weight(.medium))
        }
        .tint(.yellow)
        .padding()
        .frame(height: frameHeight)
        .modifier(CardBlockBackground())
    }
}

struct CompSimTargetEntry: View {
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    @Binding var targetStr: String
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Text("Target")
                    .font(.body.weight(.medium))
                
                Spacer()
                
                TextField("0.00", text: $targetStr)
                    .multilineTextAlignment(.trailing)
                    .modifier(ManualInputTextField(text: $targetStr))
            }
            .padding()
        }
        .frame(height: frameHeight)
        .modifier(CardBlockBackground())
    }
}
