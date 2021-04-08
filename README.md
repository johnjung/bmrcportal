creating a cool prototype for BMRC

## Loading Finding Aids

There is a 

```console
php -f admin/load_findingaids.php


To check for well-formedness errors in a single XML file:
xmllint --noout <xml-file>

To validate a single XML file against a schema:
xmllint --noout --schema <xsd-file> <xml-file>

To make an EAD finding aid schema-ready, you can convert it using the XSLT
transform above. Here's a small script to do that in Python:

import io
import sys
import lxml.etree as ET

ead_filename = 'test.xml'
xsd_filename = 'dtd2schema.xsl'

transform = ET.XSLT(ET.parse(xsd_filename))
transformed_ead = transform(ET.parse(ead_filename))

sys.stdout.write(
    ET.tostring(
        transformed_ead,
        pretty_print=True
    ).decode('utf-8')
)

Tdhe script above does not include an XML declaration in its output- to get
n 
one you can pipe the results through "xmllint --format -".

To run any of these commands on groups of files, you can loop them through
find:

for x in $(find . -name "*.xml")
do
    xmllint --noout $x
done

accessrestrict, address, blockquote, chronlist, head, legalstatus, list, note, p, table 
199 p


for $x in cts:search(
  doc(), 
  cts:and-query(
    (
      cts:collection-query("https://bmrc.lib.uchicago.edu/people/Winfrey%2C+Oprah"),
      cts:collection-query("https://bmrc.lib.uchicago.edu/people/Winfield%2C+Paul"),
      cts:collection-query("https://bmrc.lib.uchicago.edu/people/Windsor%2C+Duke+of%2C+Edward"),
      cts:collection-query("https://bmrc.lib.uchicago.edu/people/Winchell%2C+Walter"),
      cts:collection-query("https://bmrc.lib.uchicago.edu/people/Winbush%2C+LeRoy"),
      cts:collection-query("https://bmrc.lib.uchicago.edu/people/Wimp%2C+Edward"),
      cts:collection-query("https://bmrc.lib.uchicago.edu/people/Wimbish%2C+C.C."),
      cts:collection-query("https://bmrc.lib.uchicago.edu/people/Wilson%2C+William+Julius")
    )
  )
)
return document-uri($x)

*** GETTING A TITLE

declare namespace ead = 'urn:isbn:1-931666-22-9';
for $x in fn:doc() 
let $title_elements := ($x//ead:titleproper/text())[1]
return (fn:document-uri($x), fn:normalize-space(fn:string-join($title_elements, ' ')))




Here are some sites though, that I think are promising exemplars for our Top 10:
Chicago Collections Consortium Explore (of course) - ECC | Discover the History and Culture of Chicago (chicagocollections.org)
Amistad Research Center at Tulane - ArchivesSpace Public Interface | Amistad Research Center (tulane.edu)
ArchiveGrid - ArchiveGrid (oclc.org)
Duke University - Archives & Manuscripts at Duke University Libraries an ArcLight site I think
Philadelphia Area Archives Research Portal - the PAARP! Philadelphia Area Archives Research Portal (PAARP) (upenn.edu)
Rocky Mountain Online Archive - Rocky Mountain Online Archive (unm.edu) Kind of basic, but gets it done
Connecticut's Online Archives - the big CAO - CAO - by ArcLight (wcsu.edu) 
Online Archive of California - Browse Collections (0-9), Online Archive of California (cdlib.org)
Just for fun - another ArchivesSpace site - they are cookie cutter to some degree - Battling Tops (Game) | The Strong (museumofplay.org)
Rock Hall - Rock and Roll Hall of Fame and Museum | Library and Archives | Catalog Search Results (rockhall.com) they use a Fedora/Hydra/Samvera stack I think
Roosevelt University Archives - University Archives Location, Information and Resources | Roosevelt University - uses Cuadra product
Rhode Island Archival and Manuscript Collections Online - RIAMCO
Northwestern uses ArchivesSpace -- the look and functions are identical to the A-SPace sites above. Ditto University of Virginia, Uof Minnesota ArchivesSpace Public Interface | University of Minnesota Archival Collections Guides (umn.edu) and many more...

I can't believe people still are using Archon -- like me at my last workplace. 🙂 Cushing Library (tamu.edu) and CBMR http://cbmr-webapps.colum.edu/archon/ Compare!

Tufts' Digital Library kindly provides their tech stack for your delectation. Show Page // Tufts Digital Library

Anyway, that's all for now. I will continue my analysis of these comparable sites. It's quite instructive! I'm a bit sorry to say that few so far use breadcrumbs. The crumb-like "Return to search results" at top left could help thought if we decide to ditch the whole crumby idea.
Cheers,
Laurie
