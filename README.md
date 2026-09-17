# Linux Server Operations and Troubleshooting Lab

## Project Overview

This hands-on project demonstrates the operation, monitoring and troubleshooting of a Linux web server.

I built the project to strengthen practical skills for Cloud Support, Linux Support, Infrastructure Support and Cloud Operations roles. The lab combines Linux administration with my professional background in incident management, technical support, SLA handling and stakeholder communication.

## Current Architecture

Client request
→ Localhost TCP port 80
→ Nginx web server
→ Custom HTML webpage
→ HTTP response and access logs

## Environment

* Windows 11 host
* WSL 2
* Ubuntu Linux
* Nginx 1.18.0
* Git
* Bash shell

## Work Completed

* Installed and operated Nginx on Ubuntu Linux.
* Created and deployed a custom webpage.
* Validated the Nginx service through systemd.
* Verified master and worker processes.
* Confirmed that TCP port 80 was listening.
* Tested HTTP responses using curl.
* Reviewed Nginx access logs and systemd journal logs.
* Preserved the original webpage for rollback.
* Simulated a complete website outage by stopping Nginx.
* Investigated the service, process, port and log layers.
* Restored the service and validated HTTP 200 recovery.
* Documented the incident and preventive actions.

## Incident Scenarios

### INC-001: Nginx Service Stopped

The Nginx service was stopped to simulate complete website unavailability.

Observed symptoms:

* Curl could not connect to port 80.
* No HTTP status code was returned.
* The Nginx service was inactive.
* No Nginx processes were running.
* TCP port 80 was not listening.

Resolution:

* Started the Nginx service through systemd.
* Confirmed new master and worker processes.
* Verified that port 80 was listening.
* Confirmed HTTP 200 from the website.
* Verified the successful request in the access log.

Detailed report: [INC-001 - Nginx Service Stopped](incident-reports/INC-001-nginx-service-stopped.md)

## Troubleshooting Method

Each incident is investigated using the following sequence:

1. Confirm the user-facing impact.
2. Check the service state.
3. Check running processes.
4. Check the listening port.
5. Test the HTTP response.
6. Review system and application logs.
7. Restore the service safely.
8. Validate recovery at every layer.
9. Document the root cause and preventive actions.

## Skills Demonstrated

* Linux server administration
* Nginx web-server operations
* Process and service management
* TCP port investigation
* HTTP health checks
* Access-log and system-journal analysis
* Incident triage
* Root-cause documentation
* Service restoration and validation
* Runbook-based operational thinking

## Planned Enhancements

* File-permission and HTTP 403 incident
* Nginx configuration-failure incident
* Port-conflict investigation
* Bash service and website health checks
* CPU, memory and disk monitoring
* Prometheus metrics
* Grafana dashboards
* Docker-based monitoring components
* AWS Cloud Support lab using AWS Educate

## Important Note

This is a self-directed hands-on lab project. It demonstrates practical learning and troubleshooting experience and does not claim production AWS or Linux administration employment experience.
