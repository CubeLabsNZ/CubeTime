import Foundation
import SwiftUI

struct SettingsHeaderLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .font(.subheadline.weight(.bold))
                .foregroundColor(Color("accent"))
            configuration.title
                .font(.body.weight(.bold))
        }
    }
}

struct SettingsGroup<L: View, V: View>: View {
    @ViewBuilder let content: () -> V
    let label: L
    
    init(_ label: L, @ViewBuilder _ content: @escaping () -> V) {
        self.label = label
        self.content = content
    }
    

    
    var body: some View {
        VStack(alignment: .leading) {
            label
                .labelStyle(SettingsHeaderLabelStyle())
                .padding([.horizontal, .top], 10)
            
            VStack(alignment: .leading, content: content)
                .padding(.horizontal)
        }
        .padding(.bottom, 12)
        .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
    }
}

struct SettingsFootnote: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote.weight(.medium))
            .lineSpacing(-4)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Color("grey"))
            .multilineTextAlignment(.leading)
    }
}

struct DescribedSetting<V: View>: View {
    @ViewBuilder let content: () -> V
    let description: LocalizedStringKey
    
    init(description: LocalizedStringKey, @ViewBuilder _ content: @escaping () -> V) {
        self.description = description
        self.content = content
    }
    
    var body: some View {
        VStack {
            content()
            
            Text(description)
                .modifier(SettingsFootnote())
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SettingsToggle: View {
    let text: String
    @Binding var isOn: Bool
    
    init(_ text: String, _ isOn: Binding<Bool>) {
        self.text = text
        self._isOn = isOn
    }
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(text)
                .font(.body.weight(.medium))
        }
    }
}

struct SettingsPicker<SelectionValue: Hashable, V: View>: View {
    let text: String
    @Binding var selection: SelectionValue
    let maxWidth: CGFloat?
    @ViewBuilder let content: () -> V
    
    init(text: String, selection: Binding<SelectionValue>, maxWidth: CGFloat? = nil, @ViewBuilder _ content: @escaping () -> V) {
        self.text = text
        self._selection = selection
        self.maxWidth = maxWidth
        self.content = content
    }
    
    var body: some View {
        HStack {
            Text(text)
                .font(.body.weight(.medium))
            
            Spacer()
            
            Picker("", selection: $selection) {
                content()
            }
            .frame(maxWidth: maxWidth)
        }
    }
}

struct SettingsStepper<T: Comparable & Strideable>: View {
    let text: String
    let format: String
    @Binding var value: T
    let `in`: ClosedRange<T>
    let step: T.Stride
    
    var body: some View {
        Stepper(value: $value, in: `in`, step: step, label: {
            Text(text)
                .font(.body.weight(.medium))
            + Text(String(format: format, value as! CVarArg))
        })
    }
}

struct SettingsDragger<T: BinaryFloatingPoint>: View where T.Stride: BinaryFloatingPoint {
    let text: String
    @Binding var value: T
    let `in`: ClosedRange<T>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(.body.weight(.medium))
                .padding(.bottom, 4)
            
            Slider(value: $value, in: `in`, label: {EmptyView()}, minimumValueLabel: {
                Text("MIN")
                    .font(Font.system(.footnote, design: .rounded))
                    .foregroundColor(Color("grey"))
            }, maximumValueLabel: {
                Text("MAX")
                    .font(Font.system(.footnote, design: .rounded))
                    .foregroundColor(Color("grey"))
            })
        }
    }
}
