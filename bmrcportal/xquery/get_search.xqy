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

(: a browse, match facet URIs beginning with this string. :)
declare variable $b as xs:string external;

(: a JSON array of collections currently active. (i.e. 'f' params.) :)
declare variable $collections_active_raw as json:array external;

(: a query string. :)
declare variable $q as xs:string external;

(: start results from this index. :)
declare variable $start as xs:integer external;

(: number of results for this result page. :)
declare variable $size as xs:integer external;

(: how to sort search results. :)
declare variable $sort as xs:string external;

(: :)
declare variable $lookahead-pages as xs:integer := 1;

(:::::::::::::
   FUNCTIONS 
 :::::::::::::)

declare function get-collections-for-results($results) {
    (: Get a unique sequence of collections for a set of results.

       Params
         $results - search results from cts:search()

       Returns
         a sequence of unique strings, MarkLogic collection URIs. 
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

declare function get-abstract($doc) {
    (: Params
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

declare function get-collection-counts($docs, $collections, $docs-map, $sort, $limit) {
    (: 
       Params
         $docs               - accepting a list of documents is a way for this 
                               function to restrict collection counts to a specific
                               set of search results, without having to execute that
                               search. alternatively, pass in the empty sequence to
                               retrive counts for all documents. (i.e., passing in a
                               sequence of documents to refine an existing
                               search. pass in the empty sequence to start a new search.)
         $collections        - sequence of all collections to consider. the function
                               will only return collections from this sequence.
         $sort               - sort in this way.
         $limit              - limit to this many results.

       Returns
         a JSON array, e.g.:
           [
             [
               "https://bmrc.lib.uchicago.edu/topics/one",
               "one",
               100
             ],
             [
               "https://bmrc.lib.uchicago.edu/topics/two",
               "two",
               50
             ],
             [
               "https://bmrc.lib.uchicago.edu/topics/three",
               "three",
               66
             ]
           ]
       Note
         We can pre-compute collections-map and save it to the database- then
         you can retrieve it like this:

         let $collections-map := map:map(fn:doc('collections-map')/map:map)
       
         This shaves off about .2 seconds. As the database gets bigger is
         precomputing this value more and more important? 
    :)

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

declare function get-collection-counts-for-doc($doc, $starts-with, $limit) {
    (: 
       Params
         $docs               - accepting a list of documents is a way for this 
                               function to restrict collection counts to a specific
                               set of search results, without having to execute that
                               search. alternatively, pass in the empty sequence to
                               retrive counts for all documents. (i.e., passing in a
                               sequence of documents to refine an existing
                               search. pass in the empty sequence to start a new search.)
         $collections        - sequence of all collections to consider. the function
                               will only return collections from this sequence.
         $sort               - sort in this way.
         $limit              - limit to this many results.

       Returns
         a JSON array, e.g.:
           [
             [
               "https://bmrc.lib.uchicago.edu/topics/one",
               "one",
               100
             ],
             [
               "https://bmrc.lib.uchicago.edu/topics/two",
               "two",
               50
             ],
             [
               "https://bmrc.lib.uchicago.edu/topics/three",
               "three",
               66
             ]
           ]
       Note
         We can pre-compute collections-map and save it to the database- then
         you can retrieve it like this:

         let $collections-map := map:map(fn:doc('collections-map')/map:map)
       
         This shaves off about .2 seconds. As the database gets bigger is
         precomputing this value more and more important? 
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

declare function get-title($doc) {
    (: Get the title for a given document.

       Params
         $doc - a MarkLogic document object, e.g. fn:doc('BMRC.DEFENDER.INDIVIDUALS.xml')
       Returns
         a string, the document's title.
                ($doc//ead:titleproper)[fn:last()]//text()[fn:not(parent::ead:num)],
     :)

     fn:normalize-space(($doc//ead:archdesc//ead:unittitle)[1])
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
         $lookahead-pages - 

       Returns
         a sequence of paged search results.
    :)

    let $ordered-results :=
        for $r in $results
        order by
            if ($sort eq 'alpha' or $sort eq 'alpha-dsc')
            then get-title($r)
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

declare function get-query($raw-query as xs:string, $collections) as cts:query? {
    (: 
       Params
         $raw-query   - a string, the query itself.
         $collections - a sequnce of collections to restrict this query to.
       Returns
         a cts:and-query() which can be passed to cts:search()
       Notes
         all active facets are ANDed together. we return a cts:and-query()
         because we're searching the intersection of all collections passed to
         this script.
         return a cts:and-query() containing the keyword search along with each
         individual collection as a cts:collection-query().
    :)

    cts:and-query(
        (
            for $t in fn:tokenize($raw-query, 's+')[. ne '']
            return cts:word-query($t),
            for $c in json:array-values($collections)
            return cts:collection-query($c)
        )
    )
};

(:::::::::::
  VARIABLES
 :::::::::::)

(: a sequence of collections that are confirmed to exist. this also insures $collections_active has been sanitized. :)
let $collections-active :=
    for $c in $collections_active_raw
    return
        if (fn:exists($c))
        then $c
        else ()

(: a sequence of documents, e.g. (fn:doc('uri-1'), fn:doc('uri-2'), fn:doc('uri-3')) :)
let $search-results := 
    cts:search(
        fn:doc(),
        get-query(
            $q,   
            $collections-active
        )
    )

let $search-results-collections := get-collections-for-results($search-results)

(: total number of search results :)
let $total := fn:count($search-results)

(: a sequence of documents, e.g. (fn:doc('uri-1'), fn:doc('uri-2'), fn:doc('uri-3')) :)
let $paged-search-results := page-results(
    $search-results,
    $start,
    $size,
    $sort,
    $lookahead-pages
)

let $docs-map := map:new(
    if (fn:empty($search-results))
    then
        for $d in fn:doc()
        return map:entry(fn:document-uri($d), fn:true())
    else
        for $d in $search-results
        return map:entry($d, fn:true())
)

let $more-archives := 
    get-collection-counts(
        $search-results,
        for $c in $search-results-collections
        return
            if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/archives/'))
            then $c 
            else (),
        $docs-map,
        if ($b eq 'https://bmrc.lib.uchicago.edu/archives/')
        then $sort
        else 'relevance-dsc',
        if ($b eq 'https://bmrc.lib.uchicago.edu/archives/')
        then 0
        else 5
    )

let $more-decades :=
    get-collection-counts(
        $search-results,
        for $c in $search-results-collections
        return
            if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/decades/'))
            then $c 
            else (),
        $docs-map,
        if ($b eq 'https://bmrc.lib.uchicago.edu/decades/')
        then $sort
        else 'relevance-dsc',
        if ($b eq 'https://bmrc.lib.uchicago.edu/decades/')
        then 0
        else 5
    )

let $more-organizations :=
    get-collection-counts(
        $search-results,
        for $c in $search-results-collections
        return
            if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/organizations/'))
            then $c 
            else (),
        $docs-map,
        if ($b eq 'https://bmrc.lib.uchicago.edu/organizations/')
        then $sort
        else 'relevance-dsc',
        if ($b eq 'https://bmrc.lib.uchicago.edu/organizations/')
        then 0
        else 5
    )

let $more-people :=
    get-collection-counts(
        $search-results,
        for $c in $search-results-collections
        return
            if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/people/'))
            then $c 
            else (),
        $docs-map,
        if ($b eq 'https://bmrc.lib.uchicago.edu/people/')
        then $sort
        else 'relevance-dsc',
        if ($b eq 'https://bmrc.lib.uchicago.edu/people/')
        then 0
        else 5
    )

let $more-places :=
    get-collection-counts(
        $search-results,
        for $c in $search-results-collections
        return
            if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/places/'))
            then $c 
            else (),
        $docs-map,
        if ($b eq 'https://bmrc.lib.uchicago.edu/places/')
        then $sort
        else 'relevance-dsc',
        if ($b eq 'https://bmrc.lib.uchicago.edu/places/')
        then 0
        else 5
    )

let $more-topics :=
    get-collection-counts(
        $search-results,
        for $c in $search-results-collections
        return
            if (fn:starts-with($c, 'https://bmrc.lib.uchicago.edu/topics/'))
            then $c 
            else (),
        $docs-map,
        if ($b eq 'https://bmrc.lib.uchicago.edu/topics/')
        then $sort
        else 'relevance-dsc',
        if ($b eq 'https://bmrc.lib.uchicago.edu/topics/')
        then 0
        else 5
    )

return json:object(
    <json:object>
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
            <json:key>start</json:key>
            <json:value xsi:type="xs:integer">{ $start }</json:value>
        </json:entry>
        <json:entry>
            <json:key>size</json:key>
            <json:value xsi:type="xs:integer">{ $size }</json:value>
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
                        for $c in json:array-values($collections-active)
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
                        let $r-decades := get-collection-counts-for-doc(
                            $r,
                            "https://bmrc.lib.uchicago.edu/decades/",
                            3
                        )
                        let $r-organizations := get-collection-counts-for-doc(
                            $r,
                            "https://bmrc.lib.uchicago.edu/organizations/",
                            3
                        )
                        let $r-people := get-collection-counts-for-doc(
                            $r,
                            "https://bmrc.lib.uchicago.edu/people/",
                            3
                        )
                        let $r-places := get-collection-counts-for-doc(
                            $r,
                            "https://bmrc.lib.uchicago.edu/places/",
                            3
                        )
                        let $r-topics := get-collection-counts-for-doc(
                            $r,
                            "https://bmrc.lib.uchicago.edu/topics/",
                            3
                        )
                        return
                            <json:value>
                                <json:object>
                                    <json:entry>
                                        <json:key>abstract</json:key>
                                        <json:value>{ get-abstract($r) }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>index</json:key>
                                        <json:value xsi:type="xs:integer">{ $start - 1 + $i }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>collections-decades</json:key>
                                        <json:value>{ $r-decades }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>collections-organizations</json:key>
                                        <json:value>{ $r-organizations }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>collections-people</json:key>
                                        <json:value>{ $r-people }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>collections-places</json:key>
                                        <json:value>{ $r-places }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>collections-topics</json:key>
                                        <json:value>{ $r-topics }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>title</json:key>
                                        <json:value>{ get-title($r) }</json:value>
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
