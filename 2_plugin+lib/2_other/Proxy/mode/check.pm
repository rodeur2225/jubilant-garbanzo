# Autheur Thibaut Depond
# Date 13/12/2018
# compare une page web (telecharger via wget) en passant par le proxy en en ne passant pas par le proxy

package other::Proxy::mode::check;

use base qw(centreon::plugins::mode);

use strict;
use warnings;
use centreon::plugins::misc;

sub new {
	my ($class, %options) = @_;
	my $self = $class->SUPER::new(package => __PACKAGE__, %options);
	bless $self, $class;

	$self->{version} = '1,0';
	$options{options}->add_options(arguments =>
		{
			"proxy-addr:s" => { name => 'PADDR' },
		        "search:s"    => { name =>'search', default => 'https://perdu.com' },
			"timeout"   => { name => 'timeout', default => 30 },
		});
	return $self;
}	

sub check_options {
	
	my ($self, %options) = @_;
	$self->SUPER::init(%options);

	if (!defined($self->{option_results}->{PADDR})) {
		$self->{output}->add_option_msg(short_msg => "adresse du serveur proxy OBLIGATOIRE !");
		$self->{output}->option_exit();
	}
}

sub run {
	my ($self, %options) = @_;
	my $cmd='/usr/lib/centreon_sh/scripts/check_proxy.sh ' . $self->{option_results}->{PADDR} . ' ' . $self->{option_results}->{search} . ' ' . $self->{option_results}->{timeout};
	printf (`$cmd`);   
	$self->{output}->exit();
}

1;

__END__

=head1 MODE

verfife le bon fonctionnement d'un proxy en telecharger deux fois la meme page web (via wget)
une page est telecharger en passant par le proxy
l'autre est directment telecharge

les pages sont ensuit si elle identique tout va bien

=over 8

=item B<--proxy-addr>

l'adresse IP du proxy (obligatoire)

=item B<--search>

page web a telachargé (https://perdu.com par défaut)

=item B<--timeout>

temps limite de la requete envoyer (30 par default)
ce temps ne doit etre ni trop long ni trop court

=back

=cut
