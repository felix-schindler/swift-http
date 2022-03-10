//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 10..
//

import Foundation
import SwiftHttp

struct PostsApi: JsonCodablePipelineCollection {
    
    var encoder: JSONEncoder = { .init() }()
    var decoder: JSONDecoder = { .init() }()
    
    let client: HttpClient = UrlSessionHttpClient(log: true)
    let apiBaseUrl = HttpUrl(host: "jsonplaceholder.typicode.com")
    
    func listPosts() async throws -> [Post] {
        try await decodable(executor: client.request,
                            url: apiBaseUrl.path("posts"),
                            method: .get)
    }
    
    func getPost(_ id: Int) async throws -> Post {
        try await decodable(executor: client.request,
                            url: apiBaseUrl.path("posts", String(id)),
                            method: .get)
    }
    
    func createPost(_ post: Post) async throws -> Post {
        try await codable(executor: client.request,
                          url: apiBaseUrl.path("posts"),
                          method: .post,
                          body: post)
    }
    
    func updatePost(_ id: Int, _ post: Post.Update) async throws -> Post {
        try await codable(executor: client.request,
                          url: apiBaseUrl.path("posts", String(id)),
                          method: .put,
                          body: post)
    }
    
    func patchPost(_ id: Int, _ post: Post.Update) async throws -> Post {
        try await codable(executor: client.request,
                          url: apiBaseUrl.path("posts", String(id)),
                          method: .put,
                          body: post)
    }
    
    func deletePost(_ id: Int) async throws -> HttpResponse {
        try await data(executor: client.request,
                       url: apiBaseUrl.path("posts", String(id)),
                       method: .delete)
    }
}
