#!/usr/bin/env python

# This script seeks to try to build the project
import subprocess
import util

def main():
    # We'll just do it in this main since it's soo easy
    # Attempt to build
    print util.log('Installing bundle')
    print subprocess.check_output(['bundle'])
    # now pods
    print util.log('Updating Pods')
    print subprocess.check_output(['bundle', 'exec', 'pod', 'install', '--repo-update'])
    print util.log('Done')