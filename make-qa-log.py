#! /usr/bin/env python

'''
Format the Git log between development and master into the markdown required for the HockeyApp nightly builds.
'''

import os
import re

maxLines = None
ticketRegex = re.compile(r'#(\d+)')
ticketReplacement = r'[#\1](https://github.com/Nudj/nudj-ios/issues/\1)'

def preamble():
	print '''## Nightly build for QA

Built from branch `%s` with SHA `%s`.

The technical change log since the last build shipped to the App Store follows:
''' % (currentBranch(), currentHash())

def printMarkdown(line):
	if line.startswith('New version'):
		# format as markdown heading 3
		line = '\n### %s' % line
	else:
		# format as markdown bullet point, italicizing any merge commits
		line = italicizeMerges(line)
		line = '* %s' % linkTickets(line)
	print line,

def italicizeMerges(line):
	'''Detect and italicize merge commits'''
	if line.startswith('Merge branch'):
		# slice off the trailing newline and italicize, restoring the newline
		line = '_%s_\n' % line[:-1]
	return line

def linkTickets(line):
	'''Detect and hyperlink ticket numbers'''
	return ticketRegex.sub(ticketReplacement, line)

def currentBranch():
	'''Return the current Git branch'''
	command = 'git symbolic-ref --short --quiet HEAD'
	f = os.popen(command)
	try:
		return f.readlines()[0][:-1]
	except:
		return '[detached]'

def currentHash():
	'''Return the current Git hash'''
	command = 'git show-ref --hash --head HEAD'
	f = os.popen(command)
	return f.readlines()[0][:-1]

def readLog():
	'''Scan the Git log and format it into markdown'''
	command = 'git log --pretty=format:%%s master..%s' % currentBranch()
	f = os.popen(command)
	lineCount = 0
	for line in f.readlines():
		if maxLines is not None and lineCount > maxLines:
			print "...\n"
			break
		printMarkdown(line)
		lineCount += 1
	print "\n"

def main():
	preamble()
	readLog()

if __name__ == "__main__":
    main()
