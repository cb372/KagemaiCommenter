== Kagemai commenter ==

A script for adding comments to a [Kagemai](http://www.daifukuya.com/kagemai/) bug report.

Designed to be used as an SVN post-commit hook.

See code comments for examples of customization options.

== Usage ==

Add a line similar to the following to your `post-commit` file.

    /path/to/ruby kagemai_comment.rb "$REV" "$REPOS"

== Dependencies ==

None.
