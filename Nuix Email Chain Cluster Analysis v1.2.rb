# Menu Title: Nuix Email Chain Cluster Analysis v1.2
# Created by: Nicholas COTTON
# Clusters emails based on email threads, then tags those emails to expose cluster data.
# Potentially fails if there is no email to cluster, or no actual chains.
# Does not explicitly tag attachments, so should not be  used as the basis of further POSITIVE action on kinds other then email.
# However, you can use it to exlcude items tagged as unnecessary emails
# v 1.1 add closeAllTabs command, which should save some cycles on updating the workbench in the background.
# ///// Nuix Interpreted Comments BEGIN
# Needs Case: true
# Menu Title: Email Cluster Tagging v1.2
# Fixed tag coding and added completion notification.
# encoding: utf-8
# ///// Nuix Interpreted Comments END
# javax.swing.JOptionPane.showMessageDialog(nil, "Requires existing email cluster named 'Email'") #Only true when lines 23 and 24 are commented out.
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
require 'csv' # For the export inventory file
require 'time' # For sanity checking timezone issues in the export inventory file
require "fileutils" # For moving PDFs around and renaming vetted files with the r in front.
require 'set'  # Used for sorting which markup is in use against which markup we want to actually use.

#$window.closeAllTabs # Stops the GUI from updating as the script runs, which slows things down significantly. 
bulk_tagger = utilities.getBulkAnnotater()

cluster_settings = {
	:useNearDuplicates => false,
	:useEmailThreads => true
}
T1 = Time.now
cluster_items = $current_case.search("kind:email")       					# Turns out for some reason it's WAY faster to do this part in the GUI. 
$current_case.generateClusterRun("Email",cluster_items,cluster_settings)    # So if you want to do that, comment out these two lines and put line 13 back into play. 

bulk_tagger.add_tag("07 Email-Necessary|Unclustered", current_case.search(%Q[cluster:"Email;unclustered"]))  # Emails that are not part of a cluster aka chain. 
bulk_tagger.add_tag("07 Email-Necessary|Endpoints", current_case.search(%Q[cluster:"Email;;endpoint"]))      # Emails that contain the total text of the chain to that pojnt. 
bulk_tagger.add_tag("07 Email-Necessary|EndPoint-Attachments", current_case.search(%Q[cluster:"Email;;endpoint-attach"])) # Emails that contain an attachment AT an endpoint. 
bulk_tagger.add_tag("07 Email-Necessary|Thread-Attachments", current_case.search(%Q[cluster:"Email;;thread-attach"])) # Emails that contain an attachment NOT at an endpoint. In theory you don't need the email, just the attachment, but for evidence continunity we keep both. Most common example is the first message in a thread, where the attachment is not repeated elsewhere in the replies. 
bulk_tagger.add_tag("08 Email-Unnecessary", current_case.search(%Q[kind:email NOT tag:"07 Email-Necessary*"])) # Emails that are not required for review on the basis of NOT being any of the above. 



#######################################################################################################################
# Script completed message.
#######################################################################################################################

javax.swing.JOptionPane.showMessageDialog(nil, "Note, user MUST review items under tags 04 Non-Reviewable and 05 Out of Scope and exlcude as necessary. Exclusions are not automatically applied")
puts "Script has completed"

#######################################################################################################################
# Script Completed
#######################################################################################################################
