import SwiftUI
 
struct StatsDetail: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
   
    @State var offsetValue: CGFloat = -25
    
    @State var showSolve = false
    @State var solveToShow: Solves?
    
    let solves: CalculatedAverage
    let session: Sessions
    
    private let detailDateFormat: DateFormatter
    
    private let isCurrentCompSimAverage: Bool
    
    
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "h:mm a, MM/dd/yyyy"
    
    init(solves: CalculatedAverage, session: Sessions) {
        self.solves = solves
        self.session = session
        
        
        self.detailDateFormat = DateFormatter()
        
        detailDateFormat.locale = Locale(identifier: "en_US_POSIX")
        detailDateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        detailDateFormat.dateFormat = "h:mm a, MM/dd/yy"
        
        isCurrentCompSimAverage = solves.name == "Current Average"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                if solves.average != nil || isCurrentCompSimAverage {
                    if let solveToShow = solveToShow {
                        NavigationLink("", destination: TimeDetailViewOnly(solve: solveToShow, currentSolve: nil), isActive: $showSolve)
                    }
                    ScrollView {
                        VStack (spacing: 12) {
                            if !isCurrentCompSimAverage {
                                HStack {
                                    Text(formatSolveTime(secs: solves.average!, penType: solves.totalPen))
                                        .font(.largeTitle.weight(.bold))
                                    
                                    Spacer()
                                }
                                .padding([.horizontal, .top])
                            }
                            
                            SessionBar(name: session.name ?? "Unknown session name", session: session)
                                .padding(.horizontal)
                                .padding(.top, isCurrentCompSimAverage ? 10 : -10)
                            
                            VStack {
                                HStack {
                                    if SessionTypes(rawValue: session.session_type)! == .playground {
                                        Image(systemName: "square.filled.on.square")
                                            .symbolRenderingMode(.hierarchical)
                                            .font(.system(size: 26, weight: .semibold))
                                            .foregroundColor(colourScheme == .light ? .black : .white)
                                        
                                        Text("Playground")
                                            .font(.body.weight(.semibold))
                                    } else {
                                        Image(puzzle_types[Int(session.scramble_type)].name)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                            .padding(.leading, 2)
                                            .padding(.trailing, 4)
                                        
                                        Text(puzzle_types[Int(session.scramble_type)].name)
                                            .font(.body.weight(.semibold))
                                    }
                                    
                                    Spacer()
                                    
                                    Text((["2x2", "3x3", "Square-1", "Pyraminx", "Skewb", "3x3 OH", "3x3 BLD"].contains(puzzle_types[Int(session.scramble_type)].name)) ? "RANDOM STATE" : "RANDOM MOVES")
                                        .font(.footnote.weight(.semibold))
                                        .offset(y: 2)
                                                                        
                                }
                                .padding([.leading, .top], 12)
                                .padding(.trailing)
                                
                                VStack(spacing: 0) {
                                    ForEach(Array(zip(solves.accountedSolves!.indices, solves.accountedSolves!.sorted(by: { $0.date! > $1.date! }))), id: \.0) {index, solve in
                                        VStack(spacing: 0) {
                                            Divider()
                                                .padding(.leading)
                                                
                                            HStack(alignment: .bottom) {
                                                Text("\(index+1).")
                                                    .font(Font.system(.subheadline, design: .rounded).weight(.bold))
                                                    .foregroundColor(accentColour)
                                                if solves.trimmedSolves!.contains(solve) {
                                                    Text("(" + formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!) + ")")
                                                        .font(.body.weight(.bold))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                } else {
                                                    Text(formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!))
                                                        .font(.body.weight(.bold))
                                                }
                                                
                                                Spacer()
                                                
                                                
                                                
                                                Text(solve.date ?? Date(timeIntervalSince1970: 0), formatter: detailDateFormat)
                                                    .font(Font.system(.footnote, design: .rounded).weight(.bold))
                                                    .foregroundColor(Color(uiColor: .systemGray))
                                            }
                                            .padding(.top, 8)
                                            .padding(.horizontal)
                                            
                                            HStack {
                                                
                                                if solve.scramble_type == 7 {
                                                    Text(solve.scramble ?? "Failed to load scramble")
                                                        .font(.system(size: ((globalGeometrySize.width-32) / (42.00) * 1.42), weight: .regular, design: .monospaced))
                                                } else {
                                                    Text(solve.scramble ?? "Failed to load scramble")
                                                        .font(.callout.monospaced())
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                            .padding(.bottom, (index != solves.accountedSolves!.indices.last!) ? 8 : 0)
                                        }
                                        .onTapGesture {
                                            solveToShow = solve
                                            showSolve = true
                                        }
                                    }
                                }
                                .padding(.bottom)
                            }
                            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous)))
                            .padding(.top, -10)
                            .padding(.horizontal)
                        }
                        .offset(y: -6)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(solves.name == "Comp Sim Solve" ? "Comp Sim" : solves.name)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    dismiss()
                                } label: {
                                    Text("Done")
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    copySolve(solves: solves)
                                    
                                    withAnimation(Animation.interpolatingSpring(stiffness: 140, damping: 20).delay(0.25)) {
                                        self.offsetValue = 0
                                    }
                                    
                                    withAnimation(Animation.easeOut.delay(2.25)) {
                                        self.offsetValue = -25
                                    }
                                    
                                    
                                    

                                } label: {
                                    ZStack {
                                        if self.offsetValue != 0 {
                                            Image(systemName: "doc.on.doc")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundColor(accentColour)
                                               
                                        }
                                        
                                        
                                        Image(systemName: "checkmark")
                                            .font(Font.system(.footnote, design: .rounded).weight(.bold))
                                            .clipShape(Rectangle().offset(x: self.offsetValue))
                                    }
                                    .frame(width: 20)
                                }
                            }
                        }
                    }
                } else {
                    Text("N/A")
                }
            }
        }
            .accentColor(accentColour)
    }
}
