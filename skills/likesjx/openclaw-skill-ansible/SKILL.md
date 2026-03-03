---
name: openclaw-skill-ansible
description: Operate OpenClaw Ansible mesh workflows across gateways, including plugin install/setup, health verification, invite/join bootstrap, and safe capability/task lifecycle operations. Use when an agent must configure or repair Ansible coordination behavior on a gateway.
---

# OpenClaw Skill: Ansible Operations

Execute deterministic Ansible operations on a gateway and report evidence artifacts.

## Core Contracts

1. Keep `~/code/openclaw-plugin-ansible` as source of truth for plugin code.
2. Install plugin through OpenClaw plugin manager, not by writing into `~/.openclaw/workspace/plugins` manually.
3. After plugin changes, run setup + health checks before declaring success.
4. Record machine-readable artifacts under `OPENCLAW_ARTIFACT_ROOT`.

## Action Map

Dispatch via `src/handler.py` with `task.action` mapped to `actions/<action>.sh`.

Supported operations:

1. `setup-ansible-plugin`
  - install/update ansible plugin
  - run `openclaw ansible setup`
  - verify `openclaw ansible status`
2. `collect-logs`
3. `run-cmd`
4. `deploy-skill`

## Required Workflow: Plugin Setup

When asked to install/repair Ansible plugin on a node:

1. Verify prerequisites:
  - `openclaw --help`
  - network access for plugin source (npm/GitHub)
2. Run setup action with explicit source:
  - `source=github` uses `openclaw plugins install likesjx/openclaw-plugin-ansible`
  - `source=npm` uses `openclaw plugins install @likesjx/openclaw-plugin-ansible`
  - `source=path` uses `openclaw plugins install <path>`
3. Run post-install alignment:
  - `openclaw ansible setup`
4. Collect verification:
  - `openclaw ansible status`
  - `openclaw gateway health` (best effort)
5. Emit result artifact and concise operator summary.

## Task Payload Example

```json
{
  "task_id": "task-setup-001",
  "action": "setup-ansible-plugin",
  "params": {
    "source": "github",
    "plugin_ref": "likesjx/openclaw-plugin-ansible",
    "run_setup": true,
    "verify_status": true,
    "restart_gateway": false
  },
  "caller": "architect",
  "correlation_id": "ansible-setup-001"
}
```

## Safety Rules

1. Do not write secrets to artifacts.
2. Do not force-delete plugin/runtime directories.
3. Fail fast on install/setup command errors.
4. If verification fails, return `status=failed` with the failing command and stderr summary.

## Success Criteria

A setup task is successful only if:

1. plugin install/update command exits 0
2. `openclaw ansible setup` exits 0 (when enabled)
3. `openclaw ansible status` exits 0 and returns non-error output (when enabled)

