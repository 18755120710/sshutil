import SwiftUI

struct SessionDetailView: View {
    var session: SSHSession
    @State private var consoleOutput: String = "Wait for connection..."
    
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
                    // TODO: 实现连接逻辑
                    consoleOutput += "\n正在连接 \(session.host)..."
                }) {
                    Label("连接", systemImage: "network")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // 终端模拟区
            ScrollView {
                Text(consoleOutput)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color.black.opacity(0.8))
            .foregroundColor(.green)
            
            Divider()
            
            // 文件上传区
            HStack {
                Text("SFTP 文件上传")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // TODO: 打开文件选择器并上传
                }) {
                    Label("选择文件并上传", systemImage: "doc.badge.arrow.up")
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .navigationTitle(session.name)
    }
}
