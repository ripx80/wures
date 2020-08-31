#!/usr/bin/python

from sys import argv
import os
import re

pl,pll='/usr/portage/profiles/use.desc','/usr/portage/profiles/use.local.desc'
guse,lnwrap,outfile,cpud=[],80,None,True
known_flags=frozenset(['3dnow','3dnowext','mmx','mmx2','mmxext','sse','sse2','sse3','ssse3','sse4','sse4a','sse4_1','sse4_2','sse5'])
if len(argv)>1:
	for arg in argv[1:]:
		if arg in ['--help','-?']:
			print('Usage:\n  update_useflags [OPTION...]\n')
			print('Help Options:\n  -?, --help             show help options\n\nApplication Options:')
			print('  --profile-location=PATH  alternate profile-location\n                           (default is /usr/portage/profiles)')
			print('  --globaluse=FLAGS        enable this flags globally')
			print('  --linewrap=NUM           wrap afer charcount (default is 80)')
			print('  --outfile=FILE           insert result into a file - if a USE entry\n                           exists in this file it will be replaced')
			print('  --nocpudetect            do not auto-enable cpu-supported flags (i.e. sse)')
			print('')
			exit(0)
		elif arg[:19]=='--profile-location=':
			pl='%s/use.desc'%(arg[19:])
			if not os.path.exists(pl):
				print('error: "{0}" invalid profile-location'.format(arg[19:]))
				exit(1)
		elif arg[:12]=='--globaluse=':
			guse=arg[12:].split(' ')
		elif arg[:11]=='--linewrap=':
			lnwrap=int(arg[11:])
		elif arg[:10]=='--outfile=':
			outfile=arg[10:]
			if not  os.access(outfile,os.W_OK):
				print('error: outfile does not exist or is not writeable')
				exit(1)
		elif arg[:13]=='--nocpudetect':
			cpud=False

if cpud:
	with open('/proc/cpuinfo','r') as f:
		for l in f.readlines():
			if l[:5]=='flags':
				for flag in l[l.index(':')+2:-1].split(' '):
					if flag in known_flags:
						guse.append(flag)
				break

flags=[]
# scan use.desc
with open(pl,'r') as f:
	for l in f.readlines():
		if l=='' or l=='\n' or l[0]=='#':
			continue
		flag=l[:l.find(' ')]
		flags.append(flag)
# scan use.local.desc
with open(pll,'r') as f:
	for l in f:
		if l=='' or l=='\n' or l[0]=='#':
			continue
		flag=l[l.find(':')+1:]
		flag=flag[:flag.find(' ')]
		if flag not in flags:
			flags.append(flag)
flags.sort()
# build output
s='USE="'
c=4
for flag in flags:
	if flag not in guse:
		flag='-'+flag
	flag+=' '
	if c+len(flag)>lnwrap:
		s+='\\\n     '
		c=0
	s+=flag
	c+=len(flag)
s+='"'
if outfile==None:
	print(s)
else:
	of=[]
	with open(outfile,'r') as f:
		of=f.read()
	m=re.search('^USE="(.*?)"$',of,re.M|re.S)
	if m==None: # append
		f=open(outfile,'a')
		f.write(s)
		f.close()
	else: # replace
		f=open(outfile,'w')
		f.write(of.replace(m.group(0),s))
		f.close()
