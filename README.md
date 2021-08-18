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

## Tests

### Sidebar Facets Filter Results
Clicking on a sidebar facet should always filter the current set of results.
If the current set of results = N pages, after clicking a sidebar facet the 
new result set should be less than or equal to the previous result set.

Example:
Search for "altgeld gardens" (without quotes.) As of August, 2021 it returns 
6 results. Clicking "African American newspapers (2)" in the sidebar should
return 2 results.

### Sidebar Facets Show the Number of Results For That Facet
Search for "Chicago" (without quotes.) As of August, 2021 this search
returns 1230 results. Clicking on "Jazz (38)" in the sidebar should return
38 results. 

### Exact Phrase Searching
Searching for an exact phrase, like "chicago state" (with quotes), should only
return results where those two words appear next to each other.

### A New Search Clears Previous Results
If a user has a facet selected and executes a new search, the new search should
clear the old facet away. Search for "Chicago". Click the "Jazz (38)" facet in
the sidebar. Search for "John Cage". The "Jazz" facet should be gone. 

### Searches are Case and Diacritic Insensitive
Searches for "Chicago State", "chicago state", and "Chicagö State", with or
without quotes, should all return the same number of results. 

### Multi-word Search Results Should Contain The Set Intersection of Individual Word Searches
Search for "Oneida Woodard" (without quotes.) As of August, 2021, this search
returns one result, "Chicago Defender Individuals Files". Individual searches
for "Oneida" and "Woodard" should each return more than one result, and the
Chicago Defender Individuals Files should be included in each result set. 

### Sorting Search Results 
Search for "Chicago". The default sort should be relevance. Clicking the 
alpha, reverse alpha, and shuffle buttons should sort finding aids
appropriately, by title. 

### Result Pager
Search for "Gwendolyn Brooks" (without quotes.) As of August, 2021 this search
returns 35 results. Clicking the page "2" link should take you to the next
page of results. When you're on the final page, the "Next page" link should
be deactivated. 

### Proximity Searching
A search for "bronzeville video" (without quotes) should return the "VHS video
collection" finding aid near the top of results. 

### Finding Aid View
A search for "jazz" should return 115 results, as of August, 2021. Clicking on 
the first result should display a finding aid. 
