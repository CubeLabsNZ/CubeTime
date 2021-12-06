//
//  SettingsView.swift
//  txmer
//
//  Created by Reagan Bohan on 11/25/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    var body: some View {
        /*
        VStack {
            HStack {
                VStack {
                    Image(systemName: "paintpalette.fill")
                    Text("Apperance")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: UIColor.systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                VStack {
                    Image(systemName: "gearshape.2.fill")
                    Text("General")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: UIColor.systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
            }
            HStack {
                VStack {
                    Image(systemName: "square.and.arrow.up.on.square.fill")
                    Text("Import/Export")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: UIColor.systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                VStack {
                    Image(systemName: "info.circle.fill")
                    Text("General")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: UIColor.systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
            }
        }*/
        ScrollView() {
            AppearanceSettingsView()
            GeneralSettingsView()
            ImportExportSettingsView()
            AboutSettingsView()
        }
    }
}


@available(iOS 15.0, *)

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
