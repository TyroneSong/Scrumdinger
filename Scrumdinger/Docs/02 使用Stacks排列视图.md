[toc]

# [02. 使用Stacks排列视图](https://developer.apple.com/tutorials/app-dev-training/using-stacks-to-arrange-views)



使用 SwiftUI 声明性语法创建、修改和组合视图以组成应用程序的 UI。 您将开始构建管理会议的应用程序 Scrumdinger，方法是安排视图组以创建会议计时器屏幕。 随着模块的进行，您将在完成最终设计时重新访问计时器屏幕。

按照以下步骤开始您的新项目，或打开完成的项目并自行探索代码。

## 创建项目

1. 使用 iOS App 模板创建一个新项目。
2. 在项目选项中，将产品命名为“Scrumdinger”，然后单击界面弹出菜单并选择 SwiftUI。
   1. 该模板包括根视图的起始文件 ContentView.swift 和定义应用程序入口点的文件 ScrumdingerApp.swift。
   2. 如果您是 Xcode 新手，请了解[关于主窗口](https://help.apple.com/xcode/mac/current/#/dev84c38774c)并了解如何[创建项目](https://help.apple.com/xcode/mac/current/#/dev07db0e578)。
3. 选择一个位置来保存您的项目。

## 构建视图组

视图定义了 UI 的一部分。 它们是您的应用程序的构建块。 您可以通过将小而简单的视图组合成一个复杂的视图。 在本节中，您将构建计时器屏幕的标题以显示会议的已用时间和剩余时间。

### 重构 ContentView.swift 名称

1. 双击结构体 ContenView， 选择 Refactor -> Rename
2. 重命名结构体 MettingView 

### 设置Stacks

1. 添加并初始化 ProgressView，替换 Body 中的 Text
2. 选中 ProgressView 右击 -> Show Code Actions -> Embed in VStack

```swift
var body: some View {
        VStack {
            ProgressView(value: 5, total: 15)
            HStack {
                VStack {
                    Text("Seconds Elapsed")
                    Label("300", systemImage: "hourglass.bottomhalf.fill")
                }
                VStack {
                    Text("Seconds Remaining")
                    Label("600", systemImage: "hourglass.tophalf.fill")
                }
            }
        }
    }
```

## 修改和样式视图

MeetingView.swift

```swift
struct MeetingView: View {
	var body: some View {
        VStack {
            ProgressView(value: 5, total: 15)
            HStack {
                VStack(alignment: .leading) {
                    Text("Seconds Elapsed")
                        .font(.caption)
                    Label("300", systemImage: "hourglass.bottomhalf.fill")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Seconds Remaining")
                        .font(.caption)
                    Label("600", systemImage: "hourglass.tophalf.fill")
                }
            }
            Circle()
                .strokeBorder(lineWidth: 24)
            HStack {
                Text("Speaker 1 of 3")
                Spacer()
                Button(action: {}) {
                    Image(systemName: "forward.fill")
                }
            }
        }
        .padding()
    }
}
```

## 补充无障碍数据

SwiftUI 具有内置的可访问性，因此您只需很少的额外工作即可获得可访问性支持。 例如，VoiceOver 等设备功能可以自动访问文本视图中的字符串内容。 但有时，您可能希望补充推断数据以增强用户的可访问性体验。

```swift
// MeetingView.swift

ProgressView(value: 5, total: 15)
HStack {
  ......
}
.accessibilityElement(children: .ignore)  // 或略子视图的可访问标签和值
.accessibilityLabel("Time Remaining") // 为 HStack 添加可访问标签
.accessibilityValue("10 minutes") // 为 HStack 添加可访问值， 因为子视图忽略了，所以必须添加，否则 SwiftUI 会自动推断子视图的值
```

```swift
// MeetingView.swift
Circle()
HStack{
  ....
  Button(){
    .....
  }
  .accessibilityLabel("Next speaker")  // VoiceOver 会读取标签 “Next speaker，按钮(Button)”
}
```

