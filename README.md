Introduction to Ruby Metaprogramming
====================================

I've often heard that if you aren't using the metaprogramming
capabilities in Ruby, there's no point in using Ruby to begin with. I
don't know if I necessarily agree with that, but metaprogramming in Ruby
*is* a very powerful tool that can lead to idiomatic Ruby. For Rails
 developers, even if you haven't directly used Ruby metaprogramming,
you've reaped the benefits by using Rails.

This workshop was prepared by [Christopher
Lee](http://github.com/christopherslee) for [Boston.rb Project
Night](http://bostonrb.org).

Credits
-------
If you're interested in learning more about Ruby Metaprogramming, I
recommend: [Metaprogramming Ruby: Program Like the Ruby Pros](http://amzn.to/ZvYh2Q) (amazon affiliate link)

Workshop Goals
==============

* Give you a hands on introduction to ruby metaprogramming
* Walk through different metaprogramming techniques using ``send``,
``define_method``, and ``method_missing``
* Expand your mind to Metaprogramming and get you thinking about where
you can leverage it in your own code

Setup
=====

Requirements
------------

The workshop was created with Ruby 1.9.3, but should work with most ruby
versions. There's an assumption that you have at least a basic
understanding of Ruby programming.

Clone the git repo:

    $ git clone git@github.com:christopherslee/intro_to_metaprogramming.git
    $ cd intro_to_metaprogramming

RVM (optional):

    $ rvm use --create 1.9.3@intro_to_metaprogramming

Install Gems (assuming you have bundler):

    $ bundle install

Run specs (you should see a bunch of failures):

    $ rspec

    Finished in 0.00112 seconds
    5 examples, 5 failures

    Failed examples:

    rspec ./spec/customer_spec.rb:9 # Customer#initialize stores an id and a datasource
    rspec ./spec/customer_spec.rb:16 # Customer#first gets the first name of a customer
    rspec ./spec/customer_spec.rb:22 # Customer#last gets the last name of a customer
    rspec ./spec/customer_spec.rb:28 # Customer#email gets the email address of a customer
    rspec ./spec/customer_spec.rb:34 # Customer#age gets the age of a customer

Lesson 1: Plain old Ruby
========================

Our workshop will start with developing a ruby class ``Customer``
that interacts with our very own special, read-only, in-memory database. Our
``CustomerDatastore`` contains customer data for fields 'first', 'last',
'email', and 'age'. For each of these fields there is a matching method
to query for the value and the datatype, (ex: ``get_email_value``,
``get_email_datatype``)

To help guide us along, there is a set of specs that we want to make
pass. When they go green, we know we have completed the lesson. To test
that we are setup correctly, run the following command to run rspec and
see all our red tests. For convenience I've included a .rpsec
configuration that uses the document formatter and colors the output red
or green. To run the specs, simply run the rspec command from the root
of the project.

*Note:* ideally, you don't have to understand rspec too much to get
through this workshop.

About the project
-----------------

```
+ lib/
  - customer.rb                   # your code goes here
  - customer_datasource.rb        # an imaginary database
+ spec/
  - customer_datasource_spec.rb   # customer datasource tests
  - customer_spec.rb              # customer tests
- Gemfile
- Gemfile.lock
- README.md                       # this file
```

Problem 1
---------

Define a ``Customer`` class.

* It has an initializer that takes an ``id``, and a ``datasource``
* This class has methods ``first``, ``last``, ``email``, and ``age``
that query the datastore for the value. Each method returns the
capitalized name of the field, and the value of the field. If the value
is a string, it encloses the value in single quotes.

Example:

    > customer.first
    First: 'Yokohiro'

    > customer.age
    Age: 48

You'll know when you are finished when all your tests are green! I know
that it's a little bit wacky to check if the datatype is a string, but
just pretend that you need to check it for the purposes of the workshop.

*Note:* This isn't metaprogramming, but you may have written boilerplate
 getters and setters like this before.

Lesson 2: Dynamic Dispatch
==========================

Great, we finished Lesson 1, which was mostly just making sure you're
all setup properly for the real lessons. You probably are also slightly
peeved at the reptitive nature of the code in the ``Customer`` class.
Good! That was part of the point!

Sending Messages Programatically
--------------------------------

You may recall that invoking methods in Ruby sends messages to objects to
query and manipulate them. Convenientely ``Object`` has a ``send`` method
we can use to send a message dynamically at runtime.

    class Echo
      def message(str)
        str
      end
    end

    > puts Echo.new.send 'message', "hi mom!"
    hi mom!

``Send`` allows you to invoke *any* method on an object, both public and
private. Using it to invoke private methods should be used with caution,
after all, the author must have made the private for some reason, right?
In Ruby 1.9.1 and above, there is a ``public_send`` method that
appropriately respects private methods.

Problem 2
---------

Let's DRY up our ``Customer`` class by using ``send``. Define a method
``field`` that takes a single argument ``fieldname``. Use this fieldname to
dynamically get the value and datatype, returning the appropriate result.
As your refactor, your tests should still be green!

*Hint:* The first arguement to ``send`` is just a string. How can you
 use a string to dynamically determine where to send your message?

Lesson 3: Code that writes Code
===============================

Wow, this is starting to feel a lot better, if we had to add new fields,
we could crank them out pretty quickly. We've done a great job cleaning
up our code, but now we have all these methods that just delegate to another
method. A powerful technique with Ruby metaprogramming is code that writes
code. We can use ``define_method`` to define a new method on a class.

Define Method
-------------

``define_method`` takes an argument and a block. We haven't covered
blocks in this workshop, but for now let's just assume it executes the
code we give it like so:

    class Post
      attr_reader :state

      def self.has_state(name)
        define_method name do
          @state = name
        end
      end

      has_state :success
      has_state :failure
      has_state :error
    end

    > post = Post.new
    > post.success
    > puts post.state
    success

    > post.error
    > puts post.state
    error

Problem 3
---------

Remove all our manually defined methods ``first``, ``last``, ``email``,
and ``age`` from the ``Customer`` class. Instead, use ``define_method`` to
create ourselves a handy ``has_field`` method (Does this start to remind you
of anything in Rails?) This method will use ``define_method`` to replace
the getter methods we deleted.

You'll know when to stop when your tests are all green.

*Hints:* The interpretter reads top down. Also thinking about when and where
 ``has_field`` is invoked may help you avoid an ``undefined method``
error.

Lesson 4: Interrogating Ruby
============================

Now we have code that writes code, and that's pretty cool. Our
schemaless datasource could change; wouldn't it be cooler if we automatically
created methods based on the functionality the datasource provides us? We can!

Fire up your favorite ruby interpreter (irb/pry). Try out the following:

    > require './lib/customer'
    > Customer.methods
    > Customer.methods(false)
    > Customer.public_methods
    > Customer.public_methods(false)
    > Customer.ancestors

There are many methods for introspecting Ruby classes. They can be very
useful when debugging strange problems. In our case, we want to use them
to interrogate our datasource. To learn more about then, look at the
``Object`` and ``Basic Object`` classes in the [Ruby API
docs](http://ruby-doc.org/core-2.0/).

Problem 4
---------

Change the ``Customer`` class to introspect the datasource upon
initialization and dynamically define our fields.

*Hint:* You can use the ``grep`` method to get the methods you want.
Visit the gist below to get a useful regex if you don't want to write
one yourself. This isn't a class on regular expressions, but can still
be fun to try to work through it yourself.

[View gist](https://gist.github.com/christopherslee/5521968)

Lesson 5: Ghost Methods
=======================

Very cool! Our customer class is getting shorter and shorter. Try doing that
in Java!

Method Missing
--------------

Now we've all seen errors like this before:

    NoMethodError: undefined method ‘bar’ for #<Foo:0x3c848>

In this example, we're trying to send a message ``bar`` to an instance
of ``Foo``. Skipping some details, when we call a method that doesn't
exist on an object, Ruby invokes ``method_missing`` on that object. By
default, ``method_missing`` raises ``NoMethodError``.

Just like you'd expect, we can override ``method_missing`` for our own
purposes by redefining it in our class. It takes two arguments, the
method name, and a splat.

    class Customer
      def method_missing(name, *args, &block)
        super
      end
    end

Two things to watch out for here. You generally want to invoke the
default behavior of ``method_missing`` somewhere to get the standard
behavior. You also want to be careful not to get into an infinite loop!

Problem 5
---------

Refactor your ``Customer`` class to use ``method_missing`` instead of
``define_method``.

*Hint:* Do you want all methods to delegate to the datasource? Try using
 ``respond_to?`` to make sure we don't inundate our datasource with
bogus messages.

Lesson 6: Now your methods are not really methods
=================================================

Maybe we've gotten a little too clever for our own good. Open up irb or
pry and take a look at your ``Customer`` class.

    > require './lib/customer'
    > require './lib/customer_datasource'
    > c = Customer.new :one, CustomerDatasource.new
    > c.respond_to? :first
    false

Huh? Our computer class doesn't have the methods we expect to see on it. Even
though we can invoke our component methods dynamically, they aren't
available for introspection. This is a tradeoff we have to keep in mind
when using ``method_missing``, although we could override ``respond_to?`` as well.

Problem 6
---------

Override ``respond_to?`` to return the methods that ``method_missing``
handles for us.

*Hint:* Just like ``method_missing`` we probably want to invoke the
 default behavior with a call to ``super`` if we don't match the case we
are specifically adding.

Conclusion
==========

I hope that this gave you a feel for what can be accomplished with Ruby
Metaprogramming. Metaprogramming is a powerful tool that contributes to
Ruby's goal of optimizing for developer happiness. How far can you take
these examples? Maybe you can identify places in your code that you can
DRY up with these techniques, maybe you will create the replacement
ActiveRecord.

Sample Answers
--------------

I'm sure there are many ways to solve the problems presented in this
workshop, but for those who might get a little stuck, here are some
answers to the problems:

* [Problem 1](https://gist.github.com/christopherslee/5521596)
* [Problem 2](https://gist.github.com/christopherslee/5521664)
* [Problem 3](https://gist.github.com/christopherslee/5521697)
* [Problem 4](https://gist.github.com/christopherslee/5521757)
* [Problem 5](https://gist.github.com/christopherslee/5521810)
* [Problem 6](https://gist.github.com/christopherslee/5521813)

About the Author
================

I am currently a Lead Engineer at Jana Mobile.  I was formerly a Team Lead
at ConstantContact, where I also lead the Ruby on Rails best practice
group. I was the CTO and co-founder (is the CTO of a 2
person startup _really_ a CTO?) of MobManager.com, which was acquired by
Constant Contact in 2011.

I have a B.S. Computer Science from the University of Illinois at
Urbana-Champaign, an M.S. Software Engineering w/distinction from DePaul
University, and am an alumnus of Northwestern's Kellogg School of
Management.

As a personal note, I used Rails quite successfully for at least 6 years
without using metaprogramming myself. You don't *have* to know it, but I can
say that once I was exposed to it, it opened my eyes and added another
tool to my development arsenal.

Ruby and Rails have created a lot of opportunity for me, and I thought
this workshop would be one way I could give back to the community. I am
not a professional trainer or instructor, but I would value your
feedback on how I could improve my delivery, or the material itself.

Email Me: christopher (dot) s (dot) lee (at) gmail (dot) com
