#!/usr/bin/env ruby


class SvnLogParser

  def initialize(repo_path, options = {})
    @repo_path = repo_path
    @svnlook_cmd = options[:svnlook_cmd] || "svnlook"
    @bugid_line_start = options[:bugid_line_start] || "BTS-ID:"
    @branch_name_pattern = Regexp.new(options[:branch_name_pattern] || "(trunk)|/branches/([^/]+/)")
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

  def get_changed_branches(revision)
    dirs_changed = `#{@svnlook_cmd} dirs-changed -r "#{revision}" "#{@repo_path}"`
    dirs_changed.
        map{|x| x.scan(@branch_name_pattern)}.
        flatten.
        select{|x| !x.nil?}.
        uniq
  end
  
  def extract_bug_ids(commitlog)
    bugid_lines = commitlog.lines.select {|x| x.start_with? @bugid_line_start}
    bugids = bugid_lines.map {|x| x.scan(/\d+/)}.flatten 
  end

end

