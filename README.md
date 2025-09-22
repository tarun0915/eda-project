# EDA Starter: Webhook → Action

A minimal, cloneable project to build your first **Event‑Driven Ansible (EDA)** Activation.

## What's inside
```
eda-starter/
├─ rulebooks/
│  ├─ webhook_echo.yml                    # simplest: print incoming events
│  └─ disk_full_to_controller.yml         # trigger AAP Job Template on specific event
├─ playbooks/
│  └─ handle_disk_full.yml                # sample remediation playbook (used if you prefer run_playbook)
├─ inventories/
│  └─ localhost.ini
├─ collections/
│  └─ requirements.yml                    # awx.awx (Controller API) and community.general
├─ tests/payloads/
│  └─ webhook_disk_full.json              # sample event payload
├─ scripts/
│  └─ trigger_webhook.sh                  # curl helper for testing the webhook
└─ .env.example                           # put your WEBHOOK_URL and EDA_TOKEN here (optional helper)
```

## Option A: Run locally with `ansible-rulebook`
This doesn't require AAP Controller—great for quick testing.

1) Install collections:
```bash
ansible-galaxy collection install -r collections/requirements.yml
```

2) Run the simplest rulebook and print events:
```bash
ansible-rulebook -r rulebooks/webhook_echo.yml -i inventories/localhost.ini --print-events -vv
```

3) In a separate shell, send a test event:
```bash
export WEBHOOK_URL="http://127.0.0.1:5000/endpoint"
export EDA_TOKEN="devtoken"
bash scripts/trigger_webhook.sh echo
```

You should see the event in the rulebook output.

## Option B: Use EDA Controller (UI)
1) In **EDA → Activations → Create Activation**:
   - **Source**: *Webhook*
   - **Rulebook**: `rulebooks/disk_full_to_controller.yml` (or `webhook_echo.yml` to start)
   - **Token**: set your token (e.g., `devtoken`).
   - Save. EDA will show an **Activation URL**. Copy it.

2) Test from your machine:
```bash
export WEBHOOK_URL="<Activation URL you copied>"
export EDA_TOKEN="devtoken"
bash scripts/trigger_webhook.sh disk
```

### If using `run_job_template` in the rulebook
- EDA must have access to AAP Controller and the Activation must specify:
  - **Project/Inventory/Execution Environment** with `awx.awx` available (often built-in on EDA images).
  - A **Credential** for Controller (or SSO) attached to the Activation so `run_job_template` works.
- Update the `name` and `organization` fields in `rulebooks/disk_full_to_controller.yml` to match your Job Template.

### Prefer `run_playbook` instead?
Edit the rule to use:
```yaml
action:
  run_playbook:
    name: playbooks/handle_disk_full.yml
    extra_vars:
      target_host: "{{ event.payload.result.host | default('localhost') }}"
```

## Sample cURL (manual)
```bash
curl -X POST "$WEBHOOK_URL"   -H "Content-Type: application/json"   -H "X-EDA-Token: $EDA_TOKEN"   -d @tests/payloads/webhook_disk_full.json
```

## Troubleshooting
- **403/Unauthorized**: token header missing; ensure `-H "X-EDA-Token: $EDA_TOKEN"`
- **Activation restarts**: fix YAML or missing collections; check Activation logs.
- **`run_job_template` fails**: verify Controller credential on the Activation and Job Template name/org.
