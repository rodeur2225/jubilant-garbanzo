# Copyright 2015 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets 
# the needs in IT infrastructure and application monitoring for 
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0  
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package centreon::vmware::cmddevicevm;

use base qw(centreon::vmware::cmdbase);

use strict;
use warnings;
use centreon::vmware::common;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(%options);
    bless $self, $class;
    
    $self->{commandName} = 'devicevm';
    
    return $self;
}

sub checkArgs {
    my ($self, %options) = @_;

    if (defined($options{arguments}->{vm_hostname}) && $options{arguments}->{vm_hostname} eq "") {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: vm hostname cannot be null");
        return 1;
    }
    if (defined($options{arguments}->{disconnect_status}) && 
        $options{manager}->{output}->is_litteral_status(status => $options{arguments}->{disconnect_status}) == 0) {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: wrong value for disconnect status '" . $options{arguments}->{disconnect_status} . "'");
        return 1;
    }
    if (defined($options{arguments}->{nopoweredon_status}) && 
        $options{manager}->{output}->is_litteral_status(status => $options{arguments}->{nopoweredon_status}) == 0) {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: wrong value for nopoweredon status '" . $options{arguments}->{nopoweredon_status} . "'");
        return 1;
    }
    if (($options{manager}->{perfdata}->threshold_validate(label => 'warning', value => $options{arguments}->{warning})) == 0) {
       $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                               short_msg => "Argument error: wrong value for warning value '" . $options{arguments}->{warning} . "'.");
       return 1;
    }
    if (($options{manager}->{perfdata}->threshold_validate(label => 'critical', value => $options{arguments}->{critical})) == 0) {
       $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                               short_msg => "Argument error: wrong value for critical value '" . $options{arguments}->{critical} . "'.");
       return 1;
    }
    return 0;
}

sub initArgs {
    my ($self, %options) = @_;
    
    foreach (keys %{$options{arguments}}) {
        $self->{$_} = $options{arguments}->{$_};
    }
    $self->{manager} = centreon::vmware::common::init_response();
    $self->{manager}->{output}->{plugin} = $options{arguments}->{identity};
    $self->{manager}->{perfdata}->threshold_validate(label => 'warning', value => $options{arguments}->{warning});
    $self->{manager}->{perfdata}->threshold_validate(label => 'critical', value => $options{arguments}->{critical});
}

sub run {
    my $self = shift;

    if (!($self->{connector}->{perfcounter_speriod} > 0)) {
        $self->{manager}->{output}->output_add(severity => 'UNKNOWN',
                                               short_msg => "Can't retrieve perf counters");
        return ;
    }

    my $multiple = 0;
    my $filters = $self->build_filter(label => 'name', search_option => 'vm_hostname', is_regexp => 'filter');    
    if (defined($self->{filter_description}) && $self->{filter_description} ne '') {
        $filters->{'config.annotation'} = qr/$self->{filter_description}/;
    }
    
    my @properties = ('name', 'runtime.connectionState', 'runtime.powerState', 'config.hardware.device');
    if (defined($self->{display_description})) {
        push @properties, 'config.annotation';
    }
    
    my $result = centreon::vmware::common::search_entities(command => $self, view_type => 'VirtualMachine', properties => \@properties, filter => $filters);
    return if (!defined($result));
    
    if (scalar(@$result) > 1) {
        $multiple = 1;
    }
    
    my $total_device_connected = 0;
    foreach my $entity_view (@$result) {
        next if (centreon::vmware::common::vm_state(connector => $self->{connector},
                                                    hostname => $entity_view->{name}, 
                                                    state => $entity_view->{'runtime.connectionState'}->val,
                                                    power => $entity_view->{'runtime.powerState'}->val,
                                                    status => $self->{disconnect_status},
                                                    powerstatus => $self->{nopoweredon_status},
                                                    multiple => $multiple) == 0);
        
        foreach my $dev (@{$entity_view->{'config.hardware.device'}}) {
            if (ref($dev) =~ /$self->{device}/) {
                if ($dev->connectable->connected == 1) {
                    my $prefix_msg = "'$entity_view->{name}'";
                    if (defined($self->{display_description}) && defined($entity_view->{'config.annotation'}) &&
                        $entity_view->{'config.annotation'} ne '') {
                        $prefix_msg .= ' [' . centreon::vmware::common::strip_cr(value => $entity_view->{'config.annotation'}) . ']';
                    }
                    $self->{manager}->{output}->output_add(long_msg => sprintf("%s device connected", 
                                                                                $prefix_msg));
                    $total_device_connected++;
                }
            }
        }
    }
    
    my $exit = $self->{manager}->{perfdata}->threshold_check(value => $total_device_connected, threshold => [ { label => 'critical', exit_litteral => 'critical' }, { label => 'warning', exit_litteral => 'warning' } ]);
    $self->{manager}->{output}->output_add(severity => $exit,
                                           short_msg => sprintf("%s %s device connected", $total_device_connected, $self->{device}));
    $self->{manager}->{output}->perfdata_add(label => 'connected',
                                             value => $total_device_connected,
                                             warning => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'warning'),
                                             critical => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'critical'),
                                             min => 0);
}

1;
