import Foundation
import Citadel
import NIOCore

@Observable
class SSHConnectionManager {
    var isConnected: Bool = false
    var currentClient: SSHClient?
    
    func connect(session: SSHSession) async throws {
        // FIXME: 出于安全性考虑，实际生产应验证 Host Key，由于是一个简单的测试工具，暂无条件接受全部 (acceptAnything)
        
        let client = try await SSHClient.connect(
            host: session.host,
            port: session.port,
            authenticationMethod: .password(session.passwordOrPath),
            hostKeyValidator: .acceptAnything(),
            reconnect: .never
        )
        
        self.currentClient = client
        
        await MainActor.run {
            self.isConnected = true
        }
    }
    
    func executeCommand(_ command: String) async throws -> String {
        guard let client = currentClient else {
            throw SSHManagerError.notConnected
        }
        // 使用 Citadel 的 executeCommand 执行任意指定命令，并获取带有回显的 buffer
        let buffer = try await client.executeCommand(command)
        // 从 ByteBuffer 转回 String
        if let output = String(buffer: buffer) {
            return output
        }
        return ""
    }
    
    func uploadFile(localURL: URL, remotePath: String) async throws {
        guard let client = currentClient else {
            throw SSHManagerError.notConnected
        }
        
        // 开启 SFTP 会话
        let sftp = try await client.openSFTP()
        
        let fileData = try Data(contentsOf: localURL)
        var buffer = ByteBufferAllocator().buffer(capacity: fileData.count)
        buffer.writeBytes(fileData)
        
        let file = try await sftp.openFile(
            remotePath,
            withAccess: .write,
            flags: [.create, .truncate]
        )
        
        try await file.write(buffer)
        try await file.close()
    }
    
    func disconnect() async throws {
        try await currentClient?.close()
        self.currentClient = nil
        await MainActor.run {
            self.isConnected = false
        }
    }
}

enum SSHManagerError: Error {
    case notConnected
}
