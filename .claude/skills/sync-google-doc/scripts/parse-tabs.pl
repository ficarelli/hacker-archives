#!/usr/bin/env perl
# Extract the tab list from a Google Docs /edit page.
#
# The editor bootstraps its model in a DOCS_modelChunk blob that names every
# tab. The first tab is declared as {"ty":"mkch","d":[[1,"Title"]]} and has no
# id of its own (address it as t.0); later tabs appear as
# {"ty":"ac","d":["t.<id>",[1,"Title"],[<position>]]}.
#
# Usage: parse-tabs.pl < edit.html
# Output: TSV lines of  position <TAB> tab_id <TAB> title <TAB> slug

use strict;
use warnings;

binmode(STDIN,  ':encoding(UTF-8)');
binmode(STDOUT, ':encoding(UTF-8)');

# Titles live inside a JS string literal, so \xNN and \uNNNN may appear.
sub unescape_js {
  my ($t) = @_;
  $t =~ s/\\u([0-9A-Fa-f]{4})/chr(hex($1))/ge;
  $t =~ s/\\x([0-9A-Fa-f]{2})/chr(hex($1))/ge;
  $t =~ s/\\(["'\\\/])/$1/g;
  return $t;
}

sub slugify {
  my ($t) = @_;
  $t = lc $t;
  $t =~ s/[^a-z0-9]+/-/g;
  $t =~ s/^-+|-+$//g;
  $t = 'tab' if $t eq '';
  return $t;
}

local $/;
my $html = <STDIN>;
$html = '' unless defined $html;

my @tabs;

if ($html =~ /"ty":"mkch","d":\[\[1,"((?:[^"\\]|\\.)*)"\]\]/) {
  push @tabs, { pos => 0, id => 't.0', title => unescape_js($1) };
}

while ($html =~ /"ty":"ac","d":\["(t\.[0-9A-Za-z]+)",\[1,"((?:[^"\\]|\\.)*)"\],\[(\d+)\]\]/g) {
  push @tabs, { pos => $3, id => $1, title => unescape_js($2) };
}

if (!@tabs) {
  print STDERR "parse-tabs.pl: no tabs found - is the document shared publicly?\n";
  exit 1;
}

# De-duplicate by id, keep document order.
my %seen;
@tabs = grep { !$seen{$_->{id}}++ } @tabs;
@tabs = sort { $a->{pos} <=> $b->{pos} } @tabs;

for my $t (@tabs) {
  printf "%d\t%s\t%s\t%s\n", $t->{pos}, $t->{id}, $t->{title}, slugify($t->{title});
}
