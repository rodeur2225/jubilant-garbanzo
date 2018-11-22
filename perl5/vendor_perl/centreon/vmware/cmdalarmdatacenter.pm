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

package centreon::vmware::cmdalarmdatacenter;

use base qw(centreon::vmware::cmdbase);

use strict;
use warnings;
use centreon::vmware::common;
use centreon::plugins::statefile;
use Digest::MD5 qw(md5_hex);

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(%options);
    bless $self, $class;
    
    $self->{commandName} = 'alarmdatacenter';
    
    return $self;
}

sub checkArgs {
    my ($self, %options) = @_;

    if (defined($options{arguments}->{datacenter}) && $options{arguments}->{datacenter} eq "") {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: datacenter cannot be null");
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
    $self->{manager}->{perfdata}->threshold_validate(label => 'warning', value => 0);
    $self->{manager}->{perfdata}->threshold_validate(label => 'critical', value => 0);
}

sub run {
    my $self = shift;

    if (defined($self->{memory})) {
        $self->{statefile_cache} = centreon::plugins::statefile->new(output => $self->{manager}->{output});
        $self->{statefile_cache}->read(statefile_dir => $self->{connector}->{retention_dir},
                                       statefile => "cache_vmware_connector_" . $self->{connector}->{whoaim} . "_" . $self->{commandName} . "_" . (defined($self->{datacenter}) ? md5_hex($self->{datacenter}) : md5_hex('.*')),
                                       statefile_suffix => '',
                                       no_quit => 1);
        return if ($self->{statefile_cache}->error() == 1);
    }
    
    my $multiple = 0;
    if (defined($self->{filter_time}) && $self->{filter_time} ne '' && $self->{connector}->{module_date_parse_loaded} == 0) {
        $self->{manager}->{output}->output_add(severity => 'UNKNOWN',
                                               short_msg => "Need to install Date::Parse CPAN Module");
        return ;
    }
    
    my $filters = $self->build_filter(label => 'name', search_option => 'datacenter', is_regexp => 'filter');   
    my @properties = ('name', 'triggeredAlarmState');
    my $result = centreon::vmware::common::search_entities(command => $self, view_type => 'Datacenter', properties => \@properties, filter => $filters);
    return if (!defined($result));
    
    if (scalar(@$result) > 1) {
        $multiple = 1;
    }
    
    $self->{manager}->{output}->output_add(severity => 'OK',
                                           short_msg => sprintf("No current alarms on datacenter(s)"));
    
    my $total_alarms = { red => 0, yellow => 0 };
    my $dc_alarms = {};
    my $new_datas = {};
    foreach my $datacenter_view (@$result) {
        $dc_alarms->{$datacenter_view->name} = { red => 0, yellow => 0, alarms => {} };
        next if (!defined($datacenter_view->triggeredAlarmState));
        foreach (@{$datacenter_view->triggeredAlarmState}) {
            next if ($_->overallStatus->val !~ /(red|yellow)/i);
            if (defined($self->{filter_time}) && $self->{filter_time} ne '') {
                my $time_sec = Date::Parse::str2time($_->time);
                next if (time() - $time_sec > $self->{filter_time});
            }
            $new_datas->{$_->key} = 1;
            next if (defined($self->{memory}) && defined($self->{statefile_cache}->get(name => $_->key)));
            
            my $entity = centreon::vmware::common::get_view($self->{connector}, $_->entity, ['name']);
            my $alarm = centreon::vmware::common::get_view($self->{connector}, $_->alarm, ['info']);
            
            $dc_alarms->{$datacenter_view->name}->{alarms}->{$_->key} = { type => $_->entity->type, entity_name => $entity->name, 
                                                                          time => $_->time, name => $alarm->info->name, 
                                                                          description => $alarm->info->description, 
                                                                          status => $_->overallStatus->val};
            $dc_alarms->{$datacenter_view->name}->{$_->overallStatus->val}++;
            $total_alarms->{$_->overallStatus->val}++;
        }
    }

    my $exit = $self->{manager}->{perfdata}->threshold_check(value => $total_alarms->{yellow}, 
                                                             threshold => [ { label => 'warning', exit_litteral => 'warning' } ]);
    if (!$self->{manager}->{output}->is_status(value => $exit, compare => 'ok', litteral => 1)) {
        $self->{manager}->{output}->output_add(severity => $exit,
                                               short_msg => sprintf("%s alarm(s) found(s)", $total_alarms->{yellow}));
    }
    $exit = $self->{manager}->{perfdata}->threshold_check(value => $total_alarms->{red}, threshold => [ { label => 'critical', exit_litteral => 'critical' } ]);
    if (!$self->{manager}->{output}->is_status(value => $exit, compare => 'ok', litteral => 1)) {
        $self->{manager}->{output}->output_add(severity => $exit,
                                               short_msg => sprintf("%s alarm(s) found(s)", $total_alarms->{red}));
    }    
    
    foreach my $dc_name (keys %{$dc_alarms}) {
        $self->{manager}->{output}->output_add(long_msg => sprintf("Checking datacenter %s", $dc_name));
        $self->{manager}->{output}->output_add(long_msg => sprintf("    %s warn alarm(s) found(s) - %s critical alarm(s) found(s)", 
                                                    $dc_alarms->{$dc_name}->{yellow},  $dc_alarms->{$dc_name}->{red}));
        foreach my $alert (keys %{$dc_alarms->{$dc_name}->{alarms}}) {
            $self->{manager}->{output}->output_add(long_msg => sprintf("    [%s] [%s] [%s] [%s] %s/%s", 
                                                               $dc_alarms->{$dc_name}->{alarms}->{$alert}->{status},
                                                               $dc_alarms->{$dc_name}->{alarms}->{$alert}->{type},
                                                               $dc_alarms->{$dc_name}->{alarms}->{$alert}->{entity_name},
                                                               $dc_alarms->{$dc_name}->{alarms}->{$alert}->{time},
                                                               $dc_alarms->{$dc_name}->{alarms}->{$alert}->{name},
                                                               $dc_alarms->{$dc_name}->{alarms}->{$alert}->{description}
                                                               ));
        }
        
        my $extra_label = '';
        $extra_label = '_' . $dc_name if ($multiple == 1);
        $self->{manager}->{output}->perfdata_add(label => 'alarm_warning' . $extra_label,
                                                 value => $dc_alarms->{$dc_name}->{yellow},
                                                 min => 0);
        $self->{manager}->{output}->perfdata_add(label => 'alarm_critical' . $extra_label,
                                                 value => $dc_alarms->{$dc_name}->{red},
                                                 min => 0);
    }
    
    if (defined($self->{memory})) {
        $self->{statefile_cache}->write(data => $new_datas);
    }
}

1;
