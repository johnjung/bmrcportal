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
