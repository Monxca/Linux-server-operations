# INC-002: Nginx Failed to Start Due to Invalid Configuration

## Incident Summary

A controlled Nginx configuration-change incident was simulated on an Ubuntu Linux server. An unsupported directive was added to an included configuration file. During a service restart, Nginx stopped successfully but failed to start because its pre-start configuration validation detected the invalid directive.

The website became unavailable, TCP port 80 stopped listening and HTTP requests returned connection refused. The invalid configuration file was disabled, the configuration was validated and Nginx was restored successfully.

## Incident Details

| Field | Value |
|---|---|
| Incident ID | INC-002 |
| Date | 19 September 2026 |
| Environment | Ubuntu on WSL2 |
| Affected service | Nginx |
| Affected endpoint | `http://localhost` |
| Start time | Approximately 18:10 IST |
| Recovery time | Approximately 18:15 IST |
| Duration | Approximately 4–5 minutes |
| Status | Resolved |
| Type | Controlled configuration-change simulation |

## Impact

During the incident:

- Nginx was unavailable.
- TCP port 80 was not listening.
- The local website could not be accessed.
- Curl returned connection refused.
- The health-check script reported the server as unhealthy.
- Disk and memory checks remained healthy.

The incident affected only the local lab environment. There was no external customer or production impact.

## Healthy Baseline

Before introducing the change:

```bash
systemctl is-active nginx
sudo nginx -t
curl -I --max-time 5 http://localhost
```

Results:

- Nginx service was active.
- Configuration validation was successful.
- Website returned HTTP 200.

## Change Introduced

A test configuration file was created:

```text
/etc/nginx/conf.d/incident-test.conf
```

It contained:

```nginx
# Deliberately invalid configuration for incident simulation
invalid_directive on;
```

The main Nginx configuration included files matching:

```nginx
include /etc/nginx/conf.d/*.conf;
```

Therefore, Nginx attempted to read the test file during configuration validation.

## Initial Configuration Validation

The following command was executed:

```bash
sudo nginx -t
```

Result:

```text
unknown directive "invalid_directive" in /etc/nginx/conf.d/incident-test.conf:2
configuration file /etc/nginx/nginx.conf test failed
```

At this stage, the existing Nginx processes remained active and the website continued returning HTTP 200 because they were still using the previously loaded valid configuration.

## Trigger

A restart was attempted:

```bash
sudo systemctl restart nginx
```

The restart stopped the existing Nginx processes. Nginx then attempted to start with the current configuration, but its pre-start validation failed.

Systemd reported:

```text
Control process exited, code=exited, status=1/FAILURE
Failed with result 'exit-code'
Failed to start A high performance web server and a reverse proxy server
```

## Detection

The website check failed:

```bash
curl -I --max-time 5 http://localhost
```

Result:

```text
curl: (7) Failed to connect to localhost port 80
Connection refused
```

The automated health-check script was manually executed and reported:

```text
[CRITICAL] nginx service is inactive
[CRITICAL] TCP port 80 is not listening
[CRITICAL] Website check failed: curl=7 http=000
[OK] Disk usage is 1%
[OK] Memory usage is 8%
Overall status: UNHEALTHY
```

The script returned exit code:

```text
1
```

## Investigation

The Nginx systemd journal was reviewed:

```bash
sudo journalctl -u nginx -n 20 --no-pager
```

The journal identified:

- Invalid directive: `invalid_directive`
- Affected file: `/etc/nginx/conf.d/incident-test.conf`
- Affected line: `2`
- Configuration test failure
- Service startup exit status: `1/FAILURE`

Disk and memory were healthy, which helped rule out resource exhaustion.

## Root Cause

The direct technical cause was an unsupported Nginx directive inside an included `.conf` file:

```nginx
invalid_directive on;
```

The operational cause was attempting a restart even though the preceding configuration validation had already failed.

## Resolution

The invalid file was renamed so it no longer matched the `*.conf` include pattern:

```bash
sudo mv /etc/nginx/conf.d/incident-test.conf \
/etc/nginx/conf.d/incident-test.conf.disabled
```

Configuration was validated again:

```bash
sudo nginx -t
```

Result:

```text
syntax is ok
test is successful
```

Nginx was restarted:

```bash
sudo systemctl restart nginx
```

## Recovery Validation

The following checks were completed:

```bash
systemctl is-active nginx
curl -I --max-time 5 http://localhost
./scripts/server-health-check.sh
echo $?
```

Results:

- Nginx service returned to `active`.
- Website returned HTTP 200.
- TCP port 80 was listening.
- Health check reported `HEALTHY`.
- Health-check exit code returned to `0`.

## Monitoring Observation

The systemd timer was configured to run the health check every five minutes.

The manual health check detected the outage at approximately `18:11`. The scheduled timer executed at `18:15:05`, after recovery, and recorded a healthy result.

This demonstrated that a monitoring interval can miss incidents that begin and recover between scheduled checks. Monitoring frequency should be selected according to service criticality, required detection time and operational cost.

## Corrective and Preventive Actions

- Always run `nginx -t` before restarting or reloading Nginx.
- Do not proceed with a change when configuration validation fails.
- Prefer `systemctl reload nginx` for validated configuration changes when a full restart is unnecessary.
- Maintain configuration backups and version control.
- Use peer review for production configuration changes.
- Monitor service state, listening ports and HTTP availability independently.
- Select an appropriate monitoring interval for the required detection time.
- Record the exact configuration file and line number during troubleshooting.

## Lessons Learned

- A running service may continue using a previously loaded valid configuration even when configuration files on disk are invalid.
- A restart can convert a configuration defect into a complete outage.
- Configuration validation is a preventive control, not merely a troubleshooting command.
- Systemd journals can identify the exact failing file, line and exit status.
- Service, port and HTTP checks provide different layers of evidence.
- Rollback must be followed by configuration validation and explicit service recovery.
