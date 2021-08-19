## Getting Started

Create a directory for this project and a Python 3 virtual environment, and
activate the environment:

```console
mkdir bmrcportal
cd bmrcportal
python3 -m venv venv
source venv/bin/activate
```

Install git if necessary and clone the repository:

```console
brew install git
git clone https://github.com/johnjung/bmrcportal.git
```

Install required Python packages via pip:

```console
cd bmrcportal
pip install -r requirements.txt
```

## Using Flask

Configuration files are not included in the Git repository. Request one from
another developer and place it at config/default.py.

If you're running the site on a development machine, you'll need to set up a 
tunnel for SSH connections. Run a command like the one below in a new console
window:

```console
ssh -D 9090 -q -C -N <cnetid>@staff.lib.uchicago.edu
```

To get started, set the FLASK_APP environmental variable and run the flask
command to see what's available:

```console
export FLASK_APP=bmrcportal
flask
```

Facets on the website are represented by collections in MarkLogic- you can browse
MarkLogic collections directly with commands like the following:

```console
flask browse-archives | python -m json.tool | less
flask browse-decades | python -m json.tool | less
flask browse-organizations | python -m json.tool | less
flask browse-people | python -m json.tool | less
flask browse-places | python -m json.tool | less
flask browse-topics | python -m json.tool | less
```

To run a local version of the site for testing, use the following command and
open a web browser to localhost:5000:

```console
flask run
```

## Integration Tests

### Result Pager
Search for "Gwendolyn Brooks" (without quotes.) As of August, 2021 this search
returns 35 results. Clicking the page "2" link should take you to the next
page of results. When you're on the final page, the "Next page" link should
be deactivated. 

### Finding Aid View
A search for "jazz" should return 115 results, as of August, 2021. Clicking on 
the first result should display a finding aid. 

### "View All" Facet Overlay 
Click the "view more" link in one of the sidebar facets, and then click "view
all". The facet overlay should appear.

### "View All" Facet Overlay Sorting
Facets should be sortable. 

### A New Search Clears Previous Results
If a user has a facet selected and executes a new search, the new search should
clear the old facet away. Search for "Chicago". Click the "Jazz (38)" facet in
the sidebar. Search for "John Cage". The "Jazz" facet should be gone.

### Confirm Sort Interface Display
Confirm that the sort interface works correctly. The current selected sort
should be displayed as a button, and the inactive sorts should displayed as
text. On hover, the inactive sorts should be displayed as buttons. Confirm
that this works the same on the "view all facet overlay", the browse display,
and on the search display.
