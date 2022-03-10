//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 10..
//

import Foundation

public struct HttpEncodablePipeline<T: Encodable>: HttpRequestPipeline {
    
    let url: HttpUrl
    let method: HttpMethod
    let headers: [HttpHeaderKey: String]
    let body: T
    let validators: [HttpResponseValidator]
    let encoder: HttpRequestDataEncoder<T>
    
    public init(url: HttpUrl,
                method: HttpMethod,
                headers: [HttpHeaderKey: String] = [:],
                body: T,
                validators: [HttpResponseValidator] = [HttpStatusCodeValidator()],
                encoder: HttpRequestDataEncoder<T>) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.validators = validators
        self.encoder = encoder
    }
    
    
    public func execute(_ executor: ((HttpRequest) async throws -> HttpResponse)) async throws -> HttpResponse {
        let req = HttpDataRequest(url: url,
                                  method: method,
                                  headers: headers.merging(encoder.headers) { $1 },
                                  body: try encoder.encode(body))
        
        let response = try await executor(req)
        let validation = HttpResponseValidation(validators)
        try validation.validate(response)
        return response
    }
}
