use ExtUtils::MakeMaker;

my $mm = new MM
 (
  {
   AUTHOR => "Daniel Ruoso <daniel\@ruoso.com>",
   ABSTRACT => "Perl Oak Component Tree",
   NAME => "Oak::SOAP",
   VERSION => "1.8",
   PREREQ_PM => 
   {
    'Oak::Application'   => '0',
    'SOAP::Transport::TCP' => '0',
    'XML::Parser' => '0',
    'Error' => '0.15',
    'Oak::Component' => '0',
    'SOAP::Lite' => '0'
   }
  }
 );

$mm->flush;
