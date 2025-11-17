# GitHub Actions Workflows

This directory contains automated workflows for maintaining the fork.

## sync-upstream.yml

**Purpose:** Automatically sync fork with upstream `musistudio/claude-code-router`

### Schedule
- **Automatic:** Runs daily at 2:00 AM UTC
- **Manual:** Can be triggered from GitHub Actions tab

### What it does

1. **Fetches** latest changes from upstream repository
2. **Checks** if there are new commits to sync
3. **Merges** upstream changes into main branch
4. **Pushes** updates to your fork automatically

### Conflict Handling

If the workflow encounters merge conflicts:
- ❌ Merge is aborted automatically
- 🔔 Creates a GitHub issue with conflict details
- 📝 Provides resolution instructions
- 🔍 Lists conflicted files in workflow logs

### Manual Conflict Resolution

If you see a "Sync Conflict" issue:

```bash
# SSH into Proxmox
ssh root@ssh-pm.michaelnewham.me

# Navigate to repository
cd /root/repos/claude-code-router

# Fetch and merge manually
git fetch upstream
git merge upstream/main

# Resolve conflicts in affected files
# (Usually won't conflict since custom files are in separate directories)
nano <conflicted-file>

# Mark as resolved and commit
git add .
git commit -m "Resolve merge conflicts from upstream sync"
git push origin main
```

### Viewing Workflow Status

**Via GitHub:**
1. Go to https://github.com/MichaelNewham/claude-code-router
2. Click "Actions" tab
3. Select "Sync with Upstream" workflow

**Via CLI:**
```bash
# List recent workflow runs
gh run list --workflow=sync-upstream.yml

# View specific run
gh run view <run-id>

# Watch live run
gh run watch
```

### Manual Trigger

**From GitHub:**
1. Go to Actions → Sync with Upstream
2. Click "Run workflow" → "Run"

**From CLI:**
```bash
gh workflow run sync-upstream.yml
```

### Why Daily Sync?

- Keeps your fork up-to-date with bug fixes
- Gets new features from upstream automatically
- Prevents large merge conflicts from accumulating
- Minimal maintenance overhead

### Customization

To change sync frequency, edit `.github/workflows/sync-upstream.yml`:

```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
    # Examples:
    # - cron: '0 */6 * * *'    # Every 6 hours
    # - cron: '0 0 * * 0'      # Weekly on Sunday
    # - cron: '0 0 1,15 * *'   # Twice monthly (1st and 15th)
```

### Workflow Permissions

Uses `GITHUB_TOKEN` with default permissions:
- ✅ Read repository content
- ✅ Write to repository (push changes)
- ✅ Create issues (for conflicts)
- ❌ No additional secrets required

### Notifications

GitHub will notify you:
- 📧 **Email** when workflow fails
- 🔔 **Issue** created on merge conflicts
- ✅ **Status badge** on repository README (optional)

### Testing

The workflow is triggered on push to test itself:
```bash
# Push workflow changes to test
git add .github/workflows/sync-upstream.yml
git commit -m "Update sync workflow"
git push origin main

# Check workflow execution
gh run list --workflow=sync-upstream.yml
```

---

## Future Workflows (Planned)

Ideas for additional automation:
- 🧪 **CI Testing:** Run tests on custom scripts
- 📝 **Documentation:** Auto-generate docs from scripts
- 🏷️ **Versioning:** Auto-tag releases
- 🔍 **Linting:** Check script quality
- 📦 **Backup:** Export configurations periodically
