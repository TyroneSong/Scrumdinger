[toc]

# [采用新API功能](https://developer.apple.com/tutorials/app-dev-training/adopting-new-api-features)

每个 SDK 版本都包含新技术、框架和语言功能。 在本文中，您将了解如何采用新的 API，同时保持与旧版本操作系统的兼容性。

## 设置部署目标

Xcode 项目中的每个目标都有一个部署目标设置，用于指定可以运行您的应用程序的操作系统的最早版本。 此设置确定您可用于开发应用程序的框架版本。 当您想要采用新功能或框架时，您可以更改此设置。

Scrumdinger 的部署目标是 iOS 14.0，这意味着任何运行 iOS 14.0 或更高版本的设备都可以运行该应用程序。

假设您决定使用 iOS 15.0 中引入的 listRowSeparator(_:edges:) 修饰符来隐藏 ScrumsList 中的分隔符。 如果添加修饰符，Xcode 会显示编译器错误，因为该方法仅在 iOS 15.0 或更高版本中可用，但应用仍支持 iOS 14.0。 要修复该错误，请将 Scrumdinger 的部署目标设置为 iOS 15.0。 但是，更改目标意味着该应用将不再在 iOS 15.0 之前的任何 iOS 版本上运行。

## 检查操作系统版本

您可以使用可用条件保持与早期版本的操作系统的向后兼容性。 使用#available，您可以为特定版本的操作系统执行一段代码。 以下示例中的视图修饰符仅在运行 iOS 15.0 或更高版本的设备上应用 listRowSeparator(_:edges:) 修饰符：

```swift
struct ScrumsListSeparator: ViewModifier {
   func body(content: Content) -> some View {
      if #available(iOS 15, *) {
         content
            .listRowSeparator(.hidden)
      } else {
         content
     }
   }
}
```

您可以使用 @available 属性将函数或整个类型标记为可用于特定操作系统。 下面定义的函数只能在 iOS 15.1 及更高版本中访问：

```swift
@available(iOS 15.1, *)
func setupGroupSession() {...}
```

您已经了解了部署设置和可用性检查如何让您在应用中采用新的 API 和功能。 在下一篇文章中，您将了解 iOS 15.0 中提供的新 Swift 5.5 语言功能如何让您更轻松地编写异步代码。