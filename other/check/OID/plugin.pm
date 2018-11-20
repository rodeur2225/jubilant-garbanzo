#
#  Rod'n
# 21/11/18

package other::check::OID::plugin;

use strict;
use warnings;
use base qw(centreon::plugins::script_simple);

sub new {
  my ($class, %options) = @_;
  my $self = $class->SUPER::new(package => __PACKAGE__, %options);
  bless $self,$class;
  
  $self->{version} = '0.1';
  %{$self->{modes}} = (
    'string' => 'other::check::OID::string',
    );
   return $self;
}

1;

__END__

=head1 PLUGIN DESCRIPTION

Check OID

=cut
