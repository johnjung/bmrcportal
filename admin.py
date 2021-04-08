#!/usr/bin/env python
"""Usage:
    admin.py --browse-collections
    admin.py --browse-collection <collection>
    admin.py --browse-corpnames
    admin.py --browse-decades
    admin.py --browse-institutions
    admin.py --browse-people
    admin.py --browse-places
    admin.py --browse-topics
    admin.py --clear-cache
    admin.py --delete-finding-aid <uri>
    admin.py --delete-all-finding-aids
    admin.py --get-finding-aid <uri>
    admin.py --load-finding-aids <dir>
    admin.py --search <search> <start> [--browse <browse>] [--collection <collection>]... 
"""

# search- 

# within one or more collections.
# within 
#   all text nodes
#   topic:  //occupation | //subject
#   people: //fanname | //name | //namegrp | //persname
#   date:   //date (does this have to do ranges?)
#   place:  //geogname

import io, json, os, re, sys, textwrap, urllib
import xml.etree.ElementTree as ElementTree
import lxml.etree as etree
from docopt import docopt
from bmrcportal import (clear_cache, delete_findingaid,
                        get_collections_for_xml, get_decades_for_xml,
                        get_findingaid, get_collections,
                        get_institutions_for_xml, get_search, load_findingaid,
                        setup_cache)

ElementTree.register_namespace('', 'urn:isbn:1-931666-22-9')


