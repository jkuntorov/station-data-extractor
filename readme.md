# TfL Tube Data Collector
Extracting raw tube usage data from TfL resources and collecting it in one place.

## How does it work
This repository contains a collection of small Ruby programs, which manipulate the TfL data in different ways:
- **journeys.rb** - extracts a number of components from a set of journeys; TfL provide a CSV containing 2.6 million journeys made on their network during a week in November 2009;
- **locations.rb** - extracts the geographic coordinates and names of Tube stations from a KML file, provided by TfL;
- **compare.rb** - a helper program which exports names of the stations collected from both the *Journeys* and *Locations* programs into a text file;
- **combine.rb** - a helper program which takes the JSON exports of the *Journeys* and *Locations* programs and combines them into one JSON file which contains all of the information.

### Journeys
The `journeys.rb` program goes through each one of the 2.6 million journey records and extracts information about the transport system they're made with and the day, times and stations of travel. It filters out all journeys made on a system different than the Underground (LUL), as well as the ones which are marked as either Unstarted or Unfinished. Also, it cuts down the few journeys which end after midnight, as their time is marked as 25 o'clock. In order to keep the journey data as accurate as possible, some stations are removed or merged semi-automatically. They can be edited in separate CSV lists, located in the `data` directory (`excess_stations_from_journeys.csv`, `merge_stations.csv`).

##### Exported JSON structure
```
{
    {...},
    {
        "name": "Goodge Street",
        "data": {
            "Mon": {...},
            "Tue": {
                ...,
                "09": {...},
                "10": {
                    "in": 8,
                    "out": 36,
                    "all": 44
                },
                "11": {...},
                ...
            },
            "Wed: {...},
            ...
        }
    },
    {...}
}
```

I have been running this program on a 13-inch mid-2012 MacBook Air and it takes around 8 minutes and 40 seconds to parse through the full 140MB CSV file.

### Locations
The `locations.rb` program iterates through a KML file which contains geographic information about the Tube Stations in London. It covers both the Underground and the Docklands Light Railway (DLR), however some of the data is outdated. To fix that, some stations have to be manually added and removed (as referenced in [this article](http://www.qwghlm.co.uk/2012/03/06/why-it-took-me-five-months-to-write-whensmytube/)). The information about those is stored in the `missing_stations.csv` and `excess_stations_from_locations.csv` files in the `data` directory.

##### Exported JSON structure
```
{
    "Clapham South Station": {
        "lat": "51.452599834714476000",
        "lon": "-.147982098639174410"
    },
    "Cockfosters Station": {
        "lat": "51.651687534574954000",
        "lon": "-.149614715155877680"
    },
    "Colindale Station": {
        "lat": "51.595286518799250000",
        "lon": "-.250142587760251700"
    }
}
```

### Compare
The compare app produces the `comparison.txt` and `matches.txt` files. The first one contains lists with the station names contained in the exports from the *Journeys* and *Locations* programs. The second contains the way they're matched, e.g.
`Heathrow Terms 123 => Heathrow Terminals 1, 2, 3 Station`.

### Combine
In order to use all of the data at once more easily, the `combine.rb` program takes both JSON files, exported from the *Journeys* and *Locations* programs, and matches the stations by name. Again, this process is automatic to some extent, but in order to avoid complexity the ones which are too different are listed in the `custom_matches.csv` file (again, in the `data` directory). 

When the matches have been made, the `data.json` file is exported containing the proper name, geographic coordinates and usage data for each station.

##### Exported JSON structure
```
{
    {...},
    {
        "name": "Goodge Street Station",
        "coordinates": {
            "lat"=>"51.520424996045500000",
            "lon"=>"-.134662152092394320"
        }
        "data": {
            "Mon": {...},
            "Tue": {
                ...,
                "09": {...},
                "10": {
                    "in": 8,
                    "out": 36,
                    "all": 44
                },
                "11": {...},
                ...
            },
            "Wed: {...},
            ...
        }
    },
    {...}
}
```

## How to run this project
If you're running an OSX install, here's how you can run this project:
- Make sure you have Ruby installed by typing `ruby -v` in your Terminal;
- You will need the `nokogiri` Ruby gem to parse the KML file in the *Locations* program. You can install it by running `gem install nokogiri`; Similarly, you might need to install the `csv`, `json` and `open-uri` libraries if they are not installed on your machine already.
- Register with TfL to use their [API Portal](https://api-portal.tfl.gov.uk) so that you can get access to all of the data about the journeys;
- Download the *Oyster card journey information* which contains a 5% sample of all journeys made on the TfL network during a week in November 2009;
- Clone this repository and put the Oyster dataset in the `/data/journeys` directory;
- Run the *Journeys* program by typing `ruby journeys.rb` whilst you are in the same directory;
- Run the *Locations* program by typing `ruby locations.rb`;
- Run the *Combine* program by typing `ruby combine.rb`;
- At this point you can review the `data.json` file in the `export` directory, which is ready for use.

## About this project
This repository contains the first part of my Final Major Project at Camberwell College of Arts, University of the Arts London. The data extracted here will be used for a data visualisation of Tube usage. A link to that repository will be put here, once it's ready.

I am in no way affiliated with Transport for London or any of its subsidiaries or partners.
