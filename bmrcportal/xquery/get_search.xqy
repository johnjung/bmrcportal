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

declare function get-collection($results, $collections, $starts-with, $limit, $count-all-docs) {
    (: 
       Params
         $results        - search results to get collections for.
         $collections    - sequence of active collections.
         $starts-with    - look for collections beginning with this substring.
         $limit          - return this number of results at most. if -1, return
                           all.
         $count-all-docs - boolean. if fn:true(), this function will return the
                           number of times a facet appears in the entire
                           database. this is appropriate for situations where
                           links constructed from the data this function
                           returns will start new searches. if fn:false() the 
                           function will return the number of times a facet
                           appears within these search results. this is
                           appropriate when links constructed from this
                           function's return value refine existing searches.
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
       
       Notes
         precomputing $result-docs before the loops below greatly speeds up
         processing. other variables are precomputed to make the code cleaner.
    :)
    let $result-docs := 
        for $x in $results
        return fn:document-uri($x)
    let $collections-starts-with :=
        for $c in $collections
        return
            if (fn:starts-with($c, $starts-with))
            then  $c
            else ()
    let $ordered-collections :=
        if ($limit > -1)
        then
            for $c in $collections-starts-with
            order by 
                fn:count(
                    cts:search(
                        fn:doc($result-docs), 
                        cts:collection-query($c)
                    )
                ) descending
            return $c
        else
            for $c in $collections
            order by $c
            return $c
    let $subsequence-collections :=
        if ($limit > -1)
        then fn:subsequence($ordered-collections, 1, $limit)
        else $ordered-collections
    return
        <json:array>
            {
                for $c in $subsequence-collections
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
                                fn:count(
                                    cts:search(
                                        if ($count-all-docs)
                                        then fn:doc()
                                        else fn:doc($result-docs), 
                                        cts:collection-query($c)
                                    )
                                ) 
                            }
                        </json:value>
                    </json:array>
            }
        </json:array>
};

declare function get-collections-for-doc($doc) {
    (: Get a sequence of collections for a given document.

       Params
         $doc - a string, the URI for a MarkLogic document.

       Returns
         a sequence of strings, MarkLogic collection URIs.
    :)
      
    for $c in xdmp:document-get-collections(fn:document-uri($doc))
    return 
        if ($c = 'https://bmrc.lib.uchicago.edu/institutions/BMRC+Portal')
        then ()
        else
            if (fn:count(fn:collection($c)) > 1)
            then $c
            else ()
};