if __name__ == '__main__':
    args = docopt(__doc__)

    try:
        server_args = (
            os.environ['BMRCPORTAL_MARKLOGIC_SERVER'],
            os.environ['BMRCPORTAL_MARKLOGIC_USERNAME'],
            os.environ['BMRCPORTAL_MARKLOGIC_PASSWORD'],
            os.environ['BMRCPORTAL_PROXY_SERVER']
        )
    except KeyError:
        sys.stderr.write((
            'ERROR: MISSING ENVIRONMENTAL VARIABLES\n\n'
            'The following environmental variables must be set for this '
            'script to function properly.\n\n'
            'BMRCPORTAL_MARKLOGIC_SERVER\n'
            '  The protocol, server, and port for the MarkLogic database, '
            'e.g. http://marklogic.lib.uchicago.edu:8014\n'
            'BMRCPORTAL_MARKLOGIC_USERNAME\n'
            '  Username for the MarkLogic database\n'
            'BMRCPORTAL_MARKLOGIC_PASSWORD\n'
            '  Password for the MarkLogic database\n'
            'BMRCPORTAL_PROXY_SERVER\n'
            '  The server, and port for a proxy server to connect to '
            'MarkLogic. This may be helpful for local development from a '
            'machine that is not allowed to connect to the MarkLogic server '
            'directly. e.g., http://localhost9090. To set up a SOCKS proxy '
            'via SSH for this connection, try the following command:\n'
            'ssh -D 9090 -q -C -N <user>@staff.lib.uchicago.edu\n'
            'If you\'re running this code from a machine that can connect to '
            'the MarkLogic server on it\'s own, set this variable to the '
            'empty string.\n'
        ))
        sys.exit()

    browse_namespaces = {
        '--browse-collection': 'https://bmrc.lib.uchicago.edu/',
        '--browse-collections': 'https://bmrc.lib.uchicago.edu/',
        '--browse-corpnames': 'https://bmrc.lib.uchicago.edu/corpnames/',
        '--browse-decades': 'https://bmrc.lib.uchicago.edu/decades/',
        '--browse-institutions': 'https://bmrc.lib.uchicago.edu/institutions/',
        '--browse-people': 'https://bmrc.lib.uchicago.edu/people/',
        '--browse-places': 'https://bmrc.lib.uchicago.edu/places/',
        '--browse-topics': 'https://bmrc.lib.uchicago.edu/topics/'
    }

    # load for browses or other commands that require them.
    for n in browse_namespaces.keys():
        if args[n]:
            collections = get_collections(*server_args + (browse_namespaces[n],))
    if args['--delete-all-finding-aids']:
        collections = get_collections(*server_args + ('https://bmrc.lib.uchicago.edu/institutions/',))
    if args['--search']:
        collections = get_collections(*server_args + ('https://bmrc.lib.uchicago.edu/',))

    if args['--browse-collection']:
        print(json.dumps(collections[args['<collection>']]))
    elif args['--clear-cache']:
        setup_cache()
        clear_cache()
    elif args['--delete-finding-aid']:
        delete_findingaid(*server_args + (args['<uri>'],))
    elif args['--delete-all-finding-aids']:
        for collection, findingaids in collections.items():
            for findingaid in findingaids:
                print('DELETING {}...'.format(findingaid[0]))
                delete_findingaid(*server_args + (findingaid[0],))
    elif args['--get-finding-aid']:
        xml = get_findingaid(*server_args + (args['<uri>'],))
        # Use ElementTree here, rather than lxml, to output XML with a default
        # namespace.
        print(ElementTree.tostring(xml, encoding='utf8', method='xml').decode('utf-8'))
    elif args['--load-finding-aids']:
        print('Building corporate name browse...')
        corpnames = get_collections_for_xml(
            args['<dir>'],
            'https://bmrc.lib.uchicago.edu/corpnames/{}',
            '//ead:corpname',
            {'ead': 'urn:isbn:1-931666-22-9'}
        )
        print('Building decade browse...')
        decades = get_decades_for_xml(
            args['<dir>'],
            'https://bmrc.lib.uchicago.edu/decades/{}'
        )
        print('Building institution browse...')
        institutions = get_institutions_for_xml(
            args['<dir>'],
            'https://bmrc.lib.uchicago.edu/institutions/{}'
        )
        print('Building person browse...')
        people = get_collections_for_xml(
            args['<dir>'],
            'https://bmrc.lib.uchicago.edu/people/{}',
            ' | '.join((
                '//ead:famname',
                '//ead:name',
                '//ead:namegrp',
                '//ead:persname'
            )),
            {'ead': 'urn:isbn:1-931666-22-9'}
        )
        print('Building place browse...')
        places = get_collections_for_xml(
            args['<dir>'],
            'https://bmrc.lib.uchicago.edu/places/{}',
            '//ead:geogname',
            {'ead': 'urn:isbn:1-931666-22-9'}
        )
        print('Building topic browse...')
        topics = get_collections_for_xml(
            args['<dir>'],
            'https://bmrc.lib.uchicago.edu/topics/{}',
            ' | '.join((
                '//ead:occupation',
                '//ead:subject'
            )),
            {'ead': 'urn:isbn:1-931666-22-9'}
        )
        browses = {**corpnames, **decades, **institutions, **people, **places, **topics}

        transform_xsd = etree.XSLT(
            etree.parse(
                os.path.join(
                    'bmrcportal',
                    'xslt',
                    'dtd2schema.xsl'
                )
            )
        )
        
        for dir in os.listdir(args['<dir>']):
            for eadid in os.listdir(os.path.join(args['<dir>'], dir)):
                try:
                    transformed_xml = transform_xsd(
                        etree.parse(
                            os.path.join(args['<dir>'], dir, eadid)
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
                    print('LOADING {}...'.format(eadid))
                    load_findingaid(
                        *server_args +
                        (
                            fh, 
                            eadid,
                            collections
                        )
                    )
    elif args['--search']:
        if not args['<collection>']:
            args['<collection>'] = ['https://bmrc.lib.uchicago.edu/institutions/BMRC+Portal']

        results = get_search(
            *server_args + (args['<search>'], args['<start>'], args['<collection>'], args['<browse>'] or '')
        )

        print(json.dumps(results))
        sys.exit()

        if not isinstance(results, dict):
            print(results)
            sys.exit()

        print('start = {}'.format(results['start']))
        print('size = {}'.format(results['size']))
        print('total = {}'.format(results['total']))
        print('')
    
        for result in results['results']:
            print(result['index'] + '.')

            # get institution from collections.
            for collection in result['collections']:
                if collection.startswith('https://bmrc.lib.uchicago.edu/institutions/') \
                   and not collection == 'https://bmrc.lib.uchicago.edu/institutions/BMRC+Portal':
                    print(
                        urllib.parse.unquote_plus(
                            collection.replace('https://bmrc.lib.uchicago.edu/institutions/', '')
                        )
                    )
            print(result['title'])
            print('')

            print(result['uri'])
            print('')

            print('\n'.join(textwrap.wrap(result['abstract'])))
            print('')

            # get all collections other than institutions.
            collection_output = {
                'corpnames': [],
                'decades': [],
                'places': [],
                'people': [],
                'topics': []
            }

            for collection in sorted(result['collections']):
                output = []
                if not collection.startswith('https://bmrc.lib.uchicago.edu/institutions/') and \
                   len(collections[collection]) > 1:
                    collection_type = collection.split('/')[3]
                    collection_label = urllib.parse.unquote_plus(
                        re.sub('^https:\/\/bmrc\.lib\.uchicago\.edu\/[^/]*/', '', collection)
                    )
                    collection_output[collection_type].append((
                        collection_label,
                        len(collections[collection])
                    ))
          
            for collection_type in sorted(collection_output.keys()): 
                output = sorted(collection_output[collection_type], key=lambda c: c[1], reverse=True)
                for c in output[:3]:
                    print('[{}: {} ({})]'.format(collection_type, c[0], c[1]))

            print('\n-------------------------------------------------------------------------------\n')

        print('*******************************************************************************\n')

        for facet, count in results['collections'].items():
            print('{} ({})'.format(facet, count))

    elif any([args[n] for n in browse_namespaces.keys()]):
        print(json.dumps(collections))
