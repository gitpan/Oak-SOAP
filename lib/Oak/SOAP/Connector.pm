package Oak::SOAP::Connector;

use strict;
use Error qw(:try);
use base qw(Oak::Component);

=head1 NAME

Oak::SOAP::Connector - Connects to a SOAP application

=head1 DESCRIPTION

This module creates an interface to SOAP::Lite.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Persistent|Oak::Persistent>

L<Oak::Component|Oak::Component>

L<Oak::SOAP::Connector|Oak::SOAP::Connector>


=head1 PROPERTIES

=over

=item uri

Mandatory. Universal Resource Identifier. Defines the uri of the service.
See: SOAP::Lite for more help

=item proxy

Mandatory. This property defines the address of the server.
See: SOAP::Lite for more help

=back

=cut

=head1 METHODS

=over

=item connect

Connect to the SOAP server. The constructor calls this function.
The set method calls this function.

=back

=cut

sub connect {
	my $self = shift;
	require SOAP::Lite;
	$self->{__CONNECTOR__} = new SOAP::Lite
	  (
	   uri => $self->get("uri"),
	   proxy => $self->get("proxy"),
	  );
}

sub set {
	my $self = shift;
	my %params = @_;
	my $ret = $self->SUPER::set(%params);
	$self->connect;
	return $ret;
}

=over

=item call(NAME,PARAMS)

Call a method of the remote object, but just return what has been returned
by the remote object

=back

=cut

sub call {
	my $self = shift;
	my $name = shift;
	my @params = @_;
	$self->connect;
	my $som = $self->{__CONNECTOR__}->call($name, @params);
	if ($som->fault) {
		throw Oak::SOAP::Connector::Fault -text => $som->faultstring;
	} else {
		return $som->result;
	}
}

=over

=item call_throws(NAME,PARAMS)

Call a method of the remote object and throws the remote exception if it
does not return a hash ref (Oak::SOAP::Application always do when works)

=back

=cut

sub call_throws {
	my $self = shift;
	my @params = @_;
	my $ret = $self->call(@params);
	if (ref $ret eq 'HASH') {
		return $ret;
	} else {
		my ($class,$message) = split(/;/, $ret, 2);
		eval "require $class";
		if ($@) {
			throw Error::Simple "Cannot remotely-load the class $class - message: $message.";
		} else {
			$class->throw($message);
		}
	}
}


package Oak::SOAP::Connector::Fault;

use base qw(Error);

sub textify {
	my $self = shift;
	return " SOAP Fault: ".$self->text;
}


1;

__END__

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
Aguimar Mendonca Neto <aguimar@email.com.br>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
