LlamaKit
========

Collection of must-have functional tools. Trying to be as lightweight as possible, hopefully providing a simple foundation that
more advanced systems can build on. LlamaKit is very Cocoa-focused. It is designed to work with common Cocoa paradigms, use names
that are understandable to Cocoa devs, integrate with Cocoa tools like GCD, and in general strive for a low-to-modest learning
curve for devs familiar with ObjC and Swift rather than Haskell and ML. There are more functionally beautiful toolkits out there
(see [Swiftz](https://github.com/maxpow4h/swiftz) and [Swift-Extras](https://github.com/CodaFi/Swift-Extras) for some nice
examples). LlamaKit intentionally is much less full-featured, and is focused only on things that come up commonly in Cocoa
development. (Within those restrictions, it hopes to be based as much as possible on the lessons of other FP languages, and I
welcome input from folks with deeper FP experience.)

Currently has a `Result` object, which is the most critical. (And in the end, it may be the *only* thing in the main module.)
`Result` is mostly done except for documentation (in progress). Tests are built.

`Future` is in progress. It's heavily inspired by [Scala's approach](http://docs.scala-lang.org/overviews/core/futures.html),
though there are some small differences. I haven't decided if a `Promise` ISA `Future` or HASA `Future`. The Scala approach
is a weird hybrid. It technically HASA `Future`, but in the main implementation, the `Promise` is its own `Future`, so it's
kind of ISA, too. Still a work in progress there. I'm considering pulling `Future` out; it already makes this module too
complicated (did I mention that LlamaKit wants to be really, really simple?)

LlamaKit should be considered highly experimental, pre-alpha, in development, I promise I will break you.

But the `Result` object is kind of nice already if you want to go ahead and use it. :D

Current Thinkings on Structure
==============================

(This is highly in progress and subject to change, like everything. Comments welcome.)

I want LlamaKit to provide several important tools to simplify functional composition. But LlamaKit doesn't intend to be a programming approach (vs. [ReactiveCocoa](https://github.com/ReactiveCocoa) or [TypeLift](https://github.com/typelift) which provide powerful ways to think about problems). LlamaKit is just a bag of tools. If you want to borrow my hammer, you don't have to take my circular saw, too. So LlamaKit is split up into several small frameworks so you can pick-and-choose.

<table>
<tr><td colspan=2 align="center">LlamaKit (umbrella)</td></tr>
<tr><td>LlamaFuture</td><td>Llama... (?)</td><td>LlamaOps</td></tr>
<tr><td colspan=3  align="center">LlamaCore</td></tr>
</table>

LlamaCore
: The absolute basics. If it's in LlamaCore, I believe that the majority of Swift developers should be using it. I think other libraries should bulid on top of it. I think Apple should put it into stdlib. This is the stuff that I worry *many* developers will reinvent, and that will cause collisions between code bases. LlamaCore strives to be incredibly non-impacting. It avoids creating top-level functions that might conflict with consuming code. It declares no new opeartors. The bar is very high to be in LlamaCore. It currently contains just two types: `Result` (which I think Apple should put into stdlib) and `Box` (which only exists because of Swift compiler limitations). In the ideal LlamaKit, LlamaCore would be empty.

LlamaFuture
: Concurrency primitives, most notably `Future`. In my current design, `Future` is actually stand-alone and doesn't require LlamaCore, but I think that most developers will want a failable `Future<Result>>` (which I am tentatively calling `Task`). I also expect this to hold `Promise`, which is a future that the caller manually completes. (This is still under very heavy consideration; I'm not sure exactly what I want yet.) LlamaFuture is tightly coupled to GCD, and is intended as a nicer interface to common Cocoa concurrency primitives, not a replacement for them.

LlamaOps
: Functional composition with operators like `>>=` and `|>` is a beautiful thing. But it carries with it a lot of overhead. Not only are there cognative loads (the code is not obvious at all to the uninitiated), there are non-trivial compiler and language impacts. Operators are declared globally (specifically precedence and associativity). The Swift compiler has some serious performance problems building code with complex operator usage. And in the case of operator conflict, the resulting errors are very confusing. Widely used libraries should strongly avoid bringing in new operators implicitly. My intention is that you would always have to import LlamaOps explicitly, even if you import the umbrella LlamaKit.

LlamaKit
: I do expect most of the things in LlamaKit to be useful to many, if not most, Cocoa devs. I don't want to force you to take everything, but I do want to make it easy to take everything (except operators). So hopefully I can provide an umbrella framework. I don't know if that actually works in Xcode, but we'll see.

Llama...
: At this point I'm not expecting a ton more stuff, but this is where it would go. While I'm evangelizing functional programming, I want most people to use Swift to achieve that, not lots of layers on top of Swift. So for instance, I'm not particularly sold on an `Either` right now. In most cases I'd rather you use an enum directly. And I don't want to create a full functor-applicative-monad hierarchy (TypeLift is covering that for us). I probabaly do want somewhere to put `sequence()`, `lift()`, `pure()`, and `flip()` and maybe that could become LlamaLambda (LlamaLamb? LlamaFunc?) But I want to go slow there and see what needs arrise in real projects.