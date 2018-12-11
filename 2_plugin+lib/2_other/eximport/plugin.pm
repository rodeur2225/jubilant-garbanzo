# Autheur Thibaut Depond
# Date 10/12/2018
# appel un script bash permettant d'exporter la configuration de centreon

package other::eximport::plugin;

use strict;
use warnings;
use base qw(centreon::plugins::script_simple);

sub new {
	my ($class, %options) = @_;
	my $self = $class->SUPER::new(package => __PACKAGE__,%options);
	bless $self,$class;

	$self->{version} = '0.1';
	%{$self->{modes}} = (
		'export' => 'other::eximport::mode::export',
		);
	return $self;
}

1;

__END__

=head1 PLUGIN DESCRIPTION

Export or Import centreon configguration

=cut
