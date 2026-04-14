import SwiftUI
import SwiftData

struct AddServerFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var host: String = ""
    @State private var port: String = "22"
    @State private var username: String = ""
    @State private var passwordOrPath: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("会话名称 (例如: Prod server)", text: $name)
                    TextField("标示 (IP/域名)", text: $host)
                    TextField("端口", text: $port)
                    TextField("用户名", text: $username)
                }
                
                Section(header: Text("认证信息")) {
                    SecureField("密码或私钥路径", text: $passwordOrPath)
                }
            }
            .padding()
            .frame(minWidth: 400, minHeight: 300)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveSession()
                    }
                    .disabled(name.isEmpty || host.isEmpty || username.isEmpty)
                }
            }
        }
    }
    
    private func saveSession() {
        let newSession = SSHSession(
            name: name,
            host: host,
            port: Int(port) ?? 22,
            username: username,
            passwordOrPath: passwordOrPath
        )
        modelContext.insert(newSession)
        dismiss()
    }
}

#Preview {
    AddServerFormView()
}
