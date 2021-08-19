import json, unittest
from bmrcportal import get_search
from bmrcportal.config.default import MARKLOGIC_SERVER, MARKLOGIC_USERNAME, MARKLOGIC_PASSWORD, PROXY_SERVER

# server, username, password, proxy_server, q, sort, start, page_length, sidebar_facet_limit, collections, b):

class TestBMRCPortal(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestBMRCPortal, self).__init__(*args, **kwargs)

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

if __name__ == '__main__':
    unittest.main()
