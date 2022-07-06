[toc]

# [使用 Bindings 传递数据](https://developer.apple.com/tutorials/app-dev-training/passing-data-with-bindings)

在上一个教程中，您使用绑定在编辑视图和该视图中的各个 UI 控件之间共享数据。 现在，您将通过使用允许主题选择器和编辑视图共享数据的绑定构建颜色主题选择器来扩展编辑功能。

[下载](https://docs-assets.developer.apple.com/published/fafc920fb1054af88b2601bb53098f75/600/PassingDataWithBindings.zip)启动项目并按照本教程进行操作，或者打开完成的项目并自行探索代码。

## 1. 创建主题视图

```swift
struct ThemeView: View {
    let theme: Theme 
  
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(theme.mainColor)
            Label(theme.name, systemImage: "paintpalette")
          			.padding(4)
        }
        .foregroundColor(theme.accentColor)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct ThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeView(theme: .buttercup)
    }
}
```

## 2. 添加主题选择器

在本节中，您将为用户创建自定义交互式视图，以选择会议视图的颜色主题。 使用主题视图，您将在选取器控件中列出应用程序的所有主题。 然后，您将所选主题的值存储在绑定到父视图的变量中。 以这种方式，主题视图将主题选择传达给父视图。

1. 让 Theme 继承 CaseIterable, Identifiable， 并添加 id 属性

   ```swift
   // Theme.swift
   - enum Theme: String {
   + enum Theme: String, CaseIterable, Identifiable {
    ...
   +  var id: String {
   +    name
   +  }
   }
   ```

2. 创建 ThemePicker, @Binding 属性 selecctor: Theme

   ```swift
   // ThemePicker.swift
   struct ThemePicker: View {
       @Binding var selection: Theme
       
       var body: some View {
           Picker("Theme", selection: $selection) {
               ForEach(Theme.allCases) { theme in
                   ThemeView(theme: theme)
                       .tag(theme)
               }
           }
       }
   }
   
   struct ThemePicker_Previews: PreviewProvider {
       static var previews: some View {
           ThemePicker(selection: .constant(.periwinkle))
       }
   }
   ```

3. 在 DetailView 中添加 ThemePicker，并绑定一个 theme 值

   ```swift
   // DetailView.swift
   Section(header: Text("Meeting Info")) {
     TextField("Title", text: $data.title)
     HStack {...}
   +  ThemePicker(section: $data.theme)
   }
   ```

## 3. 将编辑视图的一个Binding传递给数据

当用户修改有关 Scrum 的信息时，应用程序中的多个屏幕需要反映这些更改。 在本节中，您将向编辑视图添加一个绑定，当用户点击完成按钮时，该绑定会更新详细视图中的 scrum。

1. 修改编辑页面的 data @State属性为@Binding属性，用来共享 DetailView 和 DetailEditView 的真实源

   ```swift
   // DetailEditView.swift
   - @State private var data = DailyScrum.Data()
   + @Binding var data: DailyScrum.Data
   ```

   * Data 现在是一个初始化参数，所以需要删除 private 属性和初始化

2. 在 Previews 更新 data 传参

   ```swift
   // DetailEditView.swif
   struct DetailEditView_Previews: PreviewProvider {
       static var previews: some View {
   -        DetailEditView()
   +        DetailEditView(data: .constant(DailyScrum.sampleData[0].data))
       }
   }
   ```

3. 在 DetailView 中添加 @State 属性 data

   ```swift
   // DetailView.swift
   struct DetailView: View {
   	let scrum: DailyScrum
   +  @State private var data: DailyScrum.Data()
     ...
   }
   ```

4. 在点击编辑按钮时，设置 data = scrum.data

   ```swift
   // DetailView.swift
   .toolbar {
     Button("Edit") {
       isPresentingEditView = true
   +    data = scrum.data
     }
   }
   ```

5. 给初始化 DetailEditView 传参

   ```swift
   // DetailView.swift
   NavigationView {
   -  DetailEditView()
   +  DetailEditView(data: $data)
     ..
   }
   ```

6. 当点击 toolbar 上完成按钮时，更新数据

   ```swift
   // DetailView.swift
   NavigationView {
     DetailEditView(data: $data)
     		.toolbar {
           .....
           ToolbarItem(placement: .confirmationAction) {
             Button("Done") {
               isPresentingEditView = false
   +            scrum.update(from: data)
             }
           }
         }
   }
   ```

7. 绑定 scrum 属性，确保用户在修改 scrum 后展示唯一源

   ```swift
   // DetailView.swift
   - let scrum: DailyScrum
   + @Binding var scrum: DailyScrum
   ```

8. 给 DetailView_Previews 传参

   ```swift
   // DetailView.swift
   struct DetailView_Previews: PreviewProvider {
       static var previews: some View {
           NavigationView {
               DetailView(scrum: .constant(DailyScrum.sampleData[0]))
           }
       }
   }
   ```

## 4. 传递绑定信息到详情页

列表视图还需要反映用户对编辑屏幕上的单个 scrum 所做的更改。 对于此数据流，您需要将另一个绑定向下传递到视图层次结构。

您将从将 scrums 属性从常量更改为绑定开始。 然后，您将创建从 scrums 数组中的各个项目到详细视图的绑定。   

1. 在 ScrumsView 中重写 scrums 绑定属性

   ```swift
   // ScrumsView.swift
   - var scrums: [DailyScrum]
   + @Binding var scrums: [DailyScrum]
   
   // 在 PreViews 中传参
   struct ScrumsView_Previews: PreviewProvider {
       static var previews: some View {
           NavigationView {
               ScrumsView(scrums: .constant(DailyScrum.sampleData))
           }
       }
   }
   ```

2. 修改 ForEach 视图以接受 Binding<[DailyScrum]>

3. 将闭包参数类型更改为 Binding<DailyScrum>

4. 将 Binding<DailyScrum> 传递给 DetailView 初始化程序

   ```swift
   // ScrumsView.swift
   List {
   -    ForEach(scrums) { scrum in
   +    ForEach($scrums) { $scrum in
   -        NavigationLink(destination: DetailView(scrum: scrum)) {
   +        NavigationLink(destination: DetailView(scrum: $scrum)) {
             ....
           }
        }
   }
   ```

## 5. 传递一个绑定到列表视图

ScrumdingerApp 定义了应用程序的入口点和结构。 在本节中，您将通过将 @State 属性添加到 ScrumdingerApp 来为您的应用程序数据创建事实来源。 然后，您会将对该数据的绑定沿层次结构向下传递到列表视图。

```swift
// ScrumdingerApp.swift
@main
struct ScrumdingerApp: App {
+    @State private var scrums = DailyScrum.sampleData
    var body: some Scene {
        WindowGroup {
            NavigationView {
-                ScrumsView(scrums: DailyScrum.sampleData)
+              	 ScrumsView(scrums: $scrums)
            }
        }
    }
}
```



* @State 为值类型创建了真实来源
* @Binding 与其他视图共享对状态的写访问
