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

package centreon::vmware::cmdlimitvm;

use base qw(centreon::vmware::cmdbase);

use strict;
use warnings;
use centreon::vmware::common;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(%options);
    bless $self, $class;
    
    $self->{commandName} = 'limitvm';
    
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
    if (defined($options{arguments}->{cpu_limitset_status}) && 
        $options{manager}->{output}->is_litteral_status(status => $options{arguments}->{cpu_limitset_status}) == 0) {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: wrong value for cpu limitset status '" . $options{arguments}->{cpu_limitset_status} . "'");
        return 1;
    }
    if (defined($options{arguments}->{memory_limitset_status}) && 
        $options{manager}->{output}->is_litteral_status(status => $options{arguments}->{memory_limitset_status}) == 0) {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: wrong value for memory limitset status '" . $options{arguments}->{memory_limitset_status} . "'");
        return 1;
    }
    if (defined($options{arguments}->{disk_limitset_status}) && 
        $options{manager}->{output}->is_litteral_status(status => $options{arguments}->{disk_limitset_status}) == 0) {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: wrong value for disk limitset status '" . $options{arguments}->{disk_limitset_status} . "'");
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
}

sub display_verbose {
    my ($self, %options) = @_;
    
    $self->{manager}->{output}->output_add(long_msg => $options{label});
    foreach my $vm (sort keys %{$options{vms}}) {
        my $prefix = $vm;
        if ($options{vms}->{$vm} ne '') {
            $prefix .= ' [' . centreon::vmware::common::strip_cr(value => $options{vms}->{$vm}) . ']';
        }
        $self->{manager}->{output}->output_add(long_msg => '    ' . $prefix);
    }
}

sub run {
    my $self = shift;

    my $multiple = 0;
    my $filters = $self->build_filter(label => 'name', search_option => 'vm_hostname', is_regexp => 'filter');
    if (defined($self->{filter_description}) && $self->{filter_description} ne '') {
        $filters->{'config.annotation'} = qr/$self->{filter_description}/;
    }
    
    my @properties = ('name', 'runtime.connectionState', 'runtime.powerState', 'config.cpuAllocation.limit', 'config.memoryAllocation.limit');
    if (defined($self->{check_disk_limit})) {
         push @properties, 'config.hardware.device';
    }
    if (defined($self->{display_description})) {
        push @properties, 'config.annotation';
    }

    my $result = centreon::vmware::common::search_entities(command => $self, view_type => 'VirtualMachine', properties => \@properties, filter => $filters);
    return if (!defined($result));
    
    if (scalar(@$result) > 1) {
        $multiple = 1;
    }
    if ($multiple == 1) {
        $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => sprintf("All Limits are ok"));
    } else {
        $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => sprintf("Limits are ok"));
    }
    
    my %cpu_limit = ();
    my %memory_limit = ();
    my %disk_limit = ();
    foreach my $entity_view (@$result) {
        next if (centreon::vmware::common::vm_state(connector => $self->{connector},
                                                  hostname => $entity_view->{name}, 
                                                  state => $entity_view->{'runtime.connectionState'}->val,
                                                  status => $self->{disconnect_status},
                                                  nocheck_ps => 1,
                                                  multiple => $multiple) == 0);
    
        next if (defined($self->{nopoweredon_skip}) && 
                 centreon::vmware::common::is_running(power => $entity_view->{'runtime.powerState'}->val) == 0);

        # CPU Limit
        if (defined($entity_view->{'config.cpuAllocation.limit'}) && $entity_view->{'config.cpuAllocation.limit'} != -1) {
            $cpu_limit{$entity_view->{name}} = defined($entity_view->{'config.annotation'}) ? $entity_view->{'config.annotation'} : '';
        }
        
        # Memory Limit
        if (defined($entity_view->{'config.memoryAllocation.limit'}) && $entity_view->{'config.memoryAllocation.limit'} != -1) {
            $memory_limit{$entity_view->{name}} = defined($entity_view->{'config.annotation'}) ? $entity_view->{'config.annotation'} : '';
        }
        
        # Disk
        if (defined($self->{check_disk_limit})) {
            foreach my $device (@{$entity_view->{'config.hardware.device'}}) {
                if ($device->isa('VirtualDisk')) {
                   if (defined($device->storageIOAllocation->limit) && $device->storageIOAllocation->limit != -1) {
                       $disk_limit{$entity_view->{name}} = defined($entity_view->{'config.annotation'}) ? $entity_view->{'config.annotation'} : '';
                       last;
                   }
                }
            }
        }        
    }
    
    if (scalar(keys %cpu_limit) > 0 && 
        !$self->{manager}->{output}->is_status(value => $self->{cpu_limitset_status}, compare => 'ok', litteral => 1)) {
        $self->{manager}->{output}->output_add(severity => $self->{cpu_limitset_status},
                                               short_msg => sprintf('%d VM with CPU limits', scalar(keys %cpu_limit)));
        $self->display_verbose(label => 'CPU limits:', vms => \%cpu_limit);
    }
    if (scalar(keys %memory_limit) > 0 &&
        !$self->{manager}->{output}->is_status(value => $self->{memory_limitset_status}, compare => 'ok', litteral => 1)) {
        $self->{manager}->{output}->output_add(severity => $self->{memory_limitset_status},
                                               short_msg => sprintf('%d VM with memory limits', scalar(keys %memory_limit)));
        $self->display_verbose(label => 'Memory limits:', vms => \%memory_limit);
    }
    if (scalar(keys %disk_limit) > 0 &&
        !$self->{manager}->{output}->is_status(value => $self->{disk_limitset_status}, compare => 'ok', litteral => 1)) {
        $self->{manager}->{output}->output_add(severity => $self->{disk_limitset_status},
                                               short_msg => sprintf('%d VM with disk limits', scalar(keys %disk_limit)));
        $self->display_verbose(label => 'Disk limits:', vms => \%disk_limit);
    }
}

1;
