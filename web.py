import click, io, jinja2, json, math, os, random, urllib, urllib.parse, re, sys
import lxml.etree as etree
import xml.etree.ElementTree as ElementTree
from flask import current_app, Flask, jsonify, redirect, render_template, request, send_from_directory
from flask.cli import with_appcontext
from urllib.parse import unquote_plus
from bmrcportal import (clear_cache, delete_findingaid,
                        get_archives_for_xml, get_collection,
                        get_collections, get_collections_for_xml,
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

# XSLT FUNCTIONS
ns = etree.FunctionNamespace('https://lib.uchicago.edu/functions/')

def bmrc_search_url(context, ns, s):
    """EXSLT has str:encode-uri, but it behaves differently than
       urllib.parse.quote_plus. I add quote_plus() as an extention function in
       XSLT so that the transform can have access to the exact function that
       produces collection URIs when they're first added to MarkLogic."""

    # build the collection URI the same way Python does when we first load
    # finding aids into MarkLogic.
    uri = '{}{}'.format(ns, urllib.parse.quote_plus(s.strip()))

    # to streamline the XSLT, return the entire search URL. (note
    # double-quoting.)
    return '/search/?f={}'.format(
        urllib.parse.quote_plus(uri)
    )
    
ns['bmrc_search_url'] = bmrc_search_url

# UTILITY FUNCTIONS

@app.context_processor
def utility_processor():
    def quote_plus(s):
        """Make quote_plus available in templates."""
        return urllib.parse.quote_plus(s)

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

    def clear_facets_from_url_params(search_results):
        """
        Clear all facets from current URL params.

        Args:
           search_results: object returned from MarkLogic.

        Returns:
            a URL query string.
        """
        params = []
        for p in ('q', 'sort'):
            if p in search_results and search_results[p]:
                params.append((p, search_results[p]))
        return urllib.parse.urlencode(params)

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
        clear_facets_from_url_params = clear_facets_from_url_params,
        get_active_facet = get_active_facet,
        get_url_params = get_url_params,
        quote_plus = quote_plus,
        remove_from_url_params = remove_from_url_params
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
        '//ead:corpname[not(ancestor::ead:publisher) and not(ancestor::ead:repository)]',
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
                'bmrcportal',
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
        'decades': 'All Decades',
        'organizations': 'All Organizations',
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
        if not s.startswith('BMRC Portal'):
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
    fsort = request.args.get('fsort', default='relevance', type=str)
    q = request.args.get('q', default='', type=str)
    sort = request.args.get('sort', default='relevance', type=str)

    assert sort in ('alpha', 'alpha-dsc', 'relevance', 'shuffle')

    search_results = {}

    if collections_active:
        search_results['collections-active'] = []
        for c in collections_active:
            search_results['collections-active'].append([
                c,
                unquote_plus(c.split('/')[4]),
                0
            ])

    facet_name = a.replace('https://bmrc.lib.uchicago.edu/', '').split('/')[0]
    assert facet_name in ('archives', 'decades', 'organizations', 'people', 'places', 'topics')

    title = facet_name.capitalize()

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

    # To simplify the template, append a fourth element to each list: True if
    # the facet is currently active, false if not.
    out = []
    for f in search_results['active-' + facet_name]:
        out.append(f + [True])
    for f in search_results['more-' + facet_name]:
        out.append(f + [False])

    if fsort == 'relevance':
        out.sort(key=lambda i: i[2], reverse=True)
    elif fsort == 'alpha':
        out.sort(key=lambda i: re.sub('^The ', '', i[1]).lower())
    elif fsort == 'alpha-dsc':
        out.sort(key=lambda i: re.sub('^The ', '', i[1]).lower(), reverse=True)
    elif fsort == 'shuffle':
        random.shuffle(out)

    return render_template(
        'facet_view_all.html',
        a = a,
        collection = out,
        collection_active = collections_active,
        fsort = fsort,
        q = q,
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
    member_spotlight_img = ''
    for a in app.config['ARCHIVES']:
       if a['finding_aid_prefix'] == 'BMRC.NIU': 
           member_spotlight_title = a['name']
           member_spotlight_html = a['member_spotlight_html']
           member_spotlight_img = a['archivebox_logo']

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
        member_spotlight_img = member_spotlight_img,
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

    # redirect to the view if there is a single result.
    # if search_results['total'] == 1:
    #     return redirect(
    #         '/view/?{}'.format(
    #             urllib.parse.urlencode({
    #                 'id': search_results['results'][0]['uri']
    #             })
    #         )
    #     )

    total_pages = math.ceil(search_results['total'] / app.config['PAGE_LENGTH'])
    min_page_link, max_page_link = get_min_max_page_links(page, total_pages)

    if q:
        title = 'Portal Search - {}'.format(q)
    else:
        title = 'Portal Search'

    # if this search includes an archive facet, get the logo, short title and
    # html for archive contact info.
    archivebox_address = archivebox_link = archivebox_logo = name = ''
    c = [c for c in collections if c.startswith('https://bmrc.lib.uchicago.edu/archives/')]
    try:
        s = urllib.parse.unquote_plus(
            c[0].replace(
                'https://bmrc.lib.uchicago.edu/archives/', 
                ''
            )
        )
        a = [a for a in app.config['ARCHIVES'] if a['name'] == s]
        archivebox_address = a[0]['archivebox_address']
        archivebox_link = a[0]['archivebox_link']
        archivebox_logo = a[0]['archivebox_logo']
        name = a[0]['name']
    except IndexError:
        pass

    return render_template(
        'search.html',
        archivebox_address = archivebox_address,
        archivebox_link = archivebox_link,
        archivebox_logo = archivebox_logo,
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
        name = name,
        sort = sort,
        start = start,
        title = title,
        total_pages = total_pages
    )

# need to display ead:runner
@app.route('/view/')
def view():
    id = request.args.get('id')

    def t(filename):
        return etree.XSLT(
            etree.parse(
                os.path.join(
                    os.path.dirname(__file__),
                    'bmrcportal',
                    'xslt',
                    filename
                )
            )
        )

    tn = t('navigation.xsl')
    tr = t('regularize.xsl')
    tv = t('view.xsl')

    findingaid = tv(
        tr(
            etree.fromstring(
                ElementTree.tostring(
                    get_findingaid(*server_args + (id,)),
                    encoding='utf8', 
                    method='xml'
                )
            )
        )
    )

    try:
        title = ''.join(findingaid.xpath('//h1')[0].itertext())
    except IndexError:
        title = ''

    prefix = '.'.join(id.split('.')[:2])
    archivebox_address = archivebox_link = archivebox_logo = name = ''
    a = [a for a in app.config['ARCHIVES'] if a['finding_aid_prefix'] == prefix]
    try:
        archivebox_address = a[0]['archivebox_address']
        archivebox_link = a[0]['archivebox_link']
        archivebox_logo = a[0]['archivebox_logo']
        name = a[0]['name']
    except IndexError:
        pass
    
    navigation = tn(findingaid)

    return render_template(
        'view.html',
        archivebox_address = archivebox_address,
        archivebox_link = archivebox_link,
        archivebox_logo = archivebox_logo,
        breadcrumbs = [
            ('https://bmrc.lib.uchicago.edu/', 'Black Metropolis Research Consortium'),
            ('/', 'Collections Portal')
        ],
        findingaid_html = findingaid,
        navigation_html = navigation,
        search_results = [],
        name = name,
        title = title
    )

@app.route('/css/<path:path>')
def css(path):
    return send_from_directory('css', path)

@app.route('/img/<path:path>')
def img(path):
    return send_from_directory('img', path)

@app.route('/js/<path:path>')
def js(path):
    return send_from_directory('js', path)

if __name__ == '__main__':
    app.run(debug=True)
