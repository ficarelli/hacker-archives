#!/usr/bin/env perl
# Convert a Google Docs HTML export into structured plain text.
#
#   headings   ->  "### Heading" (hash count = heading level)
#   list items ->  "- item"
#   hyperlinks ->  "link text @@https://target@@"
#
# Google wraps outbound links in https://www.google.com/url?q=<target>&... ;
# those are unwrapped so the real target survives.
#
# Usage: html-to-text.pl < export.html > tab.txt

use strict;
use warnings;

binmode(STDIN,  ':encoding(UTF-8)');
binmode(STDOUT, ':encoding(UTF-8)');

my %NAMED = (
  amp => 0x26, lt => 0x3C, gt => 0x3E, quot => 0x22, apos => 0x27,
  nbsp => 0x20, ldquo => 0x201C, rdquo => 0x201D, lsquo => 0x2018,
  rsquo => 0x2019, ndash => 0x2013, mdash => 0x2014, hellip => 0x2026,
  middot => 0xB7, bull => 0x2022, deg => 0xB0, times => 0xD7, copy => 0xA9,
  reg => 0xAE, trade => 0x2122, euro => 0x20AC, pound => 0xA3, sect => 0xA7,
  laquo => 0xAB, raquo => 0xBB, aacute => 0xE1, eacute => 0xE9,
  iacute => 0xED, oacute => 0xF3, uacute => 0xFA, agrave => 0xE0,
  egrave => 0xE8, auml => 0xE4, euml => 0xEB, ouml => 0xF6, uuml => 0xFC,
  Ouml => 0xD6, Uuml => 0xDC, Auml => 0xC4, aring => 0xE5, Aring => 0xC5,
  oslash => 0xF8, Oslash => 0xD8, ccedil => 0xE7, ntilde => 0xF1,
  szlig => 0xDF, ae => 0xE6, AE => 0xC6,
);

# Decode HTML entities in one pass so "&amp;lt;" does not become "<".
sub decode_entities {
  my ($t) = @_;
  $t =~ s{&(#x[0-9A-Fa-f]+|#[0-9]+|[A-Za-z][A-Za-z0-9]*);}{
    my $e = $1;
    if    ($e =~ /^#x([0-9A-Fa-f]+)$/) { chr(hex($1)) }
    elsif ($e =~ /^#([0-9]+)$/)        { chr($1) }
    elsif (exists $NAMED{$e})          { chr($NAMED{$e}) }
    else                               { "&$e;" }
  }ge;
  return $t;
}

sub percent_decode {
  my ($u) = @_;
  $u =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge;
  return $u;
}

local $/;
my $html = <STDIN>;
$html = '' unless defined $html;

# Body only. Cut past the opening <body ...> tag itself, not just to "<body".
$html =~ s/^.*?<body[^>]*>//s;
$html =~ s{</body>.*$}{}s;

# Hyperlinks -> "text @@url@@"
$html =~ s{<a\b[^>]*?href="([^"]*)"[^>]*>(.*?)</a>}{
  my ($href, $text) = ($1, $2);
  $href = decode_entities($href);
  if ($href =~ m{^https?://(?:www\.)?google\.com/url\?q=([^&]*)}) {
    $href = percent_decode($1);
  }
  $text =~ s/<[^>]+>//gs;
  "$text \@\@$href\@\@";
}gse;

# Headings -> "#### text"
$html =~ s{<h([1-6])\b[^>]*>(.*?)</h\1>}{"\n" . ('#' x $1) . " $2\n"}gse;

# List items -> "- text"
$html =~ s{<li\b[^>]*>(.*?)</li>}{"\n- $1\n"}gse;

# Remaining block boundaries -> newlines
$html =~ s{</p>|</div>|</tr>|<br\s*/?>}{\n}gs;

# Drop every other tag, then decode entities in the surviving text
$html =~ s/<[^>]+>//gs;
$html = decode_entities($html);
$html =~ s/\x{feff}//g;

my @out;
for my $line (split /\n/, $html) {
  $line =~ s/\s+/ /g;
  $line =~ s/^\s+|\s+$//g;
  next if $line eq '';
  next if $line eq '-';
  push @out, $line;
}
print join("\n", @out), "\n" if @out;
