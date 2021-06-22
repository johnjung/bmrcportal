import module namespace json =
  "http://marklogic.com/xdmp/json"
  at "/MarkLogic/json/json.xqy";

import module namespace search =
  "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare namespace cts = "http://marklogic.com/cts";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xs  = "http://www.w3.org/2001/XMLSchema";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare default function namespace "https://bmrc.lib.uchicago.edu";

(::::::::::::::::::::
  EXTERNAL VARIABLES
 ::::::::::::::::::::)

(: For a complete browse of of a certain facet type, match browse URIs
   beginning with this string, e.g., https://bmrc.lib.uchicago.edu/topics/
   In browse mode you can also pass sort and limit for browse results
   instead of search results. :)
declare variable $b as xs:string external;

(: A JSON array of collections currently active. (i.e. 'f' params.) 
   search results will be restricted to these collections only. :)
declare variable $collections_active_raw as json:array external;

(: A query string. :)
declare variable $q as xs:string external;

(: For paged search results, start a page of search results from this index. :)
declare variable $start as xs:integer external;

(: For paged search results, number of results for this result page. :)
declare variable $size as xs:integer external;

(: Sorting for searches and browses. :)
declare variable $sort as xs:string external;

(: Placeholder variable for estimated search results. :)
declare variable $lookahead-pages as xs:integer := 1;

(:::::::::::::
   FUNCTIONS 
 :::::::::::::)

