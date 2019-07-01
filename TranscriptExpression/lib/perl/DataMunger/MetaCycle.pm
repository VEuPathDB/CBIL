package CBIL::TranscriptExpression::DataMunger::MetaCycle;
use base qw(CBIL::TranscriptExpression::DataMunger::Loadable);

use strict;
use CBIL::TranscriptExpression::Error;
use File::Temp qw/ tempfile tempdir /;
use Exporter;
use Data::Dumper;
#use File::Basename;

#-------------------------------------------------------------------------------
my $PROTOCOL_NAME = 'MetaCycle';

#-------------------------------------------------------------------------------


#sub getInputFile       { $_[0]->{inputFile} }
#sub setInputFile       { $_[0]->{inputFile} = $_[1]}

#sub getMainDirectory       { $_[0]->{mainDirectory} }
#sub setMainDirectory       { $_[0]->{mainDirectory} = $_[1]}


sub new {
    my ($class, $args) = @_;

   # my $requiredParams = ['inputFile'];
    
    my $self = $class->SUPER::new($args);
    
    return $self;
}
sub munge {
  my ($self) = @_;
  
  my $inputFile = $self->getInputFile();
  my $mainDirectory = $self->getMainDirectory();

  my $rFile = $self->makeTempROutputFile($inputFile,  $mainDirectory);

  $self->runR($rFile);

  opendir(DIR,  $mainDirectory) or die $!; 

  my @files = readdir DIR ;

  my @names;
  my @fileNames;


  foreach my $result (@files){   

  ######################################## ARSER file  (@names)   ##############################
      if($result =~ /^ARSresult_$inputFile/){

	  push(@names,$result);
	  
	  my $new_ARSER_result = &formatARSERtable($result, $mainDirectory);
	  
      }
      
 ##########################################JTK file (@names)  ##############################   
      if($result =~ /^JTKresult_$inputFile/){
	  
	  push(@names,$result);

	  my $new_JTK_result = &formatJTKtable($result, $mainDirectory);

      }
 ########################################## ARSER file (@fileNames)  ##############################   

      if($result =~ /^new_arser_ARSresult_$inputFile/){
	  
	  push(@fileNames,$result);

      }
      
 ##########################################JTK file (@fileNames) ##############################   
      if($result =~ /^new_jtk_JTKresult_$inputFile/){
	  
	  push(@fileNames,$result);

      }
      
  }


  unless($self->getDoNotLoad()) {
      $self->setNames([@names]);                                                                                                  
      $self->setFileNames([@fileNames]);################## FileNames!!!!!!!!!!!!!!!!   
      $self->setProtocolName($PROTOCOL_NAME);
      $self->setSourceIdType("gene");
  }
  
 
  $self->createConfigFile();

 
}

sub makeTempROutputFile {
    
    my ($self, $inputFile, $mainDirectory) = @_;

    my ($rFh, $rFile) = tempfile();

    my $rCode = <<"RCODE";
    library(MetaCycle);
    meta2d(infile="$mainDirectory/$inputFile", outdir ="$mainDirectory", filestyle = "txt", timepoints = "line1", minper = 20, maxper = 28, 
	   cycMethod= c("ARS","JTK"), analysisStrategy = "auto", outputFile = TRUE);
RCODE
    print $rFh $rCode;
    close $rFh;
return $rFile;
}




sub formatARSERtable{
    my ($arserTable,  $mainDirectory) = @_;
    
    my $rCode = <<"RCODE";
    old_arser<-read.delim("$mainDirectory/$arserTable"); ## need to know the 1)'file name' and 2)'file path'
    new_arser<-old_arser[c(1,5,6,12)];
    colnames(new_arser) <- c("CycID","Period", "Amplitude", "Pvalue");

    write.table(new_arser,"$mainDirectory/new_arser_$arserTable", row.names=F,col.names=T,quote=F,sep="\t");
    basename("$mainDirectory/new_arser_$arserTable");
 
RCODE

my ($FH, $File) = tempfile(SUFFIX => '.R');
    print $FH  $rCode;
    my $command = "Rscript " .  $File;
    my $ARSER_result  =  `$command`;
    close ($FH);

    return $ARSER_result;

}

sub formatJTKtable{
    my ($jtkTable, $mainDirectory) = @_;

    my $rCode = <<"RCODE";
    old_jtk<-read.delim("$mainDirectory/$jtkTable"); ## need to know the 1) 'file name' and 2) 'file path'  
    new_jtk<-old_jtk[c(1,4,6,3)];
    colnames(new_jtk) <- c("CycID","Period", "Amplitude","Pvalue" );
    write.table(new_jtk,"$mainDirectory/new_jtk_$jtkTable", row.names=F,col.names=T,quote=F,sep="\t");                             
    basename("$mainDirectory/new_jtk_$jtkTable");  

RCODE

my ($fh, $file) = tempfile(SUFFIX => '.R');
    print $fh  $rCode;
    my $command = "Rscript " .  $file;
    my $JTK_result  =  `$command`;
    close ($fh);

    return $JTK_result;

}


1;


