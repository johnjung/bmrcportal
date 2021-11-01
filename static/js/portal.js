function toggleBurger() {
    var burger = $('.burger');
    var menu = $('.navbar-menu');
    burger.toggleClass('is-active');
    menu.toggleClass('is-active');
}

/*************************************
 * VIEW MORE / VIEW ALL FACETS LINKS *
 *************************************/

// get the view less and view more limits from data attributes.
var view_less_limit = parseInt(document.getElementById('facets').dataset.sidebar_view_less_facet_count);
var view_more_limit = parseInt(document.getElementById('facets').dataset.sidebar_view_more_facet_count);

var facets = document.getElementsByClassName('facet');
for (var i = 0; i < facets.length; i++) {
    var facet_name = facets[i].dataset.facet;

    var ul = facets[i].querySelector('ul');
    var lis = facets[i].querySelectorAll('li:not([view_link])');
    var lis_length = lis.length;
   
    for (var j = lis.length - 1; j >= 0; j--) {
        if (j >= view_more_limit) {
            lis[j].parentNode.removeChild(lis[j]);
        } else if (j >= view_less_limit) {
            lis[j].classList.add('view_more');
            lis[j].style.display = 'none';
        }
    }

    if (lis_length > view_less_limit) {
        ul.innerHTML += '<li class="view_link"><a class="view_more_link" href="#">View more ' + facet_name + ' >></a></li>';
        ul.innerHTML += '<li class="view_link"><a class="view_less_link" href="#"><< View less ' + facet_name + '</a></li>';
        ul.querySelector('.view_less_link').parentNode.style.display = 'none';
    }
    if (lis_length > view_more_limit) {
        ul.innerHTML += '<li class="view_link"><a class="view_all_link" href="#">View all relevant ' + facet_name + ' >></a></li>';
        ul.querySelector('.view_all_link').parentNode.style.display = 'none';
    }
}

// view less links.
var view_less_links = document.getElementsByClassName('view_less_link');
for (var i = 0; i < view_less_links.length; i++) {
    view_less_links[i].onclick = function(e) {
        e.preventDefault();

        var a = this;

        var div = a.parentNode.parentNode.parentNode;

        // get the facet name, e.g. "Organizations", from link text.
        var facet_name = div.dataset.facet;

        // get the "view more" <li>s for this facet.
        var lis = a.parentNode.parentNode.querySelectorAll('li[class="view_more"]');

        // turn off view more links.
        for (var j = 0; j < lis.length; j++) {
            lis[j].style.display = 'none';
        }

        div.querySelector('.view_less_link').parentNode.style.display = 'none';
        div.querySelector('.view_more_link').parentNode.style.display = 'block';
        div.querySelector('.view_all_link').parentNode.style.display = 'none';
    };
}

// view more links.
var view_more_links = document.getElementsByClassName('view_more_link');
for (var i = 0; i < view_more_links.length; i++) {
    view_more_links[i].onclick = function(e) {
        e.preventDefault();

        var a = this;

        var div = a.parentNode.parentNode.parentNode;

        // get the facet name, e.g. "Organizations", from link text.
        var facet_name = div.dataset.facet;

        // get the "view more" <li>s for this facet.
        var lis = a.parentNode.parentNode.querySelectorAll('li[class="view_more"]');

        // turn on view more links.
        for (var j = 0; j < lis.length; j++) {
            lis[j].style.display = 'block';
        }

        div.querySelector('.view_less_link').parentNode.style.display = 'block';
        div.querySelector('.view_more_link').parentNode.style.display = 'none';
        div.querySelector('.view_all_link').parentNode.style.display = 'block';
    };
}

/****************************
 * MODAL OVERLAY FOR FACETS *
 ****************************/

var body = document.querySelector('body');
var overlay_bg = document.createElement('div');
overlay_bg.id = 'facet_overlay_bg';
body.appendChild(overlay_bg);

var overlay = document.createElement('div');
overlay.id = 'facet_overlay';
overlay_bg.appendChild(overlay);
 
var overlay_display = false; 

var view_all_links = document.getElementsByClassName('view_all_link');
for (var i = 0; i < view_all_links.length; i++) {
    view_all_links[i].onclick = function(e) {
        e.preventDefault();

        var a = this;

        // e.g. "people"
        var facet_name = a.parentNode.parentNode.parentNode.dataset.facet;

        document.getElementById('facet_overlay_bg').style.display = 'block';
        var xml_http = new XMLHttpRequest();
        xml_http.onreadystatechange = function() {
            if (xml_http.readyState == 4 && xml_http.status == 200) {
                document.getElementById('facet_overlay').innerHTML = xml_http.responseText;

                document.getElementById('facet_overlay_close').onclick = function(e) {
                    e.preventDefault();
                    document.getElementById('facet_overlay_bg').style.display = 'none';
                    document.getElementById('facet_overlay').innerHTML = '';
                }

                var sort_links = document.getElementsByClassName('facet_overlay_sort');
                for (var j = 0; j < sort_links.length; j++) {
                    sort_links[j].onclick = function(e) {
                        e.preventDefault();

                        var a = this;

                        var facet_uri = 'https://bmrc.lib.uchicago.edu/' + facet_name + '/';

                        var params = window.location.search;
                        if (params) {
                            params += '&'
                        } else {
                            params += '?'
                        }
                        params += 'fsort=' + encodeURIComponent(a.dataset.sort);
                        params += '&a=' + encodeURIComponent(facet_uri)

                        var url = '/facet_view_all/' + params;
                        console.log(url);
                        overlay_bg.dataset.url = url;
                        xml_http.open('GET', url);
                        xml_http.send(null);
                    }
                }
            }
        }
        var facet_uri = 'https://bmrc.lib.uchicago.edu/' + facet_name + '/';
        var params = window.location.search;
        if (params) {
            params += '&a=' + encodeURIComponent(facet_uri)
        } else {
            params = '?a=' + encodeURIComponent(facet_uri)
        }
        var url = '/facet_view_all/' + params;
        console.log(url);
        overlay_bg.dataset.url = url;
        xml_http.open('GET', url);
        xml_http.send(null);
    }
}

// need the x to close out the overlay.

var sorts = document.getElementsByClassName('facet_overlay_sort');
for (var i = 0; i < sorts.length; i++) {
    sorts[i].onclick = function(e) {
        e.preventDefault();

        // get the sort url from the overlay_bg.
        // request the data from 
    }
}
