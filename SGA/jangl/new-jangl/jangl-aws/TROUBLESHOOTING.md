**Jangl Application/System Troubleshooting Guidelines**

  # Diagnose.
  # Quarantine.
  # Disable.
  # Rebuild/Redeploy.

**Jangl Tier 0 Application Troubleshooting Checklist**

Check Sentry System Events 
  - Dig into Sentry for more error info on where best to look.
    - start with highest error activity and follow the red dots.
    
  - If (Sentry Events > 20,000)
    Probably Infrastructure, go to Tier 2.
  - else
    - Look in Sentry to identify the problem children
      **Goto https://sentry.jangl.com/sentry/teams/jangl/**
      - Find the app with the highest number of events
      - Inspect and Correlate sentry errors in stach trace to identify root cause.
        - Look for connection errors.
        - Identify rest endpoints.
        - Look for errors in suspect apps
        - If app errors
          - Application Issues, go to Tier 1. 
        - else check mesos logs
          - if nothing noticable, ecsalate to Tier 2.
          
Begin troubleshooting triage analysis. 

**Jangl Tier 1 Application Troubleshooting Checklist**

Ping Post DB CPUs Near 100%.

Goto: https://p.datadoghq.com/sb/95999ca2b-95d90f7a2f

    - If (Webleads || Accounts) DB CPU near 100%
        # Upsize Immediately to the next largest RDS instance. 5 minute lag.

Ping Post Response Time over 30 seconds.

Goto: https://p.datadoghq.com/sb/95999ca2b-95d90f7a2f

  - Verify Webleads Ping Delta.
  - If (**Webleads Ping Delta** avg over 10 seconds, scale resources.)
    # Check webleads-api.logs in mesos and if Status not "200" or durartion < 20 sec...
      - Suspend/Scale weblead apps in the following order Workers, Webleads, Api. (gentle)
      - Check and document **existing instance numbers** in Marathon before suspend/scaling marathon apps.
        (e.g.: 40 workers, 18 webleads, 18 webleads-api instances.)
  - If webleads-api.log is good, then check mesos webleads-workers.log. (Always look at the mesos log with most data.)
    # if getting-get deltas are > 10 sec
      - Suspend weblead apps in the following order Workers, Webleads, Api.
      - Give it 2 minutes to settle perkolate and then re-check Ping Post Request Duration.
      - Scale to Spec: Check and document **existing instance numbers** in Marathon before suspend/scaling marathon apps. 
        (e.g.: 40 workers, 18 webleads, 18 webleads-api instances.)
    # If things are still wonky, conider escalating to Tier 2 Troubleshooting and notify team.

**Jangl Tier 2 System Troubleshooting Checklist**

  - Check Kafka Broker List.
  - If there are less than 6 Brokers, big problem
    # ansible tag_Service_kafka -a "sudo systemctl restart kafka" -l [$TARGET_IP's]
    # if ansible not working, then ssh, diagnose, journalctl, then restart... sudo systemctl restart kafka

High Ping Post Reds (400's) and Oranges (500's) that persist after tier 1 has been exhausted
  - Probably an Infrastructure issue (pgbouncer || nginx-consul)
    # Check disk space (df -h)
    # If disk full
      - delete old logs from /var/log
    # If ansible not working
      - ssh onto the boxes to investigate with journalctl and systemctl.

  - If Tier 1 and Tier 2 fail to resolve the issue, escalate to Tier 3 and notify team.
  
Subsystem Diagnosis
  - ansible-playbook playbooks/check_resource_services.yml

**Jangl Tier 3 System Reset Checklist**

  - terraform refresh (to pull existing AWS terraform.tfstate)
  - terraform taint and replace production resource servers 1 at a time using the process contained in...
    https://phab.jangl.com/P91
  - check to make sure the new resource box is online in EC2.
  - cd $JANGL_HOME/ansible 
  - ansible-playbook playbooks/all.yml -l [TARGET_RESOUCE_SERVER_IP]
  - ansible-playbook playbooks/datadog.yml -l [TARGET_RESOUCE_SERVER_IP]
  - takes on order of 20 minuites to resolve.
