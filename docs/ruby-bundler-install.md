## Installation

```sh
$ brew update
$ brew install rbenv
```
Add the following in ~/.zshrc or (.bashrc) file:
```sh
eval "$(rbenv init -)"
```
Now, we can look at the list of ruby versions available for install

```sh
$ rbenv install -l
```
Install version 3.1.6 for example

```sh
$ rbenv install 3.1.6
```
Now we can use this ruby version globally

```sh
$ rbenv global 3.1.6
```
Finally run

```sh
$ rbenv rehash
$ which ruby
/Users/myuser/.rbenv/shims/ruby
$ ruby -v
ruby 2.3.7p456 (2018-03-28 revision 63024) [x86_64-darwin17]
```

`which ruby` should *not* return /usr/bin/ruby
If `$ ruby -v` returns `rbenv: version `ruby' is not installed` then run `$ rbenv local 3.1.6`

## Now install bundler

```sh
$ gem install bundler
```
For our needs in particular (depends on your Gemfile requirements)
```sh
$ gem install bundler:2.6.2
```

After which we can run `bundle install` for our Gemfile.

Thanks to https://stackoverflow.com/questions/51126403/you-dont-have-write-permissions-for-the-library-ruby-gems-2-3-0-directory-ma for this working solution



## Some usefull commands for ruby-install

List supported Rubies and their major versions: `$ ruby-install`

List the latest versions: `$ ruby-install --latest`

Install the current stable version of Ruby: `$ ruby-install ruby`

Install the latest version of Ruby: `$ ruby-install --latest ruby`

Install a stable version of Ruby: `$ ruby-install ruby 2.3`

Install a specific version of Ruby: `$ ruby-install ruby 2.3.1`

Install a Ruby into a specific directory: `$ ruby-install --install-dir /path/to/dir ruby`

Here is a link to the documentation - https://git.io/vLJIJ

I would highly suggest a tool such as rbenv - which allows you to manage your ruby environment, downloading multiple versions & switch between them very easily +more - https://github.com/rbenv/rbenv
Ref:https://stackoverflow.com/questions/37648055/ruby-install-to-install-latest-ruby




### Failed attempt with chruby
```sh
brew install chruby ruby-install
```

Then `open ~/.zshrc` (or ~/.bashrc)

Add `source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh`

Then `source ~/.zshrc (or ~/.bashrc)`

```sh
which chruby
```

To check that is well installed. 

Then `chruby 3.1.3` or  `ruby-install 3.1.3` if chruby: unknown Ruby: 3.1.3

`which ruby` should *not* return /usr/bin/ruby

```sh
ruby -v
```
