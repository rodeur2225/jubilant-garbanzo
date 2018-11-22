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

package centreon::vmware::cmdservicehost;

use base qw(centreon::vmware::cmdbase);

use strict;
use warnings;
use centreon::vmware::common;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(%options);
    bless $self, $class;
    
    $self->{commandName} = 'servicehost';
    
    return $self;
}

sub checkArgs {
    my ($self, %options) = @_;

    if (defined($options{arguments}->{esx_hostname}) && $options{arguments}->{esx_hostname} eq "") {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: esx hostname cannot be null");
        return 1;
    }
    if (defined($options{arguments}->{disconnect_status}) && 
        $options{manager}->{output}->is_litteral_status(status => $options{arguments}->{disconnect_status}) == 0) {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: wrong value for disconnect status '" . $options{arguments}->{disconnect_status} . "'");
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

    my $multiple = 0;
    my $filters = $self->build_filter(label => 'name', search_option => 'esx_hostname', is_regexp => 'filter');
    my @properties = ('name', 'runtime.connectionState', 'runtime.inMaintenanceMode', 'configManager.serviceSystem');
    my $result = centreon::vmware::common::search_entities(command => $self, view_type => 'HostSystem', properties => \@properties, filter => $filters);
    return if (!defined($result));

    my %host_names = ();
    my @host_array = ();
    foreach my $entity_view (@$result) {
        next if (centreon::vmware::common::host_state(connector => $self->{connector},
                                                      hostname => $entity_view->{name}, 
                                                      state => $entity_view->{'runtime.connectionState'}->val,
                                                      status => $self->{disconnect_status},
                                                      multiple => $multiple) == 0);
        next if (centreon::vmware::common::host_maintenance(connector => $self->{connector},
                                                            hostname => $entity_view->{name}, 
                                                            maintenance => $entity_view->{'runtime.inMaintenanceMode'},
                                                            multiple => $multiple) == 0);
        if (defined($entity_view->{'configManager.serviceSystem'})) {
            push @host_array, $entity_view->{'configManager.serviceSystem'};
            $host_names{$entity_view->{'configManager.serviceSystem'}->{value}} = $entity_view->{name}; 
        }
    }
    
    return if (scalar(@host_array) == 0);
    
    @properties = ('serviceInfo');
    my $result2 = centreon::vmware::common::get_views($self->{connector}, \@host_array, \@properties);
    return if (!defined($result2));
    
    if (scalar(@$result) > 1) {
        $multiple = 1;
    }

    if ($multiple == 1) {
        $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => sprintf("All ESX services are ok"));
    }
    
    foreach my $entity (@$result2) {
        my $hostname = $host_names{$entity->{mo_ref}->{value}};
        
        my @services_ok = ();
        my @services_problem = ();
        foreach my $service (@{$entity->{serviceInfo}->{service}}) {
            next if (defined($self->{filter_services}) && $self->{filter_services} ne '' &&
                     $service->{key} !~ /$self->{filter_services}/);
            
            if ($service->{policy} =~ /^on|automatic/i && !$service->{running}) {
                push @services_problem, $service->{key};
            } else {
                push @services_ok, $service->{key};
            }
        }
        
        $self->{manager}->{output}->output_add(long_msg => sprintf("'%s' services [ ok : %s ] [ nok : %s ]", $hostname, 
                                                                   join(', ', @services_ok), join(', ', @services_problem)));
        my $status = 'OK';
        $status = 'CRITICAL' if (scalar(@services_problem) > 0);
        if ($multiple == 0 || 
            !$self->{manager}->{output}->is_status(value => $status, compare => 'ok', litteral => 1)) {
            $self->{manager}->{output}->output_add(severity => $status,
                                                   short_msg => sprintf("'%s' services [ ok : %s ] [ nok : %s ]", $hostname, 
                                                                        join(', ', @services_ok), join(', ', @services_problem)));
        }
    }
}

1;
