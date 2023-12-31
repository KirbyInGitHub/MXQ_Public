//
//  WXBizJsonMsgCrypt.swift
//  
//
//  Created by 张鹏 on 2023/2/24.
//

import Foundation
import Crypto
import CryptoSwift

struct WXBizJsonMsgCrypt {
    let key: Data
    let sToken: String
    let sReceiveId: String
    
    public init(sToken: String, sEncodingAESKey: String, sReceiveId: String) throws {
        guard let decodeData = Data(base64Encoded: "\(sEncodingAESKey)=", options: Data.Base64DecodingOptions.init(rawValue: 0)) else {
            throw MsgCryptError.init(status: .msgCryptInstall, reason: "解码失败")
        }
        self.key = decodeData
        self.sToken = sToken
        self.sReceiveId = sReceiveId
    }
    
    // 验证 URL
    public func verifyURL(sMsgSignature: String, sTimeStamp: String, sNonce: String, sEchoStr: String) throws -> String {
        let pc = Prpcrypt(key: self.key)
        return try pc.decrypt(text: sEchoStr, receiveid: self.sReceiveId)
    }
    
    // 解密信息
    public func decryptMsg(msgSignature: String, timeStamp: String, nonce: String, msgEncrypt: String) throws  -> String {
        let signature = calSignature(timeStamp: timeStamp, nonce: nonce, data: msgEncrypt)
        if signature != msgSignature {
            throw MsgCryptError.init(status: .decrypt, reason: "签名失败")
        }
        
        let pc = Prpcrypt(key: self.key)
        let xmlContent = try pc.decrypt(text: msgEncrypt, receiveid: self.sReceiveId)
        return xmlContent
    }
    
    // 加密信息
    public func encryptMsg(replyMsg: String, timestamp: String, nonce: String) throws -> (signature: String, xmlContent: String) {
        let pc = Prpcrypt(key: self.key)
        let xmlContent = try pc.encrypt(replyMsg: replyMsg, receiveid: self.sReceiveId)
        
        let signature = calSignature(timeStamp: timestamp, nonce: nonce, data: xmlContent)
        
        return (signature, xmlContent)
    }
    // 签名验证
    func calSignature(timeStamp: String, nonce: String, data: String) -> String {
        let sort_arr = [self.sToken, timeStamp, nonce, data].sorted(by: <).joined()
        guard let signatureData = sort_arr.data(using: .utf8) else { return "" }
        let digest = Insecure.SHA1.hash(data: signatureData)
        let hexDigest = digest.map { String(format: "%02hhx", $0) }.joined()
        return hexDigest
    }
}


extension WXBizJsonMsgCrypt {
    
