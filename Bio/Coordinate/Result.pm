# $Id$
#
# bioperl module for Bio::Coordinate::Result
#
# Cared for by Heikki Lehvaslaiho <heikki@ebi.ac.uk>
#
# Copyright Heikki Lehvaslaiho
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Coordinate::Result - Results from coordinate transformation

=head1 SYNOPSIS

  use Bio::Coordinate::Result;

  #get results from a Bio::Coordinate::MapperI
  $matched = $result->each_match;

=head1 DESCRIPTION

The results from Bio::Coordinate::MapperI are kept in an array. The
results are either Matches or Gaps.  SeeL<Bio::Coordinate::Result::Match>
and L<Bio::Coordinate::Result::Match>.

If only one Match is returned, there is a convenience method of
retrieving it or accessing its methods. Same holds true for a Gap.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to the
Bioperl mailing lists  Your participation is much appreciated.

  bioperl-l@bioperl.org                         - General discussion
  http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.  Bug reports can be submitted via
 email or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - Heikki Lehvaslaiho

Email:  heikki@ebi.ac.uk
Address:

     EMBL Outstation, European Bioinformatics Institute
     Wellcome Trust Genome Campus, Hinxton
     Cambs. CB10 1SD, United Kingdom

=head1 CONTRIBUTORS

Additional contributors names and emails here

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::Coordinate::Result;
use vars qw(@ISA );
use strict;

use Bio::Location::Split;

@ISA = qw(Bio::Location::Split);


=head2 add_location

 Title   : add_location
 Usage   : $obj->add_location($variant)
 Function: 

           Pushes one Bio::LocationI into the list of variants.

 Example : 
 Returns : 1 when succeeds
 Args    : Location object

=cut

sub add_sub_Location {
  my ($self,$value) = @_;
  $self->throw("Is not a Bio::LocationI but [$value]")
      unless $value->isa('Bio::LocationI');

  $self->{'_match'} = $value
      if $value->isa('Bio::Coordinate::Result::Match');

  $self->{'_gap'} = $value
      if $value->isa('Bio::Coordinate::Result::Gap');

  $self->SUPER::add_sub_Location($value);

}

=head2 add_result

 Title   : add_result
 Usage   : $obj->add_result($result)
 Function: Adds the contents of one Bio::Coordinate::Result
 Example : 
 Returns : 1 when succeeds
 Args    : Result object

=cut

sub add_result {
  my ($self,$value) = @_;

  $self->throw("Is not a Bio::Coordinate::Result but [$value]")
      unless $value->isa('Bio::Coordinate::Result');

  map {  $self->add_sub_Location($_);} $value->each_Location;

}

=head2 seq_id

  Title   : seq_id
  Usage   : my $seqid = $location->seq_id();
  Function: Get/Set seq_id that location refers to

            We override this here in order to propagate to all sublocations
            which are not remote (provided this root is not remote either)

  Returns : seq_id
  Args    : [optional] seq_id value to set


=cut

sub seq_id {
    my ($self, $seqid) = @_;
#
#    if(! $self->is_remote()) {
#	foreach my $subloc ($self->sub_Location(0)) {
#	    $subloc->seq_id($seqid) if ! $subloc->is_remote();
#	}
#    }
#    return $self->SUPER::seq_id($seqid);
}


=head2 Convenience methods

These methods are shortcuts to Match and Gap locations.

=cut

=head2 each_gap

 Title   : each_gap
 Usage   : $obj->each_gap();
 Function: 

            Returns a list of Bio::Coordianate::Result::Gap objects.

 Returns : list of gaps
 Args    : none

=cut

sub each_gap{
   my ($self) = @_;


   my @gaps;
   foreach my $gap ($self->each_Location) {
       push @gaps, $gap if $gap->isa('Bio::Coordinate::Result::Gap');
   }
   return @gaps;

}


=head2 each_match

 Title   : each_match
 Usage   : $obj->each_match();
 Function: 

            Returns a list of Bio::Coordinate::Result::Match objects.

 Returns : list of Matchs
 Args    : none

=cut

sub each_match {
   my ($self) = @_;

   my @matches;
   foreach my $match ($self->each_Location) {
       push @matches, $match if $match->isa('Bio::Coordinate::Result::Match');
   }
   return @matches;
}

=head2 match

 Title   : match
 Usage   : $match_object = $obj->match(); #or
           $gstart = $obj->gap->start;
 Function: Read only method for retrieving or accessing the match object.
 Returns : one Bio::Coordinate::Result::Match
 Args    : 

=cut

sub match {
   my ($self) = @_;

   $self->warn("More than one match in results")
       if $self->each_match > 1 and $self->verbose > 0;
   unless (defined $self->{'_match'} ) {
       my @m = $self->each_match;
       $self->{'_match'} = $m[-1];
   }
   return $self->{'_match'};
}

=head2 gap

 Title   : gap
 Usage   : $gap_object = $obj->gap(); #or
           $gstart = $obj->gap->start;
 Function: Read only method for retrieving or accessing the gap object.
 Returns : one Bio::Coordinate::Result::Gap
 Args    : 

=cut

sub gap {
   my ($self) = @_;

   $self->warn("More than one gap in results")
       if $self->each_gap > 1 and $self->verbose > 0;
   unless (defined $self->{'_gap'} ) {
       my @m = $self->each_gap;
       $self->{'_gap'} = $m[-1];
   }
   return $self->{'_gap'};
}

1;
