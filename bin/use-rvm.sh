#!/bin/bash

# Load RVM into a shell session *as a function*
# Loading RVM *as a function* is mandatory
# so that we can use 'rvm use <specific version>'
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
  echo "using user install $HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
  echo "using root install /usr/local/rvm/scripts/rvm"
else
  echo "ERROR: An RVM installation was not found.\n"
fi

RUBY_VERSION=$(cat .ruby-version)

rvm use $RUBY_VERSION