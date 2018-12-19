# Autheur Thibaut Depond
# Date 13/12/2018
# appel de scripts bash pour tester le proxy

package other::Proxy::plugin;

use strict;
use warnings;
use base qw(centreon::plugins::script_simple);

sub new {
	my ($class, %options) = @_;
	my $self = $class->SUPER::new(package => __PACKAGE__,%options);
	bless $self,$class;

	$self->{version} = '0,1';
	%{$self->{modes}} = (
		'check' => 'other::Proxy::mode::check',
	);
	return $self;
}

1;

__END__

=head1 PLUGIN DESCRIPTION

verification de l'etat d'un proxy

=cut
