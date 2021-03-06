package CBIL::Util::SshCluster;

use strict;
use File::Basename;
use CBIL::Util::Utils;
use Cwd;

#############################################################################
#          Public Methods
#############################################################################

# $mgr is an object with the following methods:
#  $mgr->run($testmode, $cmd)
#  $mgr->error($msg)
sub new {
    my ($class, $server, $user, $mgr) = @_;

    my $self = {};
    bless $self, $class;

    $self->{server} = $server;
    $self->{user} = $user;
    $self->{mgr} = $mgr;
    return $self;
}

#  param fromDir  - the directory in which fromFile resides
#  param fromFile - the basename of the file or directory to copy
sub copyTo {
    my ($self, $fromDir, $fromFile, $toDir) = @_;
          # buildDIr, release/speciesNickname, serverPath

    my $cwd = cwd();
    chdir $fromDir || $self->{mgr}->error("Can't chdir $fromDir\n" . __FILE__ . " line " . __LINE__ . "\n\n");

    my @arr = glob("$fromFile");
    $self->{mgr}->error("origin directory $fromDir/$fromFile doesn't exist\n" . __FILE__ . " line " . __LINE__ . "\n\n") unless (@arr >= 1);


    my $user = "$self->{user}\@" if $self->{user};
    my $ssh_to = "$user$self->{server}";

    print STDERR "tar cf - $fromFile | gzip -c | ssh -2 $ssh_to 'cd $toDir; gunzip -c | tar xf -' \n" . __FILE__ . " line " . __LINE__ . "\n\n";

    # workaround scp problems
    $self->{mgr}->runCmd(0, "tar cf - $fromFile | gzip -c | ssh -2 $ssh_to 'cd $toDir; gunzip -c | tar xf -'");
    chdir $cwd;
}

#  param fromDir  - the directory in which fromFile resides
#  param fromFile - the basename of the file or directory to copy
sub copyFrom {
    my ($self, $fromDir, $fromFile, $toDir) = @_;

    my $cwd = cwd();
    # workaround scp problems
    chdir $toDir || $self->{mgr}->error("Can't chdir $toDir\n");

    my $user = "$self->{user}\@" if $self->{user};
    my $ssh_target = "$user$self->{server}";

    $self->{mgr}->runCmd(0, "ssh -2 $ssh_target 'cd $fromDir; tar cf - $fromFile | gzip -c' | gunzip -c | tar xf -");

#    $self->runCmd("ssh $server 'cd $fromDir; tar cf - $fromFile' | tar xf -");
    my @arr = glob("$toDir/$fromFile");
    $self->{mgr}->error("$toDir/$fromFile wasn't successfully copied from liniac\n") unless (@arr >= 1);
    chdir $cwd;
}

sub runCmdOnCluster {
  my ($self, $test, $cmd) = @_;

  my $user = "$self->{user}\@" if $self->{user};
  my $ssh_target = "$user$self->{server}";

  $self->{mgr}->runCmd($test, "ssh -2 $ssh_target '/bin/bash -login -c \"$cmd\"'");
}

1;
