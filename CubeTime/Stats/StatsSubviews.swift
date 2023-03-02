import SwiftUI
import CoreData

struct StatsBlock<Content: View>: View {
    @Environment(\.colorScheme) var colourScheme
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    let dataView: Content
    let title: String
    let blockHeight: CGFloat?
    let isBigBlock: Bool
    let isColoured: Bool
    
    
    init(title: String, blockHeight: CGFloat?, isBigBlock: Bool=false, isColoured: Bool=false, @ViewBuilder _ dataView: () -> Content) {
        self.title = title
        self.blockHeight = blockHeight
        
        self.isBigBlock = isBigBlock
        self.isColoured = isColoured
        
        self.dataView = dataView()
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundColor(
                    title == "CURRENT STATS"
                    ? Color("dark")
                    : isColoured
                    ? Color.white
                    : Color("grey")
                )
                .frame(height: blockHeight, alignment: .topLeading)
                .padding(.top, 20)
            
            dataView
        }
        .frame(height: blockHeight)
        .padding(.horizontal, 12)
        .background(
            (isColoured
             ? AnyView(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected))
             : AnyView(title == "CURRENT STATS"
                   ? Color("overlay0")
                   : Color("overlay1")))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .padding(.horizontal, isBigBlock ? nil : 0)
    }
}



struct StatsBlockText: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    let displayText: String
    let colouredText: Bool
    let colouredBlock: Bool
    let displayDetail: Bool
    let nilCondition: Bool
    
    @ScaledMetric private var blockHeightSmall = 75
    
    
    init(displayText: String, colouredText: Bool=false, colouredBlock: Bool=false, displayDetail: Bool=false, nilCondition: Bool) {
        self.displayText = displayText
        self.colouredText = colouredText
        self.colouredBlock = colouredBlock
        self.displayDetail = displayDetail
        self.nilCondition = nilCondition
    }
    
    var body: some View {
        HStack {
            if nilCondition {
                Group {
                    if (colouredText) {
                        Text(displayText)
                            .gradientForeground(gradientSelected: gradientSelected)
                    } else {
                        Text(displayText)
                            .foregroundColor(
                                colouredBlock
                                ? .white
                                : Color("dark")
                            )
                    }
                }
                .font(.largeTitle.weight(.bold))
                .modifier(DynamicText())
            } else {
                Text("-")
                    .font(.title.weight(.medium))
                    .foregroundColor(colouredBlock
                                     ? Color(0xF6F7FC) // hardcoded
                                     : Color("grey"))
            }
            
            Spacer()
        }
        .frame(height: blockHeightSmall)
        .padding(.top, 20)
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
                        .foregroundColor(
                            discarded
                            ? colouredBlock
                              ? Color("indent2")
                              : Color("grey")
                            : colouredBlock
                              ? .white
                              : Color("dark")
                        )
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
    @ScaledMetric private var spacing: CGFloat = -4
        
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
                    VStack(alignment: .leading, spacing: spacing) {
                        Text(title)
                            .font(.footnote.weight(.medium))
                            .foregroundColor(Color("grey"))
                        
                        if let datum = data[index] {
                            Text(formatSolveTime(secs: datum.average ?? 0, penType: datum.totalPen))
                                .font(.title2.weight(.bold))
                                .foregroundColor(Color("dark"))
                                .modifier(DynamicText())
                        } else {
                            Text("-")
                                .font(.title3.weight(.medium))
                                .foregroundColor(Color("grey"))
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
