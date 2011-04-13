#!/usr/bin/python

# Python shell script for Duplicating IPlug Projects
# Oli Larkin 2011 http://www.olilarkin.co.uk
# License: WTFPL http://sam.zoy.org/wtfpl/COPYING
# Modified from this script by Bibha Tripathi http://code.activestate.com/recipes/435904-sedawk-python-script-to-rename-subdirectories-of-a/
# Author accepts no responsibilty for wiping your hd

# NOTES:
# not designed to be fool proof- think carefully about what you choose for a project name
# best to stick to standard characters in your project names - avoid spaces, numbers and dots
# windows users need to install python 2 (not tested with 3) and set it up so you can run it from the command line
# see http://www.voidspace.org.uk/python/articles/command_line.shtml
# this involves adding the python folder e.g. C:\Python27\ to your %PATH% environment variable
# to get the debugging setup on mac, you have to rename IPlugEffect/IPlugEffect.xcodeproj/oli.pbxuser to match your OSX username,
# the script asks you if you want to do this

# USAGE:
# duplicate.py [inputprojectname] [outputprojectname] [manufacturername]

from __future__ import generators

import fileinput, glob, string, sys, os, re
from shutil import copytree, ignore_patterns, rmtree
from os.path import join

def checkdirname(name, searchproject):
	"check if directory name matches with the given pattern"
	print ""
	print 'checking sub directory:', name
	if name == searchproject + ".xcodeproj":
		return True
	else:
		return False

def replacestrs(filename, s, r):
	files = glob.glob(filename)
	
	for line in fileinput.input(files,inplace=1):
		string.find(line, s)
		line = line.replace(s, r)
		sys.stdout.write(line)

def dirwalk(dir, searchproject, replaceproject, searchman, replaceman):
	for f in os.listdir(dir):
		fullpath = os.path.join(dir, f)
		
		if os.path.isdir(fullpath) and not os.path.islink(fullpath):			
			if checkdirname(f, searchproject):
				os.rename(fullpath, os.path.join(dir, replaceproject + ".xcodeproj"))
				fullpath = os.path.join(dir, replaceproject + ".xcodeproj")
				
				for x in dirwalk(fullpath, searchproject, replaceproject, searchman, replaceman):
					print 'recursing in subdirectory: ', f , x
					yield x
				
		if os.path.isfile(fullpath):
			filename = os.path.basename(fullpath)
			newfilename = filename.replace(searchproject, replaceproject)
			print 'Replacing project name strings in file', filename
			replacestrs(fullpath, searchproject, replaceproject)
			
			print 'Replacing manufacturer name strings in file', filename
			replacestrs(fullpath, searchman, replaceman)
			
			base, extension = os.path.splitext(filename)
	
			if filename != newfilename:
				print 'Renaming file ' + filename + ' to ' + newfilename
				os.rename(fullpath, os.path.join(dir, newfilename))
	
			yield f, fullpath	
		else:
			
			yield f, fullpath

def main():
	print "\nIPlug Project Duplicator v0-5 by Oli Larkin ------------------------------\n"
	
	if len(sys.argv) != 4:
		print "Usage: duplicate.py inputprojectname outputprojectname [manufacturername]",
		sys.exit(1)
	else:
		input=sys.argv[1]
		output=sys.argv[2]
		manufacturer=sys.argv[3]

		if ' ' in input:
			print "error: input project name has spaces",
			sys.exit(1)
			
		if ' ' in output:
			print "error: output project name has spaces",
			sys.exit(1)
		
		if ' ' in manufacturer:
			print "error: manufacturer name has spaces",
			sys.exit(1)
		
		# remove a trailing slash if it exists
		if input[-1:] == "/":
			input = input[0:-1]
		
		if output[-1:] == "/":
			output = output[0:-1]
			
		#check that the folders are OK
		if os.path.isdir(input) == False:
			print "error: input project not found",
			sys.exit(1)
				
		if os.path.isdir(output):
			print "error: output folder allready exists",
			sys.exit(1)
		#	rmtree(output)
		
		print "copying " + input + "folder to " + output
		copytree(input, output, ignore=ignore_patterns('*.svn', '*.ncb', '*.suo', 'build-*', '*.layout', '*.depend', '.DS_Store' ))
		cpath = os.path.join(os.getcwd(), output)

		#replace Manufacturer name strings
		for dir in dirwalk(cpath, input, output, "Manufacturer", manufacturer):
			pass
		
		xcuserfile = output + "/" + output + ".xcodeproj/wdlce.pbxuser"
		#vsuserfile = + output + "/" + output + ".vcxproj.user
		ans = raw_input("import default debug setups? y/n ...")

		if ans == "y":
			print "\n renaming the file " + xcuserfile
			osxun = raw_input("enter your osx username ...")
			if ' ' in osxun:
				print "error: spaces in user name"
				sys.exit(1)
			else:
				nxcuserfile = xcuserfile.replace("wdlce", osxun);
				os.rename(xcuserfile, nxcuserfile)
			
		elif ans == "n":
			print "\n not renaming the file " + xcuserfile + " debugging setup will be lost"
			#print "\n not renaming the file " + vsuserfile

		print "\ndone - don't forget to change PLUG_UNIQUE_ID and PLUG_MFR_ID in resource.h"
		
if __name__ == '__main__':
	main()