#!/usr/bin/perl
use strict; 
use warnings;  
use IO::File; 
use Data::Dumper;
my ($details,$title);
my $url = 'https://www.mycancergenome.org/content'; 
my $response = `curl -k $url`;
if ($response){ 
	my $start = '<ul class="expandable-navigation" id="">';  
	my $end = '</ul>';  
	if($response =~ /($start.*?$end)/s){       
		$response = $1;   
	}
	$start = '<li class="menu_li">';
	$end = '</li>';  
	my @find_all = ($response =~ /$start(.*?)$end/gs);    
	my %disease;
	foreach my $re1(@find_all){  
		if($re1 =~ /<a href="(.*?)">(.*?)<\/a>/s){
	     	my $name = lc(join "-", (split " ", $2));
	     	my $path = "./HTML/$name.html";
	     	if (!-e $path) {
	     		my $fh = IO::File->new("> ./HTML/$name.html");
	     		$url = $1;
	     		$response = `curl -k $url`;
	     		print $fh "$response";
	     		$fh->close;
	     	}
	     	$disease{$name} = $path;
	    }  #30        
	} 
	my @disease_keys = keys %disease;
	my $fh = IO::File->new(">> ./aaa.xls");
	foreach my $disease_name (@disease_keys){
		open(HTML,"<","./HTML/$disease_name.html");
		print "$disease_name\n";
		my $flag = 0;
		my @responses;
		my $detail = 0;

		while (<HTML>) {
			 
			 if($_ =~ /^<div class="expandable-navigation-container"><ul class="expandable-navigation" id="">/){
                 $flag +=1;
             }
             if($flag == 1){
             	push @responses, $_;
             }
             if ($flag == 2) {
             	$start = '<span class="fake-anchor expandable">';
				$end = '</span><ul class="submenu closed">';
				foreach my $rep(@responses){
					#print "$rep\n";
					if ($rep =~ /$start(.*?)$end/s) {
						#print "$1\n";
					}
					if ($rep =~ /<a class="subitem" href="(.*?)">(.*?)<\/a>/s) {
						#print "$1\t$2\n";
					}
				} 				
				$flag+=1;
             }
             if ($_=~/<h2>(.*?)<\/h2>/) {
             	$detail = 1;
             	chomp $1;
             	$title = $1;
             	$details=undef;
             	next;
             }
             if ($detail == 1) {
             	chomp($_);
             	$details.=$_;
             	if (/^<link/){
             		print "$detail\n";
             		$detail = 2;
             		$details =~ s/\s+//g;
		     		$details =~ s/<.*?>//g;
       				$details =~ s/&nbsp;/ /g;
       				$details =~ s/&gt;/>/g;
       				$details =~ s/&lt;/</g;
       				$details =~ s/&amp;/&/g;
       				$details =~ s/&quot;/"/g;
       				$details =~ s/&#8203;//g;
       				#print "$details\n";
             		#$details =~ s/Suggested Citation:/\nSuggested Citation:/g;
             		#$details =~ s/Last Updated:/\nLast Updated:/g;
             		#$details =~ s/Disclaimer/\nDisclaimer/g;
             		#print "$details\n";
             		print $fh "$title\t$details\n";
             	}
             	

             	#
             	
             }
	
		}
		
		#last;
	}
	$fh->close();
	close(HTML);
}