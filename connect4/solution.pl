use v5.36;

use strict;
use warnings;

use List::Util qw/any/;
use Data::Dumper;

my $nrows = 6;
my $ncols = 7;

my @grid = split '', '.' x ($nrows * $ncols);

my $input;

do {
  print_grid();
  print 'Insert token into column: ';
} while (defined($input = <>) and not insert_token($input, ($. % 2) ? 'o' : 'x'));

say 'Player ', ($. % 2) ? 2 : 1, 'wins';

sub insert_token {
  my ($column, $token) = @_;

  unless ($column =~ m/\d+/) {
    printf "\nINVALID INPUT: must be an integer between 0 and %d\n\n", $ncols - 1;
    return 1;
  }

  my $pos;

  for (my $i=0; $i<=$#grid; $i += $ncols) {
      $pos = $i + $column;
      if ($grid[$pos] eq '.') { # Find first available slot
          $grid[$pos] = $token;
          last;
    }
  }

  return is_winning_move($pos, $token);
}

sub is_winning_move {
  my ($pos, $token) = @_;

  my $row = $pos / $nrows;
  my $col = $pos % $ncols;

  my @horizontal = get_horizontal($pos);
  my @vertical = get_vertical($pos);
  my @left_diagonal = get_left_diagonal($pos);
  my @right_diagonal = get_right_diagonal($pos);

  say 'Position ', $pos;
  say join ',', @horizontal;
  say join ',', @vertical;
  say join ',', @left_diagonal;
  say join ',', @right_diagonal;

  my @lines = map { join '', @grid[@{$_}] } \@horizontal, \@vertical, \@right_diagonal, \@left_diagonal;

  print Dumper \@lines;

  my $regex = qr/${token}{4}/;

  say $regex;

  my $bool = any { m/$regex/ } @lines;

  print Dumper $bool;

  return $bool;
}

sub get_vertical {
    my $pos = shift;

    my $col = $pos % $ncols;

    # Can be optimized since there will never be a token above the current one
    return split "\n", `seq $col $ncols $#grid`;
}

sub get_horizontal {
    my $pos = shift;

    my $start = $pos - $pos % $ncols;
    my $end = $start + $ncols - 1; # -1 since ranges are inclusive

    return $start..$end;
}

sub get_right_diagonal {
    my $pos = shift;

    my $inc = $ncols + 1;
    my $start = ($pos % $inc) ? $pos % $inc : $inc; # this does not seem right

    my @lines = split "\n", `seq $start $inc $#grid`;
    my $offset = 0;

    # Walk the list
    for ($offset; $lines[$offset] % $ncols == $ncols - 1; ++$offset) {}

    return @lines[$offset..$#lines];
}

sub get_left_diagonal {
    my $pos = shift;

    my $inc = $ncols - 1;
    my $start = $pos % $inc;

    my @lines = split "\n", `seq $start $inc $#grid`;
    my $offset = 0;

    # Walk the list
    for ($offset; $lines[$offset] % $ncols; ++$offset) {}

    my @slice = @lines[$offset..$#lines];

    say "Left diagonal slice: ", @slice;

    return @slice;
}

sub print_grid {
  say ' ', join ' ', 0..6;
  for (my $i=$#grid; $i>0; $i -= $ncols) { # Print rows in reverse
    say '|', join('|', @grid[$i-$ncols+1..$i]), '|';
  }
  print "\n";
}
