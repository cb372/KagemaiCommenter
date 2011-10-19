# Kagemai commenter

A script for adding comments to a [Kagemai](http://www.daifukuya.com/kagemai/) bug report.

Designed to be used as an SVN post-commit hook.

The Kagemai comment can include:
* the SVN revision of the commit
* the SVN branch(es) changed by the commit
* the username/email address of the committer

See code comments in `config.rb` for examples of customization options.


## Usage

Edit options in `config.rb` to match your environment.

Add a line similar to the following to your `post-commit` file.

    /path/to/ruby /path/to/KagemaiCommenter/main.rb "$REV" "$REPOS"

## Dependencies

None.

Tested in Ruby 1.8.7.
