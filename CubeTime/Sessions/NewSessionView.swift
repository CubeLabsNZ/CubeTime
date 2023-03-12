import SwiftUI

struct NewSessionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    let sessionType: SessionType
    let typeName: String
    @Binding var showNewSessionPopUp: Bool
    
    // All sessions
    @State private var name: String = ""
    @State var pinnedSession: Bool = false
    
    // Non-Playground
    @State private var sessionEventType: Int32 = 0
    
    // Multiphase
    @State private var phaseCount: Int = 2
    
    // Comp sim
    @State private var targetStr: String = ""
    
    
    @ScaledMetric(relativeTo: .body) var frameHeight: CGFloat = 45
    @ScaledMetric(relativeTo: .title2) var bigFrameHeight: CGFloat = 220
    @ScaledMetric(relativeTo: .title2) var otherBigFrameHeight: CGFloat = 80
    
    
    var body: some View {
        ZStack {
            BackgroundColour()
            
            ScrollView {
                VStack (spacing: 16) {
                    VStack (alignment: .center, spacing: 0) {
                        if sessionType != SessionType.playground {
                            PuzzleHeaderImage(imageName: puzzle_types[Int(sessionEventType)].name)
                        }
                        
                        SessionNameField(name: $name)
                            .if(sessionType == SessionType.playground) { view in
                                view.padding(.top)
                            }
                        
                        if let sessionDescription = sessionDescriptions[sessionType] {
                            Text(sessionDescription)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(Color("grey"))
                                .padding([.horizontal, .bottom])
                        }
                    }
                    .modifier(CardBlockBackground())
                    .frame(minHeight: otherBigFrameHeight)
                    
                    if sessionType == .multiphase {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text("Phases: ")
                                    .font(.body.weight(.medium))
                                Text("\(phaseCount)")
                                
                                Spacer()
                                
                                Stepper("", value: $phaseCount, in: 2...8)
                                
                            }
                            .padding()
                        }
                        .frame(height: frameHeight)
                        .modifier(CardBlockBackground())
                    } else if sessionType == .compsim {
                        CompSimTargetEntry(targetStr: $targetStr)
                    }
                    
                    if sessionType != .playground {
                        EventPicker(sessionEventType: $sessionEventType)
                    }
                    
                    PinSessionToggle(pinnedSession: $pinnedSession)
                    
                    Spacer()
                }
            }
            //            .ignoresSafeArea(.keyboard)
            .navigationBarTitle("New \(typeName) Session", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let sessionItem = sessionTypeForID[sessionType, default: Sessions.self].init(context: managedObjectContext)
                        
                        sessionItem.name = name
                        sessionItem.pinned = pinnedSession
                        sessionItem.session_type = sessionType.rawValue
                        
                        if let sessionItem = sessionItem as? MultiphaseSession {
                            sessionItem.phase_count = Int16(phaseCount)
                        } else if let sessionItem = sessionItem as? CompSimSession {
                            sessionItem.target = timeFromStr(targetStr)!
                        }
                        
                        if sessionType != .playground {
                            sessionItem.scramble_type = sessionEventType
                        }
                        
                        try! managedObjectContext.save()
                        stopwatchManager.currentSession = sessionItem
                        showNewSessionPopUp = false
                    } label: {
                        Text("Create")
                    }
                    .disabled(name.isEmpty || (sessionType == .compsim && targetStr.isEmpty))
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}
