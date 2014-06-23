Celluloid Benchmark realistically load tests websites.

Write expressive, concise load tests in Ruby. Use [Rubinius](http://rubini.us) and [Celluloid](https://github.com/celluloid/celluloid)
for high concurrency. Use [Mechanize](http://mechanize.rubyforge.org) for a realistic (albeit non-JavaScript) browser client.

Getting Started
===============
    gem install celluloid-benchmark
    echo "benchmark :home_page, 1
    get 'https://github.com/scottwillson/celluloid-benchmark'" > session.rb
    celluloid-benchmark -d 1

Congrats! You just load-tested the project's Github page.

For your own tests, create a session file and pass its path to celluloid-benchmark.

Simple scenario
---------------
    CelluloidBenchmark::Session.define do
      benchmark :home_page, 1
      get "https://github.com/scottwillson/celluloid-benchmark"
    end

`benchmark :label, duration` means "measure the following requests and group them under 'label'".
Duration is optional and defaults to 0.3 seconds.

Find and click a link
---------------------
    page = get "/offer/1"
    buy_now_link = page.links_with(class: "buy_button").first

    benchmark :purchase_new
    page = get(buy_now_link.href)

Forms
-----
    form = page.forms_with(class: "simple_form purchase_form").first
    form["CARDNO"] = "4111111111111111"
    submit(form)

HTTP auth
---------
    add_auth "https://staging.example.com", "qa", "password"


Simulate AJAX
-------------
    transact do
      get "https://example.com/post_zones/AAA1NNN", [], nil, {
        "Accept" => "application/json, text/javascript, */*; q=0.01",
        "X-Requested-With" => "XMLHttpRequest"
      }
    end

JSON requests (e.g., a mobile app API)
--------------------------------------
  get "/mobile-api/v2/offers.json", [], nil, {
          "Accept" => "application/json, text/javascript, */*; q=0.01"
        }

  post(
    "/mobile-api/v2/signup.json",
    MultiJson.dump({ email: email }),
    { "Content-Type" => "application/json" }
  )

Options
-------
    celluloid-benchmark --help

Test data
=========
Because test scenarios are plain Ruby, you can drive tests in many different ways. The
[Faker gem](http://rubydoc.info/github/stympy/faker/master/frames) is handy
for random, realistic test data:

    require "faker"
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    post_town = Faker::Address.city

    form["CN"] = "#{first_name} #{last_name}"
    form["c[addr][post_town]"] = post_town

The [Forgery gem](http://sevenwire.github.io/forgery/) is good, too.

Celluloid Benchmark can also pull random test data from CSV files. For example:

    get "https://example.com/post_zones/#{random_data(:post_zone)}"

`random_data(:post_zone)` pulls a random line from tmp/data/post_zones.csv

Extending session DSL
=====================
The DSL is simple and will change in early releases. To add custom DSL methods, add methods to Visitor
    module CelluloidBenchmark
      class Visitor
        def visit_from_homepage(target)
          ...
        end
      end
    end

Celluloid Benchmark agents delegate calls to Mechanize. If you need something more complicated
than the examples, check out the [Mechanize API](http://mechanize.rubyforge.org/HTTP/Agent.html) and call it directly with `browser.` in your test scenario.

For a longer test, pass in a second duration argument (seconds):
    celluloid-benchmark my_test_session.rb 180

Sessions are defined as Procs, which means that you can't call `return` in a session definition. If you do need to
short-circuit a session (for example, to simulate an early visitor exit), encapsulate that part of the session in a
method. You can call return from the method. See "Extending session DSL" above.

Why
===
I need to simulate a lot of realistic traffic against preproduction code.
There are many good tools that can put a high load on a static URL (e.g., [ab](http://httpd.apache.org/docs/2.2/programs/ab.html)), and there are a few tools
(e.g., [Tsung](http://tsung.erlang-projects.org)) that can generate realistic multiple-URL loads. By "realistic" I mean: follow links, maintain
session state from one page to the next, simulate different types of simultaneous visitors (5% admin users + 10%
business customers + 75% consumers). I found it difficult to maintain complex scenarios. Our Tsung tests,
for instance, exploded into many ERB files that concatenated into a giant Tsung XML config (with some custom Erlang
functions). I also wanted control over recording and displaying test results.

Wouldn't it be nice to just write Ruby?

Yes, expect for that Ruby GIL issue. Which led me to Rubinius and Celluloid.

Rubinius is a concurrency-friendly implementation of Ruby, and Celluloid is a nice Ruby actor framework.

Celluloid also works with MRI 1.9 and 2.0, though Celluloid Benchmark can generate more concurrent load with
Rubinius. [JRuby](http://jruby.org) should also work well, maybe better.

I've just added features I need, but it should be easy to add more. For example:

  * Pull specific keys/columns from CSV files
  * Add random "think times" for visitors to pause on pages

Alternatives
============

Simple
------
[ab (Apache Bench)](http://httpd.apache.org/docs/2.2/programs/ab.html)

[httperf](http://www.hpl.hp.com/research/linux/httperf/)

[siege](http://freecode.com/projects/siege)


Complex
-------
[Tsung](http://tsung.erlang-projects.org)

[The Grinder](http://grinder.sourceforge.net)

[JMeter](http://jmeter.apache.org)


Develop
=======
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
    curl -L https://get.rvm.io | bash
    rvm install rbx-2.2.1
    git clone git@github.com:scottwillson/celluloid-benchmark.git
    cd celluloid-benchmark
    rvm gemset use celluloid-benchmark --create
    bundle
    rake

CI
==
    https://travis-ci.org/scottwillson/celluloid-benchmark


[![Build Status](https://travis-ci.org/scottwillson/celluloid-benchmark.svg?branch=master)](https://travis-ci.org/scottwillson/celluloid-benchmark)
[![Code Climate](https://codeclimate.com/github/scottwillson/celluloid-benchmark.png)](https://codeclimate.com/github/scottwillson/celluloid-benchmark)
