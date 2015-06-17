# Adagios + NSCA

This image is an extension of [pschmitt/adagios](https://registry.hub.docker.com/u/pschmitt/adagios/) that adds configuration for passive checking with NSCA. See **pschmitt**'s repository for extra configuration options. Note that the Adagios admin username must be "admin" for this container, and that using Git repos is autoenabled.

## NSClient++
To work, install [NSClient++](http://www.nsclient.org/download/0-4-3/) on a widows host. Remember to add the common check modules and NSCA during setup.

Then add the text below to ``nsclient.ini``. FRemember to replace the IP at 
"``address = 192.168.43.128``" with the IP-address of your Docker container running Nagios/Adagios.

Restart the NSClient++ service after editing the INI file.

    ;;; nsclient.ini
    
    [/modules]
    CheckDisk = 1
    CheckEventLog = 1
    CheckExternalScripts = 1
    CheckHelpers = 1
    CheckNSCP = 1
    CheckSystem = 1
    CheckWMI = 1
    NSCAClient = 1
    Scheduler = 1
    
    [/settings/external scripts/alias]
    alias_cpu = checkCPU warn=80 crit=90 time=5m time=1m time=30s
    alias_cpu_ex = checkCPU warn=$ARG1$ crit=$ARG2$ time=5m time=1m time=30s
    alias_disk = CheckDriveSize MinWarn=10% MinCrit=5% CheckAll FilterType=FIXED
    alias_disk_loose = CheckDriveSize MinWarn=10% MinCrit=5% CheckAll     FilterType=FIXED ignore-unreadable
    alias_event_log = CheckEventLog file=application file=system MaxWarn=1     MaxCrit=1 "filter=generated gt -2d AND severity NOT IN ('success',     'informational') AND source != 'SideBySide'" truncate=800 unique descriptions     "syntax=%severity%: %source%: %message% (%count%)"
    alias_file_age = checkFile2 filter=out "file=$ARG1$" filter-written=>1d     MaxWarn=1 MaxCrit=1 "syntax=%filename% %write%"
    alias_file_size = CheckFiles "filter=size > $ARG2$" "path=$ARG1$" MaxWarn=1     MaxCrit=1 "syntax=%filename% %size%" max-dir-depth=10
    alias_mem = checkMem MaxWarn=80% MaxCrit=90% ShowAll=long type=physical     type=virtual type=paged type=page
    alias_process = checkProcState "$ARG1$=started"
    alias_process_count = checkProcState MaxWarnCount=$ARG2$ MaxCritCount=$ARG3$     "$ARG1$=started"
    alias_process_hung = checkProcState MaxWarnCount=1 MaxCritCount=1 "$ARG1$=hung"
    alias_process_stopped = checkProcState "$ARG1$=stopped"
    alias_sched_all = CheckTaskSched "filter=exit_code ne 0" "syntax=%title%:     %exit_code%" warn=>0
    alias_sched_long = CheckTaskSched "filter=status = 'running' AND     most_recent_run_time < -$ARG1$" "syntax=%title% (%most_recent_run_time%)" warn=    >0
    alias_sched_task = CheckTaskSched "filter=title eq '$ARG1$' AND exit_code ne     0" "syntax=%title% (%most_recent_run_time%)" warn=>0
    alias_service = checkServiceState CheckAll
    alias_service_ex = checkServiceState CheckAll "exclude=Net Driver HPZ12"     "exclude=Pml Driver HPZ12" exclude=stisvc
    alias_up = checkUpTime MinWarn=1d MinWarn=1h
    alias_updates = check_updates -warning 0 -critical 0
    alias_volumes = CheckDriveSize MinWarn=10% MinCrit=5% CheckAll=volumes     FilterType=FIXED
    alias_volumes_loose = CheckDriveSize MinWarn=10% MinCrit=5% CheckAll=volumes     FilterType=FIXED ignore-unreadable
    default = 
    
    [/settings/scheduler]
    threads = 5
    
    [/settings/scheduler/schedules/default]
    channel=NSCA
    interval=30s
    report=all
    
    [/settings/scheduler/schedules]
    ; Services to be checked
    host_check=check_ok
    cpu=alias_cpu
    mem=alias_mem
    disk=alias_disk_loose
    service=alias_service
    
    [/settings/NSCA/client]
    channel = NSCA
    hostname = auto ;;; Can be overridden with custom name
    
    [/settings/NSCA/client/targets/default]
    address = 192.168.43.128 ;;; Set this to the Nagios server name/ip
    encryption = 1
    password = 
    ;;; Optional properties ;;;
    ;port = 5667
    ;allowed ciphers = ADH
    ;certificate = 
    ;timeout = 30
    ;use ssl = false
    ;verify mode = none
    
    [/settings/log]
    date format = %Y-%m-%d %H:%M:%S
    file name = ${exe-path}/nsclient.log
    level = warn

## Adding a host

When NSClient is up and running, go to the Adagios configuration and add a host to the ``passive_windows`` hostgroup. Use the existing ``NEUROMANCER`` host as a template. Once you have at least one host defined, you can remove the ``NEUROMANCER`` host.