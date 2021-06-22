import click, io, jinja2, json, math, os, random, urllib, urllib.parse, re, sys
import lxml.etree as etree
import xml.etree.ElementTree as ElementTree
from flask import current_app, Flask, jsonify, render_template, request, send_from_directory
from flask.cli import with_appcontext
from urllib.parse import unquote_plus
from . import (clear_cache, delete_findingaid, get_archives_for_xml,
               get_collection, get_collections, get_collections_for_xml,
               get_decades_for_xml, get_findingaid, get_search,
               load_findingaid, setup_cache)

app = Flask(__name__, instance_relative_config=True)
app.config.from_object('bmrcportal.config.default')

#cli.register(app)

# UTILITY FUNCTIONS

@app.context_processor
def utility_processor():
    def quote_plus(s):
        return urllib.parse.quote_plus(s)

    def get_active_facet(search_results, starts_with):
        counts = []
        for c in search_results['collections-active']:
            if c[0].startswith(starts_with):
                counts.append(c)
        return counts

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
        if 'b' in d:
            pass
        elif search_results['b']:
            params.append(('b', search_results['b']))
        if 'q' in d:
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
        get_active_facet = get_active_facet,
        get_url_params = get_url_params,
        quote_plus = quote_plus,
        remove_from_url_params = remove_from_url_params,
    )
    
# GLOBAL VARIABLES

max_page_links = 11
max_page_links_before = 5
max_page_links_after = 5
page_length = 50

server_args = (
    os.environ['BMRCPORTAL_MARKLOGIC_SERVER'],
    os.environ['BMRCPORTAL_MARKLOGIC_USERNAME'],
    os.environ['BMRCPORTAL_MARKLOGIC_PASSWORD'],
    os.environ['BMRCPORTAL_PROXY_SERVER']
)

# CLI

@click.command(name='browse-archives')
def browse_archives():
    '''Browse all archives in MarkLogic.'''
    click.echo(
        json.dumps(
            get_collections(
                *server_args + ('https://bmrc.lib.uchicago.edu/archives/',)
            )
        )
    )
app.cli.add_command(browse_archives)

@click.command(name='browse-decades')
def browse_decades():
    '''Browse all decades in MarkLogic.'''
    click.echo(
        json.dumps(
            get_collections(
                *server_args + ('https://bmrc.lib.uchicago.edu/decades/',)
            )
        )
    )
app.cli.add_command(browse_decades)

@click.command(name='browse-organizations')
def browse_organizations():
    '''Browse all organizations in MarkLogic.'''
    click.echo(
        json.dumps(
            get_collections(
                *server_args + ('https://bmrc.lib.uchicago.edu/corpnames/',)
            )
        )
    )
app.cli.add_command(browse_organizations)

@click.command(name='browse-people')
def browse_people():
    '''Browse all people in MarkLogic.'''
    click.echo(
        json.dumps(
            get_collections(
                *server_args + ('https://bmrc.lib.uchicago.edu/people/',)
            )
        )
    )
app.cli.add_command(browse_people)

@click.command(name='browse-places')
def browse_places():
    '''Browse all people in MarkLogic.'''
    click.echo(
        json.dumps(
            get_collections(
                *server_args + ('https://bmrc.lib.uchicago.edu/places/',)
            )
        )
    )
app.cli.add_command(browse_places)

@click.command(name='browse-topics')
def browse_topics():
    '''Browse all people in MarkLogic.'''
    click.echo(
        json.dumps(
            get_collections(
                *server_args + ('https://bmrc.lib.uchicago.edu/topics/',)
            )
        )
    )
app.cli.add_command(browse_topics)

@click.command(name='clear-cache')
def clear_cache_cli():
    '''Clear the cache.'''
    setup_cache()
    clear_cache()
app.cli.add_command(clear_cache_cli)

@click.command(name='delete-all-finding-aids')
# @with_appcontext
def delete_all_finding_aids():
    '''Delete all finding aids from the BMRC Portal MarkLogic database.'''
    collections = get_collections(*server_args + ('https://bmrc.lib.uchicago.edu/archives/',))
    for collection, findingaids in collections.items():
        for findingaid in findingaids:
            click.echo('DELETING {}...'.format(findingaid[0]))
            delete_findingaid(*server_args + (findingaid[0],))
app.cli.add_command(delete_all_finding_aids)

