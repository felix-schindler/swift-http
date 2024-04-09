//
//  UrlSessionHttpClient.swift
//  SwiftHttp
//
//  Created by Tibor Bodecs on 2022. 03. 10..
//

import Foundation
import Logging

/// Default URLSession based implementation of the HttpClient protocol
public struct UrlSessionHttpClient: HttpClient {

    private let loggerLabel = "com.binarybirds.swift-http"

    let session: URLSession
    let logger: Logger

    ///
    /// Initializes an instance of `HTTPClient` with the given session and logging level.
    ///
    /// - Parameter session: The `URLSession` instance to be used for network requests. Defaults to `.shared`.
    /// - Parameter logLevel: The `Logger.Level` to be used for logging. Defaults to `.critical`.
    ///
    /// - Returns: An instance of `HTTPClient`.
    ///
    public init(
        session: URLSession = .shared,
        logLevel: Logger.Level = .critical
    ) {
        var logger = Logger(label: loggerLabel)
        logger.logLevel = logLevel

        self.session = session
        self.logger = logger
    }

    ///
    /// Initialize a new client object
    ///
    /// - Parameter session: The URLSession instance, default: `.shared`
    /// - Parameter log: Is logging enabled for the client
    ///
    /// - Returns: An instance of `HTTPClient`.
    ///
    @_disfavoredOverload
    @available(*, deprecated, message: "Use init(session:logLevel:) instead.")
    public init(session: URLSession = .shared, log: Bool = false) {
        var logger = Logger(label: loggerLabel)
        logger.logLevel = log ? .info : .critical

        self.session = session
        self.logger = logger
    }

    ///
    /// Performs a data task (in memory) HTTP request
    ///
    /// - Parameter req: The request object
    ///
    /// - Throws: `HttpError` if something was wrong with the request
    ///
    /// - Returns: The entire HTTP response
    ///
    public func dataTask(_ req: HttpRequest) async throws -> HttpResponse {
        let urlRequest = req.urlRequest
        logger.info(.init(stringLiteral: urlRequest.curlString))

        // Type: (Data, URLResponse)
        let res = try await session.data(for: urlRequest)

        do {
            let rawResponse = try HttpRawResponse(res)
            logger.trace(.init(stringLiteral: rawResponse.traceLogValue))
            logger.debug(.init(stringLiteral: res.0.logValue))
            return rawResponse
        } catch {
            logger.debug(.init(stringLiteral: res.0.logValue))
            throw error
        }
    }

    ///
    /// Uploads the contents of the request and returns the response
    ///
    /// - Parameter req: The request object
    ///
    /// - Throws: `HttpError` if something was wrong with the request
    ///
    /// - Returns: The entire HTTP response
    ///
    public func uploadTask(_ req: HttpRequest) async throws -> HttpResponse {
        let urlRequest = req.urlRequest
        guard let data = urlRequest.httpBody else {
            throw HttpError.missingUploadData
        }

        logger.info(.init(stringLiteral: urlRequest.curlString))

        // Type: (Data, URLResponse)
        let res = try await session.upload(
            for: urlRequest,
            from: data,
            delegate: nil
        )

        do {
            let rawResponse = try HttpRawResponse(res)
            logger.trace(.init(stringLiteral: rawResponse.traceLogValue))
            logger.debug(.init(stringLiteral: res.0.logValue))
            return rawResponse
        } catch {
            logger.debug(.init(stringLiteral: res.0.logValue))
            throw error
        }
    }

    ///
    /// Downloads the contents of the request and returns the response
    ///
    /// - Parameter req: The request object
    ///
    /// - Throws: `HttpError` if something was wrong with the request
    ///
    /// - Returns: The entire response, setting the file location url as an encoded utf8 string as the response data
    ///
    public func downloadTask(_ req: HttpRequest) async throws -> HttpResponse {
        let urlRequest = req.urlRequest
        logger.info(.init(stringLiteral: urlRequest.curlString))

        // Type: (URL, URLResponse)
        let res = try await session.download(for: urlRequest, delegate: nil)

        guard let pathData = res.0.path.data(using: .utf8) else {
            throw HttpError.invalidResponse
        }

        do {
            let rawResponse = try HttpRawResponse((pathData, res.1))
            logger.trace(.init(stringLiteral: rawResponse.traceLogValue))
            logger.debug(.init(stringLiteral: res.0.absoluteString))
            return rawResponse
        }
        catch {
            logger.debug(.init(stringLiteral: res.0.absoluteString))
            throw error
        }
    }
}
