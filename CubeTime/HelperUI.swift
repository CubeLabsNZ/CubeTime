//
//  HelperUI.swift
//  CubeTime
//
//  Created by Tim Xie on 25/02/23.
//

import Foundation
import SwiftUI


// MARK: - COLOURS AND GRADIENTS
// colour extensions
extension UIColor {
    func colorsEqual (_ rhs: UIColor) -> Bool {
        var sred: CGFloat = 0
        var sgreen: CGFloat = 0
        var sblue: CGFloat = 0
        
        var rred: CGFloat = 0
        var rgreen: CGFloat = 0
        var rblue: CGFloat = 0
        

        self.getRed(&sred, green: &sgreen, blue: &sblue, alpha: nil)
        rhs.getRed(&rred, green: &rgreen, blue: &rblue, alpha: nil)

        return (Int(sred*255), Int(sgreen*255), Int(sblue*255)) == (Int(rred*255), Int(rgreen*255), Int(rblue*255))
    }
}

extension Color: RawRepresentable {
    public typealias RawValue = String
    init(_ hex: UInt) {
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

func getGradient(gradientArray: [[Color]], gradientSelected: Int?) -> LinearGradient {
    if let gradientSelected = gradientSelected {
        return LinearGradient(gradient: Gradient(colors: gradientArray[gradientSelected]), startPoint: .bottomTrailing, endPoint: .topLeading)
    } else {
        return LinearGradient(gradient: Gradient(colors: gradientArray[6]), startPoint: .bottomTrailing, endPoint: .topLeading)
    }
}

func getGradientColours(gradientArray: [[Color]], gradientSelected: Int?) -> [Color] {
    if let gradientSelected = gradientSelected {
        return gradientArray[gradientSelected]
    } else {
        return gradientArray[6]
    }
}

class CustomGradientColours {
    static let gradientColours: [[Color]] = [
        [Color(0x0093c1), Color(0x05537a)], // light blue - dark blue
        [Color(0x52c8cd), Color(0x007caa)], // aqua - light blue
        [Color(0xe6e29a), Color(0x3ec4d0)], // pale yellow/white ish - aqua
        [Color(0xffd325), Color(0x94d7be)], // yellow - green
        [Color(0xff9e45), Color(0xffd63c)], // pale orange-yellow
        
        [Color(0xfc7018), Color(0xffc337)], // darker orange - yellow
        [Color(0xfb5b5c), Color(0xff9528)], // pink-orange
        [Color(0xd35082), Color(0xf77d4f)], // magenta-orange
        [Color(0x8548ba), Color(0xd95378)], // purple-pink
        [Color(0x3f248f), Color(0x702f86)], // dark blue-purple
    ]
}


// MARK: - MAIN TIMER STATIC VALUES
#warning("TODO: merge this with tabrouter")
@available(*, deprecated, message: "Use UIDevice.hasBottomBar instead.")
class SetValues {
    static let hasBottomBar = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom)! > 0
}

extension Color {
    struct Timer {
        static let normal: Color = Color("dark")
        static let heldDown: Color = Color("red")
        static let canStart: Color = Color("green")
        static let loading: Color = Color("grey")
    }
    
    struct Inspection {
        static let eight: Color = Color(red: 234/255, green: 224/255, blue: 182/255)
        static let twelve: Color = Color(red: 234/255, green: 212/255, blue: 182/255)
        static let penalty: Color = Color(red: 234/255, green: 194/255, blue: 192/255)
    }
}


struct ShadowLight: ViewModifier {
    @Environment(\.colorScheme) private var env
    
    let x: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: env == .dark ? .clear : Color("indent1").opacity(0.5), radius: 6, x: x, y: y)
    }
}

struct ShadowDark: ViewModifier {
    @Environment(\.colorScheme) private var env
    
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: env == .dark ? .clear : Color("indent1"), radius: 4, x: x, y: y)
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

enum HierarchialButtonType {
    case mono, coloured, halfcoloured, disabled, red, green
}

enum HierarchialButtonSize {
    case small, medium, large, ultraLarge
}

struct AnimatedButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.00)
            .opacity(configuration.isPressed ? 0.80 : 1.00)
            .animation(Animation.customFastSpring, value: configuration.isPressed)
    }
}

struct HierarchialButton<V: View>: View {
    let type: HierarchialButtonType
    let size: HierarchialButtonSize
    
    let outlined: Bool
    let square: Bool
    
    let hasShadow: Bool
    let hasBackground: Bool
    
    let expandWidth: Bool
        
    let onTapRun: () -> Void
    @ViewBuilder let content: () -> V
    
    init(type: HierarchialButtonType,
         size: HierarchialButtonSize,
         outlined: Bool=false,
         square: Bool=false,
         hasShadow: Bool=true,
         hasBackground: Bool=true,
         expandWidth: Bool=false,
         onTapRun: @escaping () -> Void,
         @ViewBuilder _ content: @escaping () -> V) {
        self.type = type
        self.size = size
        
        self.outlined = outlined
        self.square = square
        
        self.hasShadow = hasShadow
        self.hasBackground = hasBackground
        
        self.expandWidth = expandWidth
        
        self.onTapRun = onTapRun
        self.content = content
    }
    
