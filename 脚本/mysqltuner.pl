#!/usr/bin/env perl
# mysqltuner.pl - Version 1.7.19
# High Performance MySQL Tuning Script
# Copyright (C) 2006-2018 Major Hayden - major@mhtx.net
#
# For the latest updates, please visit http://mysqltuner.com/
# Git repository available at https://github.com/major/MySQLTuner-perl
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# This project would not be possible without help from:
#   Matthew Montgomery     Paul Kehrer          Dave Burgess
#   Jonathan Hinds         Mike Jackson         Nils Breunese
#   Shawn Ashlee           Luuk Vosslamber      Ville Skytta
#   Trent Hornibrook       Jason Gill           Mark Imbriaco
#   Greg Eden              Aubin Galinotti      Giovanni Bechis
#   Bill Bradford          Ryan Novosielski     Michael Scheidell
#   Blair Christensen      Hans du Plooy        Victor Trac
#   Everett Barnes         Tom Krouper          Gary Barrueto
#   Simon Greenaway        Adam Stein           Isart Montane
#   Baptiste M.            Cole Turner          Major Hayden
#   Joe Ashcraft           Jean-Marie Renouard  Christian Loos
#   Julien Francoz
#
# Inspired by Matthew Montgomery's tuning-primer.sh script:
# http://www.day32.com/MySQL/
#
package main;

use 5.005;
use strict;
use warnings;

use diagnostics;
use File::Spec;
use Getopt::Long;
use Pod::Usage;
use File::Basename;
use Cwd 'abs_path';

use Data::Dumper;
$Data::Dumper::Pair = " : ";

# for which()
#use Env;

# Set up a few variables for use in the script
my $tunerversion = "1.7.19";
my ( @adjvars, @generalrec );

# Set defaults
my %opt = (
    "silent"         => 0,
    "nobad"          => 0,
    "nogood"         => 0,
    "noinfo"         => 0,
    "debug"          => 0,
    "nocolor"        => ( !-t STDOUT ),
    "color"          => 0,
    "forcemem"       => 0,
    "forceswap"      => 0,
    "host"           => 0,
    "socket"         => 0,
    "port"           => 0,
    "user"           => 0,
    "pass"           => 0,
    "password"       => 0,
    "ssl-ca"         => 0,
    "skipsize"       => 0,
    "checkversion"   => 0,
    "updateversion"  => 0,
    "buffers"        => 0,
    "passwordfile"   => 0,
    "bannedports"    => '',
    "maxportallowed" => 0,
    "outputfile"     => 0,
    "noprocess"      => 0,
    "dbstat"         => 0,
    "nodbstat"       => 0,
    "tbstat"         => 0,
    "notbstat"       => 0,
    "idxstat"        => 0,
    "noidxstat"      => 0,
    "sysstat"        => 0,
    "nosysstat"      => 0,
    "pfstat"         => 0,
    "nopfstat"       => 0,
    "skippassword"   => 0,
    "noask"          => 0,
    "template"       => 0,
    "json"           => 0,
    "prettyjson"     => 0,
    "reportfile"     => 0,
    "verbose"        => 0,
    "defaults-file"  => '',
);

# Gather the options from the command line
GetOptions(
    \%opt,             'nobad',
    'nogood',          'noinfo',
    'debug',           'nocolor',
    'forcemem=i',      'forceswap=i',
    'host=s',          'socket=s',
    'port=i',          'user=s',
    'pass=s',          'skipsize',
    'checkversion',    'mysqladmin=s',
    'mysqlcmd=s',      'help',
    'buffers',         'skippassword',
    'passwordfile=s',  'outputfile=s',
    'silent',          'noask',
    'json',            'prettyjson',
    'template=s',      'reportfile=s',
    'cvefile=s',       'bannedports=s',
    'updateversion',   'maxportallowed=s',
    'verbose',         'password=s',
    'passenv=s',       'userenv=s',
    'defaults-file=s', 'ssl-ca=s',
    'color',           'noprocess',
    'dbstat',          'nodbstat',
    'tbstat',          'notbstat',
    'sysstat',         'nosysstat',
    'pfstat',          'nopfstat',
    'idxstat',         'noidxstat',
  )
  or pod2usage(
    -exitval  => 1,
    -verbose  => 99,
    -sections => [
        "NAME",
        "IMPORTANT USAGE GUIDELINES",
        "CONNECTION AND AUTHENTICATION",
        "PERFORMANCE AND REPORTING OPTIONS",
        "OUTPUT OPTIONS"
    ]
  );

if ( defined $opt{'help'} && $opt{'help'} == 1 ) {
    pod2usage(
        -exitval  => 0,
        -verbose  => 99,
        -sections => [
            "NAME",
            "IMPORTANT USAGE GUIDELINES",
            "CONNECTION AND AUTHENTICATION",
            "PERFORMANCE AND REPORTING OPTIONS",
            "OUTPUT OPTIONS"
        ]
    );
}

my $devnull = File::Spec->devnull();
my $basic_password_files =
  ( $opt{passwordfile} eq "0" )
  ? abs_path( dirname(__FILE__) ) . "/basic_passwords.txt"
  : abs_path( $opt{passwordfile} );

# Username from envvar
if ( exists $opt{userenv} && exists $ENV{ $opt{userenv} } ) {
    $opt{user} = $ENV{ $opt{userenv} };
}

# Related to password option
if ( exists $opt{passenv} && exists $ENV{ $opt{passenv} } ) {
    $opt{pass} = $ENV{ $opt{passenv} };
}
$opt{pass} = $opt{password} if ( $opt{pass} eq 0 and $opt{password} ne 0 );

# for RPM distributions
$basic_password_files = "/usr/share/mysqltuner/basic_passwords.txt"
  unless -f "$basic_password_files";

# check if we need to enable verbose mode
if ( $opt{verbose} ) {
    $opt{checkversion} = 1;    #Check for updates to MySQLTuner
    $opt{dbstat}       = 1;    #Print database information
    $opt{tbstat}       = 1;    #Print database information
    $opt{idxstat}      = 1;    #Print index information
    $opt{sysstat}      = 1;    #Print index information
    $opt{buffers}      = 1;    #Print global and per-thread buffer values
    $opt{pfstat}       = 1;    #Print performance schema info.
    $opt{cvefile} = 'vulnerabilities.csv';    #CVE File for vulnerability checks
}
$opt{nocolor} = 1 if defined( $opt{outputfile} );
$opt{tbstat}  = 0 if ( $opt{notbstat} == 1 );    # Don't Print table information
$opt{dbstat} = 0 if ( $opt{nodbstat} == 1 );  # Don't Print database information
$opt{noprocess} = 0
  if ( $opt{noprocess} == 1 );                # Don't Print process information
