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

package centreon::vmware::cmddatastoreusage;

use base qw(centreon::vmware::cmdbase);

use strict;
use warnings;
use centreon::vmware::common;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(%options);
    bless $self, $class;
    
    $self->{commandName} = 'datastoreusage';
    
    return $self;
}

sub checkArgs {
    my ($self, %options) = @_;

    if (defined($options{arguments}->{datastore_name}) && $options{arguments}->{datastore_name} eq "") {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: datastore name cannot be null");
        return 1;
    }
    if (defined($options{arguments}->{disconnect_status}) && 
        $options{manager}->{output}->is_litteral_status(status => $options{arguments}->{disconnect_status}) == 0) {
        $options{manager}->{output}->output_add(severity => 'UNKNOWN',
                                                short_msg => "Argument error: wrong value for disconnect status '" . $options{arguments}->{disconnect_status} . "'");
        return 1;
    }
     if (!defined($options{arguments}->{units}) || $options{arguments}->{units} !~ /^(%|B)$/) {
        $self->{output}->add_option_msg(short_msg => "Wrong units option '" . (defined($options{arguments}->{units}) ? $options{arguments}->{units} : 'null') . "'.");
        $self->{output}->option_exit();
    }
    foreach my $label (('warning', 'critical', 'warning_provisioned', 'critical_provisioned')) {
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
    foreach my $label (('warning', 'critical', 'warning_provisioned', 'critical_provisioned')) {
        $self->{manager}->{perfdata}->threshold_validate(label => $label, value => $options{arguments}->{$label});
    }
}

sub run {
    my $self = shift;

    my $multiple = 0;
    my $filters = $self->build_filter(label => 'name', search_option => 'datastore_name', is_regexp => 'filter');
    my @properties = ('summary');

    my $result = centreon::vmware::common::search_entities(command => $self, view_type => 'Datastore', properties => \@properties, filter => $filters);
    return if (!defined($result));
    
    if (scalar(@$result) > 1) {
        $multiple = 1;
    }
    if ($multiple == 1) {
        $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => sprintf("All Datastore usages are ok"));
    }
    
    foreach my $entity_view (@$result) {
        next if (centreon::vmware::common::datastore_state(connector => $self->{connector},
                                                         name => $entity_view->summary->name, 
                                                         state => $entity_view->summary->accessible,
                                                         status => $self->{disconnect_status},
                                                         multiple => $multiple) == 0);
        
        # capacity 0...
        if ($entity_view->summary->capacity <= 0) {
            if ($multiple == 0) {
                $self->{manager}->{output}->output_add(severity => 'OK',
                                               short_msg => sprintf("datastore size is 0"));
            }
            next;
        }

        # in Bytes
        my $exits = [];
        my $name_storage = $entity_view->summary->name;        
        my $total_size = $entity_view->summary->capacity;
        my $total_free = $entity_view->summary->freeSpace;
        my $total_used = $total_size - $total_free;
        my $prct_used = $total_used * 100 / $total_size;
        my $prct_free = 100 - $prct_used;
        
        my ($total_uncommited, $prct_uncommited);
        my $msg_uncommited = '';
        if (defined($entity_view->summary->uncommitted)) {
            $total_uncommited = $total_used + $entity_view->summary->uncommitted;
            $prct_uncommited = $total_uncommited * 100 / $total_size;
            my ($total_uncommited_value, $total_uncommited_unit) = $self->{manager}->{perfdata}->change_bytes(value => $total_uncommited);
            $msg_uncommited = sprintf(" Provisioned: %s (%.2f%%)", $total_uncommited_value . " " . $total_uncommited_unit, $prct_uncommited);
            push @{$exits}, $self->{manager}->{perfdata}->threshold_check(value => $prct_uncommited, threshold => [ { label => 'critical_provisioned', exit_litteral => 'critical' }, { label => 'warning_provisioned', exit_litteral => 'warning' } ]);
        }
        
        my ($threshold_value);
        $threshold_value = $total_used;
        $threshold_value = $total_free if (defined($self->{free}));
        if ($self->{units} eq '%') {
            $threshold_value = $prct_used;
            $threshold_value = $prct_free if (defined($self->{free}));
        } 
        push @{$exits}, $self->{manager}->{perfdata}->threshold_check(value => $threshold_value, threshold => [ { label => 'critical', exit_litteral => 'critical' }, { label => 'warning', exit_litteral => 'warning' } ]);
        my $exit = $self->{manager}->{output}->get_most_critical(status => $exits);
        
        my ($total_size_value, $total_size_unit) = $self->{manager}->{perfdata}->change_bytes(value => $total_size);
        my ($total_used_value, $total_used_unit) = $self->{manager}->{perfdata}->change_bytes(value => $total_used);
        my ($total_free_value, $total_free_unit) = $self->{manager}->{perfdata}->change_bytes(value => $total_free);

        $self->{manager}->{output}->output_add(long_msg => sprintf("Datastore '%s' Total: %s Used: %s (%.2f%%) Free: %s (%.2f%%)%s", $name_storage,
                                            $total_size_value . " " . $total_size_unit,
                                            $total_used_value . " " . $total_used_unit, $prct_used,
                                            $total_free_value . " " . $total_free_unit, $prct_free,
                                            $msg_uncommited));
        if (!$self->{manager}->{output}->is_status(value => $exit, compare => 'ok', litteral => 1) || $multiple == 0) {
            $self->{manager}->{output}->output_add(severity => $exit,
                                                   short_msg => sprintf("Datastore '%s' Total: %s Used: %s (%.2f%%) Free: %s (%.2f%%)%s", $name_storage,
                                            $total_size_value . " " . $total_size_unit,
                                            $total_used_value . " " . $total_used_unit, $prct_used,
                                            $total_free_value . " " . $total_free_unit, $prct_free,
                                            $msg_uncommited));
        }    

        my $label = 'used';
        my $value_perf = $total_used;
        if (defined($self->{free})) {
            $label = 'free';
            $value_perf = $total_free;
        }
        my $extra_label = '';
        $extra_label = '_' . $name_storage if ($multiple == 1);
        my %total_options = ();
        if ($self->{units} eq '%') {
            $total_options{total} = $total_size;
            $total_options{cast_int} = 1; 
        }
        $self->{manager}->{output}->perfdata_add(label => $label . $extra_label, unit => 'B',
                                                 value => $value_perf,
                                                 warning => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'warning', %total_options),
                                                 critical => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'critical', %total_options),
                                                 min => 0, max => $total_size);
        if (defined($total_uncommited)) {
            $self->{manager}->{output}->perfdata_add(label => 'provisioned' . $extra_label, unit => 'B',
                                                    value => $total_uncommited,
                                                    warning => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'warning_provisioned', total => $total_size, cast_int => 1),
                                                    critical => $self->{manager}->{perfdata}->get_perfdata_for_output(label => 'critical_provisioned', total => $total_size, cast_int => 1),
                                                    min => 0, max => $total_size);
        }
    }
}

1;
