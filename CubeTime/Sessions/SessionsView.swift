import SwiftUI
import CoreData
import Combine

// MARK: - MAIN SESSION VIEW
struct SessionsView: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @State var showNewSessionPopUp = false
    
    @FetchRequest(
        entity: Sessions.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Sessions.pinned, ascending: false),
            NSSortDescriptor(keyPath: \Sessions.name, ascending: true)
        ]
    ) var sessions: FetchedResults<Sessions>
    
    var body: some View {
        let _ = NSLog("\(sessions.map({$0.scramble_type}))")
        NavigationView {
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    Color("base")
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack (spacing: 10) {
                            ForEach(sessions) { item in
                                SessionCard(item: item, allSessions: sessions, parentGeo: geo)
                            }
                        }
                    }
                    .safeAreaInset(safeArea: .tabBar, avoidBottomBy: 50)
                    
                    HierarchialButton(type: .coloured, size: .large, onTapRun: {
                        showNewSessionPopUp = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .offset(x: -2)
                            
                            Text("New Session")
                        }
                    }
                    .padding(.bottom, 58)
                    .padding(.bottom, UIDevice.hasBottomBar ? 0 : nil)
                    .padding(.horizontal)
                }
                .navigationTitle("Your Sessions")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: ToolsList()) {
                            HierarchialButtonBase(type: .coloured, size: .small, outlined: false, square: false, hasShadow: true, hasBackground: true, expandWidth: false) {
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
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showNewSessionPopUp) {
            NewSessionRootView(showNewSessionPopUp: $showNewSessionPopUp)
                .environment(\.managedObjectContext, managedObjectContext)
        }
    }
}


// MARK: - CUSTOMISE SESSIONS
struct CustomiseSessionView: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    let sessionItem: Sessions
    
    @State private var name: String
    @State private var targetStr: String
    @State private var phaseCount: Int
    
    @State var pinnedSession: Bool
    
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    @ScaledMetric(relativeTo: .title2) var bigFrameHeight: CGFloat = 220
    
    
    @State private var sessionEventType: Int32
    
    
    init(sessionItem: Sessions) {
        self.sessionItem = sessionItem
        
        self._name = State(initialValue: sessionItem.name ?? "")
        self._pinnedSession = State(initialValue: sessionItem.pinned)
        self._targetStr = State(initialValue: filteredStrFromTime((sessionItem as? CompSimSession)?.target))
        self._phaseCount = State(initialValue: Int((sessionItem as? MultiphaseSession)?.phase_count ?? 0))
        
        self._sessionEventType = State(initialValue: sessionItem.scramble_type)
    }
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("base")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .center, spacing: 0) {
                            PuzzleHeaderImage(imageName: puzzle_types[Int(sessionEventType)].name)
                            
                            SessionNameField(name: $name)
                        }
                        .frame(height: bigFrameHeight)
                        .modifier(CardBlockBackground())
                        
                        if sessionItem.session_type == SessionTypes.compsim.rawValue {
                            CompSimTargetEntry(targetStr: $targetStr)
                        }
                        
                        if sessionItem.session_type == SessionTypes.playground.rawValue {
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
                            
                            if sessionItem.session_type == SessionTypes.compsim.rawValue {
                                (sessionItem as! CompSimSession).target = timeFromStr(targetStr)!
                            }
                            
                            if sessionItem.session_type == SessionTypes.multiphase.rawValue {
                                (sessionItem as! MultiphaseSession).phase_count = Int16(phaseCount)
                            }
                            
                            if sessionItem.session_type == SessionTypes.playground.rawValue {
                                if sessionItem == stopwatchManager.currentSession {
                                    stopwatchManager.playgroundScrambleType = sessionEventType
                                } else {
                                    sessionItem.scramble_type = sessionEventType
                                }
                            }
                            
                            try! managedObjectContext.save()
                            
                            dismiss()
                        })
                        .disabled(self.name.isEmpty || (sessionItem.session_type == SessionTypes.compsim.rawValue && targetStr.isEmpty))
                    }
                }
            }
        }
        .accentColor(accentColour)
        .ignoresSafeArea(.keyboard)
    }
}


// MARK: - HELPER FUNCTIONS
struct EventPicker: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    
    @Binding var sessionEventType: Int32
    
    let sessionEventTypeColumns = [GridItem(.adaptive(minimum: 40))]
    
    var body: some View {
        HStack {
            Text("Session Event")
                .font(.body.weight(.medium))
            
            
            Spacer()
            
            Menu {
                Picker("", selection: $sessionEventType) {
                    ForEach(Array(puzzle_types.enumerated()), id: \.offset) {index, element in
                        Text(element.name).tag(Int32(index))
                            .font(.body)
                    }
                }
            } label: {
                Text(puzzle_types[Int(sessionEventType)].name)
                    .font(.body)
                    .frame(maxWidth: 120, alignment: .trailing)

            }
            .accentColor(accentColour)
            
        }
        .padding()
        .frame(height: frameHeight)
        .modifier(CardBlockBackground())
        
        
        LazyVGrid(columns: sessionEventTypeColumns, spacing: 0) {
            ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                Button {
                    sessionEventType = Int32(index)
                } label: {
                    ZStack {
                        Image("circular-" + element.name)
                        
                        Circle()
                            .strokeBorder(Color(uiColor: .systemGray3), lineWidth: (index == sessionEventType) ? 3 : 0)
                            .frame(width: 54, height: 54)
                            .offset(x: -0.2)
                    }
                }
            }
        }
        .padding()
        .frame(height: 180)
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
            .cornerRadius(10)
            .padding([.horizontal, .bottom])
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
                    .modifier(TimeMaskTextField(text: $targetStr))
            }
            .padding()
        }
        .frame(height: frameHeight)
        .modifier(CardBlockBackground())
    }
}

/// **Customise Sessions **

struct NewSessionTypeCard: View {
    let name: String
    let icon: SessionTypeIcon
    @Binding var show: Bool
    
    var body: some View {
        HStack {
            Group {
                Image(systemName: icon.iconName)
                    .font(.system(size: icon.size, weight: icon.weight))
                    .padding(.leading, icon.padding.leading)
                    .padding(.trailing, icon.padding.trailing)
                    .padding(.vertical, 8)
                
                Text(name)
                    .font(.body)
            }
            .foregroundColor(Color("dark"))
            
            
            Spacer()
        }
        .background(Color("overlay0"))
        .onTapGesture {
            show = true
        }
    }
}


struct NewSessionTypeCardGroup<Content: View>: View {
    @Environment(\.colorScheme) var colourScheme
    let title: String
    let content: () -> Content
    
    
    @inlinable init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title2.weight(.bold))
                .padding(.bottom, 8)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color("overlay0"))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .padding(.horizontal)
    }
}