$opt{sysstat} = 0 if ( $opt{nosysstat} == 1 ); # Don't Print sysstat information
$opt{pfstat}  = 0
  if ( $opt{nopfstat} == 1 );    # Don't Print performance schema information
$opt{idxstat} = 0 if ( $opt{noidxstat} == 1 );   # Don't Print index information

# for RPM distributions
$opt{cvefile} = "/usr/share/mysqltuner/vulnerabilities.csv"
  unless ( defined $opt{cvefile} and -f "$opt{cvefile}" );
$opt{cvefile} = '' unless -f "$opt{cvefile}";
$opt{cvefile} = './vulnerabilities.csv' if -f './vulnerabilities.csv';

$opt{'bannedports'} = '' unless defined( $opt{'bannedports'} );
my @banned_ports = split ',', $opt{'bannedports'};

#
my $outputfile = undef;
$outputfile = abs_path( $opt{outputfile} ) unless $opt{outputfile} eq "0";

my $fh = undef;
open( $fh, '>', $outputfile )
  or die("Fail opening $outputfile")
  if defined($outputfile);
$opt{nocolor} = 1 if defined($outputfile);
$opt{nocolor} = 1 unless ( -t STDOUT );

$opt{nocolor} = 0 if ( $opt{color} == 1 );

# Setting up the colors for the print styles
my $me = `whoami`;
$me =~ s/\n//g;

# Setting up the colors for the print styles
my $good = ( $opt{nocolor} == 0 ) ? "[\e[0;32mOK\e[0m]"  : "[OK]";
my $bad  = ( $opt{nocolor} == 0 ) ? "[\e[0;31m!!\e[0m]"  : "[!!]";
my $info = ( $opt{nocolor} == 0 ) ? "[\e[0;34m--\e[0m]"  : "[--]";
my $deb  = ( $opt{nocolor} == 0 ) ? "[\e[0;31mDG\e[0m]"  : "[DG]";
my $cmd  = ( $opt{nocolor} == 0 ) ? "\e[1;32m[CMD]($me)" : "[CMD]($me)";
my $end  = ( $opt{nocolor} == 0 ) ? "\e[0m"              : "";

# Checks for supported or EOL'ed MySQL versions
my ( $mysqlvermajor, $mysqlverminor, $mysqlvermicro );

# Super structure containing all information
my %result;
$result{'MySQLTuner'}{'version'} = $tunerversion;
$result{'MySQLTuner'}{'options'} = \%opt;

# Functions that handle the print styles
sub prettyprint {
    print $_[0] . "\n" unless ( $opt{'silent'} or $opt{'json'} );
    print $fh $_[0] . "\n" if defined($fh);
}
sub goodprint  { prettyprint $good. " " . $_[0] unless ( $opt{nogood} == 1 ); }
sub infoprint  { prettyprint $info. " " . $_[0] unless ( $opt{noinfo} == 1 ); }
sub badprint   { prettyprint $bad. " " . $_[0]  unless ( $opt{nobad} == 1 ); }
sub debugprint { prettyprint $deb. " " . $_[0]  unless ( $opt{debug} == 0 ); }

sub redwrap {
    return ( $opt{nocolor} == 0 ) ? "\e[0;31m" . $_[0] . "\e[0m" : $_[0];
}

sub greenwrap {
    return ( $opt{nocolor} == 0 ) ? "\e[0;32m" . $_[0] . "\e[0m" : $_[0];
}
sub cmdprint { prettyprint $cmd. " " . $_[0] . $end; }

