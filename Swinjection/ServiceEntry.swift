//
//  ServiceEntry.swift
//  Swinjection
//
//  Created by Sasha on 26.06.22.
//

public class ServiceEntry {
     let service: Any?
     let factory: ((Resolver) -> Any)?
     let scope: ObjectScope
     var isResolving: Bool

     init(
             service: Any?,
             scope: ObjectScope,
             _ factory: ((Resolver) -> Any)?
     ) {
         self.service = service
         self.scope = scope
         self.factory = factory
         self.isResolving = false
     }
 }
