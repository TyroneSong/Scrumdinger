//
//  ScrumProgressViewStyle.swift
//  Scrumdinger
//
//  Created by 宋璞 on 2022/7/1.
//

import Foundation
import SwiftUI

struct ScrumProgressViewStyle: ProgressViewStyle {
    var theme: Theme
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(theme.accentColor)
                .frame(height: 20)
            if #available(iOS 15.0, *) {
                ProgressView(configuration)
                    .tint(theme.mainColor)
                    .frame(height: 12.0)
                    .padding(.horizontal)
            } else {
                ProgressView(configuration)
                    .frame(height: 12.0)
                    .padding(.horizontal)
                
            }
        }
    }
    
}
