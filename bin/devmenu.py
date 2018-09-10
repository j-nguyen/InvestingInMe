#!/usr/bin/env python

# Import some stuff
import subprocess
import util
import branch
import build

def show_menu():
    """ Shows a menu """
    print '================== ' + util.HEADER + 'WORKFLOW MENU' + util.ENDC + ' =================='
    print '1) Create a git branch'
    print '2) Rebase your contents'
    print '3) Exit - Exits workflow'
    print '==================================================='

    choice = raw_input('Enter in a number (1-3): ')

    while choice not in ['1', '2', '3']:
        choice = raw_input(util.FAIL + 'Invalid Input! ' + util.ENDC + 'Please enter in a number (1-5): ')

    return choice

def rebase_contents():
    print subprocess.check_call(['git', 'fetch'])
    print subprocess.check_call(['git', 'pull', 'origin', 'staging'])
    # Re-run the build script
    build.main()

def main():
    """ Main function """
    options = int(show_menu())

    if options == 1:
        branch.main()
    elif options == 2:
        rebase_contents()
    elif options == 3:
        exit()

