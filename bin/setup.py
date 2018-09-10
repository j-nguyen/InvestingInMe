#!/usr/bin/env python

# Sets up the project, assumes you have rvm though
import subprocess
import util
import build

def main():
    ruby_version = subprocess.check_output(['cat', '.ruby-version']).replace('\n', '')
    # Sets up ruby
    print util.log('Installing ruby ' + ruby_version)
    print subprocess.check_output(['rvm', 'install', ruby_version])
    # Sets up rvm
    print util.log('Use Ruby ' + ruby_version)
    subprocess.call(['./bin/use-rvm.sh'])
    # Install bundle
    print util.log('Install Bundle')
    print subprocess.check_output(['gem', 'install', 'bundler'])
    # Install gems
    build.main()
