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
	my $exit = `echo $?`;
	my $sev = 'OK';
	if ($exit == 1){
		$sev = 'Warning';
	} else {
		if($exit == 512){
			$sev = 'Critical';
		} else {
			if ($exit == 768){
				$sev = 'Unknown';
			}
		}
	}
	$self->{output}->output_add(severity => $sev,
		short_msg => $result);
	$self->{output}->display();
	$self->{output}->exit();
}

1;

__END__

=head1 MODE

export la configuration de centreon vers /tmp/clapi-export
si ce plugin ne fonctionnne pas vérifier les idenifiants et mot de passe entre dans Export.sh dans /usr/lib/centreon_sh
verfifier aussi les autorisation donné au plugin et au scripts

=over 8 

=cut
