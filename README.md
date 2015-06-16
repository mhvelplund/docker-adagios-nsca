The two objects below are needed to accept a passive update about the TestMessage service.

    # Define a passive check template
    define service {
    	use 					generic-service 
    	name 					passive_service 
    	active_checks_enabled	0 
    	passive_checks_enabled	1 # We want only passive checking
    	flap_detection_enabled	0
    	register				0 # This is a template, not a real service
    	is_volatile				0
    	check_period			24x7 
    	max_check_attempts		1 
    	normal_check_interval	5 
    	retry_check_interval	1 
    	check_freshness			0
    	contact_groups 			admins
    	check_command			check_dummy!0
    	notification_interval	120
    	notification_period		24x7
    	notification_options	w,u,c,r
    	stalking_options		w,c,u
    }
    
    # Define a passive service
    define service {
    	use						passive_service
    	service_description		TestMessage
    	host_name				localhost
    }

