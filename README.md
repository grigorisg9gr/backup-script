 This is a bash script used for a regular back-up from a server to a local PC. 
 You should run this script from the PC client that the data will be copied and NOT from the server. 
 It is advisable to have [ssh without login](http://www.linuxproblem.org/art_9.html) from the client PC to the server. 
 
 Call like this: ./backup.sh "[project_name_[folder]]" "" "[path_in_the_sever_to_be_copied]" "[path_in_the_local_machine_that_script_will_be_executed]" "[username]@[IP]:" "[dummy_mail]" "" "" [optional_arg]
 The last optional argument indicates whether the script will be saved in one of the folders Daily, Weekly, Monthly 
 or in a folder BY_TIME. In the latter case, it will be written based on the timestamp and not overwritten. 

 Copyright (C) 2014 Grigorios G. Chrysos
 available under the terms of the Apache License, Version 2.0


 For any issues or questions, contact me in grigoris.chrysos@gmail.com

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Original README: 

Checkout [blog post about this script](http://thebestsolution.org/rsync-backup-script-bash/)
