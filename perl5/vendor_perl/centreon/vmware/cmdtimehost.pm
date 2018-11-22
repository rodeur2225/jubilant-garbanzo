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

package centreon::vmware::cmdtimehost;

use base qw(centreon::vmware::cmdbase);

use strict;
use warnings;
use centreon::vmware::common;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(%options);
    bless $self, $class;
    
    $self->{commandName} = 'timehost';
    
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
    foreach my $label (('warning_time', 'critical_time')) {
        if (($options{manager}->{perfdata}->threshold_validate(label => $label, value => $options{arguments}->{$label})) == 0) {
            $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                    short_msg => "Argument error: wrong value for $label value '" . $options{arguments}->{$label} . "'.");
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
    foreach my $label (('warning_time', 'critical_time')) {
        $self->{manager}->{perfdata}->threshold_validate(label => $label, value => $options{arguments}->{$label});
    }
}

sub run {
    my $self = shift;

    if ($self->{connector}->{module_date_parse_loaded} == 0) {
        $self->{manager}->{output}->output_add(severity => 'UNKNOWN',
                                               short_msg => "Need to install Date::Parse CPAN Module");
        return ;
    }
    
    my $multiple = 0;
    my $filters = $self->build_filter(label => 'name', search_option => 'esx_hostname', is_regexp => 'filter');
    my @properties = ('name', 'configManager.dateTimeSystem', 'runtime.connectionState');

    my $result = centreon::vmware::common::search_entities(command => $self, view_type => 'HostSystem', properties => \@properties, filter => $filters);
    return if (!defined($result));
    
    if (scalar(@$result) > 1) {
        $multiple = 1;
    }

    if ($multiple == 1) {
        $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => 'All Times are ok');
    }
    my @host_array = ();
    foreach my $entity_view (@$result) {
        next if (centreon::vmware::common::host_state(connector => $self->{connector},
                                                      hostname => $entity_view->{name}, 
                                                      state => $entity_view->{'runtime.connectionState'}->{val},
                                                      status => $self->{disconnect_status},
                                                      multiple => $multiple) == 0);
        if (defined($entity_view->{'configManager.dateTimeSystem'})) {
            push @host_array, $entity_view->{'configManager.dateTimeSystem'};
        }
    }
    
    @properties = ();
    my $result2 = centreon::vmware::common::get_views($self->{connector}, \@host_array, \@properties);
    return if (!defined($result2));
    
    my $localtime = time();
    foreach my $entity_view (@$result) {
        my $host_dts_value = $entity_view->{'configManager.dateTimeSystem'}->{value};
        foreach my $host_dts_view (@$result2) {
            if ($host_dts_view->{mo_ref}->{value} eq $host_dts_value) {
                my $time = $host_dts_view->QueryDateTime();
                my $timestamp = Date::Parse::str2time($time);
                my $offset = $localtime - $timestamp;
                
                my $exit = $self->{manager}->{perfdata}->threshold_check(value => $offset, threshold => [ { label => 'critical_time', exit_litteral => 'critical' }, { label => 'warning_time', exit_litteral => 'warning' } ]);
                $self->{manager}->{output}->output_add(long_msg => sprintf("'%s' date: %s, offset: %s second(s)", 
                                                                           $entity_view->{name},
                                                                           $time, $offset));
                if ($multiple == 0 ||
                    !$self->{manager}->{output}->is_status(value => $exit, compare => 'ok', litteral => 1)) {
                     $self->{manager}->{output}->output_add(severity => $exit,
                                                            short_msg => sprintf("'%s' Time offset %d second(s) : %s", 
                                                                                $entity_view->{name}, $offset,
                                                                                $time));
                }
                
                my $extra_label = '';
                $extra_label = '_' . $entity_view->{name} if ($multiple == 1);
                $self->{manager}->{output}->perfdata_add(label => 'offset' . $extra_label, unit => 's',
                                                         value => $offset,
                                                         warning => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'warning_time'),
                                                         critical => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'critical_time'),
                                                         min => 0);
                
                last;
            }
        }
    }
}

1;
