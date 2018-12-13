# Installing everything

We are going to work with ruby cucumber so, if you don't have ruby installed this is a goos moment to do it. You can easily get ruby by using RVM (it is a tool similar to nvm). Run the following commands:
```
\curl -sSL https://get.rvm.io | bash
rvm install 2.5.1
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

Now we have to give it something to run!