//
//  Swinjection.swift
//  Swinjection
//
//  Created by Sasha on 26.06.22.
//

public protocol ServiceLocatorProtocol {
     func register<T>(
             service: T.Type,
             scope: ObjectScope,
             _ factory: @escaping (Resolver) -> T
     )
 }

 public protocol Resolver {
     func resolve<T>() throws -> T?
 }

 public enum ResolveError: Error {
     case noSuchServiceRegistered
     case unexpectedBehaviour
     case cyclicDependency
 }

 public class ServiceLocator: ServiceLocatorProtocol {
     public static let shared = ServiceLocator()

     private lazy var services = [String: ServiceEntry]()

     private init() {}

     public func register<T>(
             service: T.Type,
             scope: ObjectScope,
             _ factory: @escaping (Resolver) -> T
     ) {
         let serviceType = typeName(service)
         if (services.keys.contains(serviceType)) {
             return
         }
         switch (scope) {
         case .singleton:
             let service = ServiceEntry(
                 service: factory(self),
                 scope: scope,
                 nil
             )
             services[serviceType] = service
         case .transient:
             let service = ServiceEntry(
                 service: nil,
                 scope: scope,
                 factory
             )
             services[serviceType] = service
         }
     }

     private func typeName(
             _ any: Any
     ) -> String {
         (any is Any.Type) ? "\(any)" : "\(type(of: any))"
     }
 }

 extension ServiceLocator: Resolver {
     public func resolve<T>() throws -> T {
         let serviceType = typeName(T.self)
         guard let serviceEntry = services[serviceType] else {
             throw ResolveError.noSuchServiceRegistered
         }
         if (serviceEntry.isResolving) {
             throw ResolveError.cyclicDependency
         }
         serviceEntry.isResolving = true
         switch (serviceEntry.scope) {
         case .singleton:
             let service = serviceEntry.service as! T
             serviceEntry.isResolving = false
             return service
         case .transient:
             let service = serviceEntry.factory!(self) as! T
             serviceEntry.isResolving = false
             return service
         }
     }
 }
