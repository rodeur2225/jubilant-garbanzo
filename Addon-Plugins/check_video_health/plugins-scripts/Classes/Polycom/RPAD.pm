package Classes::Polycom::RPAD;
our @ISA = qw(Classes::Polycom);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem("Classes::HOSTRESOURCESMIB::Component::EnvironmentalSubsystem");
  } elsif ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("Classes::UCDMIB::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("Classes::UCDMIB::Component::MemSubsystem");
  } elsif ($self->mode =~ /device::videophone::health/) {
    $self->analyze_and_check_environmental_subsystem("Classes::POLYCOMACCESSMANAGEMENTMIB::Component::EnvironmentalSubsystem");
  } else {
    $self->no_such_mode();
  }
}

