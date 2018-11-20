package other::check::OID::mode::string;

use base qw(centreon::plugins::mode);

use strict;
use warnings;

sub run {
  $self->{output}->output_add(severity => 'OK',short_msg => 'hello banana');
  $self->{output}->display();
  $self->{output}->exit();
}

1;

__END__

=head1 MODE

just a random msg

=cut
