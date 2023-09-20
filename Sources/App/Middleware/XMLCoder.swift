//
//  File.swift
//
//
//  Created by 张鹏 on 2023/2/24.
//

import Vapor
import XMLCoder

extension XMLEncoder: ContentEncoder {
    public func encode<E: Encodable>(
        _ encodable: E,
        to body: inout ByteBuffer,
        headers: inout HTTPHeaders
    ) throws {
        headers.contentType = .xml
        
        // Note: You can provide an XMLHeader or DocType if necessary
        let data = try self.encode(encodable)
        body.writeData(data)
    }
}

extension XMLDecoder: ContentDecoder {
    
    public func decode<D>(_ decodable: D.Type, from body: NIOCore.ByteBuffer, headers: NIOHTTP1.HTTPHeaders) throws -> D where D : Decodable {
        var b = body
        let d = b.readData(length: b.readableBytes)!
        return try self.decode(D.self, from: d)
    }
}
