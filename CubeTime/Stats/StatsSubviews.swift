import SwiftUI
import CoreData

struct StatsBlock<Content: View>: View {
    @Environment(\.colorScheme) var colourScheme
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    let dataView: Content
    let title: String
    let blockHeight: CGFloat?
    let bigBlock: Bool
    let coloured: Bool
    
    
    init(_ title: String, _ blockHeight: CGFloat?, _ bigBlock: Bool, _ coloured: Bool, @ViewBuilder _ dataView: () -> Content) {
        self.dataView = dataView()
        self.title = title
        self.bigBlock = bigBlock
        self.coloured = coloured
        self.blockHeight = blockHeight
    }
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Text(title)
                            .font(.footnote.weight(.medium))
                            .foregroundColor(Color(uiColor: title == "CURRENT STATS"
                                                   ? (colourScheme == .light
                                                      ? .black
                                                      : .white)
                                                   : (coloured
                                                      ? (colourScheme == .light
                                                         ? .systemGray5
                                                         : .white)
                                                      : .systemGray)))
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.top, 9)
                .padding(.leading, 12)
                
                dataView
            }
        }
        .frame(height: blockHeight)
        .if(coloured) { view in
            view.background(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected)                                        .clipShape(RoundedRectangle(cornerRadius:16)))
        }
        .if(!coloured) { view in
            view.background(Color(uiColor: title == "CURRENT STATS"
                                    ? .systemGray5
                                    : (colourScheme == .light
                                        ? .white
                                        : .systemGray6)).clipShape(RoundedRectangle(cornerRadius:16)))
        }
        .if(bigBlock) { view in
            view.padding(.horizontal)
        }
    }
}



struct StatsBlockText: View {
    @Environment(\.colorScheme) var colourScheme
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    let displayText: String
    let colouredText: Bool
    let colouredBlock: Bool
    let displayDetail: Bool
    let nilCondition: Bool
    
    @ScaledMetric private var blockHeightSmall = 75
    
    private let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                                (scene as? UIWindowScene)?.keyWindow
                            }).first?.frame.size
    
    init(_ displayText: String, _ colouredText: Bool, _ colouredBlock: Bool, _ displayDetail: Bool, _ nilCondition: Bool) {
        self.displayText = displayText
        self.colouredText = colouredText
        self.colouredBlock = colouredBlock
        self.displayDetail = displayDetail
        self.nilCondition = nilCondition
    }
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                
                HStack {
                    if nilCondition {
                        Text(displayText)
                            .font(.largeTitle.weight(.bold))
                            .frame(minWidth: 0, maxWidth: UIScreen.screenWidth/2 - 42, alignment: .leading)
                            .modifier(DynamicText())
                            .padding(.bottom, 2)
                        
                            .if(!colouredText) { view in
                                view.foregroundColor(Color(uiColor: colouredBlock ? .white : (colourScheme == .light ? .black : .white)))
                            }
                            .if(colouredText) { view in
                                view.gradientForeground(gradientSelected: gradientSelected)
                            }
                        
                            
                        
                    } else {
                        VStack {
                            Text("-")
                                .font(.title.weight(.medium))
                                .foregroundColor(Color(uiColor: .systemGray5))
                                .padding(.top, 20)
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding(.bottom, 4)
            .padding(.leading, 12)
            .frame(height: blockHeightSmall)
//            .background(Color.red)
            
            
            if displayDetail {
                Spacer()
            }
        }
    }
}

struct StatsBlockDetailText: View {
    @Environment(\.colorScheme) var colourScheme
    let calculatedAverage: CalculatedAverage
    let colouredBlock: Bool
    
    var body: some View {
        let _ = NSLog("calculated average : \(calculatedAverage.name)")
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                ForEach(calculatedAverage.accountedSolves!, id: \.self) { solve in
                    let discarded = calculatedAverage.trimmedSolves!.contains(solve)
                    let time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
                    Text(discarded ? "("+time+")" : time)
                        .font(.body)
                        .foregroundColor(discarded ? Color(uiColor: colouredBlock ? .systemGray5 : .systemGray) : (colouredBlock ? .white : (colourScheme == .light ? .black : .white)))
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 2)
                }
            }
            Spacer()
        }
        .padding(.bottom, 9)
        .padding(.leading, 12)
    }
}

struct StatsBlockSmallText: View {
    @Environment(\.colorScheme) var colourScheme
    @ScaledMetric private var bigSpacing: CGFloat = 2
    @ScaledMetric private var spacing: CGFloat = -6
        
    var titles: [String]
    var data: [CalculatedAverage?]
    @Binding var presentedAvg: CalculatedAverage?
    
    init(_ titles: [String], _ data: [CalculatedAverage?], _ presentedAvg: Binding<CalculatedAverage?>) {
        self.titles = titles
        self.data = data
        self._presentedAvg = presentedAvg
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: bigSpacing) {
            ForEach(Array(zip(titles.indices, titles)), id: \.0) { index, title in
                HStack {
                    VStack (alignment: .leading, spacing: spacing) {
                        Text(title)
                            .font(.footnote.weight(.medium))
                            .foregroundColor(Color(uiColor: .systemGray))
                        
                        if let datum = data[index] {
                            Text(formatSolveTime(secs: datum.average ?? 0, penType: datum.totalPen))
                                .font(.title2.weight(.bold))
                                .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                .modifier(DynamicText())
                        } else {
                            Text("-")
                                .font(.title3.weight(.medium))
                                .foregroundColor(Color(uiColor:.systemGray2))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.leading, 12)
                .contentShape(Rectangle())
                .onTapGesture {
                    if data[index] != nil {
                        presentedAvg = data[index]
                    }
                }
            }
        }
        .padding(.top, 16)
    }
}

struct StatsDivider: View {
    @Environment(\.colorScheme) var colourScheme
    
    private let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                                (scene as? UIWindowScene)?.keyWindow
                            }).first?.frame.size

    var body: some View {
        Divider()
            .frame(width: windowSize!.width / 2)
            .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray))
    }
}
