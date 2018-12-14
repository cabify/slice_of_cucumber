# Installing everything

We are going to work with ruby cucumber so, if you don't have ruby installed this is a goos moment to do it. You can easily get ruby by using RVM (it is a tool similar to nvm). Run the following commands:
```
\curl -sSL https://get.rvm.io | bash
rvm install 2.5.1
```

Clone this repository to start working on it
```
git clone https://github.com/cabify/slice_of_cucumber.git
```

Now we'll install `Bundler`
```
gem install bundler
```

And finally, cucumber itself (we are adding cucumber as a dependency to the Gemfile in the project):
```
bundle add cucumber
```

We should now be able to execute `cucumber`, do it. You should get an output similar to this
```
No such file or directory - features. You can use `cucumber --init` to get started.
```

So let's do what `cucumber` is telling us to.
```
cucumber --init
```

The following folder structure has been added to our project (we'll start working on it right now).
```
features
    |_ step_definitions
    |_ support
        |_ env.rb
```

If we run `cucumber` now, the tool will tell us there is nothing for it to execute
```
0 scenarios
0 steps
0m0.000s
```

## So, what is this `cucumber` thingy I have just installed?

Good question.

`Cucumber` is a software tool that executes behaviour specifications written in a near-to-natural language called `Gherkin`. 

In other words, you write software behaviour in a language similar to plain english (there are a couple of rules you must follow, we'll see them soon), save it to a file and tell `cucumber` to execute it. And `cucumber` does it (at least it tries).

This is an example of one of those files:

```
Feature: Is it Friday yet?
  Everyone in the office wants to know when it's Friday.
  Which are the rules to know when it's Friday?

  Scenario: Monday isn't Friday
    Given today is Monday
    When I ask whether it's Friday yet
    Then I should be told "No"
```

In fact, in this file there are `keywords` that `cucumber` uses to parse the information, and execute a `Scenario` (a specific example about how the described system must behave). This `Scenario` is composed by different `Steps` (those `Given`, `When` and `Then` lines) which in fact will be executed sequentially by `cucumber`.

Ok, let's try this.
