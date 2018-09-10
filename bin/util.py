#!/usr/bin/env python

""" This module is a helper-class util, designed to help out with specific methods """

HEADER = '\033[95m'
OKBLUE = '\033[94m'
OKGREEN = '\033[92m'
WARNING = '\033[93m'
FAIL = '\033[91m'
ENDC = '\033[0m'
BOLD = '\033[1m'
UNDERLINE = '\033[4m'

def log(string):
    """ Outputs like a console log """
    return '~*~*~*~*~**~*~*~*~* {0} ~*~*~*~*~**~*~*~*~*'.format(string)
    