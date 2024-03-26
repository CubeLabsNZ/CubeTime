//
//  HelperUI.swift
//  CubeTime
//
//  Created by Tim Xie on 25/02/23.
//

import Foundation
import SwiftUI


// MARK: - Colours, Gradients
extension Color: RawRepresentable {
    public typealias RawValue = String
    
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255
        )
    }
    
    public init(rawValue: RawValue) {
        try! self.init(uiColor: NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: Data(base64Encoded: rawValue)!)!)
    }

    public var rawValue: RawValue {
        return try! NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false).base64EncodedString()
    }
}


extension Color {
    struct Timer {
        static let normal: Color = Color("dark")
        static let heldDown: Color = Color("red")
        static let canStart: Color = Color("green")
        static let loading: Color = Color("grey")
    }
}


// MARK: - Shadows
struct ShadowLight: ViewModifier {
    @Environment(\.colorScheme) private var env
    
    let x: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: env == .dark ? .clear : Color.black.opacity(0.04), radius: 6, x: x, y: y)
    }
}

struct ShadowDark: ViewModifier {
    @Environment(\.colorScheme) private var env
    
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: env == .dark ? .clear : Color.black.opacity(0.07), radius: 4, x: x, y: y)
    }
}

extension View {
    func shadowLight(x: CGFloat, y: CGFloat) -> some View {
        modifier(ShadowLight(x: x, y: y))
    }
    
    func shadowDark(x: CGFloat, y: CGFloat) -> some View {
        modifier(ShadowDark(x: x, y: y))
    }
}


// MARK: - Animations
extension Animation {
    static let customFastSpring: Animation = .spring(response: 0.3, dampingFraction: 0.72)
    static let customSlowSpring: Animation = .spring(response: 0.45, dampingFraction: 0.76)
    
    static let customDampedSpring: Animation = .spring(response: 0.3, dampingFraction: 0.82)
    static let customBouncySpring: Animation = .spring(response: 0.42, dampingFraction: 0.66)
    
    static let customFastEaseOut: Animation = .easeOut(duration: 0.28)
    static let customEaseInOut: Animation = .easeInOut(duration: 0.26)
}


// MARK: - Dynamic & Animating Text
struct DynamicText: ViewModifier {
    @inlinable func body(content: Content) -> some View {
        content
            .scaledToFit()
            .minimumScaleFactor(0.25)
            .lineLimit(1)
    }
}

struct AnimatingFontSize: AnimatableModifier {
    let font: CTFontDescriptor
    var fontSize: CGFloat

    @inlinable var animatableData: CGFloat {
        get { fontSize }
        set { fontSize = newValue }
    }

    @inlinable func body(content: Self.Content) -> some View {
        content
            .font(Font(CTFontCreateWithFontDescriptor(font, fontSize, nil)))
    }
}


// MARK: - Safe Area
enum SafeAreaType {
    case tabBar
}

struct TabBarSafeAreaInset: ViewModifier {
    let avoidBottomBy: CGFloat
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Rectangle()
                .fill(Color.clear)
                .frame(height: 50)
                .padding(.top, 8 + avoidBottomBy)
                .padding(.bottom, UIDevice.hasBottomBar ? 0 : nil)
            }
    }
}

extension View {
    func safeAreaInset(safeArea: SafeAreaType, avoidBottomBy: CGFloat=0) -> some View {
        switch safeArea {
        case .tabBar:
            return modifier(TabBarSafeAreaInset(avoidBottomBy: avoidBottomBy))
        }
    }
}


// MARK: - Other Views
struct ThemedDivider: View {
    let isHorizontal: Bool
    
    init(isHorizontal: Bool = true) {
        self.isHorizontal = isHorizontal
    }
    
    var body: some View {
        Capsule()
            .fill(Color("indent0"))
            .frame(width: isHorizontal ? nil : 1.15, height: isHorizontal ? 1.15 : nil)
    }
}


struct BackgroundColour: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.colorScheme) var colourScheme
    
    let isSessions: Bool
    
    init(isSessions: Bool=false) {
        self.isSessions = isSessions
    }
    
    var body: some View {
        Group {
            if (!UIDevice.deviceIsPad || hSizeClass == .compact) { // if phone or small split screen ipad, then NO modals
                Color("base")
            } else {
                if (isSessions) {
                    Color("overlay1")
                } else {
                    if (colourScheme == .dark) {
                        Color("indent1")
                    } else {
                        Color("base")
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#warning("todo: make timedetailview/statsdetailview use this")
struct CardBlockBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color("overlay1"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(.horizontal)
    }
}


// global geometry reader structs
/// as the default textfield does not dynamically adjust its width according to the text
/// and instead is always set to the maximum width, this globalgeometrygetter is used
/// for the target input field on the timer view to change its width dynamically.

// source: https://stackoverflow.com/a/56729880/3902590
struct GlobalGeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        return GeometryReader { geometry in
            DispatchQueue.main.async {
                self.rect = geometry.frame(in: .global)
            }

            return Rectangle().fill(Color.clear)
        }
    }
}


// MARK: - BUBBLE
struct CTSessionBubble: View {
    let session: Session
    
    let hasMultiple: Bool
    
    
    init(session: Session) {
        self.session = session
        
        self.hasMultiple = [SessionType.compsim, SessionType.multiphase].contains(SessionType(rawValue: session.sessionType))
    }
    
    var body: some View {
        CTBubble(type: .lightMono, size: .bubble) {
            HStack(spacing: 4) {
                session.icon(size: 14)
                
                Text(session.typeName)
            }
        }
        
        if (hasMultiple) {
            CTPuzzleBubble(scrambleType: Int(session.scrambleType))
        }
    }
}

struct CTPuzzleBubble: View {
    @ScaledMetric private var iconSize: CGFloat = 11
    
    let icon: Image
    let text: String
    
    init(scrambleType: Int) {
        icon = Image(PUZZLE_TYPES[scrambleType].name)
        text = PUZZLE_TYPES[scrambleType].name
    }
    
    init(scrambleType: PuzzleType) {
        icon = Image(scrambleType.name)
        text = scrambleType.name
    }
    
    init(session: Session) {
        icon = session.icon() as! Image
        text = session.typeName
    }
    
    var body: some View {
        CTBubble(type: .lightMono, size: .bubble) {
            HStack(spacing: 4) {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 14, maxHeight: 14)
                    .font(.system(size: iconSize, weight: .semibold, design: .default))
                
                Text(text)
            }
        }
    }
}
