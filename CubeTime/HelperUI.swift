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
        static let normal: Color = Color.primary
        static let heldDown: Color = Color.red
        static let canStart: Color = Color.green
        static let loading: Color = Color(uiColor: .systemGray)
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
            .shadow(color: env == .dark ? .clear : .black.opacity(0.02), radius: 6, x: x, y: y)
    }
}

struct ShadowDark: ViewModifier {
    @Environment(\.colorScheme) private var env
    
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: env == .dark ? .clear : .black.opacity(0.04), radius: 4, x: x, y: y)
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
    case mono, coloured, halfcoloured
}

enum HierarchialButtonSize {
    case small, medium, large
}

struct AnimatedButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.00)
            .opacity(configuration.isPressed ? 0.80 : 1.00)
            .animation(.easeIn(duration: 0.1), value: configuration.isPressed)
    }
}

struct HierarchialButton<V: View>: View {
    let content: V
    let onTapRun: () -> Void
    
    let colourBg: Color
    let colourFg: Color
    let colourShadow: Color
    
    let frameHeight: CGFloat
    let horizontalPadding: CGFloat
    let fontType: Font
    
    let square: Bool
    
    
    init(type: HierarchialButtonType,
         size: HierarchialButtonSize,
         outlined: Bool=false,
         square: Bool=false,
         onTapRun: @escaping () -> (),
         @ViewBuilder _ content: @escaping () -> V) {
        switch (type) {
        case .halfcoloured:
            self.colourBg = Color("overlay0")
            self.colourFg = Color.accentColor
            self.colourShadow = Color.black.opacity(0.04)
            
        case .coloured:
            self.colourBg = Color("accent4")
            self.colourFg = Color.accentColor
            self.colourShadow = Color.accentColor.opacity(0.08)
            
        case .mono:
            self.colourBg = Color("overlay0")
            self.colourFg = Color("dark")
            self.colourShadow = Color.black.opacity(0.04)
        }
        
        switch (size) {
        case .small:
            self.frameHeight = 28
            self.horizontalPadding = 6
            self.fontType = Font.callout.weight(.medium)
            
            
        case .medium:
            self.frameHeight = 32
            self.horizontalPadding = 8
            self.fontType = Font.body.weight(.medium)
            
            
        case .large:
            self.frameHeight = 35
            self.horizontalPadding = 12
            self.fontType = Font.body.weight(.medium)
            
            
            
        }
        
        self.square = square
        self.onTapRun = onTapRun
        self.content = content()
    }
    
    var body: some View {
        Button {
            self.onTapRun()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(self.colourBg)
                    .shadow(color: self.colourShadow, radius: 4, x: 0, y: 1)
                    .frame(width: square ? self.frameHeight : nil, height: self.frameHeight)
                
                content
                    .foregroundColor(self.colourFg)
                    .font(self.fontType)
                    .padding(.horizontal, self.horizontalPadding)
            }
            .fixedSize()
        }
        .buttonStyle(AnimatedButton())
    }
}

