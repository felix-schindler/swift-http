//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 10..
//

import Foundation


public struct HttpJsonPipeline<T: Encodable, U: Decodable>: HttpRequestPipeline {
    
    let url: HttpUrl
    let method: HttpMethod
    let headers: [String: String]
    let body: T
    let validators: [HttpResponseValidator]
    let encoder: HttpJsonRequestDataEncoder<T>
    let decoder: HttpJsonResponseDataDecoder<U>
    
    public init(url: HttpUrl,
         method: HttpMethod,
         headers: [String: String] = [:],
         body: T,
         validators: [HttpResponseValidator] = [HttpStatusCodeValidator()],
         encoder: HttpJsonRequestDataEncoder<T> = .init(),
         decoder: HttpJsonResponseDataDecoder<U> = .init()) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.validators = validators
        self.encoder = encoder
        self.decoder = decoder
    }
    
    public func execute(using client: HttpClient) async throws -> U {
        let req = HttpDataRequest(url: url,
                                  method: method,
                                  headers: headers,
                                  body: try encoder.encode(body))
            .header(.accept, "application/json")
            .header(.contentType, "application/json")

        let response = try await client.request(req)

        let validation = HttpResponseValidation(validators + [
            HttpHeaderValidator(.contentType) {
                $0.contains("application/json")
            },
        ])

        try validation.validate(response)

        return try decoder.decode(response.data)
    }
}


