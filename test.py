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

#    def test_sidebar_facets_show_number_of_results_per_facet(self):
#        '''Test the underlying functionality behind the following interaction:
#
#           Search for "Chicago", and then click on "Jazz" in the sidebar facets
#           to filter that serach to finding aids tagged with the "Jazz" topic.
#
#           The initial search should contain a greater number of records than
#           the filtered search, and the sidebar facet should be able to
#           correctly display the number of results that will result from a
#           filtered search.'''
#
#        s = get_search(
#            *self.production_server_args + 
#            (
#                'Chicago',
#                'relevance',
#                1,
#                25,
#                10,
#                [],
#                ''
#            )
#        )
#        initial_total = s['total']
#
#        collection = filtered_total = None
#        for t in s['more-topics']:
#            if t[1] == 'Jazz':
#                collection, _, filtered_total = t
#        self.assertIsNotNone(collection)
#        self.assertGreater(initial_total, filtered_total)
#
#        s = get_search(
#            *self.production_server_args + 
#            (
#                'Chicago',
#                'relevance',
#                1,
#                25,
#                10,
#                [collection],
#                ''
#            )
#        )
#        self.assertEqual(filtered_total, s['total'])
#
#    def test_case_and_diacritic_insensitive_searches(self):
#        '''Search should be case and diacritic insensitive. Confirm
#           that searches for "Chicago State", "chicago state" and "Chicagö
#           State" (all without quotes) return the same number of results.'''
#
#        def s(q):
#            return get_search(
#                *self.production_server_args + 
#                (
#                    q,
#                    'relevance',
#                    1,
#                    25,
#                    10,
#                    [],
#                    ''
#                )
#            )
#        s1, s2, s3 = s('Chicago State'), s('chicago state'), s('Chicagö State')
#        self.assertEqual(s1['total'], s2['total'])
#        self.assertEqual(s2['total'], s3['total'])

    def test_unquoted_multi_word_searches(self):
        '''A search for multiple, unquoted words should return the set
           intersection of individual word searches.'''

        def s(q):
            return get_search(
                *self.production_server_args + 
                (
                    q,
                    'relevance',
                    1,
                    25,
                    10,
                    [],
                    ''
                )
            )

        '''
        s1 = set([r['uri'] for r in s('oneida woodard')['results']])
        s2 = set([r['uri'] for r in s('oneida')['results']])
        s3 = set([r['uri'] for r in s('woodard')['results']])

        print(s1)
        print(s2)
        print(s3)
        '''

        print(json.dumps(s('oneida woodard'), indent=2))

### Multi-word Search Results Should Contain The Set Intersection of Individual Word Searches
# Search for "Oneida Woodard" (without quotes.) As of August, 2021, this search
# returns one result, "Chicago Defender Individuals Files". Individual searches
# for "Oneida" and "Woodard" should each return more than one result, and the 
# Chicago Defender Individuals Files should be included in each result set. 


if __name__ == '__main__':
    unittest.main()

'''
### A New Search Clears Previous Results
If a user has a facet selected and executes a new search, the new search should
clear the old facet away. Search for "Chicago". Click the "Jazz (38)" facet in
the sidebar. Search for "John Cage". The "Jazz" facet should be gone. 

### Sorting Search Results 
Search for "Chicago". The default sort should be relevance. Clicking the 
alpha, reverse alpha, and shuffle buttons should sort finding aids
appropriately, by title. 

### Proximity Searching
A search for "bronzeville video" (without quotes) should return the "VHS video
collection" finding aid near the top of results. 
'''
