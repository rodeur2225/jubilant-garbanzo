# Autheur Thibaut Depond
# Date 13/12/2018
# conpare une page GET en passant pas par le proxy en en ne passant par le proxy

package other::Proxy::mode::check;

use base qw(centreon::plugin::mode);

use strict;
use warnings
use centreon::plugin::misc;

sub new {
	my ($class, %options) = @_;
	my $self = $class->SUPER::new(package => __PACKAGE__, %options);
	bless $self, $class;

	$self->{version} = '1,0';
	$options{options}->add_options(arguments =>
		{
			"proxy-addr" => { name => 'PADDR' },
		        "search"    => { name =>'search', default => 'https://perdu.com' },
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
	printf (`/usr/lib/centreon_sh/scripts/check_proxy $self->{option_restults}->{PADDR} $self->{option_results}->{search} $self->{option_results}->{timeout}`);   
	$self->{output}->exit();
}

1;

__END__
