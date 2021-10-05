import json, os, re, sys, unittest
import lxml.etree as etree
from bmrcportal import get_search
from bmrcportal.config.default import MARKLOGIC_SERVER, MARKLOGIC_USERNAME, MARKLOGIC_PASSWORD, PROXY_SERVER

# server, username, password, proxy_server, q, sort, start, page_length, sidebar_facet_limit, collections, b):

class TestBMRCPortalBackend(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestBMRCPortalBackend, self).__init__(*args, **kwargs)

        self.production_server_args = (
            MARKLOGIC_SERVER,
            MARKLOGIC_USERNAME,
            MARKLOGIC_PASSWORD,
            PROXY_SERVER
        )

    def test_sidebar_facets_show_number_of_results_per_facet(self):
        '''Test the underlying functionality behind the following interaction:

           Search for "Chicago", and then click on "Jazz" in the sidebar facets
           to filter that serach to finding aids tagged with the "Jazz" topic.

           The initial search should contain a greater number of records than
           the filtered search, and the sidebar facet should be able to
           correctly display the number of results that will result from a
           filtered search.'''

        s = get_search(
            *self.production_server_args + 
            (
                'Chicago',
                'relevance',
                0,
                25,
                10,
                [],
                ''
            )
        )
        initial_total = s['total']

        collection = filtered_total = None
        for t in s['more-topics']:
            if t[1] == 'Jazz':
                collection, _, filtered_total = t
        self.assertIsNotNone(collection)
        self.assertGreater(initial_total, filtered_total)

        s = get_search(
            *self.production_server_args + 
            (
                'Chicago',
                'relevance',
                0,
                25,
                10,
                [collection],
                ''
            )
        )
        self.assertEqual(filtered_total, s['total'])

    def test_case_and_diacritic_insensitive_searches(self):
        '''Search should be case and diacritic insensitive. Confirm
           that searches for "Chicago State", "chicago state" and "Chicagö
           State" (all without quotes) return the same number of results.'''

        def s(q):
            return get_search(
                *self.production_server_args + 
                (
                    q,
                    'relevance',
                    0,
                    25,
                    10,
                    [],
                    ''
                )
            )
        s1, s2, s3 = s('Chicago State'), s('chicago state'), s('Chicagö State')
        self.assertEqual(s1['total'], s2['total'])
        self.assertEqual(s2['total'], s3['total'])

    def test_unquoted_multi_word_searches(self):
        '''A search for multiple, unquoted words should return the set
           intersection of individual word searches.'''

        def s(q):
            return get_search(
                *self.production_server_args + 
                (
                    q,
                    'relevance',
                    0,
                    25,
                    10,
                    [],
                    ''
                )
            )

        s1 = set([r['uri'] for r in s('oneida woodard')['results']])
        s2 = set([r['uri'] for r in s('oneida')['results']])
        s3 = set([r['uri'] for r in s('woodard')['results']])

        self.assertEqual(len(s1), len(s2.intersection(s3)))

    def test_paging_with_single_search_result(self):
        '''Use a search for a single result to confirm that paging works
           correctly.'''

        s1 = get_search(
            *self.production_server_args + 
            (
                'Oyebemi',
                'relevance',
                0,
                1,
                1,
                [],
                ''
            )
        )
        s2 = get_search(
            *self.production_server_args + 
            (
                'Oyebemi',
                'relevance',
                1,
                1,
                1,
                [],
                ''
            )
        )
        self.assertEqual(len(s1['results']), 1)
        self.assertEqual(len(s2['results']), 0)

    def test_search_result_sorting(self):
        s1 = get_search(
            *self.production_server_args + 
            (
                'Oneida',
                'alpha',
                0,
                25,
                10,
                [],
                ''
            )
        )
        orig_alpha_sorted_titles = [t['title'] for t in s1['results']]
        manually_alpha_sorted_titles = sorted(orig_alpha_sorted_titles)
        self.assertEqual(orig_alpha_sorted_titles, manually_alpha_sorted_titles)

        s2 = get_search(
            *self.production_server_args + 
            (
                'Oneida',
                'alpha-dsc',
                0,
                25,
                10,
                [],
                ''
            )
        )
        orig_alpha_dsc_sorted_titles = [t['title'] for t in s2['results']]
        manually_alpha_dsc_sorted_titles = sorted(orig_alpha_dsc_sorted_titles, reverse=True)
        self.assertEqual(orig_alpha_dsc_sorted_titles, manually_alpha_dsc_sorted_titles)

    def test_proximity_search(self):
        '''A search for "bronzeville video" (without quotes) should return the
           "VHS video collection" finding aid near the top of results.'''

        s = get_search(
            *self.production_server_args + 
            (
                'bronzeville video',
                'alpha-dsc',
                0,
                25,
                10,
                [],
                ''
            )
        )
        uris = [r['uri'] for r in s['results']]
        self.assertTrue('BMRC.BRONZEVILLE.VHS.xml' in uris)

