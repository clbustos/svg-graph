                                   SVG::Graph

                                Sean E. Russell
                        serATgermaneHYPHENsoftwareDOTcom

WHAT IS IT?

SVG::Graph is a loose port of the Perl SVG::TT:Graph package.  It is a toolkit
for generating SVG data graphs, which are a species of plot that are oriented
toward displaying statistical data.

Actually, I just made all of that up.  Graphs differ from plots (as far as I can
tell) in that one of the columns can be non-numeric data.  Graphs are the sorts
of things that spreadsheets generate.  Feel free to email me with concise
definitions of Graphs and Plots.

WHY USE IT?

If you're a Ruby programmer, you can't use SVG::TT::Graph directly.  This
package is for you.

If you want one of the features that this package has that the Perl version
doesn't, and you don't mind doing your graph code in Ruby, then this package is
for you.

If you're a Perl wienie or you have something against Ruby, use SVG::TT::Graph.
If it doesn't provide you with the features you want, hack it yourself.

WHY?

The SVG::TT:Graph package is just fine.  It lacked a couple of features that I
wanted, and it was in Perl[1], so I re-implemented it.  

SVG::Graph is not a straight port of SVG::TT::Graph, because the Perl version
uses templates, and I don't believe that this is a job for templates.  Templates
are great when you have lots of context containing a little bit of evaluated
code, but the Graph classes are mostly code with a little SVG; therefore, it
makes more sense (and is a hell of a lot more readable) to have the SVG embedded
in the code rather than vice versa.  However, much of the logic was directly cut
and paste out of SVG::TT::Graph, so at least the first few versions of
SVG::Graph borrowed heavily from the Perl version.

I intend SVG::Graph to have more features than SVG::TT::Graph, which is the main
reason for the re-implementation.  One such feature is the ability to change the
stacking of the data sets.  For instance, SVG::Graph allows you to place the
data bars from multiple data sets on the same graph side-by-side, rather than
overlapping.

SVG::Graph is probably incomplete.  In fact, the first release only contains two
graph styles: Bar, and BarHorizontal.  The number of styles will grow.

DEPENDANCIES

REXML 3.0+, or Ruby 1.8+

USAGE

There's API documentation; use rdoc to extract it.  The API documentation is
pretty comprehensive (Leo Lapworth did a really good job on the docs, and I
stole most of them), and there's an example application in the main directory.

BUGS

SVG::Graph probably contains bugs.  In fact, it is probably mostly bugs, held
together with some working code around them.  In particular, SVG::Graph is
probably really intolerant of *your* bugs, and is likely entirely unhelpful in
helping you track down problems.  We can only pray that this situation
improves[2].

Email me, and I'll fix them.  If the package ever gets popular, I'll set up a
bug page[3].



--- SER
[1] Perl is from Hell.  The language is bad enough, but working with the package
system -- CPAN, etc. -- is an excercize in masochism.  I'd rather chew on glass.
[2] Prayer is much more effective when accompanied by sums of cash sent to the
author.
[3] Watch: five years from now, when SVG::Graph is a core Ruby package, and it
consists of a half million lines of code, and the United Nations depends on it
for all of it's graphing needs, and the Linux kernel itself depends on it for
its install process -- this documentation will be largely unchanged, and
although I'll have long since set up a bug page, I won't have changed that
paragraph.

