#! /usr/bin/env ruby
################################################################################
#                                                                              #
#  Name: install.rb                                                            #
#  Author: Sean E Russell <ser@germane-software.com>                           #
#  Version: $Id: $
#  Date: *2002-174                                                             #
#  Description:                                                                #
#    This is a generic installation script for pure ruby sources.  Features    #
#          include:                                                            #
#          * Clean uninstall                                                   #
#          * Installation into an absolute path                                #
#          * Installation into a temp path (useful for systems like Portage)   #
#          * Noop mode, for testing                                            #
#    To set for a different system, change the SRC directory to point to the   #
#    package name / source directory for the project.                          #
#                                                                              #
################################################################################

# CHANGE THIS
SRC = ['SVG' ]
STRIP = ''
SETVERSION = 'SVG'
SRCVERSION = '@ANT_VERSION@'
DATE = '@ANT_DATE@'

################################################################################
# CHANGE NOTHING BELOW THIS LINE

Dir.chdir ".." if Dir.pwd =~ /bin.?$/

require 'getoptlong'
require 'rbconfig'
require 'ftools'
require 'find'

opts = GetoptLong.new( [ '--uninstall',	'-u',		GetoptLong::NO_ARGUMENT],
											[ '--destdir', '-d', GetoptLong::REQUIRED_ARGUMENT ],
											[ '--target', '-t', GetoptLong::REQUIRED_ARGUMENT ],
											[ '--concurrent', '-c', GetoptLong::NO_ARGUMENT],
											[ '--help', '-h', GetoptLong::NO_ARGUMENT],
											[ '--noop', '-n', GetoptLong::NO_ARGUMENT])


destdir = File.join(Config::CONFIG['sitedir'], 
	"#{Config::CONFIG['MAJOR']}.#{Config::CONFIG['MINOR']}")

uninstall = false
prepend = nil
help = false
opts.each do |opt,arg|
	case opt
	when '--concurrent'
		CONCURRENT = true
	when '--destdir'
		prepend = arg
	when '--uninstall'
		uninstall = true
	when '--target'
		destdir = arg
	when '--help'
		help = true
	when '--noop'
		NOOP = true
	end
end

destdir = File.join prepend, destdir if prepend

def transmogrify( dir )
	dir = dir.sub( /^#{STRIP}\//, '' )
	if defined? CONCURRENT
		dir.sub( /#{SETVERSION}/, "#{SETVERSION}-#{SRCVERSION}")
	else
		dir
	end
end

if help
	puts "Installs #{SRC.inspect}.\nUsage:  #$0 [[-u] [-n] [-c] [-t <dir>|-d <dir>]|-h]"
	puts "   -u --uninstall\n      Uninstalls the package"
	puts "   -c --concurrent\n      Install concurrently, IE, into"
	for d in SRC
		puts "        #{destdir}/#{transmogrify( d )}"
	end
	puts "      The default behavior is to upgrade the current installation,"
	puts "      by installing into"
	for d in SRC
		puts "        #{destdir}/#{transmogrify( d )}"
	end
	puts "   -t --target\n      Installs the software at an absolute location, EG:"
	puts "      #$0 -t /usr/local/lib/ruby"
	puts "      will put the software directly underneath /usr/local/lib/ruby;"
	for d in SRC
		puts "        /usr/local/lib/ruby/#{transmogrify( d )}"
	end
	puts "   -d --destdir\n      Installs the software at a relative location, EG:"
	puts "      #$0 -d /tmp"
	puts "      will put the software under tmp, using your ruby environment."
	for d in SRC
		puts "        /tmp#{destdir}/#{transmogrify( d )}"
	end
	puts "   -n --noop\n      Don't actually do anything; just print out what it"
	puts "      would do."
	exit 0
end

def install destdir
	puts "Installing in #{destdir}"
	begin
		for src in SRC
			Find.find(src) { |file|
				dstfile = transmogrify( file )
				next if file =~ /CVS|\.svn/
				dst = File.join( destdir, dstfile )
				if defined? NOOP
					puts ">> #{dst}" if file =~ /\.rb$/
				else
					File.makedirs( File.dirname(dst) )
					File.install(file, dst, 0644, true) if file =~ /\.rb$/
				end
			}
		end
	rescue
		puts $!
	end
end

def uninstall destdir
	puts "Uninstalling in #{destdir}"
	begin
		puts "Deleting:"
		dirs = []
		Find.find(File.join(destdir,SRC)) do |file| 
			file.sub!( /#{SRC}/, "#{SRC}-#{SRCVERSION}") if defined? CONCURRENT
			if defined? NOOP
				puts "-- #{file}" if File.file? file
			else
				File.rm_f file,true if File.file? file
			end
			dirs << file if File.directory? file
		end
		dirs.sort { |x,y|
			y.length <=> x.length 	
		}.each { |d| 
			if defined? NOOP
				puts "-- #{d}"
			else
				puts d
				Dir.delete d
			end
		}
	rescue
	end
end

if uninstall
	uninstall destdir
else
	install destdir
end