declare function get-collections-for-results($results) {
    (: Get a unique sequence of collections for a set of results.

       Params
         $results - search results from cts:search()

       Returns
         a sequence of unique strings, MarkLogic collection URIs. 
    :)
 
    fn:distinct-values(
        for $r in $results
        return get-collections-for-doc($r)
    )
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

    (: highest possible index to return, if present :)
    let $paged-results :=
        for $r in $results
        order by
            if ($sort eq 'title')
            then get-title($r)
            else ()
        return $r
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
let $search-results := cts:search(
    fn:doc(),
    get-query(
        $q,   
        $collections-active
    )
)

(: total number of search results :)
let $total := fn:count($search-results)

(: collections for search results only. :)
let $search-results-collections := get-collections-for-results($search-results)

(: a sequence of documents, e.g. (fn:doc('uri-1'), fn:doc('uri-2'), fn:doc('uri-3')) :)
let $paged-search-results := page-results(
    $search-results,
    $start,
    $size,
    $sort,
    $lookahead-pages
)

let $search-results-institutions := 
    get-collection(
        $search-results,
        $search-results-collections,
        "https://bmrc.lib.uchicago.edu/institutions/",
        5,
        fn:false()
    )

let $search-results-places :=
    get-collection(
        $search-results,
        $search-results-collections,
        "https://bmrc.lib.uchicago.edu/places/",
        5,
        fn:false()
    )

let $search-results-topics :=
    get-collection(
        $search-results,
        $search-results-collections,
        "https://bmrc.lib.uchicago.edu/topics/",
        5,
        fn:false()
    )

let $search-results-decades :=
    get-collection(
        $search-results,
        $search-results-collections,
        "https://bmrc.lib.uchicago.edu/decades/",
        5,
        fn:false()
    )

let $all-institutions :=
    if ($b = 'https://bmrc.lib.uchicago.edu/institutions/')
    then 
    get-collection(
        $search-results,
        $search-results-collections,
        "https://bmrc.lib.uchicago.edu/institutions/",
        -1,
        fn:false()
    )
    else ()

let $all-places :=
    if ($b = 'https://bmrc.lib.uchicago.edu/places/')
    then 
    get-collection(
        $search-results,
        $search-results-collections,
        "https://bmrc.lib.uchicago.edu/places/",
        -1,
        fn:false()
    )
    else ()

let $all-topics :=
    if ($b = 'https://bmrc.lib.uchicago.edu/topics/')
    then 
    get-collection(
        $search-results,
        $search-results-collections,
        "https://bmrc.lib.uchicago.edu/topics/",
        -1,
        fn:false()
    )
    else ()

let $all-decades :=
    if ($b = 'https://bmrc.lib.uchicago.edu/decades/')
    then 
    get-collection(
        $search-results,
        $search-results-collections,
        "https://bmrc.lib.uchicago.edu/decades/",
        -1,
        fn:false()
    )
    else ()

return json:object(
    <json:object>
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
            <json:key>search-results-institutions</json:key>
            <json:value>{ $search-results-institutions }</json:value>
        </json:entry>
        <json:entry>
            <json:key>search-results-places</json:key>
            <json:value>{ $search-results-places }</json:value>
        </json:entry>
        <json:entry>
            <json:key>search-results-topics</json:key>
            <json:value>{ $search-results-topics }</json:value>
        </json:entry>
        <json:entry>
            <json:key>search-results-decades</json:key>
            <json:value>{ $search-results-decades }</json:value>
        </json:entry>
        <json:entry>
            <json:key>all-institutions</json:key>
            <json:value>{ $all-institutions }</json:value>
        </json:entry>
        <json:entry>
            <json:key>all-places</json:key>
            <json:value>{ $all-places }</json:value>
        </json:entry>
        <json:entry>
            <json:key>all-topics</json:key>
            <json:value>{ $all-topics }</json:value>
        </json:entry>
        <json:entry>
            <json:key>all-decades</json:key>
            <json:value>{ $all-decades }</json:value>
        </json:entry>
        <json:entry>
            <json:key>results</json:key>
            <json:value>
                <json:array>
                    {
                        for $r at $i in $paged-search-results
                        let $r-decades := get-collection(
                            $r,
                            $search-results-collections,
                            "https://bmrc.lib.uchicago.edu/decades/",
                            3,
                            fn:false()
                        )
                        let $r-people := get-collection(
                            $r,
                            $search-results-collections,
                            "https://bmrc.lib.uchicago.edu/people/",
                            3,
                            fn:false()
                        )
                        let $r-places := get-collection(
                            $r,
                            $search-results-collections,
                            "https://bmrc.lib.uchicago.edu/places/",
                            3,
                            fn:false()
                        )
                        let $r-topics := get-collection(
                            $r,
                            $search-results-collections,
                            "https://bmrc.lib.uchicago.edu/topics/",
                            3,
                            fn:false()
                        )
                        return
                            <json:value>
                                <json:object>
                                    <json:entry>
                                        <json:key>abstract</json:key>
                                        <json:value>{ get-abstract($r) }</json:value>
                                    </json:entry>
                                    <json:entry>
                                        <json:key>collections-decades</json:key>
                                        <json:value>{ $r-decades }</json:value>
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
                                        <json:key>index</json:key>
                                        <json:value xsi:type="xs:integer">{ $start - 1 + $i }</json:value>
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
