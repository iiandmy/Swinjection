import Swinjection

let container = ServiceLocator.shared

class Foo {
    init() {}
}

class Bar {
     var x: Int
     let a: Foo

     init(x: Int, a: Foo) {
         self.x = x
         self.a = a
     }
}

class Baz {
     let a: Foo
     let b: Bar

     init(a: Foo, b: Bar) {
         self.a = a
         self.b = b
     }
}

enum TestError: Error {
    case injectionFailure
}

container.register(service: Foo.self, scope: .singleton) { _ in
    return Foo()
}
container.register(service: Bar.self, scope: .transient) { r in
    guard let a: Foo = try container.resolve() else { return Bar(a: Foo())}
    return Bar(x: 0, a: a)
}

guard let bar1: Bar = try container.resolve() else { throw TestError.injectionFailure }
guard let bar2: Bar = try container.resolve() else { throw TestError.injectionFailure }

// Prints 0
print(bar1.x)

// Change the x value of bar2, bar1.x still 0
bar2.x = 1

// Prints 0, because Bar is registered as Transient object
print(bar1.x)

// Prints 1
print(bar2.x)
