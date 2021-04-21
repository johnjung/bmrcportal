import jinja2, json, os, urllib, urllib.parse, re, sys
import lxml.etree as etree
import xml.etree.ElementTree as ElementTree
from flask import current_app, Flask, jsonify, render_template, request, send_from_directory
from __init__ import get_collection, get_collections, get_findingaid, get_search

app = Flask(__name__, static_url_path='')

# UTILITY FUNCTIONS

@app.context_processor
def utility_processor():
    def quote_plus(s):
        return urllib.parse.quote_plus(s)

    def get_url_params(search_results):
        """
        Get the current URL params from the search result object.

        Args:
           search_results: object returned from MarkLogic.

        Returns:
           a URL query string.
        """
        params = []
        if search_results['q']:
            params.append(('q', search_results['q']))
        for c in search_results['collections-active']:
            params.append(('f', c[0]))
        return urllib.parse.urlencode(params)

    def add_to_url_params(search_results, d):
        """
        Add a parameter to the current url params.

        Args:
           search_results: object returned from MarkLogic.
           d:              a dictionary, where the keys are parameters to add.

        Returns:
           a URL query string.
        """

        params = []
        if search_results['b']:
            p = ('b', search_results['b'])
            if not p in params:
                params.append(p)
        if search_results['q']:
            params.append(('q', search_results['q']))
        for c in search_results['collections-active']:
            params.append(('f', c[0]))
        for k, v in d.items():
            params.append((k, v))
        return urllib.parse.urlencode(params)

    def remove_from_url_params(search_results, d):
        """
        Remove a specific facet from the current URL params.

        Args:
           search_results: object returned from MarkLogic.
           d:              dictionary, where the key is the parameter to remove.

        Returns:
            a URL query string.
        """
        params = []
        if 'b' in d and d['b'] == search_results['b']:
            pass
        elif search_results['b']:
            params.append(('b', search_results['b']))
        if 'q' in d and d['q'] == search_results['q']:
            pass
        elif search_results['q']:
            params.append(('q', search_results['q']))
        for c in search_results['collections-active']:
            if 'f' in d and d['f'] == c[0]:
                continue
            else:
                params.append(('f', c[0]))
        return urllib.parse.urlencode(params)

    return dict(
        add_to_url_params = add_to_url_params,
        get_url_params = get_url_params,
        quote_plus = quote_plus,
        remove_from_url_params = remove_from_url_params,
    )
    
# GLOBAL VARIABLES

server_args = (
    os.environ['BMRCPORTAL_MARKLOGIC_SERVER'],
    os.environ['BMRCPORTAL_MARKLOGIC_USERNAME'],
    os.environ['BMRCPORTAL_MARKLOGIC_PASSWORD'],
    os.environ['BMRCPORTAL_PROXY_SERVER']
)

@app.route('/')
def homepage():
    global server_args

    collections = request.args.getlist('f')
    q = request.args.get('q', default='', type=str)
    start = request.args.get('start', default=1, type=int)

    search_results = get_search(
        *server_args + (
            q,
            'relevance',
            start,
            collections,
            ''
        )
    )

    return render_template(
        'homepage.html', 
        breadcrumbs = [
            ('/', 'Home')
        ],
        search_results = search_results
    )

@app.route('/search/')
def search():
    global server_args

    b = request.args.get('b', default='', type=str)
    collections = request.args.getlist('f')
    q = request.args.get('q', default='', type=str)
    sort = request.args.get('sort', default='', type=str)
    start = request.args.get('start', default=1, type=int)

    if sort == '':
        if q == '':
            sort = 'alpha'
        else:
            sort = 'relevance'

    search_results = get_search(
        *server_args + (
            q,
            sort,
            start,
            collections,
            b
        )
    )

    search_results['stop'] = min(
        search_results['start'] + search_results['size'] - 1,
        search_results['total']
    )

    return render_template(
        'search.html',
        breadcrumbs = [],
        search_results = search_results
    )

@app.route('/view/')
def view():
    global server_args

    id = request.args.get('id')

    findingaid = etree.fromstring(
        ElementTree.tostring(
            get_findingaid(
                *server_args + (
                    id,
                )
            ),
            encoding='utf8', 
            method='xml'
        )
    )

    transform = etree.XSLT(
        etree.parse(
            os.path.join(
                os.path.dirname(__file__),
                'xslt',
                'view.xsl'
            )
        )
    )

    findingaid_html = transform(findingaid)

    return render_template(
        'view.html',
        breadcrumbs = [],
        findingaid_html = findingaid_html
    )

@app.route('/sidebar/<string:starts_with>', methods = ['POST'])
def sidebar(starts_with):
    # how to get docs? did that come in via POST?
    docs = request.json['docs']

    collection = get_collection(
        *server_args + (
            docs,
            'https://bmrc.lib.uchicago.edu/{}/'.format(starts_with),
            'relevance_dsc',
            3
        )
    )

    return jsonify(collection)

@app.route('/css/<path:path>')
def css(path):
    return send_from_directory('css', path)

@app.route('/js/<path:path>')
def js(path):
    return send_from_directory('js', path)

if __name__ == '__main__':
    app.run(debug=True)
