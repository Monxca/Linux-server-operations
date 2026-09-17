# INC-001: Nginx Service Stopped

## Incident Summary

The website hosted on the Ubuntu Nginx server became unavailable because the Nginx service was stopped. Client requests failed at the TCP connection stage because no process was listening on port 80.

## Environment

* Platform: WSL 2
* Operating system: Ubuntu Linux
* Web server: Nginx 1.18.0
* Website: Linux Server Operations Lab
* Incident type: Controlled lab simulation
* Impact: Complete local website unavailability

## User-Reported Symptom

The website could not be accessed.

Curl returned:

curl: (7) Failed to connect to localhost port 80: Connection refused

No HTTP status code was returned because the TCP connection could not be established.

## Healthy Baseline

Before the incident:

* Nginx was active.
* The master and worker processes were running.
* TCP port 80 was listening.
* The website returned HTTP 200.
* Requests appeared in the Nginx access log.

## Investigation

### Service Check

Command: systemctl is-active nginx
Result: inactive

### Detailed Service Status

Result: Active: inactive (dead)

Systemd reported that Nginx had stopped successfully.

### Port Check

No process was listening on TCP port 80.

### Process Check

No Nginx master or worker processes were running.

### Log Check

The system journal showed:

* nginx.service: Deactivated successfully.
* Stopped A high performance web server and a reverse proxy server.

## Root Cause

The Nginx service was stopped as part of a controlled incident simulation. Because the service was inactive, its processes exited and TCP port 80 was no longer listening.

## Resolution

The Nginx service was started using systemd.

After restoration:

* Nginx created a new master process and new worker processes.
* TCP port 80 returned to the listening state.
* The website returned HTTP 200.
* The successful request appeared in the Nginx access log.

## Validation

Recovery was validated at multiple layers:

1. Service: Nginx was active.
2. Process: Master and worker processes were running.
3. Network: TCP port 80 was listening.
4. Application: The website returned HTTP 200.
5. Logging: The successful request appeared in the access log.

## Preventive Actions

* Monitor the Nginx service state.
* Monitor website availability using HTTP health checks.
* Alert when TCP port 80 is unavailable.
* Restrict unauthorised service-control access.
* Maintain a documented service-recovery runbook.

## Key Learning

An active service check alone is not sufficient validation. Service state, processes, listening ports, HTTP responses and logs should be correlated.

A connection-refused error happens before an HTTP response is generated.
