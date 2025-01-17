package Zabbix::API::Trigger;

use strict;
use warnings;
use 5.010;
use Carp;

use parent qw/Zabbix::API::CRUDE/;

sub id {

    ## mutator for id

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{triggerid} = $value;
        return $self->data->{triggerid};

    } else {

        return $self->data->{triggerid};

    }

}

sub prefix {

    my (undef, $suffix) = @_;

    if ($suffix) {

        return 'trigger'.$suffix;

    } else {

        return 'trigger';

    }

}

sub extension {

    return ( output => 'extend',
             select_hosts => 'refer',
             select_items => 'refer',
             select_dependencies => 'extend' );

}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { filter => { description => [ $self->data->{description} ] },
                                              $self->extension })};

}

sub name {

    my $self = shift;

    # can't think of a good name for triggers -- descriptions are too long
    return $self->data->{description};

}

sub hosts {

    ## accessor for host

    my ($self, $value) = @_;

    if (defined $value) {

        croak 'Accessor hosts called as mutator';

    } else {

        unless (exists $self->{hosts}) {

            $self->{hosts} = $self->{root}->fetch('Host', params => { hostids => [ map { $_->{hostid} } @{$self->data->{hosts}} ] });

        }

        return $self->{hosts};

    }

}

sub items {

    ## accessor for host

    my ($self, $value) = @_;

    if (defined $value) {

        croak 'Accessor items called as mutator';

    } else {

        unless (exists $self->{items}) {

            $self->{items} = $self->{root}->fetch('Item', params => { itemids => [ map { $_->{itemid} } @{$self->data->{items}} ] });

        }

        return $self->{items};

    }

}

sub pull {

    # override CRUDE's pull

    my ($self, @args) = @_;

    # because they might have been updated
    delete $self->{hosts};
    delete $self->{items};

    # and now this will set the correct ids, and next time we access the hosts
    # or items they will be up to date
    $self->SUPER::pull(@args);

    return $self;

}

1;
__END__
=pod

=head1 NAME

Zabbix::API::Trigger -- Zabbix trigger objects

=head1 SYNOPSIS

  use Zabbix::API::Trigger;

  # TODO write the rest

=head1 DESCRIPTION

Handles CRUD for Zabbix trigger objects.

This is a subclass of C<Zabbix::API::CRUDE>; see there for inherited methods.

=head1 METHODS

=over 4

=item collides()

Returns true if the trigger exists with this description, false otherwise.

=item hosts()

Accessor for a local C<hosts> attribute, which it also sets from the server data
when necessary (when it is not yet set, which happens when the trigger has just
been fetched or immediately after a pull or push -- this is because a trigger's
notion of its host(s) is "whatever is referred to in the trigger expression").
The value returned is an arrayref of C<Zabbix::API::Host> instances.

=item items()

Same as C<hosts()>, for items.

=back

=head1 BUGS AND LIMITATIONS

The C<expression> data attribute stored in C<Zabbix::API::Trigger> instances is
actually an expression ID.  This is what the web API returns.  Expressions are
also not mapped by the web API, so this is all you get (well, you can get the
list of hosts and items mentioned in the expression).  If you plan on using this
distribution to manipulate trigger expressions, a workaround is to have the
trigger just use a calculated item in a very simple expression, since items work
as expected.

Dependency management is not yet supported, but that's coming soon.

=head1 SEE ALSO

L<Zabbix::API::CRUDE>.

=head1 AUTHOR

Fabrice Gabolde <fabrice.gabolde@uperto.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 Devoteam

This library is free software; you can redistribute it and/or modify it under
the terms of the GPLv3.

=cut
