use strict;
use 5.010;
use Cwd 'abs_path';

scalar @ARGV >= 1 or exit say "Must provide a word";

open F, "curl http://ejje.weblio.jp/content/".$ARGV[0]." -print|";

sub script_dir_abs_path {
    my $script_path = abs_path($0); # Get the full absolute path of this pl file
    $script_path =~ /(.*)\//; # Get directory part
    my $script_directory = $1;
}

my $script_directory = &script_dir_abs_path;
say $script_directory;

open OUT, ">", $script_directory."/data/$ARGV[0].dic"
    or die "Cannot open output file to save searched word!"; # Create a storage file

open TEMP_OUT, ">", $script_directory."/data/.temp" # A temp file, stores html of each dictionary fetched
    or die "Cannot open a temp file!";

my $htmlContent;
$htmlContent = $htmlContent.$_ while (<F>);
my $dataContent;

my @foo = `tput cols`;
my $cnt = @foo[0];

my $i = 0;
while ($htmlContent =~ /<!--開始 (?<DIC_NAME>.*?)-->(.*?)<!--終了 \k<DIC_NAME>-->/gs) {
    last if $i > 3;
    say TEMP_OUT "-" x $cnt;
    say TEMP_OUT "<a>================ $1 ================</a>";
    say TEMP_OUT "-" x $cnt;
    say TEMP_OUT $2;
    $i = $i + 1;
}

system("w3m -dump -T text/html $script_directory/data/.temp | less");
