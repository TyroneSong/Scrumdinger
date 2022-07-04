//
//  ThemePicker.swift
//  Scrumdinger
//
//  Created by 宋璞 on 2022/7/1.
//

import SwiftUI

struct ThemePicker: View {
    @Binding var selector: Theme
    
    var body: some View {
        Picker("Theme", selection: $selector) {
            List {
                ForEach(Theme.allCases) { theme in
                    ThemeView(theme: theme)
                        .tag(theme)
                }
            }
        }
    }
}

struct ThemePicker_Previews: PreviewProvider {
    static var previews: some View {
        ThemePicker(selector: .constant(.periwinkle))
    }
}
