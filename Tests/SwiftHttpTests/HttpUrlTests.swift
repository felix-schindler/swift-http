//
//  HttpUrlTests.swift
//  SwiftHttpTests
//
//  Created by Tibor Bodecs on 2022. 03. 13..
//

import XCTest
@testable import SwiftHttp

final class HttpUrlTests: XCTestCase {
        
    func testPaths() async throws {
        let baseUrl = HttpUrl(host: "jsonplaceholder.typicode.com")
        
        let todosUrl = baseUrl.path("todos")
        XCTAssertEqual(todosUrl.url.absoluteString, "https://jsonplaceholder.typicode.com/todos")
        
        let sitemapUrl = baseUrl.path("todos").resource("sitemap.xml")
        XCTAssertEqual(sitemapUrl.url.absoluteString, "https://jsonplaceholder.typicode.com/todos/sitemap.xml")

        let query1Url = baseUrl.path("todos").query("foo", "bar")
        XCTAssertEqual(query1Url.url.absoluteString, "https://jsonplaceholder.typicode.com/todos?foo=bar")
        
        let todoUrl = baseUrl.path("todos", String(1))
        XCTAssertEqual(todoUrl.url.absoluteString, "https://jsonplaceholder.typicode.com/todos/1")
        
        let query2Url = baseUrl.path("todos").query([
            "foo": "1",
        ])
        XCTAssertEqual(query2Url.url.absoluteString, "https://jsonplaceholder.typicode.com/todos?foo=1")
    }
    
    func testEncoding() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/some%2Ffile%2Fpath.xml")
        XCTAssertEqual(url?.absoluteString, "https://jsonplaceholder.typicode.com/todos/some%2Ffile%2Fpath.xml")
        
        // let httpUrl = HttpUrl(url: url!)
        // XCTAssertEqual(httpUrl?.url.absoluteString, "https://jsonplaceholder.typicode.com/todos/some%2Ffile%2Fpath.xml")

        let resourceUrl = HttpUrl(host: "jsonplaceholder.typicode.com").path("todos").resource("some/file/path.xml")
        XCTAssertEqual(resourceUrl.url.absoluteString, "https://jsonplaceholder.typicode.com/todos/some%2Ffile%2Fpath.xml")
    }
}

