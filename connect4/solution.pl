use v5.36;

use strict;
use warnings;

my $nrows = 6;
my $ncols = 7;

my @grid = split '', '.' x ($nrows * $ncols);

print_grid();

sub print_grid {
  for (my $i=0; $i<=$#grid; $i += $ncols) {
    say @grid[$i..$i+$ncols-1];
  }
}
