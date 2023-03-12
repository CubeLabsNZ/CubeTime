import SwiftUI
import UIKit
import Foundation

// share button
final class ShareButtonUIViewController: UIViewController {
    var hostingController: UIHostingController<HierarchicalButton<Label<Text, Image>>>!
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    init(toShare: String, buttonText: String) {
        super.init(nibName: nil, bundle: nil)
        self.hostingController = UIHostingController(rootView: HierarchicalButton(type: .coloured, size: .large, expandWidth: true, onTapRun: { [weak self] in
            guard let self = self else { return }
            let activityViewController = UIActivityViewController(activityItems: [toShare], applicationActivities: nil)
            activityViewController.isModalInPresentation = !UIDevice.deviceIsPad
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }) {
            Label(buttonText, systemImage: "square.and.arrow.up")
        })
    }
    
    override func viewDidLoad() {
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(hostingController)
        
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

struct ShareButton: UIViewControllerRepresentable {
    let toShare: String
    let buttonText: String
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let shareButtonUIViewController = ShareButtonUIViewController(toShare: toShare, buttonText: buttonText)
        shareButtonUIViewController.view?.backgroundColor = .clear
        shareButtonUIViewController.hostingController.view?.backgroundColor = .clear
        
        return shareButtonUIViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}


// hierarchical button


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

struct HierarchicalButton<V: View>: View {
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
            HierarchicalButtonBase(type: self.type,
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

struct HierarchicalButtonBase<V: View>: View {
    let content: V
    
    let colourBg: Color
    let colourFg: Color
    let colourShadow: Color
    
    @ScaledMetric var frameHeight: CGFloat
    
    let horizontalPadding: CGFloat
    let fontType: Font
    
    let square: Bool
    
    let hasShadow: Bool
    let hasBackground: Bool
    
    let expandWidth: Bool
    
    @State private var hovering: Bool = false
    
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
            self._frameHeight = ScaledMetric(wrappedValue: 28, relativeTo: .callout)
            self.horizontalPadding = 8
            self.fontType = Font.callout.weight(.medium)
            
            
        case .medium:
            self._frameHeight = ScaledMetric(wrappedValue: 32, relativeTo: .body)
            self.horizontalPadding = 10
            self.fontType = Font.body.weight(.medium)
            
            
        case .large:
            self._frameHeight = ScaledMetric(wrappedValue: 35, relativeTo: .body)
            self.horizontalPadding = 12
            self.fontType = Font.body.weight(.medium)
        
        case .ultraLarge:
            self._frameHeight = ScaledMetric(wrappedValue: 48, relativeTo: .title3)
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
                    .fill(Material.thinMaterial)
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
        .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
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
        HierarchicalButton(type: .mono, size: .medium, square: true, hasShadow: hasBackgroundShadow, hasBackground: hasBackgroundShadow, onTapRun: self.onTapRun) {
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