@click.command(name='load-finding-aids')
@click.argument('dir')
def load_finding_aids(dir):
    '''Load finding aids into the BMRC Portal MarkLogic database.'''
    click.echo('Building organization name browse...')
    organizations = get_collections_for_xml(
        dir,
        'https://bmrc.lib.uchicago.edu/organizations/{}',
        '//ead:corpname',
        {'ead': 'urn:isbn:1-931666-22-9'}
    )
    click.echo('Building decade browse...')
    decades = get_decades_for_xml(
        dir,
        'https://bmrc.lib.uchicago.edu/decades/{}'
    )
    click.echo('Building archives browse...')
    archives = get_archives_for_xml(
        app.config['ARCHIVES'],
        dir,
        'https://bmrc.lib.uchicago.edu/archives/{}'
    )
    click.echo('Building person browse...')
    people = get_collections_for_xml(
        dir,
        'https://bmrc.lib.uchicago.edu/people/{}',
        ' | '.join((
            '//ead:famname',
            '//ead:name',
            '//ead:namegrp',
            '//ead:persname'
        )),
        {'ead': 'urn:isbn:1-931666-22-9'}
    )
    click.echo('Building place browse...')
    places = get_collections_for_xml(
        dir,
        'https://bmrc.lib.uchicago.edu/places/{}',
        '//ead:geogname',
        {'ead': 'urn:isbn:1-931666-22-9'}
    )
    click.echo('Building topic browse...')
    topics = get_collections_for_xml(
        dir,
        'https://bmrc.lib.uchicago.edu/topics/{}',
        ' | '.join((
            '//ead:occupation',
            '//ead:subject'
        )),
        {'ead': 'urn:isbn:1-931666-22-9'}
    )
    browses = {**archives, **decades, **organizations, **people, **places, **topics}

    transform_xsd = etree.XSLT(
        etree.parse(
            os.path.join(
                'xslt',
                'dtd2schema.xsl'
            )
        )
    )
    
    for d in os.listdir(dir):
        for eadid in os.listdir(os.path.join(dir, d)):
            try:
                transformed_xml = transform_xsd(
                    etree.parse(
                        os.path.join(dir, d, eadid)
                    )
                )
            except etree.XMLSyntaxError:
                continue

            collections = []
            for uri, eadids in browses.items():
                if eadid in eadids:
                    collections.append(uri)

            with io.BytesIO(
                etree.tostring(
                    transformed_xml, 
                    encoding='utf-8', 
                    method='xml'
                )
            ) as fh:
                click.echo('LOADING {}...'.format(eadid))
                load_findingaid(
                    *server_args +
                    (
                        fh, 
                        eadid,
                        collections
                    )
                )
app.cli.add_command(load_finding_aids)

# WEB INTERFACE

@app.route('/about/')
def about():
    global server_args

    return render_template(
        'about.html', 
        breadcrumbs = [],
        search_results = {}
    )

@app.route('/browse/')
def browse():
    global max_page_links
    global max_page_links_before
    global max_page_links_after
    global page_length
    global server_args

    b = request.args.get('b', default='', type=str)
    page = request.args.get('page', default=1, type=int)
    sort = request.args.get('sort', default='relevance', type=str)

    start = (page - 1) * page_length
    stop = start + page_length

    titles = {
        'archives': 'All Archives',
        'corpnames': 'All Organizations',
        'decades': 'All Decades',
        'people': 'All People',
        'places': 'All Places',
        'topics': 'All Topics'
    }

    assert b in titles.keys()
    assert sort in ('alpha', 'alpha-dsc', 'relevance', 'shuffle')

    collections = get_collections(
        *server_args + (
            'https://bmrc.lib.uchicago.edu/{}/'.format(b),
        )
    )

    browse_results = []
    for k in collections.keys():
        u = k.replace('https://bmrc.lib.uchicago.edu/', '').split('/')[1]
        s = '{} ({})'.format(unquote_plus(u), len(collections[k]))
        browse_results.append((u, s, k))

    total_pages = math.ceil(len(browse_results) / page_length)

    min_page_link = page - max_page_links_before
    max_page_link = page + max_page_links_after

    while min_page_link < 1:
        min_page_link += 1
        max_page_link += 1

    while max_page_link > total_pages and min_page_link > 0:
        min_page_link -= 1
        max_page_link -= 1

    if sort == 'alpha':
        browse_results.sort(key=lambda i: i[0].lower())
    elif sort == 'alpha-dsc':
        browse_results.sort(key=lambda i: i[0].lower(), reverse=True)
    elif sort == 'relevance':
        browse_results.sort(key=lambda i: len(collections[i[2]]), reverse=True)
    elif sort == 'shuffle':
        random.shuffle(browse_results)

    return render_template(
        'browse.html',
        b = b,
        breadcrumbs = [],
        browse_results = browse_results[start:stop],
        max_page_link = max_page_link,
        min_page_link = min_page_link,
        page = page,
        page_length = page_length,
        sort = sort,
        start = start,
        title = titles[b],
        total_pages = total_pages
    )

@app.route('/contact/')
def contact():
    global server_args

    return render_template(
        'contact.html', 
        breadcrumbs = [
            ('/', 'Home'),
            ('/contact/', 'Contact')
        ],
        search_results = {}
    )

@app.route('/help/')
def help():
    global server_args

    return render_template(
        'help.html', 
        breadcrumbs = [
            ('/', 'Home'),
            ('/help/', 'Help')
        ],
        search_results = {}
    )

@app.route('/')
def homepage():
    global server_args

    return render_template(
        'homepage.html', 
        breadcrumbs = [
            ('/', 'Home')
        ],
        search_results = {}
    )

@app.route('/members/')
def members():
    global server_args

    return render_template(
        'members.html', 
        breadcrumbs = [
            ('/', 'Home'),
            ('/members/', 'Members')
        ],
        search_results = {}
    )

@app.route('/search/')
def search():
    global max_page_links
    global max_page_links_before
    global max_page_links_after
    global page_length
    global server_args

    b = request.args.get('b', default='', type=str)
    collections = request.args.getlist('f')
    page = request.args.get('page', default=1, type=int)
    q = request.args.get('q', default='', type=str)
    sort = request.args.get('sort', default='', type=str)

    start = (page - 1) * page_length
    stop = start + page_length

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
            page_length,
            collections,
            b
        )
    )

    if q:
        title = 'Portal Search - {}'.format(q)
    else:
        title = 'Portal Search'

    return render_template(
        'search.html',
        breadcrumbs = [],
        page = page,
        page_length = page_length,
        search_results = search_results,
        sort = sort,
        start = start,
        title = title,
        total_pages = 3
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
    l = request.json['limit']
    s = request.json['sort']

    collection = get_collection(
        *server_args + (
            docs,
            'https://bmrc.lib.uchicago.edu/{}/'.format(starts_with),
            s,
            l
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
