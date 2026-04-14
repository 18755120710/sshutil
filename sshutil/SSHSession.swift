import SwiftData
import Foundation

@Model
final class SSHSession {
    var id: UUID
    var name: String
    var host: String
    var port: Int
    var username: String
    // 出于安全考虑，建议生产环节将密码放入 Keychain，目前为简化直接存入或不存。
    var passwordOrPath: String 
    var createdAt: Date
    
    init(name: String, host: String, port: Int, username: String, passwordOrPath: String) {
        self.id = UUID()
        self.name = name
        self.host = host
        self.port = port
        self.username = username
        self.passwordOrPath = passwordOrPath
        self.createdAt = Date()
    }
}
