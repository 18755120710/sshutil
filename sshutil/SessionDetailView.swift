import SwiftUI

struct SessionDetailView: View {
    var session: SSHSession
    @State private var consoleOutput: String = "等待连接..."
    @State private var connectionManager = SSHConnectionManager()
    @State private var commandInput: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶栏信息
            HStack {
                VStack(alignment: .leading) {
                    Text(session.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(session.username)@\(session.host):\(session.port)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: {
                    Task {
                        await toggleConnection()
                    }
                }) {
                    Label(connectionManager.isConnected ? "断开" : "连接", 
                          systemImage: connectionManager.isConnected ? "network.slash" : "network")
                }
                .buttonStyle(.borderedProminent)
                .tint(connectionManager.isConnected ? .red : .blue)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // 终端模拟区
            ZStack(alignment: .bottom) {
                ScrollView {
                    Text(consoleOutput)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color.black.opacity(0.8))
                .foregroundColor(.green)
                
                // 命令输入框
                if connectionManager.isConnected {
                    HStack {
                        TextField("输入命令 (如 ls -l)...", text: $commandInput)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                executeUserCommand()
                            }
                        
                        Button("发送") {
                            executeUserCommand()
                        }
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor).opacity(0.9))
                }
            }
            
            Divider()
            
            // 文件上传区
            HStack {
                Text("SFTP 文件上传")
                    .font(.headline)
                Spacer()
                Button(action: {
                    selectAndUploadFile()
                }) {
                    Label("选择文件并上传", systemImage: "doc.badge.arrow.up")
                }
                .disabled(!connectionManager.isConnected)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .navigationTitle(session.name)
    }
    
    private func selectAndUploadFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            let filename = url.lastPathComponent
            let targetPath = "/tmp/\(filename)" // 默认传到 /tmp 目录供测试
            
            appendConsole("开始上传 \(filename) 到 \(targetPath)...")
            
            Task {
                do {
                    try await connectionManager.uploadFile(localURL: url, remotePath: targetPath)
                    appendConsole("✅ 上传成功: \(targetPath)")
                } catch {
                    appendConsole("❌ 上传失败: \(error)")
                }
            }
        }
    }
    
    private func toggleConnection() async {
        if connectionManager.isConnected {
            do {
                try await connectionManager.disconnect()
                appendConsole("已断开连接。")
            } catch {
                appendConsole("断开失败: \(error.localizedDescription)")
            }
        } else {
            appendConsole("正在连接 \(session.host)...")
            do {
                try await connectionManager.connect(session: session)
                appendConsole("连接成功！")
            } catch {
                appendConsole("连接失败: \(error)")
            }
        }
    }
    
    private func executeUserCommand() {
        guard !commandInput.isEmpty else { return }
        let cmd = commandInput
        commandInput = ""
        appendConsole("$\(cmd)")
        
        Task {
            do {
                let output = try await connectionManager.executeCommand(cmd)
                appendConsole(output)
            } catch {
                appendConsole("执行命令出错: \(error)")
            }
        }
    }
    
    private func appendConsole(_ text: String) {
        Task { @MainActor in
            consoleOutput += "\n" + text
        }
    }
}

