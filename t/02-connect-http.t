use strict;
use Error qw(:try);
use File::Spec;
use IO::File;
use Test::More;

# Globals
my $todo = 13;
my $done = 0;
my $copy_opt = {
    client_host => 1,
    client_user => 1,
    freedb_cgi => 1,
    freedb_host => 1,
    freedb_port => 1,
    proxy_host => 1,
    proxy_passwd => 1,
    proxy_port => 1,
    proxy_user => 1,
};

# Start plan
plan ( tests => $todo );

# 1) Test require InfoSys::FreeDB
require_ok( 'InfoSys::FreeDB' );
$done++; $todo--;

# 2) Test require InfoSys::FreeDB::Entry
require_ok( 'InfoSys::FreeDB::Entry' );
$done++; $todo--;

# 3) Read options
if ( &read_options() ) {
    ok( 0, 'Read t/options' ); $done++; $todo--;
    my_skip( 'cannot proceed' );
}
ok( 1, "Read t/options" ); $done++; $todo--;

# 4) Test factory
my $fact;
try {
    $fact = InfoSys::FreeDB->new();
}
catch Error::Simple with {
    ok( 0, 'Failed to instanciate a connection factory' ); $done++; $todo--;
    my_skip( 'Failed to instanciate a connection factory' );
};
ok( 1, "Instanciate factory" ); $done++; $todo--;

# 5-13) Test http connection
&test_http();

# Exit
exit(0);

sub test_http {
    SKIP: {
        # Check for skip
        if ( ! $::opt{test_http} ) {
            my $fn = File::Spec->catfile( 't', 'options' );
            my_skip( "test_http is not set in file '$fn'" );
        }

        # 5) Create connection
        my $connection;
        try {
            my $opt = {
                protocol => 'HTTP',
                client_name => 'InfoSys_FreeDB_Test',
                client_version => $InfoSys::FreeDB::VERSION,
            };
            foreach my $key ( keys( %::opt ) ) {
                exists( $copy_opt->{$key} ) ||
                    next;
                $opt->{$key} = $::opt{$key};
            }
            $connection = $fact->create_connection( $opt );
        }
        catch Error::Simple with {
            ok( 0, 'Failed to create a HTTP connection' ); $done++; $todo--;
            my_skip( 'Failed to create a HTTP connection' );
        };
        ok( 1, 'Create HTTP connection' ); $done++; $todo--;

        # 6) Motd
        my $res;
        try {
            $res = $connection->motd();
        }
        catch Error::Simple with {
            ok( 0, 'Command \'motd\' failed' ); $done++; $todo--;
            my_skip( 'Command \'motd\' failed' );
        };
        ok( 1, 'Command \'motd\'' ); $done++; $todo--;

        # 7) Lscat
        try {
            $res = $connection->lscat();
        }
        catch Error::Simple with {
            ok( 0, 'Command to \'lscat\' failed' ); $done++; $todo--;
            my_skip( 'Command \'lscat\' failed' );
        };
        ok( 1, 'Command \'lscat\'' ); $done++; $todo--;

        # 8) Sites
        try {
            $res = $connection->sites();
        }
        catch Error::Simple with {
            ok( 0, 'Command to \'sites\' failed' ); $done++; $todo--;
            my_skip( 'Command \'sites\' failed' );
        };
        ok( 1, 'Command \'sites\'' ); $done++; $todo--;

        # 9) Stat
        try {
            $res = $connection->stat();
        }
        catch Error::Simple with {
            ok( 0, 'Command to \'stat\' failed' ); $done++; $todo--;
            my_skip( 'Command \'stat\' failed' );
        };
        ok( 1, 'Command \'stat\'' ); $done++; $todo--;

        # 10) Whom
        try {
            $res = $connection->whom();
        }
        catch Error::Simple with {
            ok( 0, 'Command to \'whom\' failed' ); $done++; $todo--;
            my_skip( 'Command \'whom\' failed' );
        };
        ok( 1, 'Command \'whom\'' ); $done++; $todo--;

        # 11) Ver
        try {
            $res = $connection->ver();
        }
        catch Error::Simple with {
            ok( 0, 'Command to \'ver\' failed' ); $done++; $todo--;
            my_skip( 'Command \'ver\' failed' );
        };
        ok( 1, 'Command \'ver\'' ); $done++; $todo--;

        # 12) Read entry
        my $entry_fn = File::Spec->catfile( 'sample', 'jaco-test-in.entry');
        my $entry;
        try {
            $entry = InfoSys::FreeDB::Entry->new_from_fn( $entry_fn );
        }
        catch Error::Simple with {
            my $ex = shift;
            ok( 0, "Create entry out of \'$entry_fn\' failed" ); $done++; $todo--;
            my_skip( "Create entry out of \'$entry_fn\' failed" );
        };
        ok( 1, "Create entry out of \'$entry_fn\'" ); $done++; $todo--;

        # 13) discid
        try {
            $res = $connection->discid( $entry );
        }
        catch Error::Simple with {
            ok( 0, 'Command \'discid\' failed' ); $done++; $todo--;
            my_skip( 'Command \'discid\' failed' );
        };
        ok( 1, 'Command \'discid\'' ); $done++; $todo--;
    }
}


sub read_options {
    my $fn = File::Spec->catfile( 't', 'options' );
    my $fh = IO::File->new("< $fn");
    defined($fh) ||
       return(1);
    %::opt = ();
    while ( my $line = $fh->getline() ) {
        $line =~ s/\s+$//;
        $line =~ s/#.*$//;
        my ($attr, $val) = $line =~ /([^:]+):(.*)/;
        $attr =~ s/^\s+//; $attr =~ s/\s+$//;
        $val =~ s/^\s+//; $val =~ s/\s+$//;
        $attr ||
            next;
        $val ||
            next;
        $::opt{$attr} = $val;
    }
   return(0);
}

sub my_skip {
    my $msg = shift;

    skip( $msg, $todo );
}

