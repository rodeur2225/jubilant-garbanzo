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

package centreon::vmware::cmdgetmap;

use base qw(centreon::vmware::cmdbase);

use strict;
use warnings;
use centreon::vmware::common;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(%options);
    bless $self, $class;

    $self->{commandName} = 'getmap';
    
    return $self;
}

sub checkArgs {
    my ($self, %options) = @_;

    if (defined($options{arguments}->{esx_hostname}) && $options{arguments}->{esx_hostname} eq "") {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: esx hostname cannot be null");
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

sub run {
    my $self = shift;

    my $filters = $self->build_filter(label => 'name', search_option => 'esx_hostname', is_regexp => 'filter');
    my @properties = ('name', 'vm', 'config.product.version');
    my $result = centreon::vmware::common::search_entities(command => $self, view_type => 'HostSystem', properties => \@properties, filter => $filters);
    return if (!defined($result));

    $self->{manager}->{output}->output_add(severity => 'OK',
                                           short_msg => sprintf("List ESX host(s):"));
    
    foreach my $entity_view (@$result) {
        $self->{manager}->{output}->output_add(long_msg => sprintf("  %s [v%s] %s", $entity_view->name, $entity_view->{'config.product.version'}, 
                                                                   defined($self->{vm_no}) ? '' : ':'));
        next if (defined($self->{vm_no}));
        
        my @vm_array = ();
        if (defined $entity_view->vm) {
            @vm_array = (@vm_array, @{$entity_view->vm});
        }

        @properties = ('name', 'summary.runtime.powerState');
        my $result2 = centreon::vmware::common::get_views($self->{connector}, \@vm_array, \@properties);
        return if (!defined($result2));
        
        my %vms = ();
        foreach my $vm (@$result2) {
            $vms{$vm->name} = $vm->{'summary.runtime.powerState'}->val;
        }
        
        foreach (sort keys %vms) {
            $self->{manager}->{output}->output_add(long_msg => sprintf("      %s [%s]", 
                                                                       $_, $vms{$_}));
        }
    }
}

1;
