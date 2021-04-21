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

COMPARE THESE SITES

https://explore.chicagocollections.org/
https://amistad-finding-aids.tulane.edu/
https://researchworks.oclc.org/archivegrid/
https://archives.lib.duke.edu/
http://dla.library.upenn.edu/dla/pacscl/index.html
https://rmoa.unm.edu/
https://archives-library.wcsu.edu/cao/
https://cdlib.org/
http://catalog.rockhall.com/
https://www.roosevelt.edu/library
https://www.riamco.org/
https://findingaids.library.northwestern.edu/
http://cbmr-webapps.colum.edu/archon/

BOX LINK:
https://uchicago.box.com/s/xehva2kfd2ra0b5ek95lc4s694phy0uq

