import SwiftUI

struct SessionIconView: View {
    @ScaledMetric(wrappedValue: 35, relativeTo: .body) private var bgSize: CGFloat

    let isDynamicType: Bool
    let session: Session
    
    init(session: Session, isDynamicType: Bool = true) {
        self.session = session
        self.isDynamicType = isDynamicType
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: isDynamicType ? bgSize : 35, height: isDynamicType ? bgSize : 35)
            
            session.icon(size: 26)
        }
        .frame(width: isDynamicType ? bgSize : 35, height: isDynamicType ? bgSize : 35)
    }
}

struct TimerHeader: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var tabRouter: TabRouter
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Preference(\.showSessionType) private var showSessionType
    
    @ScaledMetric(wrappedValue: 17, relativeTo: .body) private var scale
    
    var targetFocused: FocusState<Bool>.Binding?
    
    @State private var textRect = CGRect()
    
    let previewMode: Bool
    
    var body: some View {
        let sessionType = SessionType(rawValue: stopwatchManager.currentSession.sessionType)!
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
                        
                        Text("Preview")
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
                        SessionIconView(session: stopwatchManager.currentSession, isDynamicType: false)
                        
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
                        .padding(.trailing, sessionType == .standard ? nil : (sessionType == .timerOnly ? 8 : 4))
                }
                
                switch sessionType {
                case .playground:
                    // i hate swiftui i hate apple i hate everything
                    if #available(iOS 16, *) {
                        Picker("", selection: $stopwatchManager.playgroundScrambleType) {
                            ForEach(Array(zip(PUZZLE_TYPES.indices, PUZZLE_TYPES)), id: \.0) { index, element in
                                Text(element.name).tag(Int32(index)).font(.body)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.body)
                        .scaleEffect(17/scale)
                        .frame(maxHeight: .infinity)
                    } else {
                        Picker("", selection: $stopwatchManager.playgroundScrambleType) {
                            ForEach(Array(zip(PUZZLE_TYPES.indices, PUZZLE_TYPES)), id: \.0) { index, element in
                                Text(element.name).tag(Int32(index)).font(.body)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(Color("accent"))
                        .font(.body)
                        .frame(maxHeight: .infinity)
                        .padding(.trailing, 8)
                    }
                case .multiphase:
                    HStack(spacing: 0) {
                        Text("PHASES: ")
                            .font(.system(size: 15, weight: .regular))
                        
                        Text("\(stopwatchManager.phaseCount)")
                            .font(.system(size: 15, weight: .medium))
                        
                    }
                    .padding(.trailing)
                case .compsim:
                    let solveth: Int = 1 + (stopwatchManager.currentSolveth ?? 0)
                    
                    Text("SOLVE \(solveth == 6 ? 1 : solveth)")
                        .font(.system(size: 15, weight: .regular))
                        .padding(.horizontal, 2)
                    
                    CTDivider(isHorizontal: false)
                        .padding(.vertical, 6)
                    
                    HStack (spacing: 10) {
                        Image(systemName: "target")
                            .font(.system(size: 15))
                            .foregroundColor(Color("accent"))
                        
                        ZStack {
                            Text(stopwatchManager.targetStr == "" ? "0.00" : stopwatchManager.targetStr)
                                .font(.system(size: 17))
                                .background(
                                    GeometryReader { geo in
                                        let _ = DispatchQueue.main.async {
                                            self.textRect = geo.frame(in: .global)
                                        }
                                        
                                        Rectangle().fill(Color.clear)
                                    }
                                )
                                .layoutPriority(1)
                                .opacity(0)
                            
                            
                            TextField("0.00", text: $stopwatchManager.targetStr)
                                .font(.system(size: 17, weight: .regular))
                                .frame(width: textRect.width + CGFloat(stopwatchManager.targetStr.count > 6 ? 12 : 6))
                                .submitLabel(.done)
                                .focused(targetFocused!)
                                .multilineTextAlignment(.leading)
                                .modifier(ManualInputTextField(text: $stopwatchManager.targetStr, onReceiveAlso: { text in
                                    if let time = timeFromStr(text) {
                                        (stopwatchManager.currentSession as! CompSimSession).target = time
                                        
                                        try! managedObjectContext.save()
                                        
                                        
                                        stopwatchManager.timeNeededForTarget = stopwatchManager.getTimeNeededForTarget()
                                        
                                        stopwatchManager.reachedTargets = stopwatchManager.getReachedTargets()
                                    }
                                }))
                                .padding(.trailing, 4)
                        }
                        .padding(.leading, 2)
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



struct PadTimerHeader: View {
    var targetFocused: FocusState<Bool>.Binding
    var showSessions: Binding<Bool>?
    
    
    var body: some View {
        HStack(spacing: 0) {
            TimerHeader(targetFocused: targetFocused, previewMode: false)
            
            Spacer()
            
            if let showSessions = showSessions {
                CTButton(type: .mono, size: .large, square: true, onTapRun: {
                    showSessions.wrappedValue.toggle()
                }) {
                    Image(systemName: showSessions.wrappedValue ? "hourglass.circle" : "line.3.horizontal.circle")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 35)
    }
}
