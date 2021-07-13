var docs = JSON.parse(document.getElementById('search_results_data').dataset.docs);

var facets = document.getElementsByClassName('facet');
for (var i = 0; i < facets.length; i++) {
    var facet_type = facets[i].dataset.facet;
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "/sidebar/" + facet_type, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({
        docs: docs,
        limit: 5,
        sort: 'relevance-dsc'
    }));

    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            var data = JSON.parse(this.responseText);

            console.log(data);

            /* get the facet that triggered this XHR request. */
            var f = data['b'].replace('https://bmrc.lib.uchicago.edu/', '').replace('/', '');
            console.log(f);
            var this_facet = null;
            for (var j = 0; j < facets.length; j++) {
                if (facets[j].dataset.facet == f) {
                    this_facet = facets[j];
                }
            }

            console.log(this_facet);

            /* add content to that facet. */
            if (this_facet) {
                /* remove this facet if no data was returned. */
                if (data['results'].length == 0) {
                    this_facet.parentNode.removeChild(this_facet);
                } else {
                    var facet_h3 = f.charAt(0).toUpperCase() + f.slice(1);
                    var more_href = '/search/?b=' + encodeURIComponent(data['b'])
                    var h = '';
                    h += '<h3><a href="' + more_href + '">' + facet_h3 + '</a></h3>';
                    h += '<ul>';
                    for (var j = 0; j < data['results'].length; j++) {
                        var href = '#';
                        var text = data['results'][j][1] + ' (' + data['results'][j][2] + ')';
                        h += '<li><a href="' + href + '">' + text + '</a></li>';
                    }
                    h += '</ul>';
    
                    this_facet.innerHTML = h;
                }
            }
        }
    };
}

/*
div class="facet" data-facet="topics"></div>

for each class="facet"
get the data-facet attribute.
submit an xhr request.
add an h3 with a link.
get url params from a data attribute.
make a UL.
get collections-active from a data attribute.


          <h3><a href="/search/?b=https%3A%2F%2Fbmrc.lib.uchicago.edu%2Ftopics%2F&{{ get_url_params(search_results) }}">Topics (more)</a></h3>
          <ul>
            {% for f in search_results['collections-active'] %}
              {% if f[0].startswith('https://bmrc.lib.uchicago.edu/topics/') %}
                <li>{{ f[1] }} <a href="/search/?{{ remove_from_url_params(search_results, {'f': f[0]}) }}">&#215;</a></li>
              {% endif %}
            {% endfor %}

            {% for c in search_results['sidebar-topics'] %}
              <li><a href="/search/?{{ add_to_url_params(search_results, {'f': c[0]}) }}">{{ c[1] }} ({{ c[2] }})</a></li>
            {% endfor %}
          </ul>
        </div>
*/
