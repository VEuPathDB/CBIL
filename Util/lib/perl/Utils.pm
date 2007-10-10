package CBIL::Util::Utils;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(runCmd log timeformat mail);

use strict;

sub runCmd {
    my ($cmd) = @_;

    my $output = `$cmd`;
    my $status = $? >> 8;
    die "Failed with status $status running '$cmd'\n" if $status;
    return $output;
}

sub log {
    my ($logFile, $msg) = @_;
    open(FILE, ">>$logFile") || die "couldn't open logFile $logFile";
    print FILE $msg;
    close(FILE);
}

# convert secs to hr:min:sec
sub timeformat {
    my($tot_sec) = @_;

    my $secs = $tot_sec % 60;
    my $mins = int($tot_sec / 60) % 60;
    my $hours = int($tot_sec / 3600);

    $secs = "0$secs" if $secs < 10;
    $mins = "0$mins" if $mins < 10;
    $hours = "0$hours" if $hours < 10;
    return "$hours:$mins:$secs";
}

sub mail {
  my ($to, $from, $subject, $body, $cc, $bcc) = @_;

  unless($to && $from && $subject && $body) {
    die "mail usage:  CBIL::Util::Utils::mail(to, from, subject, body, cc, bcc)";
  }

  my $ccString = $cc ? "-c $cc" : "";
  my $bccString = $bcc ? "-b $bcc" : "";

  my $cmd = "export EMAIL=$from; echo '$body'|mutt -s '$subject' $ccString $bccString $to";

  my $result = system($cmd);

  unless($result / 256 == 0) {
    die "ERROR running the following command:  $cmd";
  }
}


1;