    class Prpcrypt {
        let key: Data
        init(key: Data) {
            self.key = key
        }
        /// 解密
        func decrypt(text: String, receiveid: String) throws -> String {
            
            if key.count < 16 {
                throw MsgCryptError.init(status: .decrypt, reason: "key count < 16")
            }

            let iv = key.bytes[..<16]

            
            let decrypted = try AES(key: key.bytes, blockMode: CBC(iv: Array(iv)), padding: .noPadding)
        
            let decodeTextData = [UInt8](base64: text)
            
            let originalPlaintextData = try decrypted.decrypt(decodeTextData)
            let plaintextData = try pKCS7Unpadding(dataBytes: originalPlaintextData, blockSize: 32)
            
            if plaintextData.count < 20 {
                throw MsgCryptError.init(status: .decrypt, reason: "plaintext count < 20")
            }
            // 随机数
//            let randomBuffer: Array<UInt8> = Array(plaintextData[0..<16])
            // 获取消息长读
            let xml_lenData = Data(Array(plaintextData[16..<20]))
            let xml_unsafeValue: Int32 = xml_lenData.withUnsafeBytes({ pointer in
                pointer.load(as: Int32.self).bigEndian
            })
            let xml_lenValue: Int = Int(xml_unsafeValue)
            
            // 内容信息
            let msgData = Data(Array(plaintextData[20..<(xml_lenValue + 20)]))
            guard let xml_content = String(data: msgData, encoding: .utf8) else {
                throw MsgCryptError.init(status: .decrypt, reason: "xml encoding error")
            }
            
            let receiverIDData = Data(Array(plaintextData[(xml_lenValue + 20)...]))
            guard let receive_id  = String(data: receiverIDData, encoding: .utf8) else {
                throw MsgCryptError.init(status: .decrypt, reason: "receiveId encoding error")
            }
            
            if receiveid != receive_id {
                throw MsgCryptError.init(status: .decrypt, reason: "receive not equal")
            }
            
            return xml_content
        }
        
        
        /// 加密
        /// - Parameters:
        ///   - replyMsg: 回复消息
        ///   - nonce: 随机数
        func encrypt(replyMsg: String, receiveid: String) throws -> String {
            var byteBuffer: [UInt8] = []
            // 拼接随机数
            let randomBuffer: Array<UInt8> = randString(count: 16)
            byteBuffer.append(contentsOf: randomBuffer)
            // 拼接字符长度
            let msg_len: Int32 = Int32(replyMsg.bytes.count)
            let msg_len_data = withUnsafeBytes(of: msg_len.bigEndian) { (buffer: UnsafeRawBufferPointer) -> Data in
                // MARK: need fix Data count
                return Data.init(buffer)
            }
            
            byteBuffer.append(contentsOf: msg_len_data.bytes)
            // 拼接内容
            byteBuffer.append(contentsOf: replyMsg.bytes)
            // 拼接 receiveID
            byteBuffer.append(contentsOf: receiveid.bytes)
            
            let padMsgByteBuffer = pKCS7Padding(plainBuffer: byteBuffer, blockSize: 32)
            
            // 这里进行编码
            if key.count < 16 {
                throw MsgCryptError.init(status: .encrypt, reason: "key count < 16")
            }
            let iv = key.bytes[..<16]
            let encrypted = try AES(key: key.bytes, blockMode: CBC(iv: Array(iv)), padding: .noPadding)
            
            let ciphertext = try encrypted.encrypt(padMsgByteBuffer).toBase64()
            return ciphertext
        }
        
        // 生成随机数
        func randString(count: Int) -> [UInt8] {
            // MARK: need fix random
            let hexString = "35396433346134353236613837653938"
            return Array<UInt8>(hex: hexString)
        }
        
        func pKCS7Unpadding(dataBytes: [UInt8], blockSize: Int) throws -> Array<UInt8> {
            let plaintext_len = dataBytes.count
            
            if plaintext_len == 0{
                throw MsgCryptError.init(status: .pkcs7Unpadding, reason: "pKCS7Unpadding error nil or zero")
            }
            if plaintext_len % blockSize != 0 {
                throw MsgCryptError.init(status: .pkcs7Unpadding, reason: "pKCS7Unpadding text not a multiple of the block size")
            }
            let padding_len = dataBytes[plaintext_len-1]
            return Array(dataBytes[..<(plaintext_len - Int(padding_len))])
        }
        
        func pKCS7Padding(plainBuffer: [UInt8], blockSize: Int) -> Array<UInt8> {
            var buffer: [UInt8] = []
            buffer.append(contentsOf: plainBuffer)
            // padtext
            let padding = blockSize - (plainBuffer.count % blockSize)
            // MARK: need fix UInt8
            let paddingBytes: [UInt8] = Array(repeating: UInt8(padding), count: padding)
            buffer.append(contentsOf: paddingBytes)
            return buffer
        }
    }
}

enum CryptError {
    /// 初始化
    case msgCryptInstall
    /// 解码
    case decrypt
    /// 编码
    case encrypt
    /// AES
    case pkcs7Unpadding
}

struct MsgCryptError: Error {
    var status: CryptError
    var reason: String
}
