# Nuix-Intake-Scripts
Standard intake scripts for RCMP Nuix Workstation Intake, including "Default Quality Assurance and Tags v3" and "Email Chain Cluster Analysis v 1.1".

The purpose of these scripts is to automate parts of the Nuix Workstation intake that I always do the same way.

For a list of other useful Nuix scripts, see https://github.com/nicholasgcotton/Nuix-Scripts

## Installation
For the script(s) to function you must: 
- Download the script you want to use.
- Download [NX.jar](https://github.com/Nuix/Nx)
- Install both files to one of the Nuix scripts directories, on Windows, for example:
  - %appdata%\Nuix\Scripts - User level script directory
  - %programdata%\Nuix\Scripts - System level script directory

# Default Quality Assurance and Tags v3
## Creates Default Tags
- 01 Evidence
- 02 Not Evidence
- 03 Needs Further Review
- 04 Non-Reviewable Data
- 04 Non-Reviewable Data|System Files
- 04 Non-Reviewable Data|No Data
- 04 Non-Reviewable Data|Unrecognised
- 04 Non-Reviewable Data|Logs
- 04 Non-Reviewable Data|Microsoft ESE
- 04 Non-Reviewable Data|INI Style Configuration File
- 04 Non-Reviewable Data|JSON Data File
- 04 Non-Reviewable Data|Slack Space
- 04 Non-Reviewable Data|Images under 5kb
- 05 Out of Scope 
- 06 Technical Issue
- 07 Email-Necessary
- 08 Email-Unnecessary

## Offers to Exlcude Items
When provided with a before of after cutoff date the script will create the relevant tags:
- 05 Out of Scope|Before (Item Date) YYYYMMDD
- 05 Out of Scope|Before (Any Date Property) YYYYMMDD
- 05 Out of Scope|After (Item Date) YYYYMMDD
- 05 Out of Scope|After (Any Date Property) YYYYMMDD

Searches are conducted using both ITEM-DATE and DATE-PROPERTIES and tagged under heading 05 Out Of Scope. User must review and exclude items as necessary.

Both ITEM-DATE and DATE-PROPERTIES are used as, for example: an email may have been written in 2018 but last copied/modified in 2020. Whether to exclude that item will depend on the wording of your judicial authorization.

## Allows user to set custom metadata "Source"
Allows the user to set custom metadata in the field "Source", e.g. SITE 01 ITEM 01. For use with [Nuix Export To Evidence & Reports III](https://github.com/nicholasgcotton/NuixExportToEvidence-Reports)

# Nuix Email Chain Cluster Analysis v1.1
This can be run as a script, but it's actually faster to do it in the GUI (use the script as a guide). 

Creates a cluster of all emails with name "Email Cluster DATETIME"

Creates the following tags and puts the relevant items into each tag:
- 07 Email-Necessary|Unclustered
- 07 Email-Necessary|Endpoints
- 07 Email-Necessary|EndPoint-Attachments
- 07 Email-Necessary|Thread-Attachments

Creates the following tag and puts all emails not dealt with above into it:
- 08 Email-Unnecessary

## Notes:
1) This script requires the NX.jar: https://github.com/Nuix/Nx
2) This script uses Nuix API calls documented: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/index.html

## Thanks
- This script would not have been possible without the support of the @Nuix tech support team, and all the code samples on https://github.com/Nuix.

## License

Copyright [2020-2022] Nicholas Grant Cotton

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
