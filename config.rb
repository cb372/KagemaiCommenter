#!/usr/bin/env ruby

@svn_options = {}

=begin
# Custom options for SVN log parser  
@svn_options = { 	
	:svnlook_cmd => '/path/to/svnlook', # Full path to the svnlook command
    	:bugid_line_start => 'BUGS:'  # Marker for lines in the commit log containing bug IDs
} 
=end

@kagemai_root_url = "http://dev.mycompany.com/kagemai/" # Kagemai root URL 

@kagemai_project_name = "my-project"

@kagemai_options = {}
=begin
  # Custom options for Kagemai commenter 
@kagemai_options = { 
	:email_template => ':::user:::@mycompany.com',
	:comment_template =>
'Custom multi-line comment including...

SVN revision: :::revision::: 
SVN committer username: :::user:::
SVN committer email address: :::email:::
Link to WebSVN: http://dev.mycompany.com/wsvn/myproject/?op=revision&isdir=1&rev=:::revision:::&peg=:::revision:::' 
} 
=end
