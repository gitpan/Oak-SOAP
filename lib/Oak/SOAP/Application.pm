package Oak::SOAP::Application;

use base qw(Oak::Application);
use SOAP::Transport::TCP;
use Error qw(:try);
use strict;

=head1 NAME

Oak::SOAP::Application - SOAP Application for Oak::Controller objects

=head1 HIERARCHY

L<Oak::Object>

L<Oak::Application>

L<Oak::SOAP::Application>

=head1 DESCRIPTION

This module creates a SOAP server for mapping the Oak::Controller objects to
a uri. To do this, it will use a fourth parameter in the toplevel info passed
to new. In a SOAP application, you need to set all the Toplevels to persistent.
This is done, by setting to 1 the third parameter of the toplevel info.

=head1 METHODS

=over

=item run(LocalAddr => $addr, LocalPort => $port, Listen => $num, Reuse => $bool)

The Oak::SOAP::Application uses the SOAP::Transport::TCP::Server module, provided
by the SOAP::Lite CPAN package.

=back

=cut

sub run {
	my $self = shift;
	my %params = @_;
	while (@_) {
		shift;
	}
	my $daemon = SOAP::Transport::TCP::Server->new
	  (
	   LocalAddr => $params{LocalAddr},
	   LocalPort => $params{LocalPort},
	   Listen => $params{Listen},
	   Reuse => $params{Reuse}
	  );
	my %dispatchers;
	foreach my $name (keys %{$self->get('topLevels')}) {
		my $toplevel = $self->get('topLevels')->{$name};
		next if ref $toplevel ne "ARRAY";
		next unless $toplevel->[3];
		my %functions;
		no strict 'names','refs';
		foreach my $k ($ {"::TL::$name"}->list_childs) {
			*{"Oak::SOAP::Application::AUTO::${name}::${k}"} = sub {
				my $class = shift;
				my %params = @_;
				$k = $k;
				$name = $name;
				try {
					return $ {"::TL::$name"}->message($k,%params);
				} otherwise {
					my $e = shift;
					return ref($e).";".$e->text;
				}
			};
		}
		$dispatchers{"/$name"} = "Oak::SOAP::Application::AUTO::".$name;
	}
	$daemon->dispatch_with(\%dispatchers);
	$daemon->handle;
}

1;

__END__

=head1 EXAMPLES


  use Oak::SOAP::Application;
  
  my $serv = new Oak::SOAP::Application
    (
     ctrlStates => ["ctrlStates","ctrlStates::DATA",1,1]
    );
  
  $serv->run
    (
     LocalAddr => 'localhost',
     LocalPort => 1234,
     Listen => 5,
     Reuse => 1
    );
  
  
=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com> and
Rodolfo Sikora <rodolfo@trevas.net>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.


=cut

