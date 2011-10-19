#!/usr/bin/env ruby

require 'SvnLogParser'
require 'CommentPoster'

require 'config.rb'

def usage()
  puts "Usage:"
  puts "  #{__FILE__} revision repoPath"
  puts "  e.g. #{__FILE__} 12345 /home/svnroot/myrepo"
end

if __FILE__ == $0

  if ARGV.length != 2
    usage()
    exit
  end

  revision = ARGV[0]
  repo_path = ARGV[1]

  # Set up an SVN commit log parser
  parser = SvnLogParser.new(repo_path, @svn_options) 
  
  # Set up a Kagemai comment poster 
  commenter = CommentPoster.new(
	@kagemai_root_url,
	@kagemai_project_name,
	@kagemai_options) 
  
  # Extract all the bug IDs from the SVN commit log
  bug_ids = parser.get_bug_ids(revision)

  # Retrieve the username of the SVN committer
  username = parser.get_committer_name(revision)

  # Retrieve the changed SVN branches
  branches = parser.get_changed_branches(revision)

  # For each bug, add a comment to Kagemai
  bug_ids.each{|i| commenter.post_comment(i, revision, username, branches)}
end

