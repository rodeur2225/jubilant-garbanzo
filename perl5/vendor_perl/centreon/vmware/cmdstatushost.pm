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

package centreon::vmware::cmdstatushost;

use base qw(centreon::vmware::cmdbase);

use strict;
use warnings;
use centreon::vmware::common;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(%options);
    bless $self, $class;
    
    $self->{commandName} = 'statushost';
    
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
    my @properties = ('name', 'summary.overallStatus', 'runtime.connectionState');
    my $result = centreon::vmware::common::search_entities(command => $self, view_type => 'HostSystem', properties => \@properties, filter => $filters);
    return if (!defined($result));

    if (scalar(@$result) > 1) {
        $multiple = 1;
    }
    my %overallStatus = (
        'gray'      => 'status is unknown',
        'green'     => 'is OK',
        'red'       => 'has a problem',
        'yellow'    => 'might have a problem',
    );
    my %overallStatusReturn = (
        'gray'      => 'UNKNOWN',
        'green'     => 'OK',
        'red'       => 'CRITICAL',
        'yellow'    => 'WARNING'
    );

    if ($multiple == 1) {
        $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => sprintf("All ESX are ok"));
    }
    
    foreach my $entity_view (@$result) {
        next if (centreon::vmware::common::host_state(connector => $self->{connector},
                                                      hostname => $entity_view->{name}, 
                                                      state => $entity_view->{'runtime.connectionState'}->val,
                                                      status => $self->{disconnect_status},
                                                      multiple => $multiple) == 0);
        
        my $status_esx = $entity_view->{'summary.overallStatus'}->val;
        $self->{manager}->{output}->output_add(long_msg => sprintf("'%s' %s", $entity_view->{name}, $overallStatus{$status_esx}));
        
        if ($multiple == 0 || 
            !$self->{manager}->{output}->is_status(value => $overallStatusReturn{$status_esx}, compare => 'ok', litteral => 1)) {
            $self->{manager}->{output}->output_add(severity => $overallStatusReturn{$status_esx},
                                                   short_msg => sprintf("'%s' %s", $entity_view->{name}, $overallStatus{$status_esx}));
        }
    }
}

1;
