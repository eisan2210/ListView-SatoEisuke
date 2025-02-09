//
//  ContentView.swift
//  ListView
//
//  Created by satoeisuke on 2025/02/09.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
       FirstView() //FirstViewを表示
        //SecoundView()
    }
}
//リストのビュー
struct FirstView: View {
    
    //　”TassksData”というキーで保存されていた物を監視
    @AppStorage("TasksData") private var tasksData = Data()
    @State var tasksArray: [Task] = []
    
    //FirstViewが生成時に呼ばれる。
    init() {
        //tasksDataをデコードできたら、その値をtasksArrayにわたす
        if let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            _tasksArray = State(initialValue: decodedTasks)
            print(tasksArray)
        }
    }
    
    var body: some View {
        NavigationStack {
            // "Add New Task"をタップするとSecoundViewへ画面遷移するようにリンクを設定
            NavigationLink(destination: SecoundView(tasksArray: $tasksArray).navigationTitle("Add Task")) {
                Text("Add New Task")
                    .font(.system(size: 20, weight: .bold))
                    .padding()
            }
            
            
            List {
                //ExampleTaskの中のtaskListを　List　の内側に　ForEac を使って表示
                ForEach(tasksArray) { task in
                    Text(task.taskItem)
                }
                // リストの並び替え時の処理を設定
                .onMove { from, to in
                    replaceRow(from, to)
                }
            }
            .navigationTitle("Task List") //画面上のタイトル
            
            //ナビゲーションに編集ボタンを追加
            .toolbar {
                EditButton()
            }
            
        }
        
    }
    //並び替え処理と並び替え後の保存
        func replaceRow(_ from: IndexSet, _ to: Int) {
            tasksArray.move(fromOffsets: from, toOffset: to) //配列内での並び替え
            if let encodedArray = try? JSONEncoder().encode(tasksArray) {
                
                tasksData = encodedArray //エンコードできたらAppStorageに渡す（保存・更新）
                
            }
        }
}
// タスク入力用ビュー
struct SecoundView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // テキストフィールドに入力された文字を格納する変数
    @State private var task: String = ""
    
    @Binding var tasksArray: [Task] //タスクを入れる配列
    
    var body: some View {
        TextField("タスクを入力してください", text: $task)
            .textFieldStyle(.roundedBorder)
            .padding()
        
        Button {
            //　ボタンを押した時に実行
            addTask(newTask: task) //入力されたタスクの保存
            task = "" //テキストフィールドを空に
            print(tasksArray)
            
        } label: {
            Text("Add")
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .padding()
        
        Spacer() // 下側の余白を埋めた
        
    }
    //　タスクの追加と保存　引数は入力されたタスクの文字
    func addTask(newTask: String) {
        //テキストフィールドに入力された値が空白じゃない（何か入力されている）時だけ処理
        if !newTask.isEmpty {
            let task = Task(taskItem: newTask) // Taskをインスタンス化(実体化)
            var array = tasksArray
            array.append(task) //一時的な配列ArrayにTaskを追加
            
            // エンコードがうまくいったらUserDefaultsに保存する
            if let encoudData = try? JSONEncoder().encode(array) {
                UserDefaults.standard.setValue(encoudData, forKey: "TasksData") //保存
                tasksArray = array //保存ができた時だけ　新しいTaskが追加された配列を反映
                dismiss() //前の画面に戻る
            }
        }
    }
    
}




#Preview {
    ContentView()
}

//#Preview("SecoundView", body: {
//    SecoundView()
//})

