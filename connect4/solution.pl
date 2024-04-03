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

say 'Player ', ($. % 2) ? 2 : 1, ' wins';

sub insert_token {
  my ($column, $token) = @_;

  unless ($column =~ m/\d+/) {
    printf "\nINVALID INPUT: must be an integer between 0 and %d\n\n", $ncols - 1;
    return 0;
  }

  my $pos;
  my $i;

  for ($i=0; $i<=$#grid; $i += $ncols) {
      $pos = $i + $column;
      if ($grid[$pos] eq '.') { # Find first available slot
          $grid[$pos] = $token;
          last;
    }
  }

  if ($i > $#grid) {
      printf "\nINVALID INPUT: column is full\n\n";
      return 0;
  }

  return is_winning_move($pos, $token);
}

sub is_winning_move {
  my ($pos, $token) = @_;

  my @lines = map { join '', @grid[@{$_}] } get_horizontal($pos),
    get_vertical($pos), get_ascending_diagonal($pos), get_descending_diagonal($pos);

  my $regex = qr/${token}{4}/;

  return any { m/$regex/ } @lines;
}

sub get_vertical {
    my $pos = shift;

    my $col = $pos % $ncols;

    # Can be optimized since there will never be a token above the current one
    return [split "\n", `seq $col $ncols $#grid`];
}

sub get_horizontal {
    my $pos = shift;

    my $start = $pos - $pos % $ncols;
    my $end = $start + $ncols - 1; # -1 since ranges are inclusive

    return [$start..$end];
}

sub get_ascending_diagonal {
    my $pos = shift;

    my $inc = $ncols + 1;
    my $start = get_ascending_start($pos);
    my $end = get_ascending_end($pos);

    return [split "\n", `seq $start $inc $end`];
}

sub get_descending_diagonal {
    my $pos = shift;

    my $inc = $ncols - 1;
    my $start = get_descending_start($pos);
    my $end = get_descending_end($pos);

    return [split "\n", `seq $start $inc $end`];
}

sub get_ascending_start {
    my $pos = shift;

    my $step = $ncols + 1;

    if (($pos < $ncols) or ($pos % $ncols == 0)) {
	return $pos;
    }
    return get_ascending_start($pos - $step);
}

sub get_descending_start {
    my $pos = shift;

    my $step = $ncols - 1;

    if (($pos < $ncols) or ($pos % $ncols == $ncols - 1)) {
	return $pos;
    }
    return get_descending_start($pos - $step);
}

sub get_ascending_end {
    my $pos = shift;

    my $step = $ncols + 1;

    if (($pos > $#grid - $ncols) or ($pos % $ncols == $ncols - 1)) {
	return $pos;
    }
    return get_ascending_end($pos + $step);
}

sub get_descending_end {
    my $pos = shift;

    my $step = $ncols - 1;

    if (($pos > $#grid - $ncols) or ($pos % $ncols == 0)) {
	return $pos;
    }
    return get_descending_end($pos + $step);
}

sub print_grid {
    say ' ', join ' ', 0..6;
    for (my $i=$#grid; $i>0; $i -= $ncols) { # Print rows in reverse
	say '|', join('|', @grid[$i-$ncols+1..$i]), '|';
    }
    print "\n";
}