class TestBMRCPortalFindingAidTransformation(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestBMRCPortalFindingAidTransformation, self).__init__(*args, **kwargs)
 
        self.transform = etree.XSLT(
            etree.parse(
                os.path.join(
                    os.path.dirname(__file__),
                    'bmrcportal',
                    'xslt',
                    'view.xsl'
                )
            )
        )

    def test_abbr(self):
        """<ead:abbr> maps to <html:abbr>."""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:abbr expan="Expanded">ex</ead:abbr></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><abbr title="Expanded">ex</abbr></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:abbr audience="internal" expan="Expanded">ex</ead:abbr></ead:div>''')
                )
            ).decode('utf-8'),
            '<div/>'
        )

    def test_abstract(self):
        """<ead:abstract> contains PCDATA. If a label attribute is present, it
           should be rendered as a header. Text should be wrapped in a <p>, and
           tags in the PCDATA should be rendered."""

        self.assertEqual(
            re.sub(
                ' id="[^"]*"', 
                '', 
                etree.tostring(
                    self.transform(
                        etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:abstract label="Abstract">Abstract text, <ead:emph render="bold">bold text</ead:emph>.</ead:abstract></ead:div>''')
                    )
                ).decode('utf-8')
            ),
            '<div><h3>Abstract</h3><p>Abstract text, <strong>bold text</strong>.</p></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:abstract audience="internal" label="Abstract">Abstract text, <ead:emph>bold text</ead:emph>.</ead:abstract></ead:div>''')
                )
            ).decode('utf-8'),
            '<div/>'
        )

    def test_c(self):
        """<ead:c> gets a classname."""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:c>1</ead:c></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><div class="c c01">1</div></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:c audience="internal">1</ead:c></ead:div>''')
                )
            ).decode('utf-8'),
            '<div/>'
        )

    def test_container(self):
        """<ead:container> renders extra text."""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:container type="Folder">1</ead:container></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><div>Folder 1</div></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:container audience="internal" type="Folder">1</ead:container></ead:div>''')
                )
            ).decode('utf-8'),
            '<div/>'
        )

    def test_dao(self):
        """<ead:dao> maps to <html:a>"""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:dao href="1">2</ead:dao></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><a href="1">2</a></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:dao audience="internal" href="1">2</ead:dao></ead:div>''')
                )
            ).decode('utf-8'),
            '<div/>'
        )

    def test_emph(self):
        """<ead:emph> maps to various HTML elements."""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:emph render="italic">2</ead:emph></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><em>2</em></div>'
        )

    def test_extptr(self):
        """<ead:extprt> maps to <html:a>"""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:extptr href="1" title="2"/></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><a href="1">2</a></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:extptr audience="internal" href="1" title="2"/></ead:div>''')
                )
            ).decode('utf-8'),
            '<div/>'
        )

    def test_extref(self):
        """<ead:extref> maps to <html:a>"""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:extref href="1">2</ead:extref></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><a href="1">2</a></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:extref audience="internal" href="1">2</ead:extref></ead:div>''')
                )
            ).decode('utf-8'),
            '<div/>'
        )

    def test_item(self):
        """<ead:item> can render in several ways, depending on its parent
           element."""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:defitem><ead:label>1</ead:label><ead:item>2</ead:item></ead:defitem></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><dl><dt>1</dt><dd>2</dd></dl></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:list><ead:item>1</ead:item><ead:item>2</ead:item></ead:list></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><ul><li>1</li><li>2</li></ul></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:list><ead:item audience="internal">1</ead:item><ead:item>2</ead:item></ead:list></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><ul><li>2</li></ul></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:defitem><ead:label audience="internal">1</ead:label><ead:item>2</ead:item></ead:defitem></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><dl><dd>2</dd></dl></div>'
        )

    def test_lb(self):
        """<ead:lb> maps to <html:br>."""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:lb/></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><br/></div>'
        )

    def test_ptr(self):
        """<ead:ptr> maps to <html:a>."""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:ptr target="1" title="2"/></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><a href="#1">2</a></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:ptr audience="internal" target="1" title="2"/></ead:div>''')
                )
            ).decode('utf-8'),
            '<div/>'
        )

    def test_ptrloc(self):
        """<ead:ptr> maps to <html:div>."""

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:ptrloc id="1"/></ead:div>''')
                )
            ).decode('utf-8'),
            '<div><div id="1"/></div>'
        )

        self.assertEqual(
            etree.tostring(
                self.transform(
                    etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:ptrloc audience="internal" id="1"/></ead:div>''')
                )
            ).decode('utf-8'),
            '<div/>'
        )

    def test_convert_to_html_element(self):
        """EAD elements that convert neatly to an HTML element."""

        for e, h in (('address', 'address'), ('blockquote', 'blockquote'),
                     ('chronlist', 'dl'), ('daogrp', 'ul'), ('entry', 'td'),
                     ('imprint', 'div'), ('linkgrp', 'ul'), 
                     ('materialspec', 'div'), ('namegrp', 'ul'), ('p', 'p'),
                     ('publisher', 'div'), ('ptrgrp', 'ul'), 
                     ('revisiondesc', 'dl'), ('row', 'tr'), ('sponsor', 'div'),
                     ('table', 'table'), ('thead', 'thead'), 
                     ('titleproper', 'h1')):
            self.assertEqual(
                etree.tostring(
                    self.transform(
                        etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:{0}>1</ead:{0}></ead:div>'''.format(e))
                    )
                ).decode('utf-8'),
                '<div><{0}>1</{0}></div>'.format(h)
            )
    
            self.assertEqual(
                etree.tostring(
                    self.transform(
                        etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:{0} audience="internal">1</ead:{0}></ead:div>'''.format(e))
                    )
                ).decode('utf-8'),
                '<div/>'
            )

    def test_continue(self):
        """For some elements, we don't add anything new to the output document,
           we just keep processing. 

           NOTE: return to this list in the future to add the correct
           functionality for some of these these elements."""

        for e in ('accessrestrict', 'accruals', 'acqinfo', 'altformavail',
                  'appraisal', 'archdesc', 'archdescgrp', 'archref',
                  'arrangement', 'author', 'bibliography', 'bibref',
                  'bibseries', 'bioghist', 'change', 'controlaccess',
                  'corpname', 'creation', 'custodhist', 'daodesc', 'ead',
                  'eadgrp', 'edition', 'editionstmt', 'eventgrp', 'expan',
                  'extent', 'famname', 'filedesc', 'fileplan', 'frontmatter',
                  'function', 'genreform', 'geogname', 'index', 'indexentry',
                  'langmaterial', 'language', 'legalstatus', 'listhead',
                  'name', 'note', 'notestmt', 'num', 'occupation', 'odd',
                  'originalsloc', 'origination', 'otherfindingaid', 'persname',
                  'physdesc', 'physloc', 'phystech', 'prefercite',
                  'processinfo', 'profiledesc', 'publicationstmt', 'refloc',
                  'relatedmaterial', 'repository', 'scopecontent',
                  'separatedmaterial', 'seriesstmt', 'subarea', 'tgroup',
                  'title', 'titlestmt', 'unitdate', 'unitid', 'unittitle',
                  'userestrict'):
            self.assertEqual(
                etree.tostring(
                    self.transform(
                        etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:{0}>1</ead:{0}></ead:div>'''.format(e))
                    )
                ).decode('utf-8'),
                '<div>1</div>'
            )

    def test_skip(self):
        """We skip some elements and their descendants."""

        for e in ('colspec', 'eadheader', 'eadid', 'runner'):
            self.assertEqual(
                etree.tostring(
                    self.transform(
                        etree.fromstring('''<ead:div xmlns:ead="urn:isbn:1-931666-22-9"><ead:{0}><ead:div>1</ead:div></ead:{0}></ead:div>'''.format(e))
                    )
                ).decode('utf-8'),
                '<div/>'
            )

class TestBMRCPortalNavigation(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestBMRCPortalNavigation, self).__init__(*args, **kwargs)

        self.transform3 = etree.XSLT(
            etree.parse(
                os.path.join(
                    os.path.dirname(__file__),
                    'bmrcportal',
                    'xslt',
                    'navigation.xsl'
                )
            )
        )

    def test_navigation_root(self):
        # root only
        self.assertEqual(
            etree.tostring(
                self.transform3(
                    etree.fromstring('''<html/>''')
                )
            ).decode('utf-8'),
            '<div><h2>Contents</h2><ul/></div>'
        )

    def test_navigation_single_level(self):
        # one <h2>
        self.assertEqual(
            etree.tostring(
                self.transform3(
                    etree.fromstring('''<html><h2 id="t1">1</h2></html>''')
                )
            ).decode('utf-8'),
            '<div><h2>Contents</h2><ul><li><a href="#t1">1</a></li></ul></div>'
        )

        # two <h2>s
        self.assertEqual(
            etree.tostring(
                self.transform3(
                    etree.fromstring('''<html><h2 id="t1">1</h2><h2 id="t2">2</h2></html>''')
                )
            ).decode('utf-8'),
            '<div><h2>Contents</h2><ul><li><a href="#t1">1</a></li><li><a href="#t2">2</a></li></ul></div>'
        )

    def test_navigation_two_levels(self):
        # h2, h3
        self.assertEqual(
            etree.tostring(
                self.transform3(
                    etree.fromstring('''<html><h2 id="t1">1</h2><h3 id="t2">2</h3></html>''')
                )
            ).decode('utf-8'),
            '<div><h2>Contents</h2><ul><li><a href="#t1">1</a><ul><li><a href="#t2">2</a></li></ul></li></ul></div>'
        )

        # h2, h3, h3
        self.assertEqual(
            etree.tostring(
                self.transform3(
                    etree.fromstring('''<html><h2 id="t1">1</h2><h3 id="t2">2</h3><h3 id="t3">3</h3></html>''')
                )
            ).decode('utf-8'),
            '<div><h2>Contents</h2><ul><li><a href="#t1">1</a><ul><li><a href="#t2">2</a></li><li><a href="#t3">3</a></li></ul></li></ul></div>'
        )

        # h2, h3, h2
        self.assertEqual(
            etree.tostring(
                self.transform3(
                    etree.fromstring('''<html><h2 id="t1">1</h2><h3 id="t2">2</h3><h2 id="t3">3</h2></html>''')
                )
            ).decode('utf-8'),
            '<div><h2>Contents</h2><ul><li><a href="#t1">1</a><ul><li><a href="#t2">2</a></li></ul></li><li><a href="#t3">3</a></li></ul></div>'
        )

        # h2, h3, h2, h3
        self.assertEqual(
            etree.tostring(
                self.transform3(
                    etree.fromstring('''<html><h2 id="t1">1</h2><h3 id="t2">2</h3><h2 id="t3">3</h2><h3 id="t4">4</h3></html>''')
                )
            ).decode('utf-8'),
            '<div><h2>Contents</h2><ul><li><a href="#t1">1</a><ul><li><a href="#t2">2</a></li></ul></li><li><a href="#t3">3</a><ul><li><a href="#t4">4</a></li></ul></li></ul></div>'
        )

    def test_navigation_three_levels(self):
        # h2, h3, h4
        self.assertEqual(
            etree.tostring(
                self.transform3(
                    etree.fromstring('''<html><h2 id="t1">1</h2><h3 id="t2">2</h3><h4 id="t3">3</h4></html>''')
                )
            ).decode('utf-8'),
            '<div><h2>Contents</h2><ul><li><a href="#t1">1</a><ul><li><a href="#t2">2</a><ul><li><a href="#t3">3</a></li></ul></li></ul></li></ul></div>'
        )

        # h2, h3, h4, h2
        self.assertEqual(
            etree.tostring(
                self.transform3(
                    etree.fromstring('''<html><h2 id="t1">1</h2><h3 id="t2">2</h3><h4 id="t3">3</h4><h2 id="t4">4</h2></html>''')
                )
            ).decode('utf-8'),
            '<div><h2>Contents</h2><ul><li><a href="#t1">1</a><ul><li><a href="#t2">2</a><ul><li><a href="#t3">3</a></li></ul></li></ul></li><li><a href="#t4">4</a></li></ul></div>'
        )

        # h2, h3, h4, h4, h2
        self.assertEqual(
            etree.tostring(
                self.transform3(
                    etree.fromstring('''<html><h2 id="t1">1</h2><h3 id="t2">2</h3><h4 id="t3">3</h4><h4 id="t4">4</h4><h2 id="t5">5</h2></html>''')
                )
            ).decode('utf-8'),
            '<div><h2>Contents</h2><ul><li><a href="#t1">1</a><ul><li><a href="#t2">2</a><ul><li><a href="#t3">3</a></li><li><a href="#t4">4</a></li></ul></li></ul></li><li><a href="#t5">5</a></li></ul></div>'
        )


if __name__ == '__main__':
    unittest.main()
