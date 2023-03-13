//
//  HelperUI.swift
//  CubeTime
//
//  Created by Tim Xie on 25/02/23.
//

import Foundation
import SwiftUI


// MARK: - COLOURS AND GRADIENTS
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
    
    struct Inspection {
        static let eight: Color = Color(red: 234/255, green: 224/255, blue: 182/255)
        static let twelve: Color = Color(red: 234/255, green: 212/255, blue: 182/255)
        static let penalty: Color = Color(red: 234/255, green: 194/255, blue: 192/255)
    }
}

struct CopyButton: View {
    let toCopy: String
    let buttonText: String
    
    @State private var offsetValue: CGFloat = -25
    
    var body: some View {
        HierarchicalButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {
            UIPasteboard.general.string = toCopy
            
            withAnimation(Animation.customSlowSpring.delay(0.25)) {
                self.offsetValue = 0
            }
            
            withAnimation(Animation.customFastEaseOut.delay(2.25)) {
                self.offsetValue = -25
            }
        }) {
            HStack(spacing: 8) {
                ZStack {
                    if self.offsetValue != 0 {
                        Image(systemName: "doc.on.doc")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Color("accent"))
                           
                    }
                    
                    
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.semibold))
                        .clipShape(Rectangle().offset(x: self.offsetValue))
                }
                .frame(width: 20)
                
                Text(buttonText)
            }
        }
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



struct BackgroundColour: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.colorScheme) var colourScheme
    
    let isSessions: Bool
    
    #warning("refactor this atrocious design")
    init(isSessions: Bool=false, isTimeStatsDetail: Bool=false) {
        self.isSessions = isSessions
    }
    
    var body: some View {
        Group {
            if (!UIDevice.deviceIsPad || hSizeClass == .compact) { // if phone or small split screen ipad, then NO modals
                Color("base")
            } else {
                if (colourScheme == .dark) {
                    let _ = NSLog("here")
                    if (isSessions) {
                        Color("overlay1")
                    } else {
                        Color("indent1")
                    }
                } else {
                    Color("base")
                }
            }
        }
        .ignoresSafeArea()
    }
}
