JavaScript for the anti-JS crowd
================================

***

# Let's get this out of the way first:
## What is JavaScript *bad* at?

***

# That's easy...

```javascript
[1, 10, 5].sort(); // => [1, 10, 5]

{} + []; // => 0

+((!+[]+!![]+!![]+!![]+[])+(!+[]+!![]+[])); // => 42
```

(Yes, that last one is for real.)

***

# So we're playing that game?
## OK then, what is *Java* bad at?

***

# How about type conciseness?

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

Let's write some client code to interact with a service.

- "Bad" approach: use maps and lists for everything
- Better?: write a POJO class for every type in the domain
- Even better?: generate client libraries using a framework (e.g. protocol buffers)
- Best?: write wrappers around client libraries for additional functionality

Notice we have to write more and more code...

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
console.log(customer.name); // => 'joe'
```

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

***

# It isn't black and white is all I'm saying
## There are trade-offs involved here