declare function abstract($doc) {
    (: Get the abstract for a finding aid.

       Params
         $doc - e.g. fn:doc('BMRC.DEFENDER.INDIVIDUALS.xml')

       Returns
         a string, the document's abstract.
    :)
    let $tokens := fn:tokenize(
        fn:normalize-space(
            fn:string-join(
                ($doc//ead:abstract | $doc//ead:bioghist | $doc//ead:scopecontent)[1]//text()[fn:not(parent::ead:head)]
            )   
        ),
        ' '
    )
    return fn:concat(
        fn:string-join(
            $tokens[1 to 60],
            ' '
        ),
        ''
    )
};

declare function archive($doc) {
    (: Get the archive for a finding aid.

       Params
         $doc - e.g. fn:doc('BMRC.DEFENDER.INDIVIDUALS.xml')

       Returns
         a string, the document's archive.

    archive_lookup = { 
        'https://bmrc.lib.uchicago.edu/archives/bmrcportal':  'BMRC Portal',
        'https://bmrc.lib.uchicago.edu/archives/bronzeville': 'Bronzeville Historical',
        'https://bmrc.lib.uchicago.edu/archives/cbmr':        'CBMR',
        'https://bmrc.lib.uchicago.edu/archives/chm':         'Chicago History Museum',
        'https://bmrc.lib.uchicago.edu/archives/columbia':    'Columbia College',
        'https://bmrc.lib.uchicago.edu/archives/csu':         'Chicago State',
        'https://bmrc.lib.uchicago.edu/archives/cyc':         'Chicago Youth Ctr',
        'https://bmrc.lib.uchicago.edu/archives/defender':    'Defender',
        'https://bmrc.lib.uchicago.edu/archives/depaul':      'DePaul',
        'https://bmrc.lib.uchicago.edu/archives/du':          'Dominican',
        'https://bmrc.lib.uchicago.edu/archives/dusable':     'Dusable',
        'https://bmrc.lib.uchicago.edu/archives/ehc':         'Evanston History Ctr',
        'https://bmrc.lib.uchicago.edu/archives/eta':         'ETA Creative Arts',
        'https://bmrc.lib.uchicago.edu/archives/gerhart':     'Gerber Hart',
        'https://bmrc.lib.uchicago.edu/archives/harsh':       'CPL-Harsh',
        'https://bmrc.lib.uchicago.edu/archives/hwlc':        'CPL-HWLC',
        'https://bmrc.lib.uchicago.edu/archives/iit':         'Illinois Tech',
        'https://bmrc.lib.uchicago.edu/archives/ilhs':        'IL Labor History',
        'https://bmrc.lib.uchicago.edu/archives/isdsa':       'Intl Society Slave Ancestry',
        'https://bmrc.lib.uchicago.edu/archives/kart':        'Kartemquin',
        'https://bmrc.lib.uchicago.edu/archives/lake':        'Lake City Discovery',
        'https://bmrc.lib.uchicago.edu/archives/lanetech':    'Lane Tech HS',
        'https://bmrc.lib.uchicago.edu/archives/lbp':         'Little Black Pearl',
        'https://bmrc.lib.uchicago.edu/archives/loyola':      'Loyola',
        'https://bmrc.lib.uchicago.edu/archives/malcolmx':    'Malcolm X College',
        'https://bmrc.lib.uchicago.edu/archives/neiu':        'Northeastern IL',
        'https://bmrc.lib.uchicago.edu/archives/newberry':    'Newberry',
        'https://bmrc.lib.uchicago.edu/archives/nu':          'Northwestern',
        'https://bmrc.lib.uchicago.edu/archives/pshs':        'Pullman Historic Site',
        'https://bmrc.lib.uchicago.edu/archives/roosevelt':   'Roosevelt',
        'https://bmrc.lib.uchicago.edu/archives/rush':        'Rush U Med Ctr',
        'https://bmrc.lib.uchicago.edu/archives/shorefront':  'Shorefront',
        'https://bmrc.lib.uchicago.edu/archives/spertus':     'Spertus',
        'https://bmrc.lib.uchicago.edu/archives/sscac':       'South Side Community Arts Ctr',
        'https://bmrc.lib.uchicago.edu/archives/taylor':      'Taylor',
        'https://bmrc.lib.uchicago.edu/archives/uic':         'UIC',
        'https://bmrc.lib.uchicago.edu/archives/uoc':         'UChicago',
        'https://bmrc.lib.uchicago.edu/archives/werner':      'Werner'
    } 

    figure out what archive this document is a part of. 

    :)
    let $archives :=
        for $c in xdmp:document-get-collections(fn:document-uri($doc))
        return
            if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/archives/'))
            then $c
            else ()
    return 
        if ('https://bmrc.lib.uchicago.edu/archives/bronzeville' eq $archives) then 'Bronzeville Historical'
        else 'archive'
};

declare function collection-counts($collections, $docs, $sort, $limit) {
    (: 
       Params

         $collections - sequence of collections to consider.
         $docs        - a pre-computed sequence of document URIs to consider, like
                        the result documents from a search.
         $sort        - sort for results.
         $limit       - limit for results.

       Returns

         a JSON array, e.g.:
           [
             [
               "https://bmrc.lib.uchicago.edu/topics/one",
               "one",
               100
             ],
             ...
           ]

       Notes
         We can pre-compute collections-map and save it to the database- then
         you can retrieve it like this:

         let $collections-map := map:map(fn:doc('collections-map')/map:map)
       
         This shaves off about .2 seconds. As the database gets bigger is
         precomputing this value more and more important? 
    :)

    let $docs-map := map:new(
        if (fn:empty($docs))
        then
            for $d in fn:doc()
            return map:entry(fn:document-uri($d), fn:true())
        else
            for $d in $docs
            return map:entry($d, fn:true())
    )

    let $collections-map := map:new(
        for $c in $collections
        return map:entry(
            $c,
            map:new(
                for $d in fn:collection($c)
                return map:entry(fn:document-uri($d), fn:true())
            )
        )
    )

    let $collections-sorted :=
        if ($sort eq 'alpha')
        then
            for $c in $collections
            order by $c
            return $c
        else if ($sort eq 'alpha-dsc')
        then
            for $c in $collections
            order by $c descending
            return $c
        else if ($sort eq 'relevance')
        then
            for $c in $collections
            order by map:count($docs-map * map:get($collections-map, $c))
            return $c
        else if ($sort eq 'relevance-dsc')
        then
            for $c in $collections
            order by map:count($docs-map * map:get($collections-map, $c)) * -1
            return $c
        else if ($sort eq 'shuffle')
        then
            for $c in $collections
            order by xdmp:random()
            return $c
        else
            ()

    let $collections-limited := 
        if ($limit gt 0)
        then fn:subsequence($collections-sorted, 1, $limit)
        else $collections-sorted

    return
        <json:array>
            {
                for $c in $collections-limited
                return
                    <json:array>
                        <json:value>{ $c }</json:value>
                        <json:value>
                            { 
                                xdmp:url-decode(fn:tokenize($c, "/")[5]) 
                            }
                        </json:value>
                        <json:value xsi:type="xs:integer">
                            { 
                                map:count($docs-map * map:get($collections-map, $c))
                            }
                        </json:value>
                    </json:array>
            }
        </json:array>
};

declare function collection-counts-wrap($collections-seq, $collections-starts-with, $collections-skip, $collections-browse, $docs-seq, $sidebar-facet-sort, $browse-sort, $sidebar-facet-limit) {
    (: Wrapper function to get collection counts for either the sidebar or a complete facet browse.

       Params
 
          $collections-seq         - a sequence of collections for search
                                     results.
          $collections-starts-with - filter $collections-seq for URIs beginning
                                     with this string.
          $collections-skip        - a sequence of collection URIs to skip
                                     (e.g., currently active collections)
          $collections-browse      - if a browse was specified, return every
                                     result. otherwise, return a smaller amount
                                     of results for a sidebar facet.
          $docs-seq                - a sequence of documents from search results.
          $sidebar-facet-sort      - sort for when we're returning results for
                                     a sidebar facet.
          $browse-sort             - sort for when we're returning a complete
                                     browse list for a facet.
          $sidebar-facet-limit     - limit for sidebar facets.

       Returns
   
           See collection-counts()
    :)
    collection-counts(
        for $c in $collections-seq
        return
            if (fn:starts-with($c, $collections-starts-with) and fn:not($c = $collections-skip) and $c ne 'https://bmrc.lib.uchicago.edu/archives/BMRC+Portal')
            then $c 
            else (),
        $docs-seq,
        if ($collections-browse eq $collections-starts-with)
        then $browse-sort
        else $sidebar-facet-sort,
        if ($collections-browse eq $collections-starts-with)
        then 0
        else $sidebar-facet-limit
    )
};

declare function collection-counts-for-doc($doc, $starts-with, $limit) {
    (: Get a list of facet tags for each search results. 

       Params

         $doc         - document to retrieve facets for.
         $starts-with - retrieve facets beginning with this string, e.g.,
                        https://bmrc.lib.uchicago.edu/topics/
         $limit       - retrive this many results only.

       Returns
         a JSON array, e.g.:
           [
             [
               "https://bmrc.lib.uchicago.edu/topics/one",
               "one",
               100
             ],
             ...
           ]

       Notes

         Unlike with the collection-counts() function, this function
         assumes that clicking on one of these tags starts a new, "fresh"
         search- so the facets that are present and the counts for each facet
         reflect all documents in the system. Because of that this function
         does not include a sequence of documents to consider as a parameter.

         Results are hard-coded to sort by descending relevance.
    :)

    let $collections-filtered :=
        for $c in xdmp:document-get-collections(fn:document-uri($doc))
        return
            if (fn:starts-with($c, $starts-with))
            then $c
            else ()

    let $collections-sorted :=
        for $c in $collections-filtered
        order by fn:count(fn:collection($c)) descending
        return $c
 
    let $collections-limited :=
        if ($limit gt 0)
        then fn:subsequence($collections-sorted, 1, $limit)
        else $collections-sorted

    return
        <json:array>
            {
                for $c in $collections-limited
                return
                    <json:array>
                        <json:value>{ $c }</json:value>
                        <json:value>
                            { 
                                xdmp:url-decode(fn:tokenize($c, "/")[5]) 
                            }
                        </json:value>
                        <json:value xsi:type="xs:integer">
                            { 
                                fn:count(fn:collection($c))
                            }
                        </json:value>
                    </json:array>
            }
        </json:array>
};

declare function collections-for-results($results) {
    (: Get a unique sequence of collections for a set of results.

       Params
         $results - search results from cts:search()

       Returns
         a sequence of unique MarkLogic collection URIs. 

       Notes
         map:keys() returns a unique sequence faster than fn:distinct-values().
    :)

    map:keys(
        map:new(
            for $r in $results
            return 
                for $c in xdmp:document-get-collections(fn:document-uri($r))
                return map:entry($c, fn:true())
        )
    )
};

declare function date($doc) {
    (: Get the date for a finding aid.

       Params
         $doc - e.g. fn:doc('BMRC.DEFENDER.INDIVIDUALS.xml')

       Returns
         a string, the document's date.
    :)
    ($doc//ead:unitdate)[1]/text()
};

declare function extent($doc) {
    (: Get the extent for a finding aid.

       Params
         $doc - e.g. fn:doc('BMRC.DEFENDER.INDIVIDUALS.xml')

       Returns
         a string, the document's extent.
    :)
    $doc//ead:extent[1]/text()
};

declare function page-results(
    $results         as item()*,
    $start           as xs:integer,
    $size            as xs:integer,
    $sort            as xs:string,
    $lookahead-pages as xs:integer
) {
    (: Get a page of search results.

       Params
         $results         - a sequence of items returned from e.g. cts:search()
         $start           - begin with this index.
         $size            - size of result page.
         $sort            - sort for this result set.
         $lookahead-pages - placeholder variable.

       Returns
         a sequence of paged search results.
    :)

    let $ordered-results :=
        for $r in $results
        order by
            if ($sort eq 'alpha' or $sort eq 'alpha-dsc')
            then title($r)
            else if ($sort eq 'random')
            then xdmp:random()
            else ()
        return $r

    let $paged-results :=
        if ($sort eq 'alpha-dsc' or $sort eq 'relevance-dsc')
        then fn:reverse($ordered-results)
        else $ordered-results

    return $paged-results[$start to $start + $size - 1]
};

declare function query($raw-query as xs:string, $collections) as cts:query? {
    (: Build a query from a raw query string and a sequence of collections. 

       Params
         $raw-query   - a string, the query itself.
         $collections - a sequnce of collections to restrict this query to.

       Returns
         a cts:and-query() which can be passed to cts:search()

       Notes
         all active facets are ANDed together, to search for results within the
         intersection of all collections passed to this script.
    :)

    cts:and-query(
        (
            for $t in fn:tokenize($raw-query, 's+')[. ne '']
            return cts:word-query($t),
            for $c in $collections
            return cts:collection-query($c)
        )
    )
};

declare function title($doc) {
    (: Get the title for a given document.

       Params
         $doc - a MarkLogic document object, e.g.
                fn:doc('BMRC.DEFENDER.INDIVIDUALS.xml')

       Returns
         a string, the document's title.
     :)

     fn:normalize-space(($doc//ead:archdesc//ead:unittitle)[1])
};

(:::::::::::
  VARIABLES
 :::::::::::)

(: a sequence of collections that are confirmed to exist in the system. :)
let $collections-active :=
    for $c in json:array-values($collections_active_raw)
    return
        if (fn:exists($c))
        then $c
        else ()

(: search results. :)
let $search-results := 
    cts:search(
        fn:doc(),
        query(
            $q,   
            $collections-active
        )
    )

(: collections present in this set of search results. :)
let $search-results-collections := collections-for-results($search-results)

(: total number of search results :)
let $total := fn:count($search-results)

(: paging. :)
let $paged-search-results := page-results(
    $search-results,
    $start,
    $size,
    $sort,
    $lookahead-pages
)

(: get a sequence of document URIs for search results to pass to collection-counts(). :)
let $docs-seq := 
    if (fn:empty($search-results))
    then
        for $d in fn:doc()
        return fn:document-uri($d)
    else
        for $r in $search-results
        return fn:document-uri($r)

(: sort for sidebar facets. :)
let $sidebar-facet-sort := 'relevance-dsc'

(: number of results to return for a sidebar facet. :)
let $sidebar-facet-limit := 5

(: active collections, broken up by type, so they can be included in the facet sidebar. :)
let $active-archives :=
    <json:array>
        {
            for $c in $collections-active
            return
                if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/archives/'))
                then
                    <json:array>
                        <json:value>{ $c }</json:value>
                        <json:value>
                            { 
                                xdmp:url-decode(fn:tokenize($c, "/")[5]) 
                            }
                        </json:value>
                        <json:value xsi:type="xs:integer">0</json:value>
                    </json:array>
                else ()
        }
    </json:array>

let $active-decades :=
    <json:array>
        {
            for $c in $collections-active
            return
                if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/decades/'))
                then
                    <json:array>
                        <json:value>{ $c }</json:value>
                        <json:value>
                            { 
                                xdmp:url-decode(fn:tokenize($c, "/")[5]) 
                            }
                        </json:value>
                        <json:value xsi:type="xs:integer">0</json:value>
                    </json:array>
                else ()
        }
    </json:array>

let $active-organizations :=
    <json:array>
        {
            for $c in $collections-active
            return
                if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/organizations/'))
                then
                    <json:array>
                        <json:value>{ $c }</json:value>
                        <json:value>
                            { 
                                xdmp:url-decode(fn:tokenize($c, "/")[5]) 
                            }
                        </json:value>
                        <json:value xsi:type="xs:integer">0</json:value>
                    </json:array>
                else ()
        }
    </json:array>

let $active-people :=
    <json:array>
        {
            for $c in $collections-active
            return
                if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/people/'))
                then
                    <json:array>
                        <json:value>{ $c }</json:value>
                        <json:value>
                            { 
                                xdmp:url-decode(fn:tokenize($c, "/")[5]) 
                            }
                        </json:value>
                        <json:value xsi:type="xs:integer">0</json:value>
                    </json:array>
                else ()
        }
    </json:array>

let $active-places :=
    <json:array>
        {
            for $c in $collections-active
            return
                if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/places/'))
                then
                    <json:array>
                        <json:value>{ $c }</json:value>
                        <json:value>
                            { 
                                xdmp:url-decode(fn:tokenize($c, "/")[5]) 
                            }
                        </json:value>
                        <json:value xsi:type="xs:integer">0</json:value>
                    </json:array>
                else ()
        }
    </json:array>

let $active-topics :=
    <json:array>
        {
            for $c in $collections-active
            return
                if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/topics/'))
                then
                    <json:array>
                        <json:value>{ $c }</json:value>
                        <json:value>
                            { 
                                xdmp:url-decode(fn:tokenize($c, "/")[5]) 
                            }
                        </json:value>
                        <json:value xsi:type="xs:integer">0</json:value>
                    </json:array>
                else ()
        }
    </json:array>

(: facets for the sidebar or for complete browse lists. :)
let $more-archives := 
    collection-counts-wrap(
        $search-results-collections, 
        'https://bmrc.lib.uchicago.edu/archives/',
        $collections-active,
        $b,
        $docs-seq,
        $sidebar-facet-sort,
        $sort,
        $sidebar-facet-limit
    )
        
let $more-decades :=
    collection-counts-wrap(
        $search-results-collections, 
        'https://bmrc.lib.uchicago.edu/decades/',
        $collections-active,
        $b,
        $docs-seq,
        $sidebar-facet-sort,
        $sort,
        $sidebar-facet-limit
    )

let $more-organizations :=
    collection-counts-wrap(
        $search-results-collections, 
        'https://bmrc.lib.uchicago.edu/organizations/',
        $collections-active,
        $b,
        $docs-seq,
        $sidebar-facet-sort,
        $sort,
        $sidebar-facet-limit
    )

let $more-people :=
    collection-counts-wrap(
        $search-results-collections, 
        'https://bmrc.lib.uchicago.edu/people/',
        $collections-active,
        $b,
        $docs-seq,
        $sidebar-facet-sort,
        $sort,
        $sidebar-facet-limit
    )

let $more-places :=
    collection-counts-wrap(
        $search-results-collections, 
        'https://bmrc.lib.uchicago.edu/places/',
        $collections-active,
        $b,
        $docs-seq,
        $sidebar-facet-sort,
        $sort,
        $sidebar-facet-limit
    )

let $more-topics :=
    collection-counts-wrap(
        $search-results-collections, 
        'https://bmrc.lib.uchicago.edu/topics/',
        $collections-active,
        $b,
        $docs-seq,
        $sidebar-facet-sort,
        $sort,
        $sidebar-facet-limit
    )

return json:object(
    <json:object>
        <json:entry>
            <json:key>active-archives</json:key>
            <json:value>{ $active-archives }</json:value>
        </json:entry>
        <json:entry>
            <json:key>active-decades</json:key>
            <json:value>{ $active-decades }</json:value>
        </json:entry>
        <json:entry>
            <json:key>active-organizations</json:key>
            <json:value>{ $active-organizations }</json:value>
        </json:entry>
        <json:entry>
            <json:key>active-people</json:key>
            <json:value>{ $active-people }</json:value>
        </json:entry>
        <json:entry>
            <json:key>active-places</json:key>
            <json:value>{ $active-places }</json:value>
        </json:entry>
        <json:entry>
            <json:key>active-topics</json:key>
            <json:value>{ $active-topics }</json:value>
        </json:entry>
        <json:entry>
            <json:key>b</json:key>
            <json:value>{ $b }</json:value>
        </json:entry>
        <json:entry>
            <json:key>more-archives</json:key>
            <json:value>{ $more-archives }</json:value>
        </json:entry>
        <json:entry>
            <json:key>more-decades</json:key>
            <json:value>{ $more-decades }</json:value>
        </json:entry>
        <json:entry>
            <json:key>more-organizations</json:key>
            <json:value>{ $more-organizations }</json:value>
        </json:entry>
        <json:entry>
            <json:key>more-people</json:key>
            <json:value>{ $more-people }</json:value>
        </json:entry>
        <json:entry>
            <json:key>more-places</json:key>
            <json:value>{ $more-places }</json:value>
        </json:entry>
        <json:entry>
            <json:key>more-topics</json:key>
            <json:value>{ $more-topics }</json:value>
        </json:entry>
        <json:entry>
            <json:key>q</json:key>
            <json:value>{ $q }</json:value>
        </json:entry>
        <json:entry>
            <json:key>sort</json:key>
            <json:value>{ $sort }</json:value>
        </json:entry>
        <json:entry>
            <json:key>size</json:key>
            <json:value xsi:type="xs:integer">{ $size }</json:value>
        </json:entry>
        <json:entry>
            <json:key>start</json:key>
            <json:value xsi:type="xs:integer">{ $start }</json:value>
        </json:entry>
        <json:entry>
            <json:key>stop</json:key>
            <json:value xsi:type="xs:integer">{ fn:min(($start + $size - 1, $total)) }</json:value>
        </json:entry>
        <json:entry>
            <json:key>total</json:key>
            <json:value xsi:type="xs:integer">{ $total }</json:value>
        </json:entry>
        <json:entry>
            <json:key>collections-active</json:key>
            <json:value>
                <json:array>
                    { 
                        for $c in $collections-active
                        return
                            <json:array>
                                <json:value>{ $c }</json:value>
                                <json:value>{ xdmp:url-decode(fn:tokenize($c, "/")[5]) }</json:value>
                                <json:value xsi:type="xs:integer">{ fn:count(cts:search(fn:doc(for $x in $search-results return fn:document-uri($x)), cts:collection-query($c))) }</json:value>
                            </json:array>
                    }
                </json:array>
            </json:value>
        </json:entry>
        <json:entry>
            <json:key>results</json:key>
            <json:value>
                <json:array>
                    {
                        for $r at $i in $paged-search-results
                        (: need date, extent, and archives for each of these. :)
                        return
                            <json:value>
                                <json:object>
                                    <json:entry>
                                        <json:key>abstract</json:key>
                                        <json:value>{ abstract($r) }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>archive</json:key>
                                        <json:value>{ archive($r) }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>date</json:key>
                                        <json:value>{ date($r) }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>extent</json:key>
                                        <json:value>{ extent($r) }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>index</json:key>
                                        <json:value xsi:type="xs:integer">{ $start - 1 + $i }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>title</json:key>
                                        <json:value>{ title($r) }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>uri</json:key>
                                        <json:value>{ fn:document-uri($r) }</json:value>
                                    </json:entry>
                                </json:object>
                            </json:value>
                    }
                </json:array>
            </json:value>
        </json:entry>
    </json:object>
)
