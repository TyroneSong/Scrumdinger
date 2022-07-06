[toc]

# [更新App数据（Updating App Data）](https://developer.apple.com/tutorials/app-dev-training/updating-app-data)

在本教程中，您将向 Scrumdinger 添加两个新功能。 首先，您将添加一个视图来创建新的每日 Scrum 会议。 然后，您将更新会议计时器以跟踪过去的会议。

这两个功能都会修改应用程序中多个视图中显示的共享数据。 添加这些功能时，您将使用@State、绑定和事实来源重新审视一些基本的 SwiftUI 概念。

[下载](https://docs-assets.developer.apple.com/published/ac36b1b34ecf85600f509eb7746893d6/600/UpdatingAppData.zip)启动项目并按照本教程进行操作，或者打开完成的项目并自行探索代码。

## 1. 使用编辑页面创建一个新的 Scrum （Use the Edit View to Create a New Scrum）

在本节中，您将添加一个视图来创建一个新的每日 Scrum。 您已经创建了 DetailEditView，其中包含您需要的所有控件和数据。

您将向 ScrumsView 添加一个按钮，该按钮向用户显示 DetailEditView，他们可以使用它来创建 scrum。 用户创建 scrum 后，应用程序会将新的 scrum 添加到 scrums 数组中。 因为您将 scrums 数组声明为 @Binding，所以 ScrumsView 会自动更新以显示新元素。

1. 更新 ScrumView

   ```swift
   // ScrumView.swift
   struct ScrumsView: View {
     @Binding var scrums: [DailyScrum]
     @State private var isPresentingNewScrumView = false
     @State private var newScrumData = DailyScrum.Data()
   
     var body: some View {
         List {
             ForEach($scrums) { $scrum in
                 NavigationLink(destination: DetailView(scrum: $scrum)) {
                     CardView(scrum: scrum)
                 }
                 .listRowBackground(scrum.theme.mainColor)
             }
         }
         .navigationTitle("Daily Scrums")
         .toolbar {
             Button(action: {
                 isPresentingNewScrumView = true
             }) {
                 Image(systemName: "plus")
             }
             .accessibilityLabel("New Scrum")
         }
         .sheet(isPresented: $isPresentingNewScrumView) {
             NavigationView {
               // $标记 newScrumData 传值
                 DetailEditView(data: $newScrumData)
                     .toolbar {
                         ToolbarItem(placement: .cancellationAction) {
                             Button("Dismiss") {
                                 isPresentingNewScrumView = false
                                 newScrumData = DailyScrum.Data()
                             }
                         }
                         ToolbarItem(placement: .confirmationAction) {
                             Button("Add") {
                               // 创建新的 scrum 数据。
                                 let newScrum = DailyScrum(data: newScrumData)
                               // 新 scrum 加入到 scrums 中，因为 @Binding ，列表会自动更新
                                 scrums.append(newScrum) 	
                                 isPresentingNewScrumView = false  // 根据 bool 值，判断是否显示 sheet
                                  newScrumData = DailyScrum.Data()  //新数据恢复默认
                             }
                         }
                     }
             }
         }
     }
   }
   ```

   

## 2. 添加 Scrum 历史信息（Add Scrum History）

会议结束后，MeetingView 会记录会议日期、持续时间和与会者。 在本节中，您将向 scrum 添加一个 History 元素。 然后您将更新 DetailView 以显示历史列表。

ScrumdingerApp 中的 DailyScrum 项目数组是应用程序数据的真实来源。 ScrumsView 有一个到数组的绑定，它会将一个绑定到数组中的单个项目传递给 DetailView。 详细视图将绑定传递给 MeetingView。 绑定使您的模型数据与单一事实来源保持同步，因此您的所有视图都反映相同的数据。

1. 创建 ScrumHistory

   ```swift
   // ScrumHistory.swift
   struct History: Identifiable {
       let id: UUID
       let date: Date
       var attendees: [DailyScrum.Attendee]
       var lengthInMinutes: Int
       
       init(id: UUID = UUID(), date: Date = Date(), attendees: [DailyScrum.Attendee], lengthInMinutes: Int = 5) {
           self.id = id
           self.date = date
           self.attendees = attendees
           self.lengthInMinutes = lengthInMinutes
       }
   }
   ```

2. 在 DailyScrum 中添加 history: [History] 属性，并默认初始化 一个空数组

   ```swift
   // DailyScrum.swift
   struct DailyScrum: Identifiable {
       // ...
       var theme: Theme
   +    var history: [History] = []
   }
   ```

3. 在会议结束时，生成 history 并记录

   ```swift
   // MeetingView.swift
   .onDisapper {
     scrumTimer.stopScrum()
   +  let newHistory = History(attendees: scrum.attendees, lengthInMinutes: scrum.timer.secondsElapsed / 60)
   +  scrum.history.insert(newHistory, at: 0)
   }
   ```

4. 在 DetailScrum 中添加 History Session

   ```swift
   // DetailView.swift
   Section(header: Text("Attendees")) {
     // ...
   }
   
   Section(header: Text("History")) {
       if scrum.history.isEmpty {
           Label("No meetings yet", systemImage: "calendar.badge.exclamationmark")
       }
       ForEach(scrum.history) { history in
           HStack {
               Image(systemName: "calendar")
               Text(history.date, style: .date)
           }
       }
   }
   ```

   