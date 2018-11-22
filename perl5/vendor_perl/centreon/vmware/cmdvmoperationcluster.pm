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

package centreon::vmware::cmdvmoperationcluster;

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
    
    $self->{commandName} = 'vmoperationcluster';
    
    return $self;
}

sub checkArgs {
    my ($self, %options) = @_;

    if (defined($options{arguments}->{cluster}) && $options{arguments}->{cluster} eq "") {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: cluster cannot be null");
        return 1;
    }
    foreach my $label (('warning_svmotion', 'critical_svmotion', 'warning_vmotion', 'critical_vmotion',
                        'warning_clone', 'critical_clone')) {
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
    foreach my $label (('warning_svmotion', 'critical_svmotion', 'warning_vmotion', 'critical_vmotion',
                        'warning_clone', 'critical_clone')) {
        $self->{manager}->{perfdata}->threshold_validate(label => $label, value => $options{arguments}->{$label});
    }
}

sub run {
    my $self = shift;
    
    $self->{statefile_cache} = centreon::plugins::statefile->new(output => $self->{manager}->{output});
    $self->{statefile_cache}->read(statefile_dir => $self->{connector}->{retention_dir},
                                   statefile => "cache_vmware_connector_" . $self->{connector}->{whoaim} . "_" . $self->{commandName} . "_" . (defined($self->{cluster}) ? md5_hex($self->{cluster}) : md5_hex('.*')),
                                   statefile_suffix => '',
                                   no_quit => 1);
    return if ($self->{statefile_cache}->error() == 1);

    if (!($self->{connector}->{perfcounter_speriod} > 0)) {
        $self->{manager}->{output}->output_add(severity => 'UNKNOWN',
                                               short_msg => "Can't retrieve perf counters");
        return ;
    }

    my $multiple = 0;
    my $filters = $self->build_filter(label => 'name', search_option => 'cluster', is_regexp => 'filter');
    my @properties = ('name');
    my $result = centreon::vmware::common::search_entities(command => $self, view_type => 'ClusterComputeResource', properties => \@properties, filter => $filters);
    return if (!defined($result));
    
    if (scalar(@$result) > 1) {
        $multiple = 1;
    }
    my $values = centreon::vmware::common::generic_performance_values_historic($self->{connector},
                        $result, 
                        [{'label' => 'vmop.numVMotion.latest', 'instances' => ['']},
                         {'label' => 'vmop.numSVMotion.latest', 'instances' => ['']},
                         {'label' => 'vmop.numClone.latest', 'instances' => ['']}],
                        $self->{connector}->{perfcounter_speriod},
                        sampling_period => $self->{sampling_period}, time_shift => $self->{time_shift},
                        skip_undef_counter => 1, multiples => 1, multiples_result_by_entity => 1);
    return if (centreon::vmware::common::performance_errors($self->{connector}, $values) == 1);
    
    if ($multiple == 1) {
        $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => sprintf("All virtual machine operations are ok"));
    }
    
    my $new_datas = {};
    my $old_datas = {};
    my $checked = 0;
    foreach my $entity_view (@$result) {
        my $entity_value = $entity_view->{mo_ref}->{value};
        my $name = centreon::vmware::common::substitute_name(value => $entity_view->{name});
        my %values = ();
        my ($short_msg, $short_msg_append, $long_msg, $long_msg_append) = ('', '', '', '');
        my @exits;
        
        foreach my $label (('Clone', 'VMotion', 'SVMotion')) {
            $new_datas->{$label . '_' . $entity_value} = $values->{$entity_value}->{$self->{connector}->{perfcounter_cache}->{'vmop.num' . $label . '.latest'}->{key} . ":"};
            $old_datas->{$label . '_' . $entity_value} = $self->{statefile_cache}->get(name => $label . '_' . $entity_value);
        
            next if (!defined($old_datas->{$label . '_' . $entity_value}));
            $checked = 1;
            
            if ($old_datas->{$label . '_' . $entity_value} > $new_datas->{$label . '_' . $entity_value}) {
                $old_datas->{$label . '_' . $entity_value} = 0;
            }
                       
            my $diff = $new_datas->{$label . '_' . $entity_value} - $old_datas->{$label . '_' . $entity_value};
            $long_msg .= $long_msg_append . $label . ' ' . $diff;
            $long_msg_append = ', ';

            my $exit2 = $self->{manager}->{perfdata}->threshold_check(value => $diff, threshold => [ { label => 'critical_' . lc($label), exit_litteral => 'critical' }, { label => 'warning_' . lc($label), exit_litteral => 'warning' } ]);
            push @exits, $exit2;
            if ($multiple == 0 || !$self->{manager}->{output}->is_status(litteral => 1, value => $exit2, compare => 'ok')) {
                $short_msg .= $short_msg_append . $label . ' ' . $diff;
                $short_msg_append = ', ';
            }
            
            my $extra_label = '';
            $extra_label = '_' . $name if ($multiple == 1);
            $self->{manager}->{output}->perfdata_add(label => lc($label) . $extra_label,
                                                     value => $diff,
                                                     warning => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'warning_' . lc($label)),
                                                     critical => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'critical_' . lc($label)),
                                                     min => 0);
        }
        
        $self->{manager}->{output}->output_add(long_msg => "Cluster '" . $name . "' vm operations: $long_msg");
        my $exit = $self->{manager}->{output}->get_most_critical(status => [ @exits ]);
        if (!$self->{manager}->{output}->is_status(litteral => 1, value => $exit, compare => 'ok')) {
            $self->{manager}->{output}->output_add(severity => $exit,
                                        short_msg => "Cluster '" . $name . "' vm operations: $short_msg"
                                        );
        }
        
        if ($multiple == 0) {
            $self->{manager}->{output}->output_add(short_msg => "Cluster '" . $name . "' vm operations: $long_msg");
        }
    }
    
    if ($checked == 0) {
        $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => sprintf("Buffer creation"));
    }
    $self->{statefile_cache}->write(data => $new_datas);
}

1;