sub infoprintml {
    for my $ln (@_) { $ln =~ s/\n//g; infoprint "\t$ln"; }
}

sub infoprintcmd {
    cmdprint "@_";
    infoprintml grep { $_ ne '' and $_ !~ /^\s*$/ } `@_ 2>&1`;
}

sub subheaderprint {
    my $tln = 100;
    my $sln = 8;
    my $ln  = length("@_") + 2;

    prettyprint " ";
    prettyprint "-" x $sln . " @_ " . "-" x ( $tln - $ln - $sln );
}

sub infoprinthcmd {
    subheaderprint "$_[0]";
    infoprintcmd "$_[1]";
}

# Calculates the number of physical cores considering HyperThreading
sub cpu_cores {
    my $cntCPU =
`awk -F: '/^core id/ && !P[\$2] { CORES++; P[\$2]=1 }; /^physical id/ && !N[\$2] { CPUs++; N[\$2]=1 };  END { print CPUs*CORES }' /proc/cpuinfo`;
    return ( $cntCPU == 0 ? `nproc` : $cntCPU );
}

# Calculates the parameter passed in bytes, then rounds it to one decimal place
sub hr_bytes {
    my $num = shift;
    return "0B" unless defined($num);
    return "0B" if $num eq "NULL";

    if ( $num >= ( 1024**3 ) ) {    #GB
        return sprintf( "%.1f", ( $num / ( 1024**3 ) ) ) . "G";
    }
    elsif ( $num >= ( 1024**2 ) ) {    #MB
        return sprintf( "%.1f", ( $num / ( 1024**2 ) ) ) . "M";
    }
    elsif ( $num >= 1024 ) {           #KB
        return sprintf( "%.1f", ( $num / 1024 ) ) . "K";
    }
    else {
        return $num . "B";
    }
}

sub hr_raw {
    my $num = shift;
    return "0" unless defined($num);
    return "0" if $num eq "NULL";
    if ( $num =~ /^(\d+)G$/ ) {
        return $1 * 1024 * 1024 * 1024;
    }
    if ( $num =~ /^(\d+)M$/ ) {
        return $1 * 1024 * 1024;
    }
    if ( $num =~ /^(\d+)K$/ ) {
        return $1 * 1024;
    }
    if ( $num =~ /^(\d+)$/ ) {
        return $1;
    }
    return $num;
}

# Calculates the parameter passed in bytes, then rounds it to the nearest integer
sub hr_bytes_rnd {
    my $num = shift;
    return "0B" unless defined($num);
    return "0B" if $num eq "NULL";

    if ( $num >= ( 1024**3 ) ) {    #GB
        return int( ( $num / ( 1024**3 ) ) ) . "G";
    }
    elsif ( $num >= ( 1024**2 ) ) {    #MB
        return int( ( $num / ( 1024**2 ) ) ) . "M";
    }
    elsif ( $num >= 1024 ) {           #KB
        return int( ( $num / 1024 ) ) . "K";
    }
    else {
        return $num . "B";
    }
}

# Calculates the parameter passed to the nearest power of 1000, then rounds it to the nearest integer
sub hr_num {
    my $num = shift;
    if ( $num >= ( 1000**3 ) ) {       # Billions
        return int( ( $num / ( 1000**3 ) ) ) . "B";
    }
    elsif ( $num >= ( 1000**2 ) ) {    # Millions
        return int( ( $num / ( 1000**2 ) ) ) . "M";
    }
    elsif ( $num >= 1000 ) {           # Thousands
        return int( ( $num / 1000 ) ) . "K";
    }
    else {
        return $num;
    }
}

# Calculate Percentage
sub percentage {
    my $value = shift;
    my $total = shift;
    $total = 0 unless defined $total;
    $total = 0 if $total eq "NULL";
    return 100, 00 if $total == 0;
    return sprintf( "%.2f", ( $value * 100 / $total ) );
}

# Calculates uptime to display in a more attractive form
sub pretty_uptime {
    my $uptime  = shift;
    my $seconds = $uptime % 60;
    my $minutes = int( ( $uptime % 3600 ) / 60 );
    my $hours   = int( ( $uptime % 86400 ) / (3600) );
    my $days    = int( $uptime / (86400) );
    my $uptimestring;
    if ( $days > 0 ) {
        $uptimestring = "${days}d ${hours}h ${minutes}m ${seconds}s";
    }
    elsif ( $hours > 0 ) {
        $uptimestring = "${hours}h ${minutes}m ${seconds}s";
    }
    elsif ( $minutes > 0 ) {
        $uptimestring = "${minutes}m ${seconds}s";
    }
    else {
        $uptimestring = "${seconds}s";
    }
    return $uptimestring;
}

# Retrieves the memory installed on this machine
my ( $physical_memory, $swap_memory, $duflags );

sub memerror {
    badprint
"Unable to determine total memory/swap; use '--forcemem' and '--forceswap'";
    exit 1;
}

sub os_setup {
    my $os = `uname`;
    $duflags = ( $os =~ /Linux/ ) ? '-b' : '';
    if ( $opt{'forcemem'} > 0 ) {
        $physical_memory = $opt{'forcemem'} * 1048576;
        infoprint "Assuming $opt{'forcemem'} MB of physical memory";
        if ( $opt{'forceswap'} > 0 ) {
            $swap_memory = $opt{'forceswap'} * 1048576;
            infoprint "Assuming $opt{'forceswap'} MB of swap space";
        }
        else {
            $swap_memory = 0;
            badprint "Assuming 0 MB of swap space (use --forceswap to specify)";
        }
    }
    else {
        if ( $os =~ /Linux|CYGWIN/ ) {
            $physical_memory =
              `grep -i memtotal: /proc/meminfo | awk '{print \$2}'`
              or memerror;
            $physical_memory *= 1024;

            $swap_memory =
              `grep -i swaptotal: /proc/meminfo | awk '{print \$2}'`
              or memerror;
            $swap_memory *= 1024;
        }
        elsif ( $os =~ /Darwin/ ) {
            $physical_memory = `sysctl -n hw.memsize` or memerror;
            $swap_memory =
              `sysctl -n vm.swapusage | awk '{print \$3}' | sed 's/\..*\$//'`
              or memerror;
        }
        elsif ( $os =~ /NetBSD|OpenBSD|FreeBSD/ ) {
            $physical_memory = `sysctl -n hw.physmem` or memerror;
            if ( $physical_memory < 0 ) {
                $physical_memory = `sysctl -n hw.physmem64` or memerror;
            }
            $swap_memory =
              `swapctl -l | grep '^/' | awk '{ s+= \$2 } END { print s }'`
              or memerror;
        }
        elsif ( $os =~ /BSD/ ) {
            $physical_memory = `sysctl -n hw.realmem` or memerror;
            $swap_memory =
              `swapinfo | grep '^/' | awk '{ s+= \$2 } END { print s }'`;
        }
        elsif ( $os =~ /SunOS/ ) {
            $physical_memory =
              `/usr/sbin/prtconf | grep Memory | cut -f 3 -d ' '`
              or memerror;
            chomp($physical_memory);
            $physical_memory = $physical_memory * 1024 * 1024;
        }
        elsif ( $os =~ /AIX/ ) {
            $physical_memory =
              `lsattr -El sys0 | grep realmem | awk '{print \$2}'`
              or memerror;
            chomp($physical_memory);
            $physical_memory = $physical_memory * 1024;
            $swap_memory     = `lsps -as | awk -F"(MB| +)" '/MB /{print \$2}'`
              or memerror;
            chomp($swap_memory);
            $swap_memory = $swap_memory * 1024 * 1024;
        }
        elsif ( $os =~ /windows/i ) {
            $physical_memory =
`wmic ComputerSystem get TotalPhysicalMemory | perl -ne "chomp; print if /[0-9]+/;"`
              or memerror;
            $swap_memory =
`wmic OS get FreeVirtualMemory | perl -ne "chomp; print if /[0-9]+/;"`
              or memerror;
        }
    }
    debugprint "Physical Memory: $physical_memory";
    debugprint "Swap Memory: $swap_memory";
    chomp($physical_memory);
    chomp($swap_memory);
    chomp($os);
    $result{'OS'}{'OS Type'}                   = $os;
    $result{'OS'}{'Physical Memory'}{'bytes'}  = $physical_memory;
    $result{'OS'}{'Physical Memory'}{'pretty'} = hr_bytes($physical_memory);
    $result{'OS'}{'Swap Memory'}{'bytes'}      = $swap_memory;
    $result{'OS'}{'Swap Memory'}{'pretty'}     = hr_bytes($swap_memory);
    $result{'OS'}{'Other Processes'}{'bytes'}  = get_other_process_memory();
    $result{'OS'}{'Other Processes'}{'pretty'} =
      hr_bytes( get_other_process_memory() );
}

sub get_http_cli {
    my $httpcli = which( "curl", $ENV{'PATH'} );
    chomp($httpcli);
    if ($httpcli) {
        return $httpcli;
    }

    $httpcli = which( "wget", $ENV{'PATH'} );
    chomp($httpcli);
    if ($httpcli) {
        return $httpcli;
    }
    return "";
}

# Checks for updates to MySQLTuner
sub validate_tuner_version {
    if ( $opt{'checkversion'} eq 0 ) {
        print "\n" unless ( $opt{'silent'} or $opt{'json'} );
        infoprint "Skipped version check for MySQLTuner script";
        return;
    }

    my $update;
    my $url =
"https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl";
    my $httpcli = get_http_cli();
    if ( $httpcli =~ /curl$/ ) {
        debugprint "$httpcli is available.";

        debugprint
"$httpcli -m 3 -silent '$url' 2>/dev/null | grep 'my \$tunerversion'| cut -d\\\" -f2";
        $update =
`$httpcli -m 3 -silent '$url' 2>/dev/null | grep 'my \$tunerversion'| cut -d\\\" -f2`;
        chomp($update);
        debugprint "VERSION: $update";

        compare_tuner_version($update);
        return;
    }

    if ( $httpcli =~ /wget$/ ) {
        debugprint "$httpcli is available.";

        debugprint
"$httpcli -e timestamping=off -t 1 -T 3 -O - '$url' 2>$devnull| grep 'my \$tunerversion'| cut -d\\\" -f2";
        $update =
`$httpcli -e timestamping=off -t 1 -T 3 -O - '$url' 2>$devnull| grep 'my \$tunerversion'| cut -d\\\" -f2`;
        chomp($update);
        compare_tuner_version($update);
        return;
    }
    debugprint "curl and wget are not available.";
    infoprint "Unable to check for the latest MySQLTuner version";
    infoprint
"Using --pass and --password option is insecure during MySQLTuner execution(Password disclosure)"
      if ( defined( $opt{'pass'} ) );
}

# Checks for updates to MySQLTuner
sub update_tuner_version {
    if ( $opt{'updateversion'} eq 0 ) {
        badprint "Skipped version update for MySQLTuner script";
        print "\n" unless ( $opt{'silent'} or $opt{'json'} );
        return;
    }

    my $update;
    my $url = "https://raw.githubusercontent.com/major/MySQLTuner-perl/master/";
    my @scripts =
      ( "mysqltuner.pl", "basic_passwords.txt", "vulnerabilities.csv" );
    my $totalScripts    = scalar(@scripts);
    my $receivedScripts = 0;
    my $httpcli         = get_http_cli();

    foreach my $script (@scripts) {

        if ( $httpcli =~ /curl$/ ) {
            debugprint "$httpcli is available.";

            debugprint
              "$httpcli --connect-timeout 3 '$url$script' 2>$devnull > $script";
            $update =
              `$httpcli --connect-timeout 3 '$url$script' 2>$devnull > $script`;
            chomp($update);
            debugprint "$script updated: $update";

            if ( -s $script eq 0 ) {
                badprint "Couldn't update $script";
            }
            else {
                ++$receivedScripts;
                debugprint "$script updated: $update";
            }
        }
        elsif ( $httpcli =~ /wget$/ ) {

            debugprint "$httpcli is available.";

            debugprint
"$httpcli -qe timestamping=off -t 1 -T 3 -O $script '$url$script'";
            $update =
`$httpcli -qe timestamping=off -t 1 -T 3 -O $script '$url$script'`;
            chomp($update);

            if ( -s $script eq 0 ) {
                badprint "Couldn't update $script";
            }
            else {
                ++$receivedScripts;
                debugprint "$script updated: $update";
            }
        }
        else {
            debugprint "curl and wget are not available.";
            infoprint "Unable to check for the latest MySQLTuner version";
        }

    }

    if ( $receivedScripts eq $totalScripts ) {
        goodprint "Successfully updated MySQLTuner script";
    }
    else {
        badprint "Couldn't update MySQLTuner script";
    }
    infoprint "Stopping program: MySQLTuner has be updated.";
    exit 0;
}

sub compare_tuner_version {
    my $remoteversion = shift;
    debugprint "Remote data: $remoteversion";

    #exit 0;
    if ( $remoteversion ne $tunerversion ) {
        badprint
          "There is a new version of MySQLTuner available($remoteversion)";
        update_tuner_version();
        return;
    }
    goodprint "You have the latest version of MySQLTuner($tunerversion)";
    return;
}

# Checks to see if a MySQL login is possible
my ( $mysqllogin, $doremote, $remotestring, $mysqlcmd, $mysqladmincmd );

my $osname = $^O;
if ( $osname eq 'MSWin32' ) {
    eval { require Win32; } or last;
    $osname = Win32::GetOSName();
    infoprint "* Windows OS($osname) is not fully supported.\n";

    #exit 1;
}

sub mysql_setup {
    $doremote     = 0;
    $remotestring = '';
    if ( $opt{mysqladmin} ) {
        $mysqladmincmd = $opt{mysqladmin};
    }
    else {
        $mysqladmincmd = which( "mysqladmin", $ENV{'PATH'} );
    }
    chomp($mysqladmincmd);
    if ( !-e $mysqladmincmd && $opt{mysqladmin} ) {
        badprint "Unable to find the mysqladmin command you specified: "
          . $mysqladmincmd . "";
        exit 1;
    }
    elsif ( !-e $mysqladmincmd ) {
        badprint "Couldn't find mysqladmin in your \$PATH. Is MySQL installed?";
        exit 1;
    }
    if ( $opt{mysqlcmd} ) {
        $mysqlcmd = $opt{mysqlcmd};
    }
    else {
        $mysqlcmd = which( "mysql", $ENV{'PATH'} );
    }
    chomp($mysqlcmd);
    if ( !-e $mysqlcmd && $opt{mysqlcmd} ) {
        badprint "Unable to find the mysql command you specified: "
          . $mysqlcmd . "";
        exit 1;
    }
    elsif ( !-e $mysqlcmd ) {
        badprint "Couldn't find mysql in your \$PATH. Is MySQL installed?";
        exit 1;
    }
    $mysqlcmd =~ s/\n$//g;
    my $mysqlclidefaults = `$mysqlcmd --print-defaults`;
    debugprint "MySQL Client: $mysqlclidefaults";
    if ( $mysqlclidefaults =~ /auto-vertical-output/ ) {
        badprint
          "Avoid auto-vertical-output in configuration file(s) for MySQL like";
        exit 1;
    }

    debugprint "MySQL Client: $mysqlcmd";

    $opt{port} = ( $opt{port} eq 0 ) ? 3306 : $opt{port};

    # Are we being asked to connect via a socket?
    if ( $opt{socket} ne 0 ) {
        $remotestring = " -S $opt{socket} -P $opt{port}";
    }

    # Are we being asked to connect to a remote server?
    if ( $opt{host} ne 0 ) {
        chomp( $opt{host} );

# If we're doing a remote connection, but forcemem wasn't specified, we need to exit
        if (   $opt{'forcemem'} eq 0
            && ( $opt{host} ne "127.0.0.1" )
            && ( $opt{host} ne "localhost" ) )
        {
            badprint "The --forcemem option is required for remote connections";
            exit 1;
        }
        infoprint "Performing tests on $opt{host}:$opt{port}";
        $remotestring = " -h $opt{host} -P $opt{port}";
        if ( ( $opt{host} ne "127.0.0.1" ) && ( $opt{host} ne "localhost" ) ) {
            $doremote = 1;
        }
    }
    else {
        $opt{host} = '127.0.0.1';
    }

    if ( $opt{'ssl-ca'} ne 0 ) {
        if ( -e -r -f $opt{'ssl-ca'} ) {
            $remotestring .= " --ssl-ca=$opt{'ssl-ca'}";
            infoprint
              "Will connect using ssl public key passed on the command line";
            return 1;
        }
        else {
            badprint
"Attempted to use passed ssl public key, but it was not found or could not be read";
            exit 1;
        }
    }

    # Did we already get a username without password on the command line?
    if ( $opt{user} ne 0 and $opt{pass} eq 0 ) {
        $mysqllogin = "-u $opt{user} " . $remotestring;
        my $loginstatus = `$mysqladmincmd ping $mysqllogin 2>&1`;
        if ( $loginstatus =~ /mysqld is alive/ ) {
            goodprint "Logged in using credentials passed on the command line";
            return 1;
        }
        else {
            badprint
              "Attempted to use login credentials, but they were invalid";
            exit 1;
        }
    }

    # Did we already get a username and password passed on the command line?
    if ( $opt{user} ne 0 and $opt{pass} ne 0 ) {
        $mysqllogin = "-u $opt{user} -p'$opt{pass}'" . $remotestring;
        my $loginstatus = `$mysqladmincmd ping $mysqllogin 2>&1`;
        if ( $loginstatus =~ /mysqld is alive/ ) {
            goodprint "Logged in using credentials passed on the command line";
            return 1;
        }
        else {
            badprint
              "Attempted to use login credentials, but they were invalid";
            exit 1;
        }
    }
    my $svcprop = which( "svcprop", $ENV{'PATH'} );
    if ( substr( $svcprop, 0, 1 ) =~ "/" ) {

        # We are on solaris
        ( my $mysql_login =
`svcprop -p quickbackup/username svc:/network/mysql-quickbackup:default`
        ) =~ s/\s+$//;
        ( my $mysql_pass =
`svcprop -p quickbackup/password svc:/network/mysql-quickbackup:default`
        ) =~ s/\s+$//;
        if ( substr( $mysql_login, 0, 7 ) ne "svcprop" ) {

            # mysql-quickbackup is installed
            $mysqllogin = "-u $mysql_login -p$mysql_pass";
            my $loginstatus = `mysqladmin $mysqllogin ping 2>&1`;
            if ( $loginstatus =~ /mysqld is alive/ ) {
                goodprint "Logged in using credentials from mysql-quickbackup.";
                return 1;
            }
            else {
                badprint
"Attempted to use login credentials from mysql-quickbackup, but they failed.";
                exit 1;
            }
        }
    }
    elsif ( -r "/etc/psa/.psa.shadow" and $doremote == 0 ) {

        # It's a Plesk box, use the available credentials
        $mysqllogin = "-u admin -p`cat /etc/psa/.psa.shadow`";
        my $loginstatus = `$mysqladmincmd ping $mysqllogin 2>&1`;
        unless ( $loginstatus =~ /mysqld is alive/ ) {

            # Plesk 10+
            $mysqllogin =
              "-u admin -p`/usr/local/psa/bin/admin --show-password`";
            $loginstatus = `$mysqladmincmd ping $mysqllogin 2>&1`;
            unless ( $loginstatus =~ /mysqld is alive/ ) {
                badprint
"Attempted to use login credentials from Plesk and Plesk 10+, but they failed.";
                exit 1;
            }
        }
    }
    elsif ( -r "/usr/local/directadmin/conf/mysql.conf" and $doremote == 0 ) {

        # It's a DirectAdmin box, use the available credentials
        my $mysqluser =
          `cat /usr/local/directadmin/conf/mysql.conf | egrep '^user=.*'`;
        my $mysqlpass =
          `cat /usr/local/directadmin/conf/mysql.conf | egrep '^passwd=.*'`;

        $mysqluser =~ s/user=//;
        $mysqluser =~ s/[\r\n]//;
        $mysqlpass =~ s/passwd=//;
        $mysqlpass =~ s/[\r\n]//;

        $mysqllogin = "-u $mysqluser -p$mysqlpass";

        my $loginstatus = `mysqladmin ping $mysqllogin 2>&1`;
        unless ( $loginstatus =~ /mysqld is alive/ ) {
            badprint
"Attempted to use login credentials from DirectAdmin, but they failed.";
            exit 1;
        }
    }
    elsif ( -r "/etc/mysql/debian.cnf"
        and $doremote == 0
        and $opt{'defaults-file'} eq '' )
    {

        # We have a Debian maintenance account, use it
        $mysqllogin = "--defaults-file=/etc/mysql/debian.cnf";
        my $loginstatus = `$mysqladmincmd $mysqllogin ping 2>&1`;
        if ( $loginstatus =~ /mysqld is alive/ ) {
            goodprint
              "Logged in using credentials from Debian maintenance account.";
            return 1;
        }
        else {
            badprint
"Attempted to use login credentials from Debian maintenance account, but they failed.";
            exit 1;
        }
    }
    elsif ( $opt{'defaults-file'} ne '' and -r "$opt{'defaults-file'}" ) {

        # defaults-file
        debugprint "defaults file detected: $opt{'defaults-file'}";
        my $mysqlclidefaults = `$mysqlcmd --print-defaults`;
        debugprint "MySQL Client Default File: $opt{'defaults-file'}";

        $mysqllogin = "--defaults-file=" . $opt{'defaults-file'};
        my $loginstatus = `$mysqladmincmd $mysqllogin ping 2>&1`;
        if ( $loginstatus =~ /mysqld is alive/ ) {
            goodprint "Logged in using credentials from defaults file account.";
            return 1;
        }
    }
    else {
        # It's not Plesk or Debian, we should try a login
        debugprint "$mysqladmincmd $remotestring ping 2>&1";
        my $loginstatus = `$mysqladmincmd $remotestring ping 2>&1`;
        if ( $loginstatus =~ /mysqld is alive/ ) {

            # Login went just fine
            $mysqllogin = " $remotestring ";

       # Did this go well because of a .my.cnf file or is there no password set?
            my $userpath = `printenv HOME`;
            if ( length($userpath) > 0 ) {
                chomp($userpath);
            }
            unless ( -e "${userpath}/.my.cnf" or -e "${userpath}/.mylogin.cnf" )
            {
                badprint
"Successfully authenticated with no password - SECURITY RISK!";
            }
            return 1;
        }
        else {
            if ( $opt{'noask'} == 1 ) {
                badprint
                  "Attempted to use login credentials, but they were invalid";
                exit 1;
            }
            my ( $name, $password );

            # If --user is defined no need to ask for username
            if ( $opt{user} ne 0 ) {
                $name = $opt{user};
            }
            else {
                print STDERR "Please enter your MySQL administrative login: ";
                $name = <STDIN>;
            }

            # If --pass is defined no need to ask for password
            if ( $opt{pass} ne 0 ) {
                $password = $opt{pass};
            }
            else {
                print STDERR
                  "Please enter your MySQL administrative password: ";
                system("stty -echo >$devnull 2>&1");
                $password = <STDIN>;
                system("stty echo >$devnull 2>&1");
            }
            chomp($password);
            chomp($name);
            $mysqllogin = "-u $name";

            if ( length($password) > 0 ) {
                $mysqllogin .= " -p'$password'";
            }
            $mysqllogin .= $remotestring;
            my $loginstatus = `$mysqladmincmd ping $mysqllogin 2>&1`;
            if ( $loginstatus =~ /mysqld is alive/ ) {
                print STDERR "";
                if ( !length($password) ) {

       # Did this go well because of a .my.cnf file or is there no password set?
                    my $userpath = `printenv HOME`;
                    chomp($userpath);
                    unless ( -e "$userpath/.my.cnf" ) {
                        badprint
"Successfully authenticated with no password - SECURITY RISK!";
                    }
                }
                return 1;
            }
            else {
                badprint
                  "Attempted to use login credentials, but they were invalid.";
                exit 1;
            }
            exit 1;
        }
    }

}

# MySQL Request Array
sub select_array {
    my $req = shift;
    debugprint "PERFORM: $req ";
    my @result = `$mysqlcmd $mysqllogin -Bse "\\w$req" 2>>/dev/null`;
    if ( $? != 0 ) {
        badprint "failed to execute: $req";
        badprint "FAIL Execute SQL / return code: $?";
        debugprint "CMD    : $mysqlcmd";
        debugprint "OPTIONS: $mysqllogin";
        debugprint `$mysqlcmd $mysqllogin -Bse "$req" 2>&1`;

        #exit $?;
    }
    debugprint "select_array: return code : $?";
    chomp(@result);
    return @result;
}

sub human_size {
    my ( $size, $n ) = ( shift, 0 );
    ++$n and $size /= 1024 until $size < 1024;
    return sprintf "%.2f %s", $size, (qw[ bytes KB MB GB ])[$n];
}

# MySQL Request one
sub select_one {
    my $req = shift;
    debugprint "PERFORM: $req ";
    my $result = `$mysqlcmd $mysqllogin -Bse "\\w$req" 2>>/dev/null`;
    if ( $? != 0 ) {
        badprint "failed to execute: $req";
        badprint "FAIL Execute SQL / return code: $?";
        debugprint "CMD    : $mysqlcmd";
        debugprint "OPTIONS: $mysqllogin";
        debugprint `$mysqlcmd $mysqllogin -Bse "$req" 2>&1`;

        #exit $?;
    }
    debugprint "select_array: return code : $?";
    chomp($result);
    return $result;
}

# MySQL Request one
sub select_one_g {
    my $pattern = shift;

    my $req = shift;
    debugprint "PERFORM: $req ";
    my @result = `$mysqlcmd $mysqllogin -re "\\w$req\\G" 2>>/dev/null`;
    if ( $? != 0 ) {
        badprint "failed to execute: $req";
        badprint "FAIL Execute SQL / return code: $?";
        debugprint "CMD    : $mysqlcmd";
        debugprint "OPTIONS: $mysqllogin";
        debugprint `$mysqlcmd $mysqllogin -Bse "$req" 2>&1`;

        #exit $?;
    }
    debugprint "select_array: return code : $?";
    chomp(@result);
    return ( grep { /$pattern/ } @result )[0];
}

sub select_str_g {
    my $pattern = shift;

    my $req = shift;
    my $str = select_one_g $pattern, $req;
    return () unless defined $str;
    my @val = split /:/, $str;
    shift @val;
    return trim(@val);
}

sub get_tuning_info {
    my @infoconn = select_array "\\s";
    my ( $tkey, $tval );
    @infoconn =
      grep { !/Threads:/ and !/Connection id:/ and !/pager:/ and !/Using/ }
      @infoconn;
    foreach my $line (@infoconn) {
        if ( $line =~ /\s*(.*):\s*(.*)/ ) {
            debugprint "$1 => $2";
            $tkey = $1;
            $tval = $2;
            chomp($tkey);
            chomp($tval);
            $result{'MySQL Client'}{$tkey} = $tval;
        }
    }
    $result{'MySQL Client'}{'Client Path'}         = $mysqlcmd;
    $result{'MySQL Client'}{'Admin Path'}          = $mysqladmincmd;
    $result{'MySQL Client'}{'Authentication Info'} = $mysqllogin;

}

# Populates all of the variable and status hashes
my ( %mystat, %myvar, $dummyselect, %myrepl, %myslaves );

sub arr2hash {
    my $href = shift;
    my $harr = shift;
    my $sep  = shift;
    $sep = '\s' unless defined($sep);
    foreach my $line (@$harr) {
        next if ( $line =~ m/^\*\*\*\*\*\*\*/ );
        $line =~ /([a-zA-Z_]*)\s*$sep\s*(.*)/;
        $$href{$1} = $2;
        debugprint "V: $1 = $2";
    }
}

sub get_all_vars {

    # We need to initiate at least one query so that our data is useable
    $dummyselect = select_one "SELECT VERSION()";
    if ( not defined($dummyselect) or $dummyselect eq "" ) {
        badprint
"You probably did not get enough privileges for running MySQLTuner ...";
        exit(256);
    }
    $dummyselect =~ s/(.*?)\-.*/$1/;
    debugprint "VERSION: " . $dummyselect . "";
    $result{'MySQL Client'}{'Version'} = $dummyselect;

    my @mysqlvarlist = select_array("SHOW VARIABLES");
    push( @mysqlvarlist, select_array("SHOW GLOBAL VARIABLES") );
    arr2hash( \%myvar, \@mysqlvarlist );
    $result{'Variables'} = \%myvar;

    my @mysqlstatlist = select_array("SHOW STATUS");
    push( @mysqlstatlist, select_array("SHOW GLOBAL STATUS") );
    arr2hash( \%mystat, \@mysqlstatlist );
    $result{'Status'} = \%mystat;
    unless ( defined( $myvar{'innodb_support_xa'} ) ) {
        $myvar{'innodb_support_xa'} = 'ON';
    }
    $mystat{'Uptime'} = 1
      unless defined( $mystat{'Uptime'} )
      and $mystat{'Uptime'} > 0;
    $myvar{'have_galera'} = "NO";
    if (   defined( $myvar{'wsrep_provider_options'} )
        && $myvar{'wsrep_provider_options'} ne ""
        && $myvar{'wsrep_on'} ne "OFF" )
    {
        $myvar{'have_galera'} = "YES";
        debugprint "Galera options: " . $myvar{'wsrep_provider_options'};
    }

    # Workaround for MySQL bug #59393 wrt. ignore-builtin-innodb
    if ( ( $myvar{'ignore_builtin_innodb'} || "" ) eq "ON" ) {
        $myvar{'have_innodb'} = "NO";
    }

    # Support GTID MODE FOR MARIADB
    # Issue MariaDB GTID mode #272
    $myvar{'gtid_mode'} = $myvar{'gtid_strict_mode'}
      if ( defined( $myvar{'gtid_strict_mode'} ) );

    $myvar{'have_threadpool'} = "NO";
    if ( defined( $myvar{'thread_pool_size'} )
        and $myvar{'thread_pool_size'} > 0 )
    {
        $myvar{'have_threadpool'} = "YES";
    }

    # have_* for engines is deprecated and will be removed in MySQL 5.6;
    # check SHOW ENGINES and set corresponding old style variables.
    # Also works around MySQL bug #59393 wrt. skip-innodb
    my @mysqlenginelist = select_array "SHOW ENGINES";
    foreach my $line (@mysqlenginelist) {
        if ( $line =~ /^([a-zA-Z_]+)\s+(\S+)/ ) {
            my $engine = lc($1);

            if ( $engine eq "federated" || $engine eq "blackhole" ) {
                $engine .= "_engine";
            }
            elsif ( $engine eq "berkeleydb" ) {
                $engine = "bdb";
            }
            my $val = ( $2 eq "DEFAULT" ) ? "YES" : $2;
            $myvar{"have_$engine"} = $val;
            $result{'Storage Engines'}{$engine} = $2;
        }
    }
    debugprint Dumper(@mysqlenginelist);
    my @mysqlslave = select_array("SHOW SLAVE STATUS\\G");
    arr2hash( \%myrepl, \@mysqlslave, ':' );
    $result{'Replication'}{'Status'} = \%myrepl;
    my @mysqlslaves = select_array "SHOW SLAVE HOSTS";
    my @lineitems   = ();
    foreach my $line (@mysqlslaves) {
        debugprint "L: $line ";
        @lineitems = split /\s+/, $line;
        $myslaves{ $lineitems[0] } = $line;
        $result{'Replication'}{'Slaves'}{ $lineitems[0] } = $lineitems[4];
    }
}

sub remove_cr {
    return map {
        my $line = $_;
        $line =~ s/\n$//g;
        $line =~ s/^\s+$//g;
        $line;
    } @_;
}

sub remove_empty {
    grep { $_ ne '' } @_;
}

sub grep_file_contents {
    my $file = shift;
    my $patt;
}

sub get_file_contents {
    my $file = shift;
    open( my $fh, "<", $file ) or die "Can't open $file for read: $!";
    my @lines = <$fh>;
    close $fh or die "Cannot close $file: $!";
    @lines = remove_cr @lines;
    return @lines;
}

sub get_basic_passwords {
    return get_file_contents(shift);
}

sub get_log_file_real_path {
    my $file     = shift;
    my $hostname = shift;
    my $datadir  = shift;
    if ( -f "$file" ) {
        return $file;
    }
    elsif ( -f "$hostname.log" ) {
        return "$hostname.log";
    }
    elsif ( -f "$hostname.err" ) {
        return "$hostname.err";
    }
    elsif ( -f "$datadir$hostname.err" ) {
        return "$datadir$hostname.err";
    }
    elsif ( -f "$datadir$hostname.log" ) {
        return "$datadir$hostname.log";
    }
    elsif ( -f "$datadir"."mysql_error.log" ) {
        return "$datadir"."mysql_error.log";
    }
     elsif ( -f "/var/log/mysql.log" ) {
        return "/var/log/mysql.log";
    }
    elsif ( -f "/var/log/mysqld.log" ) {
        return "/var/log/mysqld.log";
    }
    elsif ( -f "/var/log/mysql/$hostname.err" ) {
        return "/var/log/mysql/$hostname.err";
    }
    elsif ( -f "/var/log/mysql/$hostname.log" ) {
        return "/var/log/mysql/$hostname.log";
    }
    elsif ( -f "/var/log/mysql/"."mysql_error.log" ) {
        return "/var/log/mysql/"."mysql_error.log";
    }
    else {
        return $file;
    }
}

sub log_file_recommendations {
    $myvar{'log_error'} =
      get_log_file_real_path( $myvar{'log_error'}, $myvar{'hostname'},
        $myvar{'datadir'} );

    subheaderprint "Log file Recommendations";
    if ( "$myvar{'log_error'}" eq "stderr" ) {
        badprint "log_error is set to $myvar{'log_error'} MT can't read stderr";
        return
    }
    if ( -f "$myvar{'log_error'}" ) {
        goodprint "Log file $myvar{'log_error'} exists";
    }
    else {
        badprint "Log file $myvar{'log_error'} doesn't exist";
        return;
    }
    infoprint "Log file: "
      . $myvar{'log_error'} . "("
      . hr_bytes_rnd( ( stat $myvar{'log_error'} )[7] ) . ")";

    if ( -r "$myvar{'log_error'}" ) {
        goodprint "Log file $myvar{'log_error'} is readable.";
    }
    else {
        badprint "Log file $myvar{'log_error'} isn't readable.";
        return;
    }
    if ( ( stat $myvar{'log_error'} )[7] > 0 ) {
        goodprint "Log file $myvar{'log_error'} is not empty";
    }
    else {
        badprint "Log file $myvar{'log_error'} is empty";
    }

    if ( ( stat $myvar{'log_error'} )[7] < 32 * 1024 * 1024 ) {
        goodprint "Log file $myvar{'log_error'} is smaller than 32 Mb";
    }
    else {
        badprint "Log file $myvar{'log_error'} is bigger than 32 Mb";
        push @generalrec,
          $myvar{'log_error'}
          . " is > 32Mb, you should analyze why or implement a rotation log strategy such as logrotate!";
    }

    my $numLi     = 0;
    my $nbWarnLog = 0;
    my $nbErrLog  = 0;
    my @lastShutdowns;
    my @lastStarts;

    open( my $fh, '<', $myvar{'log_error'} )
      or die "Can't open $myvar{'log_error'} for read: $!";

    while ( my $logLi = <$fh> ) {
        chomp $logLi;
        $numLi++;
        debugprint "$numLi: $logLi" if $logLi =~ /warning|error/i and $logLi !~ /Logging to/;
        $nbErrLog++                 if $logLi =~ /error/i and $logLi !~ /Logging to/;
        $nbWarnLog++                if $logLi =~ /warning/i;
        push @lastShutdowns, $logLi
          if $logLi =~ /Shutdown complete/ and $logLi !~ /Innodb/i;
        push @lastStarts, $logLi if $logLi =~ /ready for connections/;
    }
    close $fh;

    if ( $nbWarnLog > 0 ) {
        badprint "$myvar{'log_error'} contains $nbWarnLog warning(s).";
        push @generalrec,
          "Control warning line(s) into $myvar{'log_error'} file";
    }
    else {
        goodprint "$myvar{'log_error'} doesn't contain any warning.";
    }
    if ( $nbErrLog > 0 ) {
        badprint "$myvar{'log_error'} contains $nbErrLog error(s).";
        push @generalrec, "Control error line(s) into $myvar{'log_error'} file";
    }
    else {
        goodprint "$myvar{'log_error'} doesn't contain any error.";
    }

    infoprint scalar @lastStarts . " start(s) detected in $myvar{'log_error'}";
    my $nStart = 0;
    my $nEnd   = 10;
    if ( scalar @lastStarts < $nEnd ) {
        $nEnd = scalar @lastStarts;
    }
    for my $startd ( reverse @lastStarts[ -$nEnd .. -1 ] ) {
        $nStart++;
        infoprint "$nStart) $startd";
    }
    infoprint scalar @lastShutdowns
      . " shutdown(s) detected in $myvar{'log_error'}";
    $nStart = 0;
    $nEnd   = 10;
    if ( scalar @lastShutdowns < $nEnd ) {
        $nEnd = scalar @lastShutdowns;
    }
    for my $shutd ( reverse @lastShutdowns[ -$nEnd .. -1 ] ) {
        $nStart++;
        infoprint "$nStart) $shutd";
    }

    #exit 0;
}

sub cve_recommendations {
    subheaderprint "CVE Security Recommendations";
    unless ( defined( $opt{cvefile} ) && -f "$opt{cvefile}" ) {
        infoprint "Skipped due to --cvefile option undefined";
        return;
    }

#$mysqlvermajor=10;
#$mysqlverminor=1;
#$mysqlvermicro=17;
#prettyprint "Look for related CVE for $myvar{'version'} or lower in $opt{cvefile}";
    my $cvefound = 0;
    open( my $fh, "<", $opt{cvefile} )
      or die "Can't open $opt{cvefile} for read: $!";
    while ( my $cveline = <$fh> ) {
        my @cve = split( ';', $cveline );
        debugprint
"Comparing $mysqlvermajor\.$mysqlverminor\.$mysqlvermicro with $cve[1]\.$cve[2]\.$cve[3] : "
          . ( mysql_version_le( $cve[1], $cve[2], $cve[3] ) ? '<=' : '>' );

        # Avoid not major/minor version corresponding CVEs
        next
          unless ( int( $cve[1] ) == $mysqlvermajor
            && int( $cve[2] ) == $mysqlverminor );
        if ( int( $cve[3] ) >= $mysqlvermicro ) {
            badprint "$cve[4](<= $cve[1]\.$cve[2]\.$cve[3]) : $cve[6]";
            $result{'CVE'}{'List'}{$cvefound} =
              "$cve[4](<= $cve[1]\.$cve[2]\.$cve[3]) : $cve[6]";
            $cvefound++;
        }
    }
    close $fh or die "Cannot close $opt{cvefile}: $!";
    $result{'CVE'}{'nb'} = $cvefound;

    my $cve_warning_notes = "";
    if ( $cvefound == 0 ) {
        goodprint "NO SECURITY CVE FOUND FOR YOUR VERSION";
        return;
    }
    if ( $mysqlvermajor eq 5 and $mysqlverminor eq 5 ) {
        infoprint
          "False positive CVE(s) for MySQL and MariaDB 5.5.x can be found.";
        infoprint "Check careful each CVE for those particular versions";
    }
    badprint $cvefound . " CVE(s) found for your MySQL release.";
    push( @generalrec,
        $cvefound
          . " CVE(s) found for your MySQL release. Consider upgrading your version !"
    );
}

sub get_opened_ports {
    my @opened_ports = `netstat -ltn`;
    @opened_ports = map {
        my $v = $_;
        $v =~ s/.*:(\d+)\s.*$/$1/;
        $v =~ s/\D//g;
        $v;
    } @opened_ports;
    @opened_ports = sort { $a <=> $b } grep { !/^$/ } @opened_ports;
    debugprint Dumper \@opened_ports;
    $result{'Network'}{'TCP Opened'} = \@opened_ports;
    return @opened_ports;
}

sub is_open_port {
    my $port = shift;
    if ( grep { /^$port$/ } get_opened_ports ) {
        return 1;
    }
    return 0;
}