# Nginx Web Service Outage Runbook

## Purpose

This runbook provides a structured procedure for investigating and recovering an unavailable Nginx website on an Ubuntu Linux server.

## When to Use This Runbook

Use this procedure when:

- The website is unavailable.
- The HTTP health check fails.
- TCP port 80 is not listening.
- Nginx is inactive or failed.
- Users receive HTTP 4xx or 5xx errors.

## Safety Considerations

- Confirm the affected server and environment.
- Record timestamps, commands and observations in the incident ticket.
- Collect evidence before restarting the service.
- Follow approval and change-management procedures.
- Do not terminate unknown processes or change production configuration without validation.

## 1. Confirm the Problem

Test the website:

```bash
curl -I --max-time 5 http://localhost
```

Interpretation:

- `HTTP 200` — website is responding successfully.
- `HTTP 4xx` — possible URL, file, permission or authentication issue.
- `HTTP 5xx` — server-side or upstream application failure.
- `Connection refused` — nothing is accepting connections on port 80.
- `Timeout` — possible network, firewall, load or service issue.

Run the automated health check:

```bash
./scripts/server-health-check.sh
echo $?
```

Exit codes:

- `0` — all health checks passed.
- `1` — one or more checks failed.

## 2. Check the Nginx Service

```bash
systemctl is-active nginx
systemctl status nginx --no-pager
systemctl is-enabled nginx
```

Possible states:

- `active` — Nginx is running.
- `inactive` — Nginx is stopped.
- `failed` — Nginx attempted to start but encountered an error.

## 3. Validate the Configuration

```bash
sudo nginx -t
```

Expected result:

```text
syntax is ok
test is successful
```

Do not reload or restart Nginx with an invalid configuration.

## 4. Check Nginx Processes

```bash
pgrep -a nginx
ps -ef | grep '[n]ginx'
```

A healthy Nginx installation normally has:

- One master process running as `root`.
- One or more worker processes running as `www-data`.

## 5. Check Port 80

```bash
sudo ss -lntp | grep ':80'
```

Confirm that:

- Port 80 is in the `LISTEN` state.
- Nginx owns the listening socket.
- No unexpected process is using port 80.

## 6. Review Logs

Check service events:

```bash
sudo journalctl -u nginx -n 50 --no-pager
```

Check Nginx errors:

```bash
sudo tail -n 50 /var/log/nginx/error.log
```

Check recent requests:

```bash
sudo tail -n 50 /var/log/nginx/access.log
```

Look for:

- Configuration syntax errors
- Permission-denied errors
- Port-binding failures
- Missing files
- Upstream connection failures
- HTTP 4xx and 5xx responses

## 7. Recovery Actions

### Nginx Is Stopped

Validate the configuration before starting it:

```bash
sudo nginx -t
sudo systemctl start nginx
```

### Nginx Is Failed

Collect evidence first:

```bash
systemctl status nginx --no-pager
sudo journalctl -u nginx -n 50 --no-pager
sudo nginx -t
```

After identifying and correcting the cause:

```bash
sudo systemctl restart nginx
```

### Configuration Was Changed

Validate and apply the change gracefully:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### Another Process Is Using Port 80

Identify the process:

```bash
sudo ss -lntp | grep ':80'
```

Do not terminate the process until its ownership and business purpose are confirmed.

## 8. Validate Recovery

Check the service:

```bash
systemctl is-active nginx
```

Check the processes:

```bash
pgrep -a nginx
```

Check the port:

```bash
sudo ss -lntp | grep ':80'
```

Check the website:

```bash
curl -I --max-time 5 http://localhost
```

Run the complete health check:

```bash
./scripts/server-health-check.sh
echo $?
```

Successful recovery requires:

- Nginx service is active.
- Nginx processes are present.
- TCP port 80 is listening.
- Website returns HTTP 200.
- Health-check script returns exit code 0.

## 9. Escalation Criteria

Escalate when:

- Configuration errors cannot be safely corrected.
- Nginx repeatedly stops or crashes.
- Port 80 is occupied by an unexpected process.
- The server has critical CPU, memory or disk pressure.
- The issue involves an upstream service, load balancer, DNS or network control.
- Recovery requires an unapproved production change.
- User impact continues after Nginx is restored.

Include the following during escalation:

- Incident timeline
- Business impact
- Commands executed
- Relevant log entries
- Current service and port status
- Actions attempted
- Exact errors received

## 10. Incident Closure

Before closing the incident:

- Confirm recovery through the monitoring checks.
- Confirm the website works from the required client location.
- Update the incident ticket.
- Document the root cause.
- Record corrective and preventive actions.
- Monitor the service for recurrence.
