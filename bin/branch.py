#!/usr/bin/env python

# Checkouts a new branch for you
import subprocess
import util
import build

def main():
    # Get the branch name
    name = raw_input('Enter in branch name: ')
    print util.log('Checking to new branch')
    # Attempt to checkout branch
    print subprocess.check_output(['git', 'checkout', '-b', name])
    # Once done, push to new branch
    print util.log('Pushing to remote branch')
    # If it's updated, let's go through with the next process
    print subprocess.check_output(['git', 'push', 'origin', 'HEAD'])
    print util.log('Update build')
    build.main()
