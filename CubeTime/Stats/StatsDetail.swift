import SwiftUI
 
struct StatsDetail: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
   
    @State var offsetValue: CGFloat = -25
    
    @State var showSolve = false
    @State var solveToShow: Solves?
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
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
                Color("base")
                    .ignoresSafeArea()
                
                if solves.average != nil || isCurrentCompSimAverage {
                    if let solveToShow = solveToShow {
//                        NavigationLink("", destination: TimeDetailViewOnly(solve: solveToShow, currentSolve: nil), isActive: $showSolve)
                    }
                    ScrollView {
                        VStack (spacing: 12) {
                            if !isCurrentCompSimAverage {   /// WHY???????
                                HStack {
                                    Text(formatSolveTime(secs: solves.average!, penType: solves.totalPen))
                                        .font(.largeTitle.weight(.bold))
                                    
                                    Spacer()
                                }
                                .padding([.horizontal, .top])
                            }
                            
                            SessionHeader()
                                .padding(.horizontal)
                                .padding(.top, isCurrentCompSimAverage ? 10 : -10)
                            
                            VStack {
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
                                                        .fixedSize(horizontal: true, vertical: false)
                                                        .multilineTextAlignment(.leading)
                                                        // WORKAROUND
                                                        .minimumScaleFactor(0.00001)
                                                        .scaledToFit()
                                                } else {
                                                    Text(solve.scramble ?? "Failed to load scramble")
                                                }
                                                
                                                Spacer()
                                            }
                                            .font(Font(CTFontCreateWithFontDescriptor(stopwatchManager.ctFontDesc, 16, nil)))
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
                    }
                } else {
                    Text("N/A")
                }
            }
        }
            .accentColor(accentColour)
    }
}
