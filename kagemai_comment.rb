#!/usr/bin/env ruby

require 'net/http'
require 'uri'

class KagemaiCommenter
  
  def initialize(
	kagemai_url, 
	project_name, 
	options = {})
    # Required args
    @kagemai_url = ensure_trailing_slash(kagemai_url)
    @project_name = project_name

    # Options
    @email_template = options[:email_template] || ":::user:::@infoscience.co.jp"
    @comment_template = options[:comment_template] || "Committed: r:::revision:::"
  end

  def post_comment(
	bug_id, 
	commit_revision,
	commit_user)
    url = "#{@kagemai_url}guest.fcgi?action=view_report&s=1&project=#{@project_name}&id=#{bug_id}" 
    
    # GET the Kagemai page 
    resp = Net::HTTP.get_response(URI.parse(url))
    if ! resp.is_a? Net::HTTPSuccess 
      puts "Failed to connect to Kagemai URL #{url}"
      return
    end

    # Scrape the bug report title
    title = resp.body.scan(/input name="title" .* value="([^"]*)"/)

    # Fill in the email address and comment templates
    email_address = substitute(@email_template, { 'user' => commit_user })
    comment = substitute(@comment_template, 
			{ 'revision' => commit_revision,
			  'user' => commit_user,
			  'email' => email_address })

    # Post the comment to Kagemai
    resp = Net::HTTP.post_form(URI.parse(url),
			{ 'email' => email_address,
			  'title' => title,
			  'body' => comment,
			  'action' => 'add_message',
			  'project' => @project_name,
			  'id' => bug_id,
			  'jp_encoding_test' => '日' })
  end

  def substitute(template, values)
    template.gsub( /:::(.*?):::/ ) { values[ $1 ] }
  end

  def ensure_trailing_slash(url)
    if url.end_with?("/")
      url
    else
      url + "/"
    end
  end

end

class SvnLogParser

  def initialize(repo_path, options = {})
    @repo_path = repo_path
    @svnlook_cmd = options[:svnlook_cmd] || "svnlook"
    @bugid_line_start = options[:bugid_line_start] || "BTS-ID:"
  end

  def get_bug_ids(revision)
    extract_bug_ids(get_commit_log(revision))
  end

  def get_commit_log(revision)
    `#{@svnlook_cmd} log -r "#{revision}" "#{@repo_path}"`
  end

  def get_committer_name(revision)
    `#{@svnlook_cmd} author -r "#{revision}" "#{@repo_path}"`.strip
  end
  
  def extract_bug_ids(commitlog)
    bugid_lines = commitlog.lines.select {|x| x.start_with? @bugid_line_start}
    bugids = bugid_lines.map {|x| x.scan(/\d+/)}.flatten 
  end

end

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

  # Set up an SVN commit log parser (with defaults)
  parser = SvnLogParser.new(repo_path) # SVN repository path

=begin
  # Set up an SVN commit log parser (with custom options)
  parser = SvnLogParser.new(
    	repo_path, # SVN repository path
    	{ :svnlook_cmd => '/path/to/svnlook',
    	  :bugid_line_start => 'BUGS:'  }) # Marker for lines containing bug IDs
=end

  # Set up a Kagemai commenter (defaults)
  commenter = KagemaiCommenter.new(
	"http://dev.mycompany.com/kagemai/", # Kagemai root URL 
	"my-project") # Kagemai project name

=begin
  # Set up a Kagemai commenter (with custom options)
  commenter = KagemaiCommenter.new(
	"http://dev.mycompany.com/kagemai/", # Kagemai root URL 
	"my-project", # Kagemai project name
	{ :email_template => ':::user:::@mycompany.com',
	  :comment_template =>
'Custom multi-line comment including...

SVN revision: :::revision::: 
SVN committer username: :::user:::
SVN committer email address: :::email:::
Link to WebSVN: http://dev.mycompany.com/wsvn/myproject/?op=revision&isdir=1&rev=:::revision:::&peg=:::revision:::' 
	}) 
=end

  # Extract all the bug IDs from the SVN commit log
  bug_ids = parser.get_bug_ids(revision)

  # Retrieve the username of the SVN committer
  username = parser.get_committer_name(revision)

  # For each bug, add a comment to Kagemai
  bug_ids.each{|i| commenter.post_comment(i, revision, username)}
end

