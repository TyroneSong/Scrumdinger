[toc]

# [采用 Swift 并发（Adopting Swift Concurrency）](https://developer.apple.com/tutorials/app-dev-training/adopting-swift-concurrency)

Swift 5.5 包含新的 async 和 await 关键字，使您能够更轻松地编写高性能异步代码。 在本文中，您将学习如何定义和调用异步函数，并探索结构化并发如何简化复杂的异步函数。

## 简化异步代码

回想一下你在 Persisting Data 中编写的 load(completion:) 函数：

```swift
static func load(completion: @escaping (Result<[DailyScrum], Error>)->Void) {
  DispatchQueue.global(qos: .background).async {
      do {
          // Decode scrums
          DispatchQueue.main.async {
              completion(.success(dailyScrums))
          }
      } catch {
          DispatchQueue.main.async {
              completion(.failure(error))
          }
      }
  }
}
```

为了保持 UI 响应，该函数在后台队列中解码 scrum 数据。 然后在后台工作完成后，它使用完成闭包来更新主队列上的存储。 这种基于回调的异步代码在 Swift 中很常见，但可能难以阅读，尤其是当您将完成处理程序嵌套在另一个内部时。

幸运的是，Swift 5.5 引入了一种新的 async/await 模式，因此您可以编写看起来更像普通同步代码的异步函数。 在下一个教程中，您将学习如何将现有的基于回调的异步函数与 Swift 中的新并发功能集成。 但在此之前，您将学习如何使用 async 和 await 定义和调用异步函数。

## 定义一个异步函数

您可以通过在参数列表之后添加 async 关键字来定义异步函数 - 如果函数返回值，则在返回箭头 (->) 之前。 在下面的示例中，ViewModel 有一个名为 fetchParticipants() 的异步函数，它返回一个参与者数组：

```swift
class ViewModel: ObservableObject {
   @Published var participants: [Participant] = []

   func fetchParticipants() async -> [Participant] {...}
}
```

## 调用异步函数

您可以使用 await 关键字调用异步函数。 因为等待的代码可以暂停执行，所以只能在异步上下文中使用 await，例如在另一个异步函数的主体内部。 在下面的示例中，ViewModel 包含一个名为 refresh() 的新异步函数，该函数调用 fetchParticipants()：

```swift
class ViewModel: ObservableObject {
   @Published var participants: [Participant] = []

   func refresh() async {
      let fetchedParticipants = await fetchParticipants()
      self.participants = fetchedParticipants
   }
   func fetchParticipants() async -> [Participant] {...}
}
```

await 关键字允许系统暂停函数的其余部分的执行，直到 fetchParticipants() 完成。 当函数暂停时，线程可以自由地执行其他工作。 当 fetchParticipants() 完成时，系统执行 refresh() 函数中的下一行。 使用 async/await，执行顺序更容易理解，因为您的函数是线性执行的。

您可以通过创建任务从同步上下文中调用异步函数。 在下面的示例中，ContentView 中的按钮使用 Task 调用 refresh()：

```swift
struct ContentView: View {
   @StateObject var model = ViewModel()
 
   var body: some View {
      NavigationView {
         List {
            Button {
               Task {
                  await model.refresh()
               }
            } label: {
               Text("Load Participants")
            }
            ForEach(model.participants) { participant in
               ...
            }
         }
      }
   }
}
```

SwiftUI 提供了一个任务修饰符，您可以使用它在视图出现时执行异步函数：

```swift
struct ContentView: View {
   @StateObject var model = ViewModel()
 
   var body: some View {
      NavigationView {
         List {
            ForEach(model.participants) { participant in
               ...
            }
         }
         .task {
            await model.refresh()
         }
      }
   }
}
```

当视图消失时，系统会自动取消任务。

## 共同使用

在下一个教程中，您将更新 Scrumdinger 以采用 Swift 5.5 中的新并发特性。 您将为应用程序设置一个新的部署目标，并学习如何使用延续在异步函数和现有的基于回调的函数之间架起桥梁。