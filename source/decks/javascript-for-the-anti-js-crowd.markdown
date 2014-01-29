---
title: JavaScript for the anti-JS crowd
---

JavaScript for the anti-JS crowd
================================

***

# Let's get this out of the way first:
## What is JavaScript *bad* at?

***

# That's easy...

```javascript
[5, 1, 10].sort();
// => [1, 10, 5]

{} + [];
// => 0

+((!+[]+!![]+!![]+!![]+[])+(!+[]+!![]+[]));
// => 42
```

(Yes, that last one is for real.)

***

# So we're playing that game?
## OK then, what is *Java* bad at?

***

# How about conciseness?

```java
// GUESS WHAT TYPE, COMPILER?
Object object = new Object();

// Java: "Hey, I can do functional programming too!"
List<String> recordIds = Lists.transform(records, new Function<Record, String> {
  @Override
  public String apply(Record record) {
    return record.getRecordId();
  }
});
```

***

# How about conciseness?

Incidentally, here's that second snippet in JavaScript:

```javascript
var recordIds = records.map(function(record) {
  return record.recordId;
});
```

Or better yet:

```javascript
var recordIds = records.pluck('recordId');
```

*That's cheating! How would you implement `pluck`?*

It's *really* complicated...

```javascript
function pluck(collection, property) {
  return collection.map(function(item) {
    return item[property];
  });
}
```

***

# Who cares about what a tool is *bad* at?

- Tools generally have an intended purpose
- Java prioritizes *safety*
- JavaScript prioritizes *productivity*

***

# The value of static typing

Statically typed languages help us avoid silly bugs.

```java
private Customer getCustomer(int customerId) {
  // logic to get customer
}

getCustomer('1'); // Whoops! Compile error! Thanks, Java!
```

***

# The cost of static typing

This safety comes at a cost. To illustrate let's write some code for a service.

We'll consider these approaches:

- Use maps and lists for everything
- Write a POJO class for every type in the domain
- Generate client libraries using a framework (e.g. protocol buffers)
- Write wrappers around client libraries for additional functionality

***

# Use maps and lists for everything

This is a "bad" approach.

```java
public Map<String, Object> getCustomer(int customerId) {
  Map<String, Object> customer = Maps.newHashMap();
  customer.put("id", 1);
  customer.put("name", "joe");
  customer.put("real_name", "Joe Schmoe");
  customer.put("email_address", "joe.schmoe@example.com");
  return customer;
}
```

Ugly, right?

Plus, we have nowhere to put business logic.

***

# Write a POJO class for every type in the domain

```java
class Customer {
  private String name;

  public String getName() {
    return this.name;
  }

  public void setName(String name) {
    this.name = name;
  }

  // etc., etc.
}
```

I guess this is better?

At least we have type checking on the customer's properties now. Also, we can
add business logic to this class.

But that's a lot of boilerplate. Also, for serializing we may want to convert
this to a map anyway...

Yeah, for certain formats would could just use a library (e.g., Gson for JSON).
But then that's another dependency. But oh well.

***

# Generate client libraries using a framework

This is great! This way we'll have code generated *for* us, saving on
boilerplate!

Right?

Oh wait...

```protobuf
message CustomerInfoPB {
  optional int64 id = 1;
  optional string name = 2;
  optional string real_name = 3;
  optional string email_address = 3;
}
```

