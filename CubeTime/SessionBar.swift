//
//  SessionBar.swift
//  CubeTime
//
//  Created by Tim Xie on 9/05/22.
//

import SwiftUI

struct SessionBar: View {
    var name: String
    var session: Sessions
    
    
    var body: some View {
        HStack (alignment: .center) {
            Text(name)
                .font(.title3).fontWeight(.semibold)
//                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundColor(Color(uiColor: .systemGray))
            Spacer()
            
            switch SessionTypes(rawValue: session.session_type)! {
            case .standard:
                Text(puzzle_types[Int(session.scramble_type)].name)
                    .font(.callout).fontWeight(.semibold)
//                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(Color(uiColor: .systemGray))
            case .multiphase:
                HStack(spacing: 2) {
                    Image(systemName: "square.stack")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color(uiColor: .systemGray))
                    
                    Text(puzzle_types[Int(session.scramble_type)].name)
                        .font(.callout).fontWeight(.semibold)
                        .foregroundColor(Color(uiColor: .systemGray))
                }
                
            case .compsim:
                HStack(spacing: 2) {
                    Image(systemName: "globe.asia.australia")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color(uiColor: .systemGray))
                    
                    Text(puzzle_types[Int(session.scramble_type)].name)
                        .font(.callout).fontWeight(.semibold)
                        .foregroundColor(Color(uiColor: .systemGray))
                }
            
            case .playground:
                Text("Playground")
                    .font(.callout).fontWeight(.semibold)
                    .foregroundColor(Color(uiColor: .systemGray))
            
            default:
                Text(puzzle_types[Int(session.scramble_type)].name)
                    .font(.callout).fontWeight(.semibold)
                    .foregroundColor(Color(uiColor: .systemGray))
            }
        }
    }
}
