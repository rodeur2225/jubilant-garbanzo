# Autheur Thibaut Depond
# Date 10/12/2018
# export la configuration vers /tmp/clapi-export

package other::eximport::mode::export;

use base qw(centreon::plugins::mode);

use strict;
use warnings;
use centreon::plugins::misc;

sub new {
	my ($class, %options) = @_;
	my $self = $class->SUPER::new(package => __PACKAGE__, %options);
	bless $self, $class;

	$self->{version} = '1.0';
	$options{options}->add_options(arguments =>
		{
		});
	return $self;
}
sub check_options{

}
sub run {
	my ($self, %options) = @_;
	my $result = `/usr/lib/centreon_sh/scripts/Export.sh`;
	my $msg = '';
	if ( $result == 0 ){
		$msg = "Export ok (vers /tmp/clapi-export)";
	} else {
		$msg = "Fail le fichier d'export n'a pas été créé";
	}
	$self->{output}->output_add(severity => $result,
		short_msg => $msg
		);
	$self->{output}->display();
	$self->{output}->exit();
}

1;

__END__

=head1 MODE

export config

=over 8 

=cut
