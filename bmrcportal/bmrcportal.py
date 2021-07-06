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

server_args = (
    app.config['MARKLOGIC_SERVER'],
    app.config['MARKLOGIC_USERNAME'],
    app.config['MARKLOGIC_PASSWORD'],
    app.config['PROXY_SERVER']
)

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
        if 'b' in search_results and search_results['b']:
            p = ('b', search_results['b'])
            if not p in params:
                params.append(p)
        if 'collections-active' in search_results:
            for c in search_results['collections-active']:
                params.append(('f', c[0]))
        if 'q' in search_results and search_results['q']:
            params.append(('q', search_results['q']))
        if 'sort' in search_results and search_results['sort']:
            params.append(('sort', search_results['sort']))
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
    
# CLI INTERFACE

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
                *server_args + ('https://bmrc.lib.uchicago.edu/organizations/',)
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
def delete_all_finding_aids():
    '''Delete all finding aids from the BMRC Portal MarkLogic database.'''
    collections = get_collections(
        *server_args + ('https://bmrc.lib.uchicago.edu/archives/',)
    )
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

# FUNCTIONS

def get_min_max_page_links(page, total_pages):
    min_page_link = page - math.floor(app.config['MAX_PAGE_LINKS'] / 2)
    max_page_link = page + math.floor(app.config['MAX_PAGE_LINKS'] / 2)

    if min_page_link < 1:
        min_page_link = 1
        max_page_link = min(
           min_page_link + (app.config['MAX_PAGE_LINKS'] - 1),
           total_pages
        )

    if max_page_link > total_pages:
        max_page_link = total_pages
        min_page_link = max(
            1,
            max_page_link - (app.config['MAX_PAGE_LINKS'] - 1)
        )

    return min_page_link, max_page_link

# WEB INTERFACE

@app.route('/about/')
def about():
    return render_template(
        'about.html', 
        breadcrumbs = [
            ('https://bmrc.lib.uchicago.edu/', 'Black Metropolis Research Consortium'),
            ('/', 'Collections Portal')
        ],
        search_results = {},
        title = 'About'
    )

@app.route('/browse/')
def browse():
    b = request.args.get('b', default='', type=str)
    page = request.args.get('page', default=1, type=int)
    sort = request.args.get('sort', default='relevance', type=str)

    start = (page - 1) * app.config['PAGE_LENGTH']
    stop = start + app.config['PAGE_LENGTH']

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
        *server_args + ('https://bmrc.lib.uchicago.edu/{}/'.format(b),)
    )

    browse_results = []
    for k in collections.keys():
        u = k.replace('https://bmrc.lib.uchicago.edu/', '').split('/')[1]
        s = '{} ({})'.format(unquote_plus(u), len(collections[k]))
        browse_results.append((u, s, k))

    total_pages = math.ceil(len(browse_results) / app.config['PAGE_LENGTH'])
    min_page_link, max_page_link = get_min_max_page_links(page, total_pages)

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
        breadcrumbs = [
            ('https://bmrc.lib.uchicago.edu/', 'Black Metropolis Research Consortium'),
            ('/', 'Collections Portal')
        ],
        browse_results = browse_results[start:stop],
        max_page_link = max_page_link,
        min_page_link = min_page_link,
        page = page,
        page_length = app.config['PAGE_LENGTH'],
        search_results = {},
        sort = sort,
        start = start,
        title = titles[b],
        total_pages = total_pages
    )

@app.route('/contact/')
def contact():
    return render_template(
        'contact.html', 
        breadcrumbs = [
            ('https://bmrc.lib.uchicago.edu/', 'Black Metropolis Research Consortium'),
            ('/', 'Collections Portal')
        ],
        search_results = {},
        title = 'Contact'
    )

@app.route('/curated/')
def curated():
    curated_topics = app.config['CURATED_TOPICS']
    curated_topic = random.choice(curated_topics)
    return render_template(
        'curated.html', 
        breadcrumbs = [
            ('https://bmrc.lib.uchicago.edu/', 'Black Metropolis Research Consortium'),
            ('/', 'Collections Portal')
        ],
        curated_topic = curated_topic,
        search_results = {},
        title = curated_topic['title']
    )

@app.route('/facet_view_all/')
def facet_view_all():
    a = request.args.get('a', default='', type=str)
    collections_active = request.args.getlist('f')
    q = request.args.get('q', default='', type=str)
    sort = request.args.get('sort', default='relevance', type=str)

    assert sort in ('relevance', 'title', 'title-dsc', 'shuffle')

    search_results = {}

    if collections_active:
        search_results['collections-active'] = []
        for c in collections_active:
            search_results['collections-active'].append([
                c,
                unquote_plus(c.split('/')[4]),
                0
            ])
    if q:
        search_results['q'] = q
    if sort:
        search_results['sort'] = sort

    facet_name = a.replace('https://bmrc.lib.uchicago.edu/', '').split('/')[0]
    assert facet_name in ('archives', 'decades', 'organizations', 'people', 'places', 'topics')

    title = facet_name.capitalize()

    # collection = get_collections(*server_args + (a,))
    search_results = get_search(
        *server_args + 
        (
            q,
            sort,
            0,
            1,
            -1,
            collections_active,
            ''
        )
    )

    out = []
    for f in search_results['more-' + facet_name]:
        out.append(f)

    if sort == 'relevance':
        out.sort(key=lambda i: i[2], reverse=True)
    elif sort == 'title':
        out.sort(key=lambda i: re.sub('^The ', '', i[1]).lower())
    elif sort == 'title-dsc':
        out.sort(key=lambda i: re.sub('^The ', '', i[1]).lower(), reverse=True)
    elif sort == 'shuffle':
        random.shuffle(out)

    return render_template(
        'facet_view_all.html',
        collection = out,
        search_results = search_results,
        title = title
    )

