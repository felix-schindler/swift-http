//
//  HttpUrl.swift
//  SwiftHttp
//
//  Created by Tibor Bodecs on 2022. 03. 09..
//

import Foundation

/// A wrapper to store and manipulate URLs in a safer way
public struct HttpUrl {

    /// Scheme of the url, e.g. https
    public var scheme: String

    /// Hostname of the url, e.g. www.localhost.com
    public var host: String

    /// Port of the url, e.g. 80
    public var port: Int

    /// Path components of the url, e.g. `/api/list = ["api", "list"]`
    public var path: [String]

    /// Resource part of the url after the path components, e.g. `sitemap.xml`
		/// This is being URL-encoded so you can't but any path in it. To do that, add a suffix
    public var resource: String?

    /// If you need some path behind your resource, use this!
    public var suffix: String?

    /// Query parameters, e.g. `?foo=bar`
    public var query: [String: String]

    /// Fragment of the url, e.g. `#foo`
    public var fragment: String?

    ///
    /// Initialize a HttpUrl object
    ///
    /// - Parameter scheme: The  scheme, default: `https`
    /// - Parameter host: The  host
    /// - Parameter port: The  port, default: `80`
    /// - Parameter path: The  path, default: `[]`
    /// - Parameter resource: The  resource, default: `nil`
    /// - Parameter query: The  query, default: `[:]`
    /// - Parameter fragment: The  fragment, default: `nil`
    ///
    public init(
        scheme: String = "https",
        host: String,
        port: Int = 80,
        path: [String] = [],
        resource: String? = nil,
		suffix: String? = nil,
        query: Dictionary<String, String> = [:],
        fragment: String? = nil
    ) {
        self.scheme = scheme
        self.host = host
        self.port = port
        self.path = path
        self.resource = resource
        self.suffix = suffix
        self.query = query
        self.fragment = fragment
    }
}

extension HttpUrl: Equatable {
}

extension HttpUrl: Hashable {
}

extension HttpUrl: Encodable {
}

extension HttpUrl: Decodable {
}

extension HttpUrl: CustomStringConvertible {

    public var description: String {
        url.description
    }
}

extension HttpUrl {

    ///
    /// Add new scheme to a given url
    ///
    /// - Parameter values: The scheme
    ///
    /// - Returns: A new HttpUrl object
    ///
    public func scheme(_ value: String) -> HttpUrl {
        var newUrl = self
        newUrl.scheme = value
        return newUrl
    }

    ///
    /// Add new path components to a given url
    ///
    /// - Parameter values: The path components
    ///
    /// - Returns: A new HttpUrl object
    ///
    public func path(_ values: String...) -> HttpUrl {
        var newUrl = self
        newUrl.path = path + values
        return newUrl
    }

    ///
    /// Add new path components to a given url
    ///
    /// - Parameter values: The path components
    ///
    /// - Returns: A new HttpUrl object
    ///
    public func path(_ values: [String]) -> HttpUrl {
        var newUrl = self
        newUrl.path = path + values
        return newUrl
    }

    ///
    /// Add new query parameter values to the url
    ///
    /// - Parameter query: The query values
    ///
    /// - Returns: A new HttpUrl object
    ///
    public func query(_ query: [String: String?]) -> HttpUrl {
        let finalQuery = query.compactMapValues { $0 }
        var newUrl = self
        newUrl.query = newUrl.query.merging(finalQuery) { $1 }
        return newUrl
    }

    ///
    /// Add a single query parameter value to the url
    ///
    /// - Parameter key: The key of the query param
    /// - Parameter value: The value of the query param
    ///
    /// - Returns: A new HttpUrl object
    ///
    public func query(_ key: String, _ value: String?) -> HttpUrl {
        query([key: value])
    }

    ///
    /// Add a new resource part to the url
    ///
    /// - Parameter resource: The resource path component
    ///
    /// - Returns: A new HttpUrl object
    ///
    public func resource(_ resource: String) -> HttpUrl {
        var newUrl = self
        newUrl.resource = resource
        return newUrl
    }

    ///
    /// Add a suffix part to the url
    /// - Parameter suffix: Suffix path component
    /// - Returns: A new HttpUrl object
    func suffix(_ suffix: String) -> HttpUrl {
        var newUrl = self
        newUrl.suffix = suffix
        return newUrl
    }

    ///
    /// Add a fragment to the url
    ///
    /// - Parameter fragment: The fragment value
    ///
    /// - Returns: A new HttpUrl object
    ///
    public func fragment(_ fragment: String) -> HttpUrl {
        var newUrl = self
        newUrl.fragment = fragment
        return newUrl
    }

    // MARK: - URL

    /// Returns the URL representation of the HttpUrl object
    public var url: URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        var path = "/" + path.joined(separator: "/")

        if let resource = resource?.url() {
            if (!resource.starts(with: "/")) {
                path += "/"
            }

            path += resource
        }

        if let suffix = suffix {
            path += suffix
        }

        components.percentEncodedPath = path
        components.fragment = fragment
        components.queryItems = query.map {
            .init(name: $0.key, value: $0.value)
        }
        if let items = components.queryItems, items.isEmpty {
            components.queryItems = nil
        }
        if components.port == 80 {
            components.port = nil
        }
        guard let url = components.url else {
            fatalError("Invalid URL components \(components)")
        }
        return url
    }
}

extension HttpUrl {

    /// Initialize a `HttpUrl` object with `string`
    ///
    /// Returns `nil` if a `HttpUrl` cannot be formed with the string (for example, if the string contains characters that are illegal in a URL, or is an empty string).
    public init?(string: String) {
        if let url = URL(string: string) {
            self.init(url: url)
        }
        else {
            return nil
        }
    }

    /// Initialize a `HttpUrl` object with `URL` object
    ///
    /// Returns `nil` if a `HttpUrl` cannot be formed with the `URL` (for example, if the string contains characters that are illegal in a URL, or is an empty string).
    public init?(url: URL) {
        guard let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true
        ) else { return nil }
        var path = components.percentEncodedPath
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .components(separatedBy: "/")
            .filter { !$0.isEmpty }
        let resource: String?
        if path.last?.contains(".") == true {
            resource = path.removeLast()
        } else {
            resource = nil
        }
        self.init(
            scheme: components.scheme ?? "https",
            host: components.host ?? "",
            port: components.port ?? 80,
            path: path,
            resource: resource,
            query: components.queryItems.map({
                Dictionary($0.map({ ($0.name, $0.value ?? "") })) { _, s in s }
            }) ?? [:],
            fragment: components.fragment
        )
    }
}

extension String {
    /// Url encode content
    func url() -> String {
        let new = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return new ?? self
    }
}
