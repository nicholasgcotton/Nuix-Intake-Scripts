#######################################################################################################################
# ///// Nuix Interpreted Comments BEGIN
# Needs Case: true
# Menu Title: Default QA & Tags V3
# encoding: utf-8
# ///// Nuix Interpreted Comments END
#######################################################################################################################
# 2022-02-10 V3 Nicholas Cotton
#
# Creates default/standard tags. 
# Offers to apply date exclusions for before or after X date. 
# Offers to add custom metadata for all items in field "Source" for use with Export to E&R by Tag script later.
# Note: This script does not apply any exclusions, Tags 04 Non-Reviewable Data and 05 Out of Scope must be manually 
# reviewed and exlcuded.
#######################################################################################################################
###########################
# Dependencies/Requirements
###########################
script_directory = File.dirname(__FILE__)
require File.join(script_directory,"Nx.jar")
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"
java_import "com.nuix.nx.dialogs.ProcessingStatusDialog"
java_import "com.nuix.nx.digest.DigestHelper"
java_import "com.nuix.nx.controls.models.Choice"
LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)
#load File.join(__dir__, 'nx_progress.rb') # v1.0.0
require 'csv' # For the export inventory file
require 'time' # For sanity checking timezone issues in the export inventory file
require "fileutils" # For moving PDFs around and renaming vetted files with the r in front.
require 'set'  # Used for sorting which markup is in use against which markup we want to actually use.

javax.swing.JOptionPane.showMessageDialog(nil, "This script will create the following default tags:
01 Evidence 
02 Not Evidence 
03 Needs Further Review 
04 Non-Reviewable Data 
04 Non-Reviewable Data-System Files
04 Non-Reviewable Data-No Data
04 Non-Reviewable Data-Unreconised
04 Non-Reviewable Data-Logs
04 Non-Reviewable Data-Microsoft ESE
04 Non-Reviewable Data-INI Style Configuration File
04 Non-Reviewable Data-JSON Data File
04 Non-Reviewable Data-Slack Space
04 Non-Reviewable Data-Images under 5kb
05 Out of Scope 
06 Technical Issue
07 Email-Necessary
08 Email-Unnecessary")
current_case.create_tag("01 Evidence")
current_case.create_tag("02 Not Evidence")
current_case.create_tag("03 Needs Further Review")
current_case.create_tag("04 Non-Reviewable Data")
current_case.create_tag("05 Out of Scope")
current_case.create_tag("06 Technical Issue")
current_case.create_tag("07 Email-Necessary")
current_case.create_tag("08 Email-Unnecessary")


# Get the BulkAnnotater to make bulk_tagger one line commands
bulk_tagger = utilities.getBulkAnnotater()
bulk_tagger.add_tag("04 Non-Reviewable Data|System Files", current_case.search(%Q[kind:system]))  # Tags System Files
bulk_tagger.add_tag("04 Non-Reviewable Data|No Data", current_case.search(%Q[kind:no-data]))   # Tags Files with no data
bulk_tagger.add_tag("04 Non-Reviewable Data|Unrecognised", current_case.search(%Q[kind:unrecognised NOT mime-type:text/plain]))  # Tags Unrecognised but not Plain text files
bulk_tagger.add_tag("04 Non-Reviewable Data|Logs", current_case.search(%Q[kind:log]))  # Tags Log Files
bulk_tagger.add_tag("04 Non-Reviewable Data|Microsoft ESE", current_case.search(%Q[mime-type:( application/vnd.ms-ese-database OR application/vnd.ms-ese-row OR application/vnd.ms-ese-table )]))  # Tags Microsoft ESE tAbles, databases, and rows
bulk_tagger.add_tag("04 Non-Reviewable Data|INI Style Configuration File", current_case.search(%Q[mime-type:text/x-ini])) # Tags INI Files
bulk_tagger.add_tag("04 Non-Reviewable Data|JSON Data File", current_case.search(%Q[mime-type:application/json]))  # Tags JSON Data Files
bulk_tagger.add_tag("04 Non-Reviewable Data|Slack Space", current_case.search(%Q[flag:slack_space]))  # Tags Slack Space Items
bulk_tagger.add_tag("04 Non-Reviewable Data|Images under 5kb", current_case.search(%Q[file-size:[* TO 5000] kind:image]))  # Tags all images under 5kb in size

dialog = TabbedCustomDialog.new("Case Setup")
main_tab = dialog.addTab("settings_tab","Date Exclusions & Data Source")
main_tab.appendTextField("exclude_before_date","OPTIONAL: Start Date (all items before this date will be excluded from review) in format YYYYMMDD. Leave blank for none:","")
main_tab.appendTextField("exclude_after_date","OPTIONAL: End Date (all items after this date will be excluded from review) in format YYYYMMDD. Leave blank for none:","")
main_tab.appendTextField("custom_metadata","OPTIONAL: Custom Metadata e.g. \"SITE 01 ITEM 01\"","")

dialog.validateBeforeClosing do |values|
  puts "Start Date #{values["exclude_before_date"]}"
  puts "End Date #{values["exclude_after_date"]}"
  puts "Custom Metadata #{values["custom_metadata"]}"
	# Get user to confirm that they are about to export some data
	message = "Please confirm you have typed all dates in the format YYYYMMDD. Proceed?"
	title = "Proceed?"
	next CommonDialogs.getConfirmation(message,title)
end

dialog.display

if dialog.getDialogResult == true
  # Pull out settings from dialog into handy variables
  # These are all thing=values["thing"]
  values = dialog.toMap
  exclude_before_date = values["exclude_before_date"]
  exclude_after_date = values["exclude_after_date"]
  custom_metadata = values["custom_metadata"]
  
  # Excludes files with an ITEM date before [user input] as long as that item was not created, accessed or modified after the date cutoff.
  puts "Before Date value #{exclude_before_date}"
  puts "After Date value #{exclude_after_date}"
  puts "Custom Metadata value #{custom_metadata}"
  puts exclude_before_date.strip.empty?
  puts exclude_after_date.strip.empty?
  puts custom_metadata.strip.empty?

  if !exclude_before_date.strip.empty?
      bulk_tagger.add_tag("05 Out of Scope|Before (Item Date) #{exclude_before_date}", current_case.search(%Q[item-date:[* TO #{exclude_before_date}]]))
      bulk_tagger.add_tag("05 Out of Scope|Before (Any Date Property) #{exclude_before_date}", current_case.search(%Q[date-properties:"*":[* TO #{exclude_before_date}]]))
  end

  # Excludes files with an ITEM date after [user input] as long as that item was not created, accessed or modified before the date cutoff.
  if !exclude_after_date.strip.empty?
    bulk_tagger.add_tag("05 Out of Scope|After (Item Date) #{exclude_after_date}", current_case.search(%Q[item-date:[#{exclude_after_date} TO *]]))
    bulk_tagger.add_tag("05 Out of Scope|After (Any Date Property) #{exclude_after_date}", current_case.search(%Q[date-properties:"*":[#{exclude_after_date} TO *]]))
  end

  if !custom_metadata.strip.empty?
    items = $current_case.search("")
    custom_metadata_name = "Source"
    bulk_tagger.putCustomMetadata(custom_metadata_name,custom_metadata,items,nil)
  end
end


#######################################################################################################################
# Script completed message.
#######################################################################################################################

javax.swing.JOptionPane.showMessageDialog(nil, "Note, user MUST review items under tags 04 Non-Reviewable and 05 Out of Scope and exlcude as necessary. Exclusions are not automatically applied")
puts "Script has completed"

#######################################################################################################################
# Script Completed
#######################################################################################################################