@app.route('/help/')
def help():
    return render_template(
        'help.html', 
        breadcrumbs = [
            ('https://bmrc.lib.uchicago.edu/', 'Black Metropolis Research Consortium'),
            ('/', 'Collections Portal')
        ],
        search_results = {},
        title = 'Help'
    )

@app.route('/')
def homepage():
    member_spotlight_title = ''
    member_spotlight_html = ''
    for a in app.config['ARCHIVES']:
       if a['finding_aid_prefix'] == 'BMRC.CCARO': 
           member_spotlight_title = a['short_title']
           member_spotlight_html = a['member_spotlight_html']

    facet = random.choice((
        'https://bmrc.lib.uchicago.edu/topics/',
        'https://bmrc.lib.uchicago.edu/people/',
        'https://bmrc.lib.uchicago.edu/places/',
        'https://bmrc.lib.uchicago.edu/organizations/',
        'https://bmrc.lib.uchicago.edu/decades/'
    ))

    discover_more_facet = facet.replace('https://bmrc.lib.uchicago.edu/', '').replace('/', '')

    collections = get_collections(*server_args + (facet,))

    discover_more_uri = random.choice(list(collections.keys()))
    discover_more_title = unquote_plus(discover_more_uri).replace('https://bmrc.lib.uchicago.edu/', '').split('/')[1]

    return render_template(
        'homepage.html', 
        breadcrumbs = [
            ('https://bmrc.lib.uchicago.edu/', 'Black Metropolis Research Consortium')
        ],
        discover_more_title = discover_more_title,
        discover_more_uri = discover_more_uri,
        discover_more_facet = discover_more_facet,
        member_spotlight_title = member_spotlight_title,
        member_spotlight_html = member_spotlight_html,
        search_results = {},
        title = 'Collections Portal'
    )

@app.route('/members/')
def members():
    return render_template(
        'members.html', 
        breadcrumbs = [
            ('https://bmrc.lib.uchicago.edu/', 'Black Metropolis Research Consortium'),
            ('/', 'Collections Portal')
        ],
        search_results = {},
        title = 'Members'
    )

@app.route('/search/')
def search():
    b = request.args.get('b', default='', type=str)
    collections = request.args.getlist('f')
    page = request.args.get('page', default=1, type=int)
    q = request.args.get('q', default='', type=str)
    sort = request.args.get('sort', default='', type=str)

    # with a page length of 3, this is:
    # (0, 3), (3, 6), (6, 9)...

    start = (page - 1) * app.config['PAGE_LENGTH']
    stop = start + app.config['PAGE_LENGTH']

    if sort == '':
        if q == '':
            sort = 'alpha'
        else:
            sort = 'relevance'

    search_results = get_search(
        *server_args + 
        (
            q,
            sort,
            start,
            app.config['PAGE_LENGTH'],
            app.config['SIDEBAR_VIEW_MORE_FACET_COUNT'],
            collections,
            b
        )
    )

    total_pages = math.ceil(search_results['total'] / app.config['PAGE_LENGTH'])
    min_page_link, max_page_link = get_min_max_page_links(page, total_pages)

    if q:
        title = 'Portal Search - {}'.format(q)
    else:
        title = 'Portal Search'

    return render_template(
        'search.html',
        breadcrumbs = [
            ('https://bmrc.lib.uchicago.edu/', 'Black Metropolis Research Consortium'),
            ('/', 'Collections Portal')
        ],
        max_page_link = max_page_link,
        min_page_link = min_page_link,
        page = page,
        page_length = app.config['PAGE_LENGTH'],
        search_results = search_results,
        sidebar_view_less_facet_count = app.config['SIDEBAR_VIEW_LESS_FACET_COUNT'],
        sidebar_view_more_facet_count = app.config['SIDEBAR_VIEW_MORE_FACET_COUNT'],
        sort = sort,
        start = start,
        title = title,
        total_pages = total_pages
    )

@app.route('/view/')
def view():
    id = request.args.get('id')

    findingaid = etree.fromstring(
        ElementTree.tostring(
            get_findingaid(*server_args + (id,)),
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
        breadcrumbs = [
            ('https://bmrc.lib.uchicago.edu/', 'Black Metropolis Research Consortium'),
            ('/', 'Collections Portal')
        ],
        findingaid_html = findingaid_html
    )

@app.route('/css/<path:path>')
def css(path):
    return send_from_directory('css', path)

@app.route('/js/<path:path>')
def js(path):
    return send_from_directory('js', path)

if __name__ == '__main__':
    app.run(debug=True)
