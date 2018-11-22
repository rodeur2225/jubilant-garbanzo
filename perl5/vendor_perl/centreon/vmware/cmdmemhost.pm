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

package centreon::vmware::cmdmemhost;

use base qw(centreon::vmware::cmdbase);

use strict;
use warnings;
use centreon::vmware::common;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(%options);
    bless $self, $class;
    
    $self->{commandName} = 'memhost';
    
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
    foreach my $label (('warning', 'critical', 'warning_state', 'critical_state')) {
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
     foreach my $label (('warning', 'critical', 'warning_state', 'critical_state')) {
        $self->{manager}->{perfdata}->threshold_validate(label => $label, value => $options{arguments}->{$label});
    }
}

sub run {
    my $self = shift;

    if (!($self->{connector}->{perfcounter_speriod} > 0)) {
        $self->{manager}->{output}->output_add(severity => 'UNKNOWN',
                                               short_msg => "Can't retrieve perf counters");
        return ;
    }

    my $multiple = 0;
    my $filters = $self->build_filter(label => 'name', search_option => 'esx_hostname', is_regexp => 'filter');
    my @properties = ('name', 'summary.hardware.memorySize', 'runtime.connectionState');
    my $result = centreon::vmware::common::search_entities(command => $self, view_type => 'HostSystem', properties => \@properties, filter => $filters);
    return if (!defined($result));
    
    if (scalar(@$result) > 1) {
        $multiple = 1;
    }
    my $performances = [{'label' => 'mem.consumed.average', 'instances' => ['']},
                        {'label' => 'mem.overhead.average', 'instances' => ['']}];
    if (!defined($self->{no_memory_state})) {
        push @{$performances}, {'label' => 'mem.state.latest', 'instances' => ['']};
    }
    my $values = centreon::vmware::common::generic_performance_values_historic($self->{connector},
                        $result, $performances,
                        $self->{connector}->{perfcounter_speriod},
                        sampling_period => $self->{sampling_period}, time_shift => $self->{time_shift},
                        skip_undef_counter => 1, multiples => 1, multiples_result_by_entity => 1);
    return if (centreon::vmware::common::performance_errors($self->{connector}, $values) == 1);
    
    # for mem.state:
    # 0   (high)  Free memory >= 6% of machine memory minus Service Console memory.
    # 1   (soft)  4%
    # 2   (hard)  2%
    # 3   (low)  1%
    my %mapping_state = (0 => 'high', 1 => 'soft', 2 => 'hard', 3 => 'low');
    
    if ($multiple == 1) {
        $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => sprintf("All memory usages are ok"));
    }
    foreach my $entity_view (@$result) {
        next if (centreon::vmware::common::host_state(connector => $self->{connector},
                                                    hostname => $entity_view->{name}, 
                                                    state => $entity_view->{'runtime.connectionState'}->val,
                                                    status => $self->{disconnect_status},
                                                    multiple => $multiple) == 0);
        my $entity_value = $entity_view->{mo_ref}->{value};                          
        my $memory_size = $entity_view->{'summary.hardware.memorySize'}; # in B

        # in KB
        my $mem_used = centreon::vmware::common::simplify_number(centreon::vmware::common::convert_number($values->{$entity_value}->{$self->{connector}->{perfcounter_cache}->{'mem.consumed.average'}->{'key'} . ":"})) * 1024;
        my $mem_overhead = centreon::vmware::common::simplify_number(centreon::vmware::common::convert_number($values->{$entity_value}->{$self->{connector}->{perfcounter_cache}->{'mem.overhead.average'}->{'key'} . ":"})) * 1024;
        my $mem_state;
        if (!defined($self->{no_memory_state})) {
            $mem_state = centreon::vmware::common::simplify_number(centreon::vmware::common::convert_number($values->{$entity_value}->{$self->{connector}->{perfcounter_cache}->{'mem.state.latest'}->{'key'} . ":"}));
        }
        my $mem_free = $memory_size - $mem_used;
        my $prct_used = $mem_used * 100 / $memory_size;
        my $prct_free = 100 - $prct_used;
        
        my $exit1 = $self->{manager}->{perfdata}->threshold_check(value => $prct_used, threshold => [ { label => 'critical', exit_litteral => 'critical' }, { label => 'warning', exit_litteral => 'warning' } ]);
        my ($total_value, $total_unit) = $self->{manager}->{perfdata}->change_bytes(value => $memory_size);
        my ($used_value, $used_unit) = $self->{manager}->{perfdata}->change_bytes(value => $mem_used);
        my ($free_value, $free_unit) = $self->{manager}->{perfdata}->change_bytes(value => $mem_free);

        
        my ($short_msg, $short_msg_append, $long_msg, $long_msg_append) = ('', '', '', '');        
        my $output = sprintf("Memory Total: %s Used: %s (%.2f%%) Free: %s (%.2f%%)",
                             $total_value . " " . $total_unit,
                             $used_value . " " . $used_unit, $prct_used,
                             $free_value . " " . $free_unit, $prct_free);
        $long_msg .= $long_msg_append . $output;
        $long_msg_append = ', ';
        if (!$self->{manager}->{output}->is_status(value => $exit1, compare => 'ok', litteral => 1)) {
            $short_msg .= $short_msg_append . $output;
            $short_msg_append = ', ';
        }
        
        my $exit2 = 'OK';
        if (!defined($self->{no_memory_state})) {
            $output = sprintf("Memory state : %s", $mapping_state{$mem_state});
            $exit2 = $self->{manager}->{perfdata}->threshold_check(value => $mem_state, threshold => [ { label => 'critical_state', exit_litteral => 'critical' }, { label => 'warning_state', exit_litteral => 'warning' } ]);
            $long_msg .= $long_msg_append . $output;
            $long_msg_append = ', ';
            if (!$self->{manager}->{output}->is_status(value => $exit2, compare => 'ok', litteral => 1)) {
                $short_msg .= $short_msg_append . $output;
                $short_msg_append = ', ';
            }
        }
        
        my $prefix_msg = "'$entity_view->{name}'";
        $self->{manager}->{output}->output_add(long_msg => "$prefix_msg $long_msg");
        my $exit = $self->{manager}->{output}->get_most_critical(status => [ $exit1, $exit2 ]);
        if (!$self->{manager}->{output}->is_status(litteral => 1, value => $exit, compare => 'ok')) {
            $self->{manager}->{output}->output_add(severity => $exit,
                                                   short_msg => "$prefix_msg $short_msg"
                                                   );
        }
        if ($multiple == 0) {
            $self->{manager}->{output}->output_add(short_msg => "$prefix_msg $long_msg");
        }

        my $extra_label = '';
        $extra_label = '_' . $entity_view->{name} if ($multiple == 1);
        $self->{manager}->{output}->perfdata_add(label => 'used' . $extra_label, unit => 'B',
                                                 value => $mem_used,
                                                 warning => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'warning', total => $memory_size, cast_int => 1),
                                                 critical => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'critical', total => $memory_size, cast_int => 1),
                                                 min => 0, max => $memory_size);
        $self->{manager}->{output}->perfdata_add(label => 'overhead' . $extra_label, unit => 'B',
                                                 value => $mem_overhead,
                                                 min => 0);
        if (!defined($self->{no_memory_state})) {
            $self->{manager}->{output}->perfdata_add(label => 'state' . $extra_label,
                                                     value => $mem_state,
                                                     warning => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'warning_state'),
                                                     critical => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'critical_state'),
                                                     min => 0, max => 3);
        }
    }
}

1;
