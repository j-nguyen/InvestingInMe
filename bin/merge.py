#!/usr/bin/env python

# Created by: Johnny Nguyen
# This script attempts to ask for a pull request to merge

import urllib2
import base64
import json
import subprocess
import util

def read_config():
    """ Reads the configuration for us """
    with open('./bin/config.json', 'r') as f:
        return json.loads(f.read())

def get_current_branch():
    """ Gets the current branch """
    return subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD']).replace('\n', '')

def update_branch():
    """ Updates the branch for you """
    # Log out the stuff
    print util.log('Updating Branch')
    current_branch = get_current_branch()
    print current_branch
    # Attempt to pull
    try:
        subprocess.check_call(['git', 'pull', 'origin', 'staging'])
    except subprocess.CalledProcessError as error:
        print error
    print util.log('Pushing to remote branch')
    # If it's updated, let's go through with the next process
    print subprocess.check_output(['git', 'push', 'origin', 'HEAD'])

def create_pull_request():
    """ Attempts to create a pull request """
    status = subprocess.check_output(['git', 'status', '--porcelain'])
    # Check if there's nothing to be commited
    if status == '':
        config = read_config()
        update_branch()
        # Now attempt to get the title and name
        body = {'base': 'staging', 'head': get_current_branch(), 'title': '{0} - Submitting {0} to Staging'.format(get_current_branch())}
        # CALL THE REQUEST
        url = 'https://api.github.com/repos/j-nguyen/InvestingInMe/pulls'
        req = urllib2.Request(url)
        encoded = base64.b64encode('{0}:{1}'.format(config['user'], config['token']))
        req.add_header('Authorization', 'Basic {0}'.format(encoded))
        req.add_data(json.dumps(body))
        response = urllib2.urlopen(req)
        data = json.loads(response.read())
        login = list_assignees()
        assign_assignee(data['number'], login)
    else:
        print util.FAIL + util.BOLD + 'Your branch needs to be committed.' + util.ENDC

def list_assignees():
    """ Lists the assignees for us """
    # initial values
    url = 'https://api.github.com/repos/j-nguyen/InvestingInMe/assignees'
    config = read_config()
    # Start the request
    req = urllib2.Request(url)
    encoded = base64.b64encode('{0}:{1}'.format(config['user'], config['token']))
    req.add_header('Authorization', 'Basic {0}'.format(encoded))
    response = urllib2.urlopen(req)
    data = json.loads(response.read())
    # Load the results and return the id we want
    print '================== ' + util.OKGREEN + 'SELECT ASSIGNEE' + util.ENDC + ' =================='
    for i in range(len(data)):
        print str(i + 1) + ") " + data[i]['login']
    print '==================================================='

    # ask choice
    choice = raw_input('Enter in a number (1-' + str(len(data)) + '): ')
    choices = [str(i+1) for i in range(len(data))]

    while choice not in choices:
        choice = raw_input(util.FAIL + 'Invalid Input! ' + util.ENDC + 'Please enter in a number (1-5): ')

    return data[int(choice)-1]['login']

def assign_assignee(pull_request_id, login):
    """ Assigns an assignee for us """
    # initial values
    url = 'https://api.github.com/repos/j-nguyen/InvestingInMe/issues/{0}/assignees'.format(pull_request_id)
    config = read_config()
    # Start the request
    req = urllib2.Request(url)
    body = {'assignees': [login]}
    encoded = base64.b64encode('{0}:{1}'.format(config['user'], config['token']))
    req.add_header('Authorization', 'Basic {0}'.format(encoded))
    req.add_data(json.dumps(body))
    response = urllib2.urlopen(req)
    print util.log('Reading Response')
    print response.read()

def main():
    """ Our main function """
    create_pull_request()
