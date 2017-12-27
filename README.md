# ProToolsText
Text parser and CSV converter for Avid Pro Tools text exports.

## Theory of Operation

Pro Tools exports a tab-delimited text file organized in multiple parts with an uneven syntax that usually can't "drop in" to
other tools like Excel or Filemaker. This project implements a simple Mac OS X application that accepts a text export from 
Pro Tools and converts it into a CSV of the clips, unfolding track and session data in the process and also parsing
additional columns from the clip, track and session name.

Importing a normal text export outputs a CSV with one row for each clip, like this:

|PT_SessionName | PT_TrackName | PT_EventNumber | PT_ClipName |PT_Start   | PT_Finish | PT_Duration | PT_Muted| ...|
|---------------|--------------|----------------|-------------|-----------|-----------|-------------|---------|---|
|Test Session   | Track 1      | 1              | Audio 1-01  |01:00:00:05|01:01:00:12|00:01:00:07  | Unmuted |...|
|Test Session   | Track 1      | 2              | Audio 1-02  |01:01:00:12|01:01:00:20|00:00:00:08  | Unmuted |...|

etc... Each clip has a column for the track name of the clip in addition to the session name. A column for the track comments 
is also included.

### Fields in Clip Names

Track names, track comments and clip names can also contain meta-tags or "fields" to add aditional columns to the CSV output.
Thus, if a clip has the name:

`Fireworks explosion {note=Replace for final} $V=1 [FX] [DESIGN]`

The row output for this clip will contain columns for the values:

|...| PT_ClipName| note | V | FX | DESIGN | ...|
|---|------------|------|---|----|--------|----|
|...| Fireworks explosion| Replace for final | 1 | FX | DESIGN | ... |

These fields can be defined in the clip name in three ways:
* `$NAME=VALUE` creates a field named `NAME` with a one-word value `VALUE`.
* `{NAME=VALUE}` creates a field named `NAME` with the value `VALUE`. `VALUE` in this case may contain spaces or any chartacter
up to the closing bracket.
* `[$NAME]` creates a field named `NAME` with a value `NAME`. This can be used to create a boolean-valued field; in the CSV 
output, clips with the field will have it, and clips without will have the column with an empty value.

For example, if two clips are named:

`"Squad fifty-one, what is your status?" [FUTZ] {Char=Dispatcher} [ADR]`

`"We are ten-eight at Rampart Hospital." {Char=Gage} [ADR]`

The output will contain the range:

|...| PT_ClipName| Char | FUTZ | ADR | ...|
|---|------------|------|---|----|-----|
|...| "Squad fifty-one, what is your status?"| Dispatcher | FUTZ | ADR | ... |
|...| "We are ten-eight at Rampart Hospital."| Gage |  | ADR | ... |



