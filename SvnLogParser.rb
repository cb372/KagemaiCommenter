#!/usr/bin/env ruby


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