Plus this puts us back where we were with nowhere to put business logic (since
we can't modify the generated `CustomerInfoPB` class).

***

# Write wrappers around client libraries for additional functionality

Ah, *this* is the holy grail. We get serialization support through the
auto-generated client library, and we can add business logic to our wrapper
classes.

```java
class Customer {
  private CustomerInfoPB info;

  public Customer(CustomerInfoPB) {
    this.info = info;
  }

  public CustomerInfoPB getInfo() {
    return this.info;
  }

  // business logic goes here!
}
```

**Notice that as the solution gets "better" we have more and more code and more
dependencies.**

***

# The value of dynamic typing

```javascript
var service = {
  getCustomer: function() {
    return {
      id: 1,
      name: 'joe',
      real_name: 'Joe Schmoe',
      email_address: 'joe@example.com'
    };
  }
};

// Look ma, no classes!
var customer = service.getCustomer();
customer.name; // => 'joe'
```

Easy to read, easy to serialize, easy to add business logic.

***

# The cost of dynamic typing

```javascript
var service = {
  getCustomer: function(id) {
    return customers[id];
  }
};

// Oh right, forgot to pass in id...
service.getCustomer(); // => undefined
```

We can make silly mistakes again. The horror!

***

# It isn't black and white is all I'm saying
## There are trade-offs involved here

***

# OK, let's get into the basics

***

# JavaScript is not Java

1. Every object is a map
  - And all keys are strings
  - And everything is an object

2. Prototypes, not classes
  - Good for hacking
  - Good for testing
  - "Bad" for encapsulation

3. Functions are the only way to introduce scope
  - Closures
  - The most common mistake
  - IIFEs

4. All the code you write runs on one thread
  - The event loop
  - Concurrent vs. asynchronous programming

5. Binding functions to objects
  - Avoid `this` when you're starting out
  - The `new` keyword
  - `call` and `apply`

***

# 1. Every object is a map

```javascript
var object = { foo: 1 };

object.foo    // => 1
object['foo'] // => 1

object.bar = function() { return 2; };

typeof object.bar; // 'function'
object.bar();      // => 2
object['bar']();   // => 2
```

Every property access is a lookup. Dot (`object.foo`) and bracket notation
(`object['foo']`) are identical.

***

# 1a. ...and all keys are strings

"You can't use an object as a key in a JavaScript map!"

```javascript
var object = {},
    k1     = {},
    k2     = {};

object[k1] = 'foo';
object[k2] = 'bar';

JSON.stringify(object); // => '{"[object Object]":"bar"}'
```

Keys are coerced to strings. So everything is like a `Map<String, Object>`.

This keeps things simple.

***

# 1a. ...and all keys are strings

If you want to see the keys of an object use `Object.keys`.

```javascript
var k1 = {},
    k2 = {};

var object = {
  foo: 1,
  bar: 2
};

Object.keys(object); // => ['foo', 'bar']
```

***

# 1b. ...and everything is an object

```javascript
var array = [1, 2, 3];

array[0];        // => 1
array.length;    // => 3
array['0'];      // => 1
array['length']; // => 3
```

That's right, even arrays are objects. Which means they're just maps.

```javascript
Object.keys(array); // => ['0', '1', '2']
```

*Oh no, how inefficient!*

Let's not get ahead of ourselves.

I'll talk about performance in a moment.

By the way, functions are objects too.

```javascript
function foo() {}

foo.name;    // => 'foo'
foo['name']; // => 'foo'
```

***

# 2. Prototypes, not classes

JavaScript doesn't have classes. It isn't object-oriented. It's *prototypal*.

What does this mean? Objects inherit from other objects.

```javascript
// This is called a constructor function.
function Customer(name) {
  if (name) { this.name = name; }
}

// Notice: this is just an ordinary object...
var DefaultCustomer = {
  name: 'Name unavailable',
  real_name: 'Real name unavailable'
};

// ...and yet we're inheriting from it.
Customer.prototype = DefaultCustomer;

var joe = new Customer('joe');

joe.name;      // => 'joe'
joe.real_name; // => 'Real name unavailable';
```

***

# 2a. Good for hacking

Remember:

1. Objects "inherit" from other objects (prototypes)
2. You can modify any object

So...

```javascript
String.prototype.shout = function() {
  return this + '!';
};

'foo'.shout(); // => 'foo!'
```

Yes, you can modify built-in objects by changing their prototypes.

***

# 2b. Good for testing

Dependency injection in Java:

```java
public String foo(BaseClass dependency) {
  return dependency.getBar();
}

class TestBaseClass extends BaseClass {
  // UGH
}
```

With Java we need to explicitly accept dependencies in our code.

Most of the time, this is just so that we can develop + test.

***

# 2b. Good for testing

Dependency injection in JavaScript:

```javascript
// We don't necessarily need to accept explicit dependencies.
// This allows us to keep our interface cleaner, if we want.
function doSomething() {
  return new Dependency().bar;
}

// In a test somewhere...
Dependency.prototype.bar = 'blah';

doSomething().should.eql('blah');
```

Oh yeah, and we were able to put that `should` method there because
`Object.prototype` is exposed, just like everything else.

***

# 2b. Good for testing

*But implicit dependencies are bad!* I hear you saying. Well, maybe. It's a
trade-off: interface "noise" in exchange for explicitness.

Here's the good news: we could also accept an explicit dependency in JavaScript
and still have a lot less code to write than in Java:

```javascript
function doSomething(dependency) {
  return dependency.bar;
}

// In a test somewhere...
doSomething({ bar: 'blah' }).should.eql('blah');
```

***

# 2c. "Bad" for encapsulation

There are no access modifiers (`private`, `protected`, etc.) in JavaScript.

The common idiom is to use some sort of naming convention to distinguish
"private" from "public" parts of an interface.

```javascript
// "public"
Customer.prototype.fullName = function() {
  return this.firstName + ' ' + this.lastName;
};

// "private" (but not really)
Customer.prototype._dump = function() {
  console.dir(this);
};
```

***

# 2c. "Bad" for encapsulation?

...but in fact, in JavaScript you can make something *truly* private if you
want. I.e., there is no way to access it (unlike in Java, where you could always
use reflection).

```javascript
// Here the Customer function creates a closure, which captures the local 'name'
// variable and offers no mechanism for accessing it outside this scope.
function Customer(name) {
  this.getName = function() {
    return name;
  };
};
```

Don't worry; I'm about to talk about closures!

***

# 3. Functions are the only way to introduce scope

In Java you might write something like this.

```java
for (int i = 1; i <= 10; i++) {
  String foo = "blah-" + i;
}

String bar = foo; // compile error: 'foo cannot be resolved to a variable'
```

The `for` loop above introduces lexical scope. The `foo` variable is defined
within the loop, and is not visible outside it.

In JavaScript, not so:

```javascript
for (var i = 0; i < 10; i++) {
  var foo = 'blah-' + i;
}

// foo is visible outside the loop!
var bar = foo; // => 'blah-10'
```

The `for` keyword does not introduce scope in JavaScript. Neither do `do`,
`while`, `try`, etc.

The **only** way to introduce scope in JavaScript (pre-ES6) is to declare a
function.

***

# 3a. Closures

A *closure* is a function that "closes over" variables potentially declared in
an external scope.

```javascript
var counter = 1;

var increment = function() {
  return counter++;
};

increment();     // => 1
increment();     // => 2
var x = counter; // => 3
```

The `counter` variable is *closed over* by the `increment` function in the above
example.

***

# 3b. The most common mistake

```javascript
for (var i = 0; i < 3; i++) {
  // The setTimeout function executes some code
  // after the specified number of milliseconds
  setTimeout(function() {
    console.log('testing: ' + i);
  }, 10);
}
```

The above outputs:

    3
    3
    3

Why?

***

# 3b. The most common mistake

Remember: *the `for` keyword does not introduce scope*. Which means:

```javascript
var closures = [];

for (var i = 0; i < 3; i++) {
  closures.push(function() {
    return i;
  });
}

// All closures have closed over the same i variable,
// which now has a value of 3.
closures[0](); // => 3
closures[1](); // => 3
closures[2](); // => 3
```

***

# 3b. The most common mistake

The solution: **create** a new scope using a function.

```javascript
var closures = [];

for (var i = 0; i < 3; i++) {
  (function(x) {
    closures.push(function() {
      return x;
    });
  }(i));
}

// Each closure closed over a different variable x
closures[0](); // => 0
closures[1](); // => 1
closures[2](); // => 2
```

***

# 3c. IIFEs

Wait, what was that thing we just saw?

```javascript
(function(x) {

  // Whatever i was externally, at the moment this function was defined,
  // has been assigned to our very own x variable internally.

}(i));
```

This is called an **IIFE**: an *immediately executed function expression*.

It is an idiomatic way of introducing scope in JavaScript.

No big deal.

***

# 4. All the code you write runs on one thread

You may have heard, "JavaScript is single-threaded."

You may have thought, "So it isn't suitable for high-performance scenarios."

That would be wrong.

***

# 4. All the code you **write** runs on one thread

First of all, this **doesn't** mean "no way to parallelize work." It **does**
mean "no concurrency bugs."

```javascript
if (!this.instance) {
  this.instance = new Whatever();
}
```

The above code does not contain a race condition. It will always work the way
you expect.

***

# 4a. The event loop

![The event loop](http://misclassblog.com/wp-content/uploads/2013/04/event-loop.jpg)

All the code you write get executed as part of the event loop.

When you call `setTimeout`, it places an event on the queue.

When you make a network request, the response adds an event to the queue.

Your code doesn't need to think about synchronizing anything.

***

# 4b. Concurrent vs. asynchronous programming

How often do you think the CPU is the bottleneck in a software application?

![The CPU is never the bottleneck](http://misclassblog.com/wp-content/uploads/2013/04/IO-Chart2.jpg)

... basically never.

***

# 4b. Concurrent vs. asynchronous programming

So in Java (and many other languages) we have *threads*. This lets us write
synchronous (blocking) functions that wait a long time.

```java
// This might block for a while...
DbResult result = queryDbForResult();

// ...so this could happen much later.
return renderHtmlResponse(result);
```

***

# 4b. Concurrent vs. asynchronous programming

The alternative would be kinda gross:

```java
queryDbForResult(new DbResultToHtmlRenderer(this.responseWriter));

// ...somewhere else in the code...
class DbResultToHtmlRenderer {
  private PrintWriter writer;

  public DbResultToHtmlRenderer(PrintWriter writer) {
    this.writer = writer;
  }

  public void handleDbResult(DbResult result) {
    String htmlResponse = renderHtmlResponse(result);
    writer.write(htmlResponse);
  }

  // ...
}
```

***

# 4b. Concurrent vs. asynchronous programming

Pretty bad, right? Let's look at something similar in JavaScript:

```javascript
queryDbForResult(function(result) {
  writer.renderHtmlResponse(result);
});
```

In the JavaScript world, asynchronous operations are handled with *callbacks*.
This is the idiomatic way to do it, and it's not hard. And it doesn't require
any concurrency mechanisms.

> When all you have are threads, everything starts to look like a concurrency
> problem.  
> -me

***

# 4b. Concurrent vs. asynchronous programming

Why create a thread whose primary responsibility is to *wait* for something?

![Using threads to wait](http://www.projectation.com/wp-content/uploads/2012/11/square.peg_.round_.hole_.jpg)

Square peg, round hole.

***

# 5. Binding functions to objects

JavaScript binding is admittedly pretty weird.

- At some random point in your code, `this` actually refers to the *global
  object* (`window` in browser environments)
- When creating objects using the `new` keyword, `this` refers to the
  constructed object
- When calling methods while dereferencing, `this` refers to the parent object

***

# 5. Binding functions to objects

Normally, `this` is just the global object.

```html
<script>
  typeof this.alert;   // => 'function'
  typeof this.console; // => 'object'
</script>
```

...which means that if you modify `this`, you're screwing with global state.

```javascript
function setName(value) {
  this.name = value;
}

setName('foo');

window.name; // => 'foo'
```

***

# 5. Binding functions to objects

When you use the `new` keyword, then `this` refers to the object being
constructed.

```javascript
function Person(name) {
  this.name = name;
}

var p = new Person('Dan');

p.name;      // => 'Dan'
window.name; // => undefined
```

***

# 5. Binding functions to objects

However, if you *forget* the `new` keyword, then `this` is still the global
object.

```javascript
var p = Person('Dan');

p;           // => undefined (because Person doesn't return anything)
window.name; // => 'Dan'
```

***

# 5. Binding functions to objects

When you call a method while dereferencing it, `this` is the parent object.

```javascript
var parent = {
  foo: function() {
    return this.bar;
  },
  bar: 'blah'
};

parent.foo(); // => 'blah'
```

***

# 5. Binding functions to objects

But if you store a reference to a function in a variable and call it directly,
then it's *unbound*.

```javascript
var parent = {
  foo: function() {
    return this.bar;
  },
  bar: 'blah'
};

var foo = parent.foo;
foo(); // => undefined
```

***

# 5. Binding functions to objects

This means you can actually use `this` in a function where it doesn't make any
sense, but then attach it to an object so that it *does* make sense.

```javascript
var foo = function() {
  return this.bar;
};

foo(); // => undefined

var object = {
  bar: 'hello'
};

object.foo = foo;
object.foo(); // => 'hello'
```

***

# 5a. Avoid `this` when you're starting out

Honestly, it's kind of confusing, even to most seasoned JavaScript devs.

The best policy when you're still pretty new to JavaScript would be to just
avoid using `this` at all.

This is very easy, actually. For example:

```javascript
var parent = {
  foo: function() {
    return parent.bar;
  },
  bar: 'blah'
};

var foo = parent.foo;
foo(); // => 'blah'
```

***

# 5b. The `new` keyword

I already talked about this. But in case you care, there is a trick to ensure
that constructor functions are always used as constructors.

```javascript
function Person(name) {
  if (!(this instanceof Person)) {
    // Tsk tsk, somebody forgot to use the new keyword...
    return new Person(name);
  }

  // Now this definitely refers to the current Person object rather than
  // any global state.
  this.name = name;
}
```

It's a bit of a hack, yes. And again, you're probably better off (in the
beginning) avoiding `this` altogether.

***

# 5c. `call` and `apply`

You have some control over how `this` is bound within a function. The `call` and
`apply` methods both let you do this.

```javascript
function sumOwnValues() {
  var sum    = 0,
      values = this.values;

  for (var i = 0, len = values.length; i < len; ++i) {
    sum += values[i];
  }

  return sum;
}

var object = {
  values: [1, 2, 3]
};

sumOwnValues.call(object); // => 6
```

***

# 5c. `call` and `apply`

The `apply` function is particularly powerful. It takes an object to bind to
`this`, and an array of arguments, and then calls the source function with the
array passed as its parameters.

(The object can be `null`, if `this` isn't important.)

```javascript
function sum(x, y) {
  return x + y;
}

sum.apply(null, [1, 2]); // => 3
```

***

# 5c. `call` and `apply`

This lets us define function transformations that are completely agnostic of the
behavior they're modifying.

```javascript
function reverseArguments(fn) {
  return function() {
    Array.prototype.reverse.call(arguments);
    return fn.apply(this, arguments);
  };
}

function concat(str1, str2) {
  return str1 + str2;
}

reverseArguments(concat)('foo', 'bar'); // => 'barfoo';
```

***

# Questions?

I realize this is an abrupt ending, but I ran out of steam. We can obviously
always discuss JavaScript more later!
