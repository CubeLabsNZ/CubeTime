import SwiftUI
import CoreData
import Combine

// MARK: - MAIN SESSION VIEW
struct SessionsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @State var showNewSessionPopUp = false
    
    @FetchRequest(
        entity: Session.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Session.pinned, ascending: false),
            NSSortDescriptor(keyPath: \Session.name, ascending: true)
        ]
    ) var sessions: FetchedResults<Session>
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    BackgroundColour(isSessions: true)
                    
                    ScrollView {
                        VStack (spacing: 10) {
                            ForEach(sessions) { item in
                                SessionCard(item: item, allSessions: sessions, parentGeo: geo)
                            }
                        }
                    }
                    .if(!(UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
                        view.safeAreaInset(safeArea: .tabBar, avoidBottomBy: 50)
                    }
                    
                    HierarchicalButton(type: .coloured, size: .large, onTapRun: {
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
                .if(!(UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
                    view.toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: ToolsList()) {
                                HierarchicalButtonBase(type: .coloured, size: .small, outlined: false, square: false, hasShadow: true, hasBackground: true, expandWidth: false) {
                                    Label("Tools", systemImage: "wrench.and.screwdriver")
                                        .labelStyle(.titleAndIcon)
                                        .imageScale(.small)
                                }
                            }
                            .buttonStyle(AnimatedButton())
                        }
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
                            PuzzleHeaderImage(imageName: puzzleTypes[Int(sessionEventType)].name)
                            
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
                        DoneButton(onTapRun: {
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
                        ForEach(Array(puzzleTypes.enumerated()), id: \.offset) {index, element in
                            Text(element.name).tag(Int32(index))
                                .font(.body)
                        }
                    }
                } label: {
                    Text(puzzleTypes[Int(sessionEventType)].name)
                        .font(.body)
                        .frame(maxWidth: 120, alignment: .trailing)

                }
            }
            .frame(maxWidth: .infinity)
            .padding([.horizontal, .top])
            
            ThemedDivider()
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: spacing), spacing: 8)], spacing: 8) {
                ForEach(Array(zip(puzzleTypes.indices, puzzleTypes)), id: \.0) { index, element in
                    HierarchicalButton(type: (index == sessionEventType) ? .halfcoloured : .mono,
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
