# plex-offline-indexer
Iterates over media folder(s) to create fake fake media TV series files.  I use to show Plex which streaming shows I want to watch, and when new episodes are available, Plex will show as new/unwatched.

each of the TV show's folder needs to have a "_tvdbid.ini" file in it.  Contents are:
[general]
tvdbid = 0
startSeason = 1
endSeason = 200



Lookup the id number on tvdb and enter it in the tvdbid line instead of 0.
Change start and end seasons as desired.

