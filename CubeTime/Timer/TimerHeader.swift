import SwiftUI

struct SessionIconView: View {
    let session: Sessions
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 35, height: 35)
            
            
            Group {
                switch SessionTypes(rawValue: session.session_type)! {
                case .standard:
                    Image(systemName: "timer.square")
                        .font(.system(size: 26, weight: .regular))
                case .algtrainer:
                    Image(systemName: "command.square")
                        .font(.system(size: 26, weight: .regular))
                case .multiphase:
                    Image(systemName: "square.stack")
                        .font(.system(size: 22, weight: .regular))
                case .playground:
                    Image(systemName: "square.on.square")
                        .font(.system(size: 22, weight: .regular))
                case .compsim:
                    Image(systemName: "globe.asia.australia")
                        .font(.system(size: 22, weight: .medium))
                }
            }
        }
        .frame(width: 35, height: 35)
    }
}

struct TimerHeader: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var tabRouter: TabRouter
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Preference(\.showSessionType) private var showSessionType
    
    var targetFocused: FocusState<Bool>.Binding?
    
    @State private var textRect = CGRect()
    
    let previewMode: Bool
    
    var body: some View {
        let sess_type = SessionTypes(rawValue: stopwatchManager.currentSession.session_type)!
        HStack {
            if previewMode {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color("overlay0"))
                        .frame(width: 35, height: 35)
                        .shadowDark(x: 2, y: 0)
                    
                    HStack {
                        ZStack(alignment: .center) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 35, height: 35)
                            
                            
                            Group {
                                Image(systemName: "eyes")
                                    .font(.system(size: 22, weight: .regular))
                            }
                        }
                        
                        Text("PREVIEW")
                            .font(.system(size: 17, weight: .medium))
                            .padding(.trailing)
                    }
                }
            } else {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color("overlay0"))
                        .frame(width: (showSessionType) ? nil : 35, height: 35)
                        .shadowDark(x: 2, y: 0)
                    
                    HStack {
                        SessionIconView(session: stopwatchManager.currentSession)
                        
                        if (showSessionType) {
                            Text(stopwatchManager.currentSession.typeName)
                                .font(.system(size: 17, weight: .medium))
                                .padding(.trailing, 4)
                        }
                    }
                }
                .onTapGesture {
                    withAnimation(Animation.customSlowSpring) {
                        showSessionType.toggle()
                    }
                }
                
                if !showSessionType {
                    Text(stopwatchManager.currentSession.name ?? "Unknown Session Name")
                        .font(.system(size: 17, weight: .medium))
                        .padding(.trailing, sess_type == .standard ? nil : 4)
                }
                
                switch sess_type {
                case .playground:
                    Picker("", selection: $stopwatchManager.playgroundScrambleType) {
                        ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                            Text(element.name).tag(Int32(index))
                                .font(.system(size: 15, weight: .regular))
                        }
                    }
                    .pickerStyle(.menu)
                case .multiphase:
                    HStack(spacing: 0) {
                        Text("PHASES: ")
                            .font(.system(size: 15, weight: .regular))
                        
                        Text("\(stopwatchManager.phaseCount)")
                            .font(.system(size: 15, weight: .medium))
                        
                    }
                    .padding(.trailing)
                case .compsim:
                    let solveth: Int = stopwatchManager.currentSolveth!+1
                    
                    Text("SOLVE \(solveth == 6 ? 1 : solveth)")
                        .font(.system(size: 15, weight: .regular))
                        .padding(.horizontal, 2)
                    
                    ThemedDivider(isHorizontal: false)
                        .padding(.vertical, 6)
                    
                    HStack (spacing: 10) {
                        Image(systemName: "target")
                            .font(.system(size: 15))
                            .foregroundColor(Color("accent"))
                        
                        ZStack {
                            Text(stopwatchManager.targetStr == "" ? "0.00" : stopwatchManager.targetStr)
                                .background(GlobalGeometryGetter(rect: $textRect))
                                .layoutPriority(1)
                                .opacity(0)
                            
                            
                            TextField("0.00", text: $stopwatchManager.targetStr)
                                .font(.system(size: 17, weight: .regular))
                                .frame(width: textRect.width + CGFloat(stopwatchManager.targetStr.count > 6 ? 12 : 6))
                                .submitLabel(.done)
                                .focused(targetFocused!)
                                .multilineTextAlignment(.leading)
                                .modifier(TimeMaskTextField(text: $stopwatchManager.targetStr, onReceiveAlso: { text in
                                    if let time = timeFromStr(text) {
                                        (stopwatchManager.currentSession as! CompSimSession).target = time
                                        
                                        try! managedObjectContext.save()
                                    }
                                }))
                                .padding(.trailing, 4)
                        }
                        .padding(.leading, 2)
                        .padding(.trailing, 12)
                    }
                    .foregroundColor(Color("accent"))
                default:
                    EmptyView()
                }
            }
        }
        .frame(height: 35)
        .background(
            Color("overlay1")
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .animation(Animation.customFastSpring, value: stopwatchManager.playgroundScrambleType)
        )
        .padding(.top, UIDevice.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
        .animation(Animation.customSlowSpring, value: showSessionType)
    }
}
