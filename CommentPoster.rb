#!/usr/bin/env ruby

require 'net/http'
require 'uri'

class CommentPoster
  
  def initialize(
	kagemai_url, 
	project_name, 
	options = {})
    # Required args
    @kagemai_url = ensure_trailing_slash(kagemai_url)
    @project_name = project_name

    # Options
    @email_template = options[:email_template] || ":::user:::@mycompany.com"
    @comment_template = options[:comment_template] || "Committed: r:::revision:::"
    @branch_name_separator = options[:branch_name_separator] || ", "
  end

  def post_comment(
	bug_id, 
	commit_revision,
	commit_user,
	commit_branches)
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
			  'email' => email_address,
			  'branches' => commit_branches.join(@branch_name_separator) })

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

