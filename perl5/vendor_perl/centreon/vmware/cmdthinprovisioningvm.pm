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

package centreon::vmware::cmdthinprovisioningvm;

use base qw(centreon::vmware::cmdbase);

use strict;
use warnings;
use centreon::vmware::common;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(%options);
    bless $self, $class;
    
    $self->{commandName} = 'thinprovisioningvm';
    
    return $self;
}

sub checkArgs {
    my ($self, %options) = @_;

    if (defined($options{arguments}->{vm_hostname}) && $options{arguments}->{vm_hostname} eq "") {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: vm hostname cannot be null");
        return 1;
    }
    if (defined($options{arguments}->{thinprovisioning_status}) && $options{arguments}->{thinprovisioning_status} ne '') {
        my ($entry, $status) = split /,/, $options{arguments}->{thinprovisioning_status};
        if ($entry !~ /^(notactive|active)$/) {
            $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                    short_msg => "Wrong thinprovisioning-status option. Can only be 'active' or 'noactive'. Not: '" . $entry . "'.");
            return 1;
        }
        if ($options{manager}->{output}->is_litteral_status(status => $status) == 0) {
            $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                    short_msg => "Wrong thinprovisioning-status option. Not a good status: '" . $status . "'.");
            return 1;
        }
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
    
    foreach my $vm (sort keys %{$options{vms}}) {
        my $prefix = $vm;
        if ($options{vms}->{$vm}->{description} ne '') {
            $prefix .= ' [' . centreon::vmware::common::strip_cr(value => $options{vms}->{$vm}->{description}) . ']';
        }
        $self->{manager}->{output}->output_add(long_msg => $prefix);
        foreach my $disk (sort keys %{$options{vms}->{$vm}->{disks}}) {
            $self->{manager}->{output}->output_add(long_msg => '    ' . $disk);
        }
    }
}

sub run {
    my $self = shift;
    
    my $multiple = 0;
    my $filters = $self->build_filter(label => 'name', search_option => 'vm_hostname', is_regexp => 'filter');    
    if (defined($self->{filter_description}) && $self->{filter_description} ne '') {
        $filters->{'config.annotation'} = qr/$self->{filter_description}/;
    }
    
    my @properties = ('name', 'config.hardware.device', 'runtime.connectionState', 'runtime.powerState');
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
                                               short_msg => sprintf("All thinprovisoning virtualdisks are ok."));
    } else {
        $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => sprintf("Thinprovisoning virtualdisks are ok."));
    }
    
    my $disks_vm = {};
    my %maps_match = ('active' => { regexp => '^1$', output => 'VirtualDisks thinprovisioning actived' },
                      'notactive' => { regexp => '^(?!(1)$)', output => 'VirtualDisks thinprovisioning not actived' });
    my $num = 0;
    my ($entry, $status);
    if (defined($self->{thinprovisioning_status}) && $self->{thinprovisioning_status} ne '') {
        ($entry, $status) = split /,/, $self->{thinprovisioning_status};
    }
    
    foreach my $entity_view (@$result) {
        next if (centreon::vmware::common::vm_state(connector => $self->{connector},
                                                  hostname => $entity_view->{name}, 
                                                  state => $entity_view->{'runtime.connectionState'}->val,
                                                  status => $self->{disconnect_status},
                                                  nocheck_ps => 1,
                                                  multiple => $multiple) == 0);
    
        next if (defined($self->{nopoweredon_skip}) && 
                 centreon::vmware::common::is_running(power => $entity_view->{'runtime.powerState'}->val) == 0);
        
        foreach (@{$entity_view->{'config.hardware.device'}}) {         
            if ($_->isa('VirtualDisk')) {
                if (defined($entry) && $_->backing->thinProvisioned =~ /$maps_match{$entry}->{regexp}/) {
                    $num++;
                    if (!defined($disks_vm->{$entity_view->{name}})) {
                        $disks_vm->{$entity_view->{name}} = { disks => {}, description => (defined($entity_view->{'config.annotation'}) ? $entity_view->{'config.annotation'} : '') };
                    }
                    $disks_vm->{$entity_view->{name}}->{disks}->{$_->backing->fileName} = 1;
                }
            }
        }
    }

    if ($num > 0) {
        $self->{manager}->{output}->output_add(severity => $status,
                                               short_msg => sprintf('%d %s', $num, $maps_match{$entry}->{output}));
        $self->display_verbose(vms => $disks_vm);
    }
}

1;