    var body: some View {
        Button {
            self.onTapRun()
        } label: {
            HierarchialButtonBase(type: self.type,
                                  size: self.size,
                                  outlined: self.outlined,
                                  square: self.square,
                                  hasShadow: self.hasShadow,
                                  hasBackground: self.hasBackground,
                                  expandWidth: expandWidth,
                                  content: self.content)
        }
        .buttonStyle(AnimatedButton())
    }
}

struct HierarchialButtonBase<V: View>: View {
    let content: V
    
    let colourBg: Color
    let colourFg: Color
    let colourShadow: Color
    
    let frameHeight: CGFloat
    let horizontalPadding: CGFloat
    let fontType: Font
    
    let square: Bool
    
    let hasShadow: Bool
    let hasBackground: Bool
    
    let expandWidth: Bool
    
    
    init(type: HierarchialButtonType,
         size: HierarchialButtonSize,
         outlined: Bool,
         square: Bool,
         hasShadow: Bool,
         hasBackground: Bool,
         expandWidth: Bool,
         content: @escaping () -> V) {
        switch (type) {
        case .halfcoloured:
            self.colourBg = Color("overlay0")
            self.colourFg = Color("accent")
            self.colourShadow = Color("indent1")
            
        case .coloured:
            self.colourBg = Color("accent").opacity(0.20)
            self.colourFg = Color("accent")
            self.colourShadow = Color("accent").opacity(0.08)
            
        case .mono:
            self.colourBg = Color("overlay0")
            self.colourFg = Color("dark")
            self.colourShadow = Color("indent1")
            
        case .disabled:
            self.colourBg = Color("grey").opacity(0.15)
            self.colourFg = Color("grey")
            self.colourShadow = Color.clear
            
        case .red:
            self.colourBg = Color("red").opacity(0.25)
            self.colourFg = Color("red")
            self.colourShadow = Color("red").opacity(0.16)
            
        case .green:
            self.colourBg = Color("green").opacity(0.25)
            self.colourFg = Color("green")
            self.colourShadow = Color("green").opacity(0.16)

        }
        
    
        
        switch (size) {
        case .small:
            self.frameHeight = 28
            self.horizontalPadding = 8
            self.fontType = Font.callout.weight(.medium)
            
            
        case .medium:
            self.frameHeight = 32
            self.horizontalPadding = 10
            self.fontType = Font.body.weight(.medium)
            
            
        case .large:
            self.frameHeight = 35
            self.horizontalPadding = 12
            self.fontType = Font.body.weight(.medium)
        
        case .ultraLarge:
            self.frameHeight = 48
            self.horizontalPadding = 16
            self.fontType = Font.title3.weight(.semibold)
            
        }
        
        self.square = square
        
        self.hasShadow = hasShadow
        self.hasBackground = hasBackground
        self.expandWidth = expandWidth
        
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if (self.hasBackground) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Material.ultraThinMaterial)
                    .frame(width: square ? self.frameHeight : nil, height: self.frameHeight)
            }
            
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(self.hasBackground ? self.colourBg.opacity(0.92) : Color.white.opacity(0.001))
                .frame(width: square ? self.frameHeight : nil, height: self.frameHeight)
                .shadow(color: self.hasShadow
                        ? self.colourShadow
                        : Color.clear,
                        radius: self.hasShadow ? 4 : 0,
                        x: 0,
                        y: self.hasShadow ? 1 : 0)
            
            content
                .foregroundColor(self.colourFg)
                .font(self.fontType)
                .padding(.horizontal, square ? 0 : self.horizontalPadding)
        }
        .contentShape(Rectangle())
        .fixedSize(horizontal: !expandWidth, vertical: true)
    }
}

struct CloseButton: View {
    let hasBackgroundShadow: Bool
    let onTapRun: () -> Void
    
    init(hasBackgroundShadow: Bool=false, onTapRun: @escaping () -> Void) {
        self.hasBackgroundShadow = hasBackgroundShadow
        self.onTapRun = onTapRun
    }
    
    var body: some View {
        HierarchialButton(type: .mono, size: .medium, square: true, hasShadow: hasBackgroundShadow, hasBackground: hasBackgroundShadow, onTapRun: self.onTapRun) {
            Image(systemName: "xmark")
        }
    }
}

struct DoneButton: View {
    let onTapRun: () -> ()
    
    init(onTapRun: @escaping () -> ()) {
        self.onTapRun = onTapRun
    }
    
    var body: some View {
        Button {
            self.onTapRun()
        } label: {
            Text("Done")
                .font(.body.weight(.medium))
        }
        .tint(Color("accent"))
    }
}


extension Animation {
    static let customFastSpring: Animation = .spring(response: 0.3, dampingFraction: 0.72)
    static let customSlowSpring: Animation = .spring(response: 0.45, dampingFraction: 0.76)
    
    static let customDampedSpring: Animation = .spring(response: 0.3, dampingFraction: 0.82)
    static let customBouncySpring: Animation = .spring(response: 0.45, dampingFraction: 0.64)
    
    static let customFastEaseOut: Animation = .easeOut(duration: 0.28)
    static let customEaseInOut: Animation = .easeInOut(duration: 0.26)
}



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
