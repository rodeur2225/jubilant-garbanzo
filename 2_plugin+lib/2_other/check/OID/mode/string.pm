package other::check::OID::mode::string;

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
                                  "hostname:s"         => { name => 'hostname' },
                                  "oid"                => { name => 'oid' },
                                });
    return $self;
}

sub check_options {

    my ($self, %options) = @_;
    $self->SUPER::init(%options);

    if (!defined($self->{option_results}->{oid})) {
       $self->{output}->add_option_msg(short_msg => "Need to specify an oid.");
       $self->{output}->option_exit(); 
    }
    
    if (!defined($self->{option_results}->{hostname})) {
       $self->{output}->add_option_msg(short_msg => "Need to specify an hostname.");
       $self->{output}->option_exit(); 
    }
}

sub run {
  my ($self, %option) = @_;
  
  my $result = $self->get_request({oid});
  
  $self->{output}->output_add(severity => 'OK',short_msg => $result);
  $self->{output}->display();
  $self->{output}->exit();
}

1;

__END__

=head1 MODE

just a random msg

=over 8

=item B<--oid>

oid you wanna read (need --hostname)

=item B<--hostname>

Hostname to query.

=back

=cut
