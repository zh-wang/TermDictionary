use strict;
use 5.010;
use Cwd 'abs_path';
use HTML::FormatText;
use HTML::TagParser;

#--------------
#system 'curl www.google.co.jp';
#open F, "find / -atime +90 -size +1000 -print|" or die "fork: $!";
#open F, "curl http://ejje.weblio.jp/content/disclose -print|";

#while (<F>) {
#    chomp;
#    printf "%s size %dK last accessed on %s\n",
#           $_, (1023 + -s $_)/1024, -A $_;
#}
#--------------

# read from shell
#--------------
open F, "curl http://ejje.weblio.jp/small/content/".$ARGV[0]." -print|";
#open F, "curl http://ejje.weblio.jp/content/".$ARGV[0]." -print|";

my $title = '';
my $body = '';
my $pattern = "<body[^>]*>(.+)</body>";
my $htmlContent;
while (<F>) {
    $htmlContent = $htmlContent.$_;
}

my %htmlMap;

my @record = split /<!--開始 .*?-->/, $htmlContent;
my @dicNames;

#foreach my $a (@record) {
    #print "$a\n====================\n";
#}

# parse returned html to a map
my $i = 1;
while ($htmlContent =~ /<!--開始 (.*?)-->/g) {
    push (@dicNames, $1);
    $htmlMap{$1} = $record[$i];
    #print $record[$i]."\n";
    $i = $i + 1;
    #print $1."\n";
    #print "=========================\n";
    #print $htmlMap{$1}."\n";
}


my $html = HTML::TagParser->new($htmlContent);

my $number_to_show = 1;
my $cont = $html->getElementById("content");
my $contentSubTree = $cont->subTree();

#if (&getDetailFromKennkyuusya() == undef) {
   #&getDetailFromWikdictory(); 
#}

#my @division_list = $contentSubTree->getElementsByClassName("division2");
#foreach my $elem ( @division_list ) {
#    my $tagname = $elem->tagName;
#    my $attr = $elem->attributes;
#    my $text = $elem->innerText;
##    print "<$tagname";
##    foreach my $key ( sort keys %$attr ) {
##        print " $key=\"$attr->{$key}\"";
##    }
##    if ( $text eq "" ) {
##        print " />\n";
##    } else {
##        print ">$text</$tagname>\n";
##    }
#
#    print "#-------------------------\n";
#    my $divisionSubTree = $elem->subTree();
#    my @subElemList = $divisionSubTree->getElementsByTagName("dt");
#    if ($#subElemList + 1 == 0) {
#        print "no result\n";
#        last;
#    }
#    foreach my $subElem ( @subElemList ) {
#        print $subElem->innerText."\n";
#    }
#
#    $number_to_show--;
#    if ($number_to_show == 0) {
#        last;
#    }
#}

my $script_path = abs_path($0);
$script_path =~ /(.*)\//;
my $script_directory = $1;

my @division_list = $contentSubTree->getElementsByClassName("division2");
open _OUTPUT, ">", $script_directory
."/data/$ARGV[0].dic" or die "Cannot open output file to save searched word!";

#if (&wordExistd) {
#if (&getDetailFromKennkyuusya() != undef) {
    print _OUTPUT "========================"."\n";
    print "========================"."\n";
    $i = 0;
    foreach my $elem ( @division_list ) {
        #print $dicNames[$i]."\n";
        my $tagname = $elem->tagName;
        my $attr = $elem->attributes;
        my $text = $elem->innerText;
        $i = $i + 1;
        $text =~ s/[\n\r]+$ARGV[0]//;
        $text =~ s/\./\.\n\r/g;
        print $text."\n";
        print "========================"."\n";
        print _OUTPUT $text."\n";
        print _OUTPUT "========================"."\n";
        if ($i > 0) {
            last;
        }
    }
#}

# 研究社
sub getDetailFromKennkyuusya() {
    my @division_list = $contentSubTree->getElementsByClassName("division2");
    foreach my $elem ( @division_list ) {
        my $tagname = $elem->tagName;
        my $attr = $elem->attributes;
        my $text = $elem->innerText;

        my $divisionSubTree = $elem->subTree();
        my @subElemList = $divisionSubTree->getElementsByTagName("dt");
        if ($#subElemList + 1 == 0) {
            return undef;
        }
        foreach my $subElem ( @subElemList ) {
            print $subElem->innerText."\n";
        }

        $number_to_show--;
        if ($number_to_show == 0) {
            last;
        }
    }
}

# Wikdictory
sub getDetailFromWikdictory {
    my @division_list = $contentSubTree->getElementsByClassName("division2");
    foreach my $elem ( @division_list ) {
        my $tagname = $elem->tagName;
        my $attr = $elem->attributes;
        my $text = $elem->innerText;
        
        my $divisionSubTree = $elem->subTree();
        my $subElemList = $divisionSubTree->getElementsByClassName("ewSubDscTop");
        my $subElemList2 = $divisionSubTree->getElementsByClassName("ewSubDsc");
        if ($subElemList != undef && $subElemList2 != undef) {
            print $subElemList->innerText."\n";
            print "\n";
            print $subElemList2->innerText."\n";
        } else {
            print "no result.\n";
        }

        $number_to_show--;
        if ($number_to_show == 0) {
            last;
        }
    }
}

sub wordExistd {
    foreach my $elem (@division_list) {
        my $tagname = $elem->tagName;
        my $attr = $elem->attributes;
        my $text = $elem->innerText;

        my $divisionSubTree = $elem->subTree();
        my $subElemList = $divisionSubTree->getElementsByClassName("ewSubDscTop");
        my $subElemList2 = $divisionSubTree->getElementsByClassName("ewSubDsc");
        if ($subElemList != undef && $subElemList2 != undef) {
            return 1;
        } else {
            return 0;
        }
    }
}

