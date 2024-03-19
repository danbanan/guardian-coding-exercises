use v5.36;

use warnings;
use strict;

use Data::Dumper;
use List::Util qw/ shuffle /;

my @card_deck = shuffle 0..51;
my $sam = hand();
my $dealer = hand();

my $sam_score;
my $dealer_score;

print Dumper \@card_deck;

foreach (1,2) {
  $sam_score = $sam->(shift @card_deck);
  $dealer_score = $dealer->(shift @card_deck);
}

if ($sam_score == 21 and $dealer_score == 21) {
  say 'DRAW';
} elsif ($sam_score == 21) {
  say 'Sam has blackjack.';
} elsif ($dealer_score == 21) {
  say 'Dealer has blackjack.';
} else {
  do { $sam_score = $sam->(shift @card_deck) } while ($sam_score < 17);

  if ($sam_score < 21) {
    do { $dealer_score = $dealer->(shift @card_deck) } while ($dealer_score <= $sam_score);
  } else {
    say "Sam's total exceeds 21, dealer wins." and exit;
  }

  say "Winner is " . ($sam_score > $dealer_score) ? 'Sam' : 'Dealer';
}

sub hand {
  my $score = 0;
  return sub {
    my $card = (shift @_) % 13;
    if ($card) {
      $score += ($card > 10) ? 10 : $card;
    } else {
      $score += 11;
    }
  }
}
