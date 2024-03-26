use v5.36;

use warnings;
use strict;

package Participant;

sub new {
  my $class = shift;
  my $self = {
	      cards => [],
	      score => 0
	     };
  bless($self, $class);
  return $self;
}

sub receive_cards {
  my ($self, @cards) = @_;

  foreach (@cards) {
    my $card = $_ % 13;
    push @{$self->{cards}}, $card;
    if ($card) {
      $self->{score} += ($card > 10) ? 10 : $card;
    } else {
      $self->{score} += 11;
    }
  }
  return $self->{score};
}


package Player;

use base 'Participant';

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  bless($self, $class);
}

sub play {
  my ($self, $boundary, $card_deck) = @_;
  do {} while ($self->receive_cards($card_deck->draw(1)) < $boundary);
  return $self->{score};
}


package Dealer;

use base 'Participant';

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  bless($self, $class);
}

sub play {
  my ($self, $boundary, $card_deck) = @_;
  do {} while ($self->receive_cards($card_deck->draw(1)) <= $boundary);
  return $self->{score};
}


package CardDeck;

use List::Util qw/ shuffle /;

sub new {
  my $class = shift;
  my $self = { card_deck => [ shuffle 0..51 ] };
  bless($self, $class);
}

sub draw {
  my ($self, $ncards) = @_;
  return splice @{$self->{card_deck}}, 0, $ncards;
}


package main;

my $card_deck = CardDeck->new();
my $sam = Player->new();
my $dealer = Dealer->new();

$sam->receive_cards($card_deck->draw(2));
$dealer->receive_cards($card_deck->draw(2));

if ($sam->{score} == 21 and $dealer->{score} == 21) {
  say 'DRAW';
} elsif ($sam->{score} == 21) {
  say 'Sam has blackjack.';
} elsif ($dealer->{score} == 21) {
  say 'Dealer has blackjack.';
} else {
  if ($sam->play(17, $card_deck) < 21) {
    $dealer->play($sam->{score}, $card_deck);
  } else {
    say "Sam's total exceeds 21, dealer wins." and exit;
  }

  printf "%s wins.\n", ($sam->{score} > $dealer->{score}) ? 'Sam' : 'Dealer';
}
